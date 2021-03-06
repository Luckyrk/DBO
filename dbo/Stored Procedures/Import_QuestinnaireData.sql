--USE [GPS_PM_Iberia_ISEC]
--GO
 

CREATE PROCEDURE [dbo].[Import_QuestinnaireData]
(
	@pCountryISO2A AS VARCHAR(2)='ES' 
	,@ConnectionID NVARCHAR(100)
	,@FileName NVARCHAR(100)
	,@ProcessId UNIQUEIDENTIFIER
)
/*
Created By  - Satish Dandibothula
Purpose : Import Questionnaire data through SSIS.

Updates: 
Date		- Update.
03-FEB-2017 - 42853 Related: Added new columns into Questionnaire template and the same implemented in SP.
07-AUG-2017 - 44190 modifications. changed Error logging and summaries.
*/
AS

BEGIN
BEGIN TRY
	BEGIN TRY

		DECLARE @SQLString NVARCHAR(MAX) ='';
		DECLARE @ERROR INT = 0;
		DECLARE @TotalCount AS INT  = 0;
		DECLARE @IntCount AS INT = 0;
		DECLARE @ROWID AS BIGINT;
		DECLARE @GPSUser AS NVARCHAR(100) = 'SurveyQuestionnaireImport'
		DECLARE @CountryId AS UNIQUEIDENTIFIER
		DECLARE @Getdate DATETIME
		DECLARE @ImportType AS VARCHAR(50) = 'SurveyQuestionnaire'
		DECLARE @IsErrorOccured as BIT  = 0
		DECLARE @ProcessedRows AS BIGINT =0

		SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@pCountryISO2A))
		SELECT @CountryId = CountryId FROM Country WHERE CountryISO2A = @pCountryISO2A


		UPDATE [QB_DataImport].[dbo].Import_Questionnaire_Staging 
		SET IsProcessed = 0 

		DECLARE  @Temp_QuestionnaireData as TABLE(
				RowSeq BIGINT IDENTITY(1, 1)
				,GroupSequence NVARCHAR(100) COLLATE DATABASE_DEFAULT
				,PanelistID  NVARCHAR(100) COLLATE DATABASE_DEFAULT
				,PanelistName nvarchar(100) COLLATE DATABASE_DEFAULT	
				,SurveyName NVARCHAR(100) COLLATE DATABASE_DEFAULT  
				,ClientName NVARCHAR(100) COLLATE DATABASE_DEFAULT
				,ClientTeamPerson varchar(200) COLLATE DATABASE_DEFAULT
				,QuestionnaireType varchar(100) COLLATE DATABASE_DEFAULT 
				,Department varchar(100) COLLATE DATABASE_DEFAULT
				,Comment varchar(100) COLLATE DATABASE_DEFAULT			
				,CreationTimestamp NVARCHAR(100) COLLATE DATABASE_DEFAULT 			
				,GPSUPdateTimestamp NVARCHAR(100) COLLATE DATABASE_DEFAULT 			
				,GPSUser nvarchar(100) COLLATE DATABASE_DEFAULT
				,QuestionnaireTransactionID NVARCHAR(100) COLLATE DATABASE_DEFAULT
				,CountryID NVARCHAR(100) COLLATE DATABASE_DEFAULT
				,InvitationDate NVARCHAR(100) COLLATE DATABASE_DEFAULT
				,StateID NVARCHAR(100) COLLATE DATABASE_DEFAULT	
				,InterviewerCode NVARCHAR(100) COLLATE DATABASE_DEFAULT	
				,InterviewerName NVARCHAR(510) COLLATE DATABASE_DEFAULT
				,Mail  NVARCHAR(100) COLLATE DATABASE_DEFAULT
				,SourceType VARCHAR(100) COLLATE DATABASE_DEFAULT	
				,QuestionnaireID NVARCHAR(100) COLLATE DATABASE_DEFAULT
				,CompletionDate NVARCHAR(100) COLLATE DATABASE_DEFAULT
				,NumberofDays NVARCHAR(100) COLLATE DATABASE_DEFAULT
				,ProcessId int,
				TableId bigint,
				GroupMainContact VARCHAR(100) COLLATE DATABASE_DEFAULT
				,[UID]  NVarchar(20) COLLATE DATABASE_DEFAULT	
				) 
			
		DECLARE @GroupSequence NVARCHAR(20), 
		@Panelist_Name nvarchar(50), 
		@Interviewer_Code VARCHAR(100), 
		@Interviewer_Name NVARCHAR(510),
		@Mail nvarchar(50),
		@Selection nvarchar(50), 
		@SurveyName nvarchar(50),
		@clientTeamPerson varchar(200), 
		@Questionnaire_Type varchar(50),
		@CompletionDate VARCHAR(100), 
		@NumberofDays VARCHAR(100), 
		@LastDate VARCHAR(100),
		@Completion_Date VARCHAR(100), 
		@StateId varchar(100) 
		
		SET @SurveyName = 'LinkQ'
		SET @clientTeamPerson = 'LinkQ'

		--update [QB_DataImport].[dbo].Import_Questionnaire_Staging
		--SET QuestionnaireName = (CASE WHEN ISNULL(QuestionnaireName,'') ='' OR LTRIM(QuestionnaireName) = '' THEN @SurveyName ELSE QuestionnaireName END)

		SELECT @CompletionDate = column_name FROM [QB_DataImport].[dbo].[QB_ColumnMapping]  WHERE field_description='CompletionDate';
		SELECT @GroupSequence = column_name FROM [QB_DataImport].[dbo].[QB_ColumnMapping]  WHERE field_description='HOUSEHOLD_ID';

		SELECT @Panelist_Name= column_name FROM [QB_DataImport].[dbo].[QB_ColumnMapping]  WHERE field_description='PANELIST_NAME';
		SELECT @Interviewer_Code = column_name FROM [QB_DataImport].[dbo].[QB_ColumnMapping]  WHERE field_description='INTERVIEWER_ID';
		SELECT @Interviewer_Name = column_name FROM [QB_DataImport].[dbo].[QB_ColumnMapping]  WHERE field_description='INTERVIEWER_NAME';

		SELECT @Mail = column_name FROM [QB_DataImport].[dbo].[QB_ColumnMapping]  WHERE field_description='Mail';
		SELECT @Selection = column_name FROM [QB_DataImport].[dbo].[QB_ColumnMapping]  WHERE field_description='Selection';
		SELECT @Questionnaire_Type = column_name FROM [QB_DataImport].[dbo].[QB_ColumnMapping]  WHERE field_description='TYPE';
		SELECT @NumberofDays = column_name FROM [QB_DataImport].[dbo].[QB_ColumnMapping]  WHERE field_description='NumberofDays';

		INSERT INTO @Temp_QuestionnaireData (GroupSequence,PanelistName,ClientName,ClientTeamPerson
		,InterviewerCode,InterviewerName,Mail, SourceType, 
		SurveyName, CreationTimestamp,
		GPSUPdateTimestamp,GPSUser,CountryID, InvitationDate,
		CompletionDate,NumberofDays, PanelistID,QuestionnaireID,ProcessId,TableId,
		QuestionnaireType,[UID] )	

		SELECT   BusinessId, PanelistName ,'KANTAR WORLDPANEL' as ClientName, @clientTeamPerson as ClientTeamPerson
		, [InterviewerId], [InterviewerName] ,	[InterviewerEmailid] , [SourceType] 
		,(CASE WHEN LTRIM(ISNULL(QuestionnaireName,'')) ='' THEN  @SurveyName ELSE QuestionnaireName END)  as SurveyName
		, CAST(@Getdate AS VARCHAR(20)) as  CreationTimestamp , CAST(@Getdate AS VARCHAR(20))  as GPSUPdateTimestamp, @GPSUser 
		, cast( @CountryId as varchar(100)) , InvitationDate
		,CompletionDate, QuestionnaireDays, null,null ,IsProcessed ,[SLNO] , QuestionnaireType, [UID]
		FROM [QB_DataImport].[dbo].Import_Questionnaire_Staging

		UPDATE tmp SET  GroupMainContact = GroupContact_Id 
		FROM  @Temp_QuestionnaireData tmp INNER JOIN Collective C ON C.Sequence = tmp.GroupSequence AND C.CountryId = @CountryId

		-- to be updatd here ...
		Update @Temp_QuestionnaireData set QuestionnaireType = 'PAPER' where QuestionnaireType='PAPEL' 
		Update @Temp_QuestionnaireData set QuestionnaireType = 'WEB' where QuestionnaireType='CORREO' 
		UPDATE @Temp_QuestionnaireData  SET ProcessId = 5 WHERE GroupMainContact IS NULL

		--------StatusId-Validation
		
		UPDATE   tmp
		SET StateID =  SD.Id 
		FROM @Temp_QuestionnaireData tmp
		JOIN  	[QB_DataImport].[dbo].Import_Questionnaire_Staging stg ON stg.SLNO = tmp.TableId
		INNER JOIN Statedefinition SD ON SD.Code = rtrim(ltrim(stg.[Status])) AND SD.Country_Id = @CountryId
		
		/*
		INSERT INTO [QB_DataImport].dbo.ERROR_LOG ([FileName],BusinessArea,SourceKey,Error_Description,ErrorDate,ProcessId)
		SELECT @FileName,'State Id',stg.[Status],
		'Error: Invalid Status:' + stg.[Status]  + ' for BusinessId: ' +  Convert(varchar(20),stg.BusinessID) + ', UID: ' + Convert(nvarchar(20), ISNULL( stg.[UID],' ')) + ', Questionnaire: ' + stg.QuestionnaireName 
		,@Getdate,@ProcessId
		FROM @Temp_QuestionnaireData tmp
		RIGHT JOIN  	[QB_DataImport].[dbo].Import_Questionnaire_Staging stg ON stg.SLNO = tmp.TableId
		LEFT JOIN Statedefinition SD ON SD.Code = rtrim(ltrim(stg.[Status])) AND SD.Country_Id = @CountryId
		WHERE tmp.StateID IS NULL
		*/

		INSERT INTO dbo.FileImportErrorLog
			(
			[FileName],
			CountryCode,
			PanelCode,
			ImportType,
			ErrorSource,
			ErrorCode,
			ErrorDescription,
			ErrorDate,
			JobId
			)

		SELECT 
		@FileName
		,@pCountryISO2A
		,NULL as PanelCode
		,@ImportType
		,'State Id'
		,stg.[Status]
		,'Error: Invalid Status:' + stg.[Status]  + ' for BusinessId: ' +  Convert(varchar(20),stg.BusinessID) + ', UID: ' + Convert(nvarchar(20), ISNULL( stg.[UID],' ')) + ', Questionnaire: ' + stg.QuestionnaireName 
		,@Getdate
		,@ProcessId
		FROM @Temp_QuestionnaireData tmp
		RIGHT JOIN  	[QB_DataImport].[dbo].Import_Questionnaire_Staging stg ON stg.SLNO = tmp.TableId
		LEFT JOIN Statedefinition SD ON SD.Code = rtrim(ltrim(stg.[Status])) AND SD.Country_Id = @CountryId
		WHERE tmp.StateID IS NULL

		IF @@ROWCOUNT > 0
			SET  @IsErrorOccured  = 1


      ---InterviewerId Validation
	  /* 
	   INSERT INTO [QB_DataImport].dbo.ERROR_LOG ([FileName],BusinessArea,SourceKey,Error_Description,ErrorDate,ProcessId)
		SELECT @FileName,'InterviewerId',tmp.[InterviewerCode],
		'Error: Invalid InterviewerId:' + tmp.[InterviewerCode] +  ', UID: ' + Convert(nvarchar(20), ISNULL( tmp.[UID],' ')) + ', Questionnaire: ' + tmp.SurveyName 
		,@Getdate,@ProcessId
		FROM @Temp_QuestionnaireData tmp
		LEFT JOIN Interviewer I  ON I.InterviewerCode = rtrim(ltrim(tmp.[InterviewerCode])) AND I.Country_Id = @CountryId		
		WHERE I.InterviewerCode IS NULL
		 */

		INSERT INTO dbo.FileImportErrorLog
			(
			[FileName],
			CountryCode,
			PanelCode,
			ImportType,
			ErrorSource,
			ErrorCode,
			ErrorDescription,
			ErrorDate,
			JobId
			)

		SELECT 
			@FileName
			,@pCountryISO2A
			,NULL as PanelCode
			,@ImportType	
			,'InterviewerId'
			,tmp.[InterviewerCode]
			,'Error: Invalid InterviewerId:' + tmp.[InterviewerCode] +  ', UID: ' + Convert(nvarchar(20), ISNULL( tmp.[UID],' ')) + ', Questionnaire: ' + tmp.SurveyName 
			,@Getdate,
			@ProcessId
		FROM @Temp_QuestionnaireData tmp
		LEFT JOIN Interviewer I  ON I.InterviewerCode = rtrim(ltrim(tmp.[InterviewerCode])) AND I.Country_Id = @CountryId		
		WHERE I.InterviewerCode IS NULL

		IF @@ROWCOUNT > 0
			SET  @IsErrorOccured  = 1

     
	 	DECLARE @QuestionnaireID int
		DECLARE @TableId bigint = 0;
		DECLARE @OldCompltionDate VARCHAR(40) ='';
		DECLARE @NewCompltionDate VARCHAR(40) ;


		IF EXISTS (SELECT 1 FROM @Temp_QuestionnaireData WHERE ProcessId = 5)
		BEGIN
			/*
			INSERT INTO [QB_DataImport].dbo.ERROR_LOG ([FileName],BusinessArea,SourceKey,Error_Description,ErrorDate,ProcessId)
			SELECT @FileName,'Group ID',GroupSequence,'Group Id does not Exist' ,@Getdate,@ProcessId
			FROM @Temp_QuestionnaireData WHERE ProcessId = 5
			*/
		INSERT INTO dbo.FileImportErrorLog
			(
			[FileName],
			CountryCode,
			PanelCode,
			ImportType,
			ErrorSource,
			ErrorCode,
			ErrorDescription,
			ErrorDate,
			JobId
			)
			SELECT 
			@FileName
			,@pCountryISO2A
			,NULL as PanelCode
			,@ImportType	
			,'Group ID'
			,GroupSequence
			,'Group Id does not Exist' 
			,@Getdate
			,@ProcessId
			FROM @Temp_QuestionnaireData
			WHERE ProcessId = 5

			IF @@ROWCOUNT > 0
				SET  @IsErrorOccured  = 1
		END

		SELECT @TotalCount  = COUNT(0) FROM [QB_DataImport].[dbo].Import_Questionnaire_Staging ;

         -------CompletionDate Validation

			update @Temp_QuestionnaireData set ProcessId = 3 Where ISDATE(CompletionDate) = 0
			UPDATE QB_DataImport.dbo.Import_Questionnaire_Staging  SET IsProcessed = 3	Where ISDATE(CompletionDate) = 0
				/*	
			INSERT INTO [QB_DataImport].dbo.ERROR_LOG ([FileName],BusinessArea,SourceKey,Error_Description,ErrorDate,ProcessId)
			SELECT @FileName,'Completion Date',GroupSequence,'Invalid Date format' ,@Getdate,@ProcessId
			FROM @Temp_QuestionnaireData 
			Where ISDATE(CompletionDate) = 0
			*/
			INSERT INTO dbo.FileImportErrorLog
			(
			[FileName],
			CountryCode,
			PanelCode,
			ImportType,
			ErrorSource,
			ErrorCode,
			ErrorDescription,
			ErrorDate,
			JobId
			)
			SELECT 
			@FileName
			,@pCountryISO2A
			,NULL as PanelCode
			,@ImportType	
			,'Completion Date'
			,GroupSequence
			,'Invalid Date format' 
			,@Getdate
			,@ProcessId
			FROM @Temp_QuestionnaireData 
			Where ISDATE(CompletionDate) = 0

			IF @@ROWCOUNT > 0
				SET  @IsErrorOccured  = 1

			---------------InvitationDate Validation

			update @Temp_QuestionnaireData set ProcessId = 4 Where ISDATE(InvitationDate) = 0
			UPDATE QB_DataImport.dbo.Import_Questionnaire_Staging  SET IsProcessed = 4	Where ISDATE(InvitationDate) = 0
					
			INSERT INTO dbo.FileImportErrorLog
			(
			[FileName],
			CountryCode,
			PanelCode,
			ImportType,
			ErrorSource,
			ErrorCode,
			ErrorDescription,
			ErrorDate,
			JobId
			)

			SELECT 
			@FileName
			,@pCountryISO2A
			,NULL as PanelCode
			,@ImportType	
			,'InvitationDate'
			,GroupSequence
			,'Invalid Date format' 
			,@Getdate
			,@ProcessId
			FROM @Temp_QuestionnaireData 
			Where ISDATE(InvitationDate) = 0

			 /*
		INSERT INTO [QB_DataImport].dbo.ERROR_LOG ([FileName],BusinessArea,SourceKey,Error_Description,ErrorDate,ProcessId)
		SELECT @FileName,'InvitationDate',GroupSequence,'Invalid Date format' ,@Getdate,@ProcessId
		FROM @Temp_QuestionnaireData 
		Where ISDATE(InvitationDate) = 0
		*/

		IF @@ROWCOUNT > 0
			SET  @IsErrorOccured  = 1

		WHILE (@IntCount < @TotalCount)
		BEGIN				
			BEGIN TRY
				select  Top 1 @ROWID =RowSeq from @Temp_QuestionnaireData where ProcessId = 0
				select @TableId = TableId from @Temp_QuestionnaireData WHERE RowSeq = @ROWID
				
				IF  @IsErrorOccured = 0
				BEGIN 
					IF NOT EXISTS(
							SELECT 1
							FROM Questionnaire  Q
							INNER JOIN @Temp_QuestionnaireData Tmp 
							ON  Tmp.SurveyName = Q.SurveyName and Q.CollaborationType = Tmp.[SourceType] and Q.QuestionnaireType = Tmp.QuestionnaireType
							WHERE RowSeq = @ROWID
					) 

					BEGIN
						INSERT INTO Questionnaire  (
						SurveyName,ClientName,ClientTeamPerson,QuestionnaireType,Department,Comment,CreationTimestamp,GPSUPdateTimestamp,GPSUser, CollaborationType)
						
						SELECT SurveyName, ClientName as ClientName,ClientTeamPerson as ClientTeamPerson
						,QuestionnaireType as QuestionnaireType,Department as Department,Comment as Comment
						,CreationTimestamp as CreationTimestamp,GPSUPdateTimestamp as GPSUPdateTimestamp,GPSUser as GPSUser
						,SourceType 
						FROM @Temp_QuestionnaireData WHERE RowSeq = @ROWID
					END

					SELECT @QuestionnaireID = Questionnaire_ID 
					FROM Questionnaire  Q
					INNER JOIN @Temp_QuestionnaireData Tmp 
					ON  Tmp.SurveyName = Q.SurveyName 
					and Q.CollaborationType = Tmp.[SourceType]
					and Q.QuestionnaireType = Tmp.QuestionnaireType
					WHERE RowSeq = @ROWID

			
					UPDATE @Temp_QuestionnaireData SET QuestionnaireID =  @QuestionnaireID WHERE RowSeq = @ROWID

                 If Exists(SELECT 1
							FROM QuestionnaireTransaction  QT
							INNER JOIN @Temp_QuestionnaireData Tmp 
							ON   QT.GroupContactId = Tmp.[GroupMainContact] 
							and QT.QuestionnaireID = Tmp.QuestionnaireID
							AND QT.InvitationDate=Tmp.InvitationDate 
							--AND Tmp.StateID <> QT.StateID
							WHERE RowSeq = @ROWID
					 )
					 BEGIN

					 UPDATE QT SET QT.CompletionDate=Tmp.CompletionDate,QT.CountryID=Tmp.CountryID,QT.StateID=Tmp.StateID
							,QT.GroupContactId=Tmp.GroupMainContact,QT.InterviewerId=TMP.InterviewerCode,QT.InvitationDate=Tmp.InvitationDate,
							QT.NumberofDays=Tmp.NumberofDays,QT.GPSUPdateTimestamp=TMP.GPSUPdateTimestamp,QT.PanelistName=Tmp.PanelistName
							,QT.QuestionnaireID=Tmp.QuestionnaireID,QT.UID=Tmp.UID
							FROM QuestionnaireTransaction  QT
							INNER JOIN @Temp_QuestionnaireData Tmp ON   QT.GroupContactId = Tmp.[GroupMainContact] 
							and QT.QuestionnaireID = Tmp.QuestionnaireID
							AND QT.InvitationDate=Tmp.InvitationDate 
							--AND Tmp.StateID <> QT.StateID
							WHERE RowSeq = @ROWID

								SET @ProcessedRows = @ProcessedRows + @@ROWCOUNT
					 END
				ELse
					BEGIN
							INSERT INTO QuestionnaireTransaction (PanelistID,CountryID,QuestionnaireID,InvitationDate
							,StateID,GPSUser,GPSUPdateTimestamp,CompletionDate,NumberofDays,GroupContactId, [UID],InterviewerId,PanelistName)
                             
							 SELECT PanelistID AS PanelistID,CountryID AS CountryID
							,@QuestionnaireID AS QuestionnaireID, InvitationDate AS InvitationDate
							,StateID AS StateID,GPSUser AS GPSUser,GPSUPdateTimestamp AS GPSUPdateTimestamp, CompletionDate, NumberofDays, GroupMainContact, [UID]
							,InterviewerCode,PanelistName 
							FROM @Temp_QuestionnaireData WHERE RowSeq = @ROWID
							
							SET @ProcessedRows = @ProcessedRows + @@ROWCOUNT
					END

					UPDATE QB_DataImport.dbo.Import_Questionnaire_Staging  SET IsProcessed = 1	WHERE SLNO = @TableId
				END
				 
				update @Temp_QuestionnaireData set ProcessId = 1 where RowSeq = @ROWID
			END TRY

			BEGIN CATCH
				select ERROR_MESSAGE() as ErrorMessage

				UPDATE QB_DataImport.dbo.Import_Questionnaire_Staging  SET IsProcessed = 2	WHERE SLNO = @TableId
				/*
				INSERT INTO [QB_DataImport].dbo.ERROR_LOG ([FileName],BusinessArea,SourceKey,Error_Description,ErrorDate,ProcessId)
				SELECT @FileName,'LOOP ERROR',@ROWID,'ERROR OCCURED -' + ERROR_MESSAGE(),@Getdate,@ProcessId
				*/
				INSERT INTO dbo.FileImportErrorLog
				(
				[FileName],
				CountryCode,
				PanelCode,
				ImportType,
				ErrorSource,
				ErrorCode,
				ErrorDescription,
				ErrorDate,
				JobId
				)

				SELECT 
				@FileName
				,@pCountryISO2A
				,NULL as PanelCode
				,@ImportType	
				,'LOOP ERROR'
				,@ROWID
				,'ERROR OCCURED -' + ERROR_MESSAGE()
				,@Getdate
				,@ProcessId
			 
			END CATCH

			SET @IntCount = @IntCount + 1
		END -- CLOSE WHILE
		
	END TRY

	BEGIN CATCH
		/*
		INSERT INTO [QB_DataImport].dbo.ERROR_LOG ([FileName],BusinessArea,SourceKey,Error_Description,ErrorDate,ProcessId)
		SELECT 'QuestionnaireName','GLOBAL ERROR',@GroupSequence,'ERROR OCCURED -' + ERROR_MESSAGE(),@Getdate,@ProcessId
		*/
		INSERT INTO dbo.FileImportErrorLog
			(
			[FileName],
			CountryCode,
			PanelCode,
			ImportType,
			ErrorSource,
			ErrorCode,
			ErrorDescription,
			ErrorDate,
			JobId
			)

			SELECT 
			@FileName
			,@pCountryISO2A
			,NULL as PanelCode
			,@ImportType	
			,'GLOBAL ERROR'
			,@GroupSequence
			,'ERROR OCCURED -' + ERROR_MESSAGE()
			,@Getdate
			,@ProcessId
		
	END CATCH


	print '[FileImportAuditSummary]'
	IF NOT EXISTS (select 1 from FileImportErrorLog Where JobId = @ProcessId )
	BEGIN
		UPDATE [DBO].[FileImportAuditSummary] 
		SET  Comments = convert(varchar(20), @ProcessedRows) + ' Row(s) Processed.'
		,[Status] = 'Completed'  
		,ImportType = @ImportType
		WHERE  JobId = @ProcessId;

	END
	ELSE 
	BEGIN
		UPDATE [DBO].[FileImportAuditSummary] 
		SET  [Status] = 'Error'  
		,Comments = 'Input file has errors.'
		,ImportType = @ImportType
		WHERE  JobId = @ProcessId
	END
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
GO
