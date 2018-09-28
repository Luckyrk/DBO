GO
CREATE PROCEDURE [dbo].[Usp_QuestBackImportInsert]    
@pColumn ColumnTableType READONLY,    
@pQuestBackImport dbo.QuestbackImport READONLY,    
@pCountryId UniqueIdentifier=NULL,    
@pUser VARCHAR(100)=NULL,    
@pFileId UniqueIdentifier=NULL,    
@pCultureCode INT=NULL,    
@pSystemDate DATETIME=NULL    
--@pCalendareRececiedDate DATETIME=NULL    
AS    
BEGIN    
SET NOCOUNT ON;    
BEGIN TRY    
DECLARE @Getdate DATETIME,@REPETSEPARATOER NVARCHAR(MAX),@maxColumnCount INT,@ErrorMessage NVARCHAR(400), @isErrorOccured BIT=0,@TransactionSourceId UniqueIdentifier    
SET @Getdate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryId))    
IF (@Getdate IS NULL)    
BEGIN    
 SET @Getdate =GETDATE()    
END    
    
SET @maxColumnCount =13    
SET @REPETSEPARATOER = REPLICATE('|', @maxColumnCount)    
 IF NOT EXISTS (    
   SELECT 1    
   FROM ImportFile I    
   INNER JOIN StateDefinition SD ON SD.Id = I.State_Id    
    AND I.GUIDReference = @pFileId    
   WHERE SD.Code = 'ImportFileProcessing'    
    AND SD.Country_Id = @pCountryId    
   )    
 BEGIN    
  INSERT INTO ImportAudit    
  VALUES (    
   NEWID(),1,1,'File already is processed',@GetDate    
   ,NULL,NULL,@GetDate,@pUser,@GetDate,@pFileId    
   )    
    
  EXEC InsertImportFile 'ImportFileBusinessValidationError'    
   ,@pUser    
   ,@pFileId    
   ,@pCountryId    
    
  RETURN;    
 END    
    
 CREATE TABLE #QuestBackImport (    
 [Rownumber] [int] NULL,    
 [Datepointsgranted] VARCHAR(MAX),    
 [Bonuspoints] VARCHAR(MAX),    
 [Description] VARCHAR(MAX),    
 [ProjectID] VARCHAR(MAX),    
 [Projecttitle] VARCHAR(MAX),    
 [Pseudo] VARCHAR(MAX),    
 [Account] VARCHAR(MAX),    
 [Firstname] VARCHAR(MAX),    
 Name VARCHAR(MAX),    
 [Email] VARCHAR(MAX),    
 [ForeignID] VARCHAR(MAX),    
 [Dateofentrytothepanel] VARCHAR(MAX),    
 [Panelstatus] VARCHAR(MAX),    
 [FullRow] VARCHAR(MAX),    
 [IncentivePoint] VARCHAR(MAX),    
 IncentivePointID UNIQUEIDENTIFIER,    
 MainContactId UNIQUEIDENTIFIER,    
 GroupId UNIQUEIDENTIFIER,    
 IncentiveAccountTransactionInfoId UNIQUEIDENTIFIER DEFAULT NEWID(),    
 IsValidMainContactId BIT,    
 IsValidincentivePoint BIT    
)    
INSERT INTO #QuestBackImport([Rownumber],[Datepointsgranted],[Bonuspoints],[Description],[ProjectID],[Projecttitle],[Pseudo],[Account]    
,[Firstname],Name,[Email],[ForeignID],[Dateofentrytothepanel],[Panelstatus],[FullRow],[IncentivePoint],IsValidMainContactId,IsValidincentivePoint)    
SELECT [Rownumber],[Datepointsgranted],[Bonuspoints],[Description],[ProjectID],[Projecttitle],[Pseudo],[Account]    
,[Firstname],Name,[Email],[ForeignID],[Dateofentrytothepanel],[Panelstatus],[FullRow],[IncentivePoint],    
IIF(ISNULL([ForeignID],'')='',0,ISNUMERIC([ForeignID])),IIF(ISNULL([IncentivePoint],'')='',0,ISNUMERIC([IncentivePoint]))    
 FROM @pQuestBackImport    
    
 UPDATE T1 SET T1.GroupId=C.GUIDReference,T1.MainContactId=C.GroupContact_Id    
 FROM     
 #QuestBackImport T1    
 JOIN [NamedAlias] NA ON NA.[Key]=T1.ForeignID    
 JOIN NamedAliasContext NAC ON NA.AliasContext_Id = NAC.NamedAliasContextId    
 JOIN Collective C ON C.GUIDReference = NA.Candidate_Id    
 WHERE NAC.Name='AliasLoadingFR' AND ISNULL(T1.IsValidMainContactId,0)=1    
 AND C.CountryId=@pCountryId    
    
 UPDATE #QuestBackImport SET IsValidMainContactId=0 WHERE GroupId IS NULL    
    
