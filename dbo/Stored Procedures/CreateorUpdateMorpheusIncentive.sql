CREATE PROCEDURE [dbo].[CreateorUpdateMorpheusIncentive] (
	@pAppUserGUID NVARCHAR(100)
	,@pTransactionDateTime nvarchar(300)
	,@pTransaction_Reason_Code int
	,@pTransactionReason nvarchar(300)
	,@pTransactionDescription nvarchar(300)=null
	,@pTransactionValue nvarchar(300)
	,@pIsIncentive nvarchar(300)
	,@pMessageID UNIQUEIDENTIFIER 
	,@pCountryISO2A NVARCHAR(4)
	,@pCultureCode INT
	)
AS
BEGIN
--EXEC CreateorUpdateMorpheusIncentive 'G44444','10/3/2016 0:00','0','MorphuesIncentive','MorphuesIncentive',5000,'MH',2057

--SELECT * FROM NAMEDALIAS

--SELECT * FROM INDIVIDUAL WHERE GUIDREFERENCE='64436F98-7CA2-4019-9D2D-6006C0C742C8'
---SELECT * FROM IncentiveAccountTransaction WHERE Country_Id='8D4D5901-8DE0-4DE1-87DA-316743815809'
			SET NOCOUNT ON;
			SET XACT_ABORT ON;

BEGIN TRY
			DECLARE @pCountryId UNIQUEIDENTIFIER
			SET @pCountryId = (SELECT CountryId FROM COUNTRY WHERE CountryISO2A = @pCountryISO2A)

			DECLARE @GetDate DATETIME
			IF (SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(),@pCountryId)) IS NOT NULL
			BEGIN
			 SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(GETDATE(),@pCountryId))
			END
			ELSE
			BEGIN
				SET @GetDate = GETDATE()
			END
			

			DECLARE @GPSUser NVARCHAR(200)
			SET @GPSUser = 'MorpheusUser'

			DECLARE @pSystemDate DATETIME
			SET @pSystemDate = getdate()

			----SELECT * FROM COUNTRY

		
			
			DECLARE @GroupContextId UNIQUEIDENTIFIER
			SET @GroupContextId = (SELECT NamedAliasContextId FROM NamedAliasContext WHERE Name = 'MorphesAppUserContext')

			PRINT @GroupContextId

			---------validation start----------
				

		
		BEGIN TRANSACTION
		BEGIN TRY
		IF NOT EXISTS (SELECT 1 FROM  NAMEDALIAS NA WHERE  NA.[KEY]=@pAppUserGUID AND  NA.AliasContext_Id = @GroupContextId )
							BEGIN
								INSERT INTO [MorpheusErrorLog] ([MessageId],[ErrorMessage])
								SELECT @pMessageID,'AppUserGUID NOT FOUND'+ @pAppUserGUID

								DECLARE @Msg NVARCHAR(MAX)
								SET @Msg='AppUserGUID NOT FOUND'+ @pAppUserGUID
								RAISERROR(@Msg,16,1)
							END
			IF OBJECT_ID('tempdb..#MorphuesFeedData') IS NOT NULL DROP TABLE #MorphuesFeedData
			CREATE TABLE #MorphuesFeedData (
				Rownumber INT Identity NOT NULL
				,AppUserGUID NVARCHAR(300)
				,TransactionDateTime DATETIME NULL
				,Transaction_Reason_Code int null
				,TransactionReason nvarchar(300) NULL
				,TransactionDescription nvarchar(300) NULL
				,TransactionValue nvarchar(300) NULL
				,IncentiveAccountTransactionInfoId UNIQUEIDENTIFIER DEFAULT NEWID()
				,TransactionSourceId UNIQUEIDENTIFIER NULL
				,TranslationSourceDescId UNIQUEIDENTIFIER NULL
				,DepositorId UNIQUEIDENTIFIER NULL
				,IncentivePointTypeNameId UNIQUEIDENTIFIER NULL
				,IncentivePointDescId UNIQUEIDENTIFIER NULL
				,PointID UNIQUEIDENTIFIER NULL
				,RecordProcessed INT NULL
				,IsNewTransactionSrcId  INT null
				,IncentiveAccountId UNIQUEIDENTIFIER NULL
				)

				INSERT INTO #MorphuesFeedData (
									AppUserGUID 
									,TransactionDateTime 
									,Transaction_Reason_Code
									,TransactionReason 
									,TransactionDescription 
									,TransactionValue 
									,IncentiveAccountTransactionInfoId 
									,TransactionSourceId 
									,TranslationSourceDescId 
									,DepositorId 
									,IncentivePointTypeNameId
									,IncentivePointDescId
									,PointID
									,RecordProcessed 
									,IsNewTransactionSrcId
									,IncentiveAccountId
									)
					SELECT  @pAppUserGUID
									,CASE WHEN @pTransactionDateTime IS NOT NULL THEN DATEADD(DAY,0,@pTransactionDateTime) ELSE @pTransactionDateTime END
									,@pTransaction_Reason_Code
									,@pTransactionReason
									,@pTransactionDescription
									,@pTransactionValue
									,NEWID()
									,NEWID()
									,NULL
									,null
									,null
									,null
									,NULL
									,0
									,0
									,NULL
									
	
				IF EXISTS(SELECT I.GUIDReference FROM #MorphuesFeedData MFD
																JOIN Incentivepoint I ON MFD.Transaction_Reason_Code=I.CODE
																JOIN RESPONDENT R ON R.GUIDReference=i.GUIDReference 
																WHERE R.CountryID = @pCountryId
																AND @pIsIncentive=1 )
				BEGIN
				UPDATE MFD SET MFD.PointID =  I.GUIDReference FROM #MorphuesFeedData MFD
																JOIN Incentivepoint I ON MFD.Transaction_Reason_Code=I.CODE
																JOIN RESPONDENT R ON R.GUIDReference=i.GUIDReference 
						WHERE R.CountryID = @pCountryId
						AND @pIsIncentive=1

				END
				
				IF EXISTS(SELECT I.GUIDReference FROM #MorphuesFeedData MFD
																JOIN Incentivepoint I ON MFD.Transaction_Reason_Code=I.RewardCode
																JOIN RESPONDENT R ON R.GUIDReference=i.GUIDReference 
																WHERE R.CountryID = @pCountryId
																AND @pIsIncentive=0 )
				BEGIN
						
						UPDATE MFD SET MFD.PointID =  I.GUIDReference FROM #MorphuesFeedData MFD
						JOIN Incentivepoint I ON MFD.Transaction_Reason_Code=I.RewardCode
						JOIN RESPONDENT R ON R.GUIDReference=i.GUIDReference 
						WHERE R.CountryID = @pCountryId
						AND @pIsIncentive=0
				END


				
				IF NOT EXISTS(SELECT I.GUIDReference FROM #MorphuesFeedData MFD
									JOIN Incentivepoint I ON MFD.Transaction_Reason_Code= (CASE WHEN @pIsIncentive=1 then I.CODE else I.RewardCode end)	 
									JOIN RESPONDENT R ON R.GUIDReference=i.GUIDReference 
									WHERE  R.CountryID = @pCountryId)
				BEGIN

					DECLARE @IncentivePointType UNIQUEIDENTIFIER
					DECLARE @IncentivePointTransGUID UNIQUEIDENTIFIER
					DECLARE @RewardPointType UNIQUEIDENTIFIER
					DECLARE @MorphuesIncentiveKey NVARCHAR(MAX)=CAST(@pTransaction_Reason_Code AS VARCHAR(100))  +  REPLACE(@pTransactionReason,' ','')+(CASE WHEN @pIsIncentive=1 then 'Incentive' else 'RewardCode' end)
					DECLARE @MorphuesIncentiveValue NVARCHAR(MAX)=@pTransactionReason
					DECLARE @IncentivePointGUID UNIQUEIDENTIFIER=NEWID()

					select @IncentivePointType=iat.GUIDReference
					from IncentivePointAccountEntryType iat
					inner join country c on c.CountryId=iat.Country_ID
					inner join Translation T On iat.TypeName_Id=T.TranslationId AND T.KeyName='MorphuesIncentiveType'
					where c.CountryISO2A=@pCountryISO2A  and [type] ='IncentiveType'

					select @RewardPointType=iat.GUIDReference
					from IncentivePointAccountEntryType iat
					inner join country c on c.CountryId=iat.Country_ID
					inner join Translation T On iat.TypeName_Id=T.TranslationId AND T.KeyName='MorphuesRedemptionType'
					where c.CountryISO2A=@pCountryISO2A  and [type] ='RewardType'

					PRINT @MorphuesIncentiveKey;

					EXECUTE InsertTranslationValues @MorphuesIncentiveKey, @MorphuesIncentiveValue, 2057, @GPSUSER, 'BusinessTranslation'
					SET @IncentivePointTransGUID=(SELECT TranslationId FROM Translation WHERE KeyName=@MorphuesIncentiveKey)

					INSERT INTO Respondent (GUIDReference,DiscriminatorType,CountryID,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) values (@IncentivePointGUID,'Point',@pCountryId,@GPSUser,@GetDate,@GetDate)

					IF @pIsIncentive=1
					BEGIN
						
						INSERT INTO IncentivePoint(GUIDReference,Code,Value,ValidFrom,ValidTo,HasUpdateableValue,HasAllPanels,Type_Id,
							Description_Id,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,RewardCode,GiftPrice,CostPrice,RewardSource,SupplierId,
							HasStockControl,StockLevel,Type,Minimum,Maximum,DealtByCommunication)
						VALUES(@IncentivePointGUID,@pTransaction_Reason_Code,0,@GetDate,NULL,1,0,@IncentivePointType,@IncentivePointTransGUID,
						@GPSUser,@GetDate,@GetDate,NULL,0,NULL,NULL,NULL,0,NULL,'Incentive',NULL,NULL,0)
					END
					ELSE
					begin
						INSERT INTO IncentivePoint(GUIDReference,Code,Value,ValidFrom,ValidTo,HasUpdateableValue,HasAllPanels,Type_Id,
							Description_Id,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,RewardCode,GiftPrice,CostPrice,RewardSource,SupplierId,
							HasStockControl,StockLevel,Type,Minimum,Maximum,DealtByCommunication)
						VALUES(@IncentivePointGUID,0,0,@GetDate,NULL,1,0,@IncentivePointType,@IncentivePointTransGUID,
						@GPSUser,@GetDate,@GetDate,@pTransaction_Reason_Code,0,NULL,NULL,NULL,0,NULL,'Reward',NULL,NULL,0)
					END

					UPDATE MFD SET MFD.PointID =@IncentivePointGUID FROM #MorphuesFeedData MFD
				END
																		
				
				UPDATE MFD SET MFD.IncentiveAccountId = C.GroupContact_Id
							FROM #MorphuesFeedData MFD
							INNER JOIN NAMEDALIAS NA ON NA.[KEY]= MFD.AppUserGUID  COLLATE SQL_Latin1_General_CP1_CI_AI
							JOIN COLLECTIVE C ON C.GUIDReference=NA.Candidate_Id
							WHERE  C.CountryId = @pCountryId AND NA.AliasContext_Id = @GroupContextId

				UPDATE 	MFD SET MFD.IncentiveAccountId = I.IncentiveAccountId FROM 	INCENTIVEACCOUNT I
																			JOIN #MorphuesFeedData	MFD ON MFD.DepositorId = I.IncentiveAccountId
																			WHERE 	MFD.DepositorId = I.IncentiveAccountId AND I.Country_Id = @pCountryId 

				UPDATE MFD SET MFD.TransactionSourceId = TS.TransactionSourceId,MFD.TranslationSourceDescId = T.TranslationId,IsNewTransactionSrcId = 1 from TransactionSource ts 
																		 join translation t on t.TranslationId = Description_Id 
																		 JOIN #MorphuesFeedData MFD ON MFD.TransactionReason = T.keyname COLLATE SQL_Latin1_General_CP1_CI_AI
																		 WHERE T.keyname = MFD.TransactionReason COLLATE SQL_Latin1_General_CP1_CI_AI
				
				UPDATE MFD SET MFD.TranslationSourceDescId = NEWID() FROM #MorphuesFeedData MFD  WHERE IsNewTransactionSrcId = 0
				UPDATE MFD SET MFD.TransactionSourceId = NEWID() FROM #MorphuesFeedData MFD WHERE IsNewTransactionSrcId = 0

				
								
			INSERT INTO IncentiveAccountTransactionInfo(
											IncentiveAccountTransactionInfoId
											,Ammount
											,GPSUser
											,GPSUpdateTimestamp
											,CreationTimeStamp
											,GiftPrice
											,Discriminator
											,Point_Id
											,RewardDeliveryType_Id
											,Country_Id)
								SELECT MFD.IncentiveAccountTransactionInfoId
										   ,ABS(MFD.TransactionValue)
										   ,@GPSUser
										   ,@GetDate
										   ,@GetDate
										   ,NULL
										   ,'TransactionInfo'
										   ,MFD.PointID
										   ,NULL
										   ,@pCountryId
										   FROM  #MorphuesFeedData MFD

			INSERT INTO IncentiveAccountTransaction(
											IncentiveAccountTransactionId
											,CreationDate
											,SynchronisationDate
											,TransactionDate
											,Comments
											,Balance
											,GPSUser
											,GPSUpdateTimestamp
											,CreationTimeStamp
											,PackageId
											,TransactionInfo_Id
											,TransactionSource_Id
											,Depositor_Id
											,Panel_Id
											,DeliveryAddress_Id
											,Account_Id
											,[Type]
											,Country_Id
											,GiftPrice
											,CostPrice
											,ProviderExtractionDate)
								SELECT NEWID()
											,@GetDate
											,NULL
											,TransactionDateTime
											,MFD.TransactionDescription
											,MFD.TransactionValue
											,@GPSUser
											,@GetDate
											,@GetDate
											,NULL
											,MFD.IncentiveAccountTransactionInfoId
											,NULL
											,NULL
											,NULL
											,NULL
											,MFD.IncentiveAccountId 
											,(CASE WHEN @pIsIncentive=1 THEN 'Credit'  ELSE 'Debit' END)
											,@pCountryId
											,NULL
											,NULL
											,NULL
											FROM  #MorphuesFeedData MFD
 
			/*In message Reprocess, if the message processes successfully, update the status to 1, still the message status is zero */
			UPDATE dbo.MorpheusQueueLog SET  MessageStatus = 1 WHERE MessageId = @pMessageID AND MessageStatus = 0

				COMMIT TRANSACTION

			END TRY
			BEGIN CATCH
				PRINT ERROR_MESSAGE()
				ROLLBACK TRANSACTION
				INSERT INTO MorpheusErrorLog ([MessageId],[ErrorMessage]) VALUES (@pMessageID,ERROR_MESSAGE())

				DECLARE @ERROR_MESSAGE NVARCHAR(MAX)
				SET @ERROR_MESSAGE=ERROR_MESSAGE()
				RAISERROR(@ERROR_MESSAGE,16,1)
			END CATCH
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();
	
	RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH
END