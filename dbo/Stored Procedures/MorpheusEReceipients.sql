CREATE PROCEDURE MorpheusEReceipients
(
  @MorpheusEReceiptsType [MorpheusEReceiptsType] READONLY
 ,@pMessageID UNIQUEIDENTIFIER 
 ,@pCountryCode VARCHAR(2)
 ,@pCultureCode INT
)
AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @pAppUserGUID NVARCHAR(2000)
	DECLARE @CountryId UNIQUEIDENTIFIER
	SET @CountryId = (SELECT CountryId FROM COUNTRY WHERE CountryISO2A = @pCountryCode)

	DECLARE @MorphesAppUserContextId UNIQUEIDENTIFIER
	DECLARE @MorphesAppUserContext AS NVARCHAR(MAX) ='MorphesAppUserContext'
	DECLARE @MorphesIndividualContextKey AS NVARCHAR(MAX) ='MorphesIndividualContext'

	SELECT @MorphesAppUserContextId=NamedAliasContextId FROM NamedAliasContext WHERE Country_Id=@CountryId AND Name=@MorphesAppUserContext

	DECLARE @EReceiptsPresetedGuid UNIQUEIDENTIFIER

		SET @EReceiptsPresetedGuid = (
				SELECT Id
				FROM StateDefinition
				WHERE Code = 'EReceiptsPreseted'
					AND Country_Id = @CountryId
				)

	
	IF OBJECT_ID('tempdb..#TempMorpheusEReceipts') IS NOT NULL DROP TABLE #MorpheusEReceipts
	CREATE TABLE #TempMorpheusEReceipts
	(
			 Id BIGINT IDENTITY(1,1),
		MorpheusEReceiptsId UNIQUEIDENTIFIER DEFAULT NEWID(),
		CandidateId UNIQUEIDENTIFIER NOT NULL,
		EmailAddress NVARCHAR(2000) NOT NULL,
		CreatedDateTime DATETIME  NOT NULL,
		CreatedBy NVARCHAR(2000) NOT NULL,
		UpdatedDateTime DATETIME  NULL,
		UpdatedBy NVARCHAR(2000) NULL,
		StateId UNIQUEIDENTIFIER NOT NULL
	)

	BEGIN TRANSACTION
	BEGIN TRY

             IF EXISTS (   SELECT 1 FROM  
					@MorpheusEReceiptsType MET 
					LEFT OUTER JOIN NAMEDALIAS NA ON NA.[Key]=MET.AppUserGUID AND NA.AliasContext_Id=@MorphesAppUserContextId
					WHERE   NA.NamedAliasId IS NULL
				  )
		BEGIN
			--PRINT '1'			
			SELECT TOP 1 @pAppUserGUID=MET.AppUserGUID FROM  
			@MorpheusEReceiptsType MET 
			LEFT OUTER JOIN NAMEDALIAS NA ON NA.[Key]=MET.AppUserGUID AND NA.AliasContext_Id=@MorphesAppUserContextId
			WHERE   NA.NamedAliasId IS NULL 

			DECLARE @Msg NVARCHAR(MAX)
			SET @Msg='AppUserGUID NOT FOUND'+ @pAppUserGUID
			RAISERROR(@Msg,16,1)
		END

		
             IF EXISTS (   SELECT 1 FROM  
						@MorpheusEReceiptsType MET 
						LEFT OUTER JOIN EReceiptEmailStatus ES ON ES.Id=MET.[Status]
						WHERE ES.Id IS NULL
					  )
		BEGIN
			--PRINT '2'
			DECLARE @StatusId INT
			SELECT TOP 1 @StatusId=MET.[Status] FROM  
			@MorpheusEReceiptsType MET 
			LEFT OUTER JOIN EReceiptEmailStatus ES ON ES.Id=MET.[Status]
			WHERE ES.Id IS NULL
																
			DECLARE @MsgStatus NVARCHAR(MAX)
			SET @MsgStatus='Invalid Status '+ CAST(@StatusId as VARCHAR(200))
			RAISERROR(@MsgStatus,16,1)
		END


		INSERT INTO #TempMorpheusEReceipts(CandidateId,EmailAddress,CreatedDateTime,CreatedBy,UpdatedDateTime,UpdatedBy,StateId)
		SELECT NA.Candidate_Id,TM.EmailAddress,TM.CreatedDateTime,TM.CreatedBy,TM.UpdatedDateTime,TM.UpdatedBy,sd.Id
		FROM @MorpheusEReceiptsType TM
		INNER JOIN EReceiptEmailStatus ES ON ES.Id=TM.[Status]
		INNER JOIN StateDefinition sd ON  sd.Country_Id=@CountryId AND UPPER(REPLACE(sd.Code,'EReceipts',''))=UPPER(REPLACE(ES.[NAME],' ','')) COLLATE SQL_Latin1_General_CP1_CI_AI
		INNER JOIN NamedAlias NA ON NA.[Key]=TM.AppUserGUID COLLATE SQL_Latin1_General_CP1_CI_AI
		INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NAC.NamedAliasContextId
		WHERE NAC.[Name]=@MorphesAppUserContext
			 ORDER BY TM.CreatedDateTime,TM.UpdatedDateTime ASC

			 DECLARE @id BIGINT
			 
			 -- while has written because there may be a chance to have same message multiple times in that time first one is insert , second on wards update , so that if we insert in a bulk way 
			 -- message will be failed due to unique voilation , so we are processing one by one

			 WHILE EXISTS (SELECT 1 FROM #TempMorpheusEReceipts)
			 BEGIN 

			 SELECT TOP (1) @id=id FROM #TempMorpheusEReceipts ORDER BY CreatedDateTime,UpdatedDateTime ASC

		INSERT INTO MorpheusEReceiptsHistory(MorpheusEReceiptsHistoryId,MorpheusEReceiptsId,CandidateId,EmailAddress,GPSUser,CreationTimeStamp,GPSUpdateTimestamp,From_Id,To_Id)
		SELECT NEWID(),T.MorpheusEReceiptsId,T.CandidateId,T.EmailAddress,T.CreatedBy,T.CreatedDateTime,T.CreatedDateTime,@EReceiptsPresetedGuid,T.StateId
		FROM #TempMorpheusEReceipts T
             WHERE T.Id=@id AND NOT EXISTS(
             SELECT 1 FROM MorpheusEReceipts S WHERE T.EmailAddress=S.EmailAddress AND T.CandidateId=S.CandidateId
		)

		INSERT INTO MorpheusEReceiptsHistory(MorpheusEReceiptsHistoryId,MorpheusEReceiptsId,CandidateId,EmailAddress,GPSUser,CreationTimeStamp,GPSUpdateTimestamp,From_Id,To_Id)
		SELECT NEWID(),S.MorpheusEReceiptsId,S.CandidateId,S.EmailAddress,T.UpdatedBy,T.CreatedDateTime,T.UpdatedDateTime,S.StateId,T.StateId
             FROM #TempMorpheusEReceipts T INNER JOIN MorpheusEReceipts S ON T.EmailAddress=S.EmailAddress AND T.CandidateId=S.CandidateId AND T.StateId<>S.StateId
			 WHERE T.Id=@id 
	

		
             
             UPDATE T SET T.GPSUpdateTimestamp=S.UpdatedDateTime,T.GPSUser=S.UpdatedBy,T.StateId=S.StateId
             FROM #TempMorpheusEReceipts S 
             INNER JOIN MorpheusEReceipts T ON T.EmailAddress=S.EmailAddress AND T.CandidateId=S.CandidateId AND T.StateId<>S.StateId
			 WHERE S.Id=@id 

             INSERT INTO MorpheusEReceipts(MorpheusEReceiptsId,CandidateId,EmailAddress,GPSUser,CreationTimeStamp,GPSUpdateTimestamp,StateId,CountryId)
             SELECT S.MorpheusEReceiptsId,S.CandidateId,S.EmailAddress,S.CreatedBy,S.CreatedDateTime,S.UpdatedDateTime,S.StateId,@CountryId
             FROM #TempMorpheusEReceipts S
             WHERE S.Id=@id  AND NOT EXISTS(
             SELECT 1 FROM MorpheusEReceipts T WHERE T.EmailAddress=S.EmailAddress AND T.CandidateId=S.CandidateId
             )

			 DELETE FROM #TempMorpheusEReceipts WHERE Id=@id

             END                  
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
            DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
       END CATCH
END