IF EXISTS(SELECT 1 FROM #QuestBackImport WHERE ISNULL(IsValidMainContactId,0)=0)    
BEGIN    
SET @isErrorOccured = 1    
 SET @ErrorMessage='Error: invalid house hold.'    
     INSERT INTO ImportAudit (    
      GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors    
      ,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]    
      )    
     SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER    
      ,@GetDate,@pUser,@GetDate,@pFileId    
     FROM #QuestBackImport T1    
     WHERE ISNULL(IsValidMainContactId,0)=0    
    
END    
    
UPDATE T1 SET T1.IncentivePointID=IP.GUIDReference    
FROM #QuestBackImport T1    
JOIN IncentivePoint IP ON IP.Code=T1.IncentivePoint    
WHERE ISNULL(IsValidincentivePoint,0)=1    
    
UPDATE #QuestBackImport SET IsValidincentivePoint=0 WHERE IncentivePointID IS NULL    
    
IF EXISTS(SELECT 1 FROM #QuestBackImport WHERE ISNULL(IsValidincentivePoint,0)=0)    
BEGIN    
SET @isErrorOccured = 1    
 SET @ErrorMessage='Error: invalid Incentive Point.'    
     INSERT INTO ImportAudit (    
      GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors    
      ,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]    
      )    
     SELECT NEWID(),1,0,@ErrorMessage,@GetDate,[FullRow],@REPETSEPARATOER    
      ,@GetDate,@pUser,@GetDate,@pFileId    
     FROM #QuestBackImport T1    
     WHERE ISNULL(IsValidincentivePoint,0)=0    
    
END    
    
IF (@isErrorOccured =1)    
BEGIN    
 EXEC InsertImportFile 'ImportFileError'    
  ,@pUser    
  ,@pFileId    
  ,@pCountryId    
    
 RETURN;    
END    
ELSE    
BEGIN    
    
PRINT 'PROCESS STARTED'    
 INSERT INTO IncentiveAccountTransactionInfo(IncentiveAccountTransactionInfoId,Ammount,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,    
 GiftPrice,Discriminator,Point_Id,RewardDeliveryType_Id,Country_Id)    
 SELECT IncentiveAccountTransactionInfoId,Try_Parse(Bonuspoints AS INT),@pUser,@GetDate,@GetDate,    
 NULL,'TransactionInfo',IncentivePointID,NULL,@pCountryId    
 FROM  #QuestBackImport    
     
 SET @TransactionSourceId=(SELECT TransactionSourceId FROM TransactionSource WHERE Code='Questback' AND Country_Id=@pCountryId)    
 INSERT INTO IncentiveAccountTransaction(IncentiveAccountTransactionId,CreationDate,SynchronisationDate,    
 TransactionDate,Comments,Balance,GPSUser,GPSUpdateTimestamp    
 ,CreationTimeStamp,PackageId,TransactionInfo_Id,TransactionSource_Id,Depositor_Id,Panel_Id,DeliveryAddress_Id,Account_Id,    
 [Type],Country_Id,GiftPrice,CostPrice,ProviderExtractionDate)     
 SELECT NEWID(),@GetDate,@GetDate,    
 Convert(Date,[Datepointsgranted],105),'Points allocated through Questback Import',0,@pUser,@GetDate    
 ,@GetDate,NULL,IncentiveAccountTransactionInfoId,@TransactionSourceId,MainContactId,NULL,NULL,MainContactId,    
 'Credit',@pCountryId,NULL,NULL,NULL    
 FROM  #QuestBackImport    
    
 EXEC InsertImportFile 'ImportFileSuccess'    
   ,@pUser    
   ,@pFileId    
   ,@pCountryId    
    
  INSERT INTO ImportAudit (GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData    
   ,SerializedRowErrors,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]    
   )    
  SELECT NEWID(),0,0,'Questback Incentives Imported successfully....'    
   ,@GetDate,T1.[FullRow],@REPETSEPARATOER,@GetDate,@pUser,@GetDate    
   ,@pFileId    
  FROM @pQuestBackImport T1    
END    
    
 END TRY    
 BEGIN CATCH    
 INSERT INTO ImportAudit (    
    GUIDReference,Error,IsInvalid,[Message],[Date],SerializedRowData,SerializedRowErrors    
    ,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,[File_Id]    
    )    
    SELECT NEWID(),1,0,ERROR_MESSAGE(),@GetDate,ERROR_PROCEDURE(),@REPETSEPARATOER    
    ,@GetDate,@pUser,@GetDate,@pFileId    
        
    EXEC InsertImportFile 'ImportFileError',@pUser,@pFileId,@pCountryId    
 END CATCH    
    
END 
GO