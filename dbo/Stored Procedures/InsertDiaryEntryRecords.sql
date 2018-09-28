  
CREATE PROCEDURE [dbo].[InsertDiaryEntryRecords] (  
 @pGPSUser VARCHAR(100)  
 ,@pCountryId UNIQUEIDENTIFIER  
 ,@pCreationDate DATETIME = NULL  
 ,@pDiaryEntryRecords dbo.DiaryEntryRecords READONLY  
 )  
AS  
BEGIN  
 BEGIN TRY  
  
    
  DECLARE @InsertCount INT  
   ,@DiaryBeforeCount INT  
   ,@DiaryAfterCount INT  
   ,@MaxBatchId INT  
  
  SET @MaxBatchId=ISNULL((SELECT MAX(BatchId) FROM IncentiveAccountTransaction WHERE Country_Id=@pCountryId),0)+1  
  
  DECLARE @GetDate DATETIME  
  
  SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryId))  
  
  SET @InsertCount = (  
    SELECT COUNT(0)  
    FROM @pDiaryEntryRecords  
    )  
  SET @DiaryBeforeCount = (  
    SELECT COUNT(0)  
    FROM DiaryEntry  
    )  
  
  DECLARE @GPSUpdateTimestamp DATETIME  
   ,@Balance BIGINT  
   ,@TransactionSourceId UNIQUEIDENTIFIER  
  
  IF (@pCreationDate IS NULL)  
  BEGIN  
   SET @GPSUpdateTimestamp = (  
     SELECT max(iat.GPSUpdateTimestamp)  
     FROM IncentiveAccountTransaction iat  
     INNER JOIN IncentiveAccount ai ON iat.Account_id = ai.IncentiveAccountId  
     INNER JOIN Candidate c ON ai.Beneficiary_id = c.GUIDReference  
     WHERE c.Country_id = @pCountryId  
      AND CAST(iat.GPSUpdateTimestamp AS DATE) = CAST(@GetDate AS DATE)  
     )  
  
   IF @GPSUpdateTimestamp IS NULL  
    SET @GPSUpdateTimestamp = @GetDate  
  END  
  ELSE  
  BEGIN  
   SET @GPSUpdateTimestamp = @pCreationDate;  
  END  
  
  CREATE TABLE #Tempdiaries (  
   ROWID BIGINT identity(1, 1)  
   ,[Id] [uniqueidentifier] NOT NULL  
   ,[PanelId] [uniqueidentifier] NOT NULL  
   ,[PanelName] [nvarchar](150) NULL  
   ,[DiaryDateYear] [int] NOT NULL  
   ,[DiaryDatePeriod] [int] NOT NULL  
   ,[DiaryDateWeek] [int] NOT NULL  
   ,[NumberOfDaysLate] [int] NOT NULL  
   ,[NumberOfDaysEarly] [int] NOT NULL  
   ,[ReceivedDate] [varchar](50) NOT NULL  
   ,[Points] [int] NOT NULL  
   ,[CumulativePoints] [int] NOT NULL  
   ,[PointId] [uniqueidentifier] NOT NULL  
   ,[DiarySource] [nvarchar](150) NULL  
   ,[DiaryState] [nvarchar](150) NULL  
   ,[BusinessId] [nvarchar](50) NULL  
   ,[Together] [int] NOT NULL  
   ,[IncentiveCode] [int] NOT NULL  
   ,[ClaimFlag] [int] NOT NULL  
   ,[TransactionInfoId] [uniqueidentifier] NOT NULL  
   ,[IndividualId] [uniqueidentifier] NOT NULL  
   ,[Balance] [int] NOT NULL  
   )  
  
  INSERT INTO #Tempdiaries  
  SELECT *  
  FROM @pDiaryEntryRecords  
  
  ALTER TABLE #Tempdiaries  
  ADD [BeneficiaryId] [uniqueidentifier] NULL  
    
  UPDATE td SET [BeneficiaryId]=ISNULL(IA.Beneficiary_id, IA.IncentiveAccountId)  
  FROM #Tempdiaries td  
  JOIN IncentiveAccount IA ON IA.IncentiveAccountId=td.[IndividualId]  
    
  UPDATE td  
  SET Balance = V.CurrBalance  
   ,TransactionInfoId = NEWID()  
  FROM #Tempdiaries td  
  JOIN (  
   SELECT   
    --ISNULL(IA.Beneficiary_id, IA.IncentiveAccountId) AS IncentiveAccountId  
    t.[BeneficiaryId] as IncentiveAccountId  
    ,ISNULL(sum(CASE IAT.[Type]  
       WHEN 'Debit'  
        THEN (- 1 * Ammount)  
       ELSE info.Ammount  
       END), 0) AS CurrBalance  
   FROM   
   #Tempdiaries t  
   JOIN IncentiveAccount IA ON IA.IncentiveAccountId=t.BeneficiaryID OR IA.Beneficiary_id=t.BeneficiaryID  
   LEFT JOIN IncentiveAccountTransaction IAT ON IA.IncentiveAccountId = IAT.Account_Id  
   LEFT JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = Info.IncentiveAccountTransactionInfoId  
   /*WHERE IA.IncentiveAccountId IN (  
     SELECT DISTINCT IndividualId  
     FROM #Tempdiaries  
     )*/  
   GROUP BY t.[BeneficiaryId]  
   ) V ON V.IncentiveAccountId = td.[BeneficiaryId]  
     
  UPDATE #Tempdiaries  
  SET CumulativePoints = CurrBalance + Balance  
  FROM (  
   SELECT tmp.[BeneficiaryId]  
    ,[TransactionInfoId]  
    ,ISNULL(sum([Points]) OVER (  
      PARTITION BY tmp.[BeneficiaryId] ORDER BY tmp.[BeneficiaryId]  
       ,ROWID ROWS BETWEEN UNBOUNDED PRECEDING  
        AND CURRENT ROW  
      ), 0) AS CurrBalance  
   FROM #Tempdiaries tmp  
   GROUP BY tmp.[BeneficiaryId]  
    ,[TransactionInfoId]  
    ,[Points]  
    ,ROWID  
   ) V  
  WHERE V.TransactionInfoId = #Tempdiaries.TransactionInfoId  
    
  SELECT @TransactionSourceId = TransactionSourceId  
  FROM TransactionSource  
  WHERE IsDefault = 1  
   AND Country_Id = @pCountryId  
  
  SET XACT_ABORT ON  
  
  BEGIN TRANSACTION  
  
  INSERT INTO DiaryEntry (  
   Id  
   ,Points  
   ,DiaryDateYear  
   ,DiaryDatePeriod  
   ,DiaryDateWeek  
   ,NumberOfDaysLate  
   ,NumberOfDaysEarly  
   ,DiaryState  
   ,ReceivedDate  
   ,GPSUser  
   ,GPSUpdateTimestamp  
   ,CreationTimeStamp  
   ,DiarySourceFull  
   ,BusinessId  
   ,Together  
   ,PanelId  
   ,IncentiveCode  
   ,ClaimFlag  
   ,Country_Id  
   )  
  SELECT NEWID()  
   ,[Points]  
   ,[DiaryDateYear]  
   ,[DiaryDatePeriod]  
   ,[DiaryDateWeek]  
   ,[NumberOfDaysLate]  
   ,[NumberOfDaysEarly]  
   ,[DiaryState]  
   ,DATEADD(millisecond, 10 * (  
     ROW_NUMBER() OVER (  
      ORDER BY (  
        SELECT 0  
        )  
      )  
     ), [ReceivedDate])  
   ,@pGPSUser  
   ,DATEADD(millisecond, 10 * (  
     ROW_NUMBER() OVER (  
      ORDER BY (  
        SELECT 0  
        )  
      )  
     ), @GPSUpdateTimestamp)  
   ,DATEADD(millisecond, 10 * (  
     ROW_NUMBER() OVER (  
      ORDER BY (  
        SELECT 0  
        )  
      )  
     ), @GPSUpdateTimestamp)  
   ,[DiarySource]  
   ,[BusinessId]  
   ,[Together]  
   ,[PanelId]  
   ,[IncentiveCode]  
   ,[ClaimFlag]  
   ,@pCountryId  
  FROM @pDiaryEntryRecords;  
  
  SET @DiaryAfterCount = (  
    SELECT COUNT(0)  
    FROM DiaryEntry  
    )  
  
  INSERT INTO [DiaryInsertLog] (  
   [CountryId]  
   ,[CreatedTimeStamp]  
   ,[InsertCount]  
   ,[User]  
   ,[DiaryBeforeCount]  
   ,[DiaryAfterCount]  
   ,Comments  
   )  
  VALUES (  
   @pCountryId  
   ,@pCreationDate  
   ,@InsertCount  
   ,@pGPSUser  
   ,@DiaryBeforeCount  
   ,@DiaryAfterCount  
   ,'Success'  
   )  
  
  DECLARE @PanelGUID UNIQUEIDENTIFIER  
   ,@PanelType VARCHAR(50)  
  
  SELECT TOP 1 @PanelGUID = PanelId  
  FROM @pDiaryEntryRecords  
  
  SELECT @PanelType = [Type]  
  FROM panel  
  WHERE GUIDReference = @PanelGUID  
  
  -- Set the Together functionality.  
  UPDATE DE1  
  SET DE1.Together = 1,DE1.GPSUpdateTimestamp=@GetDate,DE1.GPSUser=@pGPSUser  
  FROM DiaryEntry DE1  
  INNER JOIN (  
   SELECT DE.BusinessId  
    ,CAST(DE.ReceivedDate AS DATE) AS ReceivedDate  
    ,PanelId  
    ,COUNT(0) AS ct  
   FROM DiaryEntry DE  
   WHERE PanelId = @PanelGUID  
    AND DE.BusinessId IN (  
     SELECT BusinessId  
     FROM @pDiaryEntryRecords  
     )  
    AND CAST(DE.ReceivedDate AS DATE) IN (  
     SELECT CAST(ReceivedDate AS DATE)  
     FROM @pDiaryEntryRecords  
     )  
   GROUP BY DE.BusinessId  
    ,CAST(DE.ReceivedDate AS DATE)  
    ,PanelId  
   HAVING COUNT(0) >= 3  
   ) TEMP ON TEMP.BusinessId = DE1.BusinessId  
   AND CAST(DE1.ReceivedDate AS DATE) = TEMP.ReceivedDate  
   AND DE1.PanelId = TEMP.PanelId  
  
  INSERT INTO [dbo].[IncentiveAccountTransactionInfo] (  
   [IncentiveAccountTransactionInfoId]  
   ,[Ammount]  
   ,[GPSUser]  
   ,[GPSUpdateTimestamp]  
   ,[CreationTimeStamp]  
   ,[GiftPrice]  
   ,[Discriminator]  
   ,[Point_Id]  
   ,[RewardDeliveryType_Id]  
   ,[Country_Id]  
   )  
  SELECT [TransactionInfoId]  
   ,[Points]  
   ,@pGPSUser  
   ,DATEADD(millisecond, 10 * (  
     ROW_NUMBER() OVER (  
      ORDER BY (  
        SELECT 0  
        )  
      )  
     ), @GPSUpdateTimestamp)  
   ,DATEADD(millisecond, 10 * (  
     ROW_NUMBER() OVER (  
      ORDER BY (  
        SELECT 0  
        )  
      )  
     ), @GPSUpdateTimestamp)  
   ,NULL  
   ,N'TransactionInfo'  
   ,[PointId]  
   ,NULL  
   ,@pCountryId  
  FROM #Tempdiaries  
  
  
  INSERT [dbo].[IncentiveAccountTransaction] (  
   [IncentiveAccountTransactionId]  
   ,[CreationDate]  
   ,[SynchronisationDate]  
   ,[TransactionDate]  
   ,[Comments]  
   ,[Balance]  
   ,[GPSUser]  
   ,[GPSUpdateTimestamp]  
   ,[CreationTimeStamp]  
   ,[PackageId]  
   ,[TransactionInfo_Id]  
   ,[TransactionSource_Id]  
   ,[Depositor_Id]  
   ,[Panel_Id]  
   ,[DeliveryAddress_Id]  
   ,[Account_Id]  
   ,[Type]  
   ,[Country_Id]  
   ,BatchId  
   ,TransactionId  
   )  
  SELECT NEWID()  
   ,DATEADD(millisecond, 10 * (  
     ROW_NUMBER() OVER (  
      ORDER BY (  
        SELECT 0  
        )  
      )  
     ), @GPSUpdateTimestamp)  
   ,NULL  
   ,DATEADD(millisecond, 10 * (  
     ROW_NUMBER() OVER (  
      ORDER BY (  
        SELECT 0  
        )  
      )  
     ), [ReceivedDate])  
   ,'Received on '+CONVERT(VARCHAR, CAST([ReceivedDate] AS DATE), 103)+' for panel :'+ (select Name from Panel where guidreference= [PanelId])
   +' and period :'+CONVERT(VARCHAR,[DiaryDateYear], 103)+'.'+CONVERT(VARCHAR,[DiaryDatePeriod], 103)+'.'+CONVERT(VARCHAR,[DiaryDateWeek], 103)  
   ,CumulativePoints  
   ,@pGPSUser  
   ,DATEADD(millisecond, 10 * (  
     ROW_NUMBER() OVER (  
      ORDER BY (  
        SELECT 0  
        )  
      )  
     ), @GPSUpdateTimestamp)  
   ,DATEADD(millisecond, 10 * (  
     ROW_NUMBER() OVER (  
      ORDER BY (  
        SELECT 0  
        )  
      )  
     ), @GPSUpdateTimestamp)  
   ,NULL  
   ,[TransactionInfoId]  
   ,@TransactionSourceId  
   ,[IndividualId]  
   ,[PanelId]  
   ,NULL  
   ,[BeneficiaryId]--[IndividualId]  
   ,N'Credit'  
   ,@pCountryId  
   ,@MaxBatchId,  
   ROW_NUMBER() 
   OVER (ORDER BY (SELECT 0)) 
  FROM #Tempdiaries  
    
  COMMIT TRANSACTION  
  
  SET XACT_ABORT OFF  
  
  SELECT 1  
 END TRY  
  
 BEGIN CATCH  
  ROLLBACK TRANSACTION  
  
  SET @DiaryAfterCount = (  
    SELECT COUNT(0)  
    FROM DiaryEntry  
    )  
  
  INSERT INTO [DiaryInsertLog] (  
   [CountryId]  
   ,[CreatedTimeStamp]  
   ,[InsertCount]  
   ,[User]  
   ,[DiaryBeforeCount]  
   ,[DiaryAfterCount]  
   ,Comments  
   )  
  VALUES (  
   @pCountryId  
   ,@pCreationDate  
   ,@InsertCount  
   ,@pGPSUser  
   ,@DiaryBeforeCount  
   ,@DiaryAfterCount  
   ,ERROR_MESSAGE()  
   )  
  
  SELECT 0  
  
  SELECT ERROR_MESSAGE()  
 END CATCH  
  
 DROP TABLE #Tempdiaries  
END