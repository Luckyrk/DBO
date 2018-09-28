
CREATE PROCEDURE [dbo].[PanelistBulkInsert] (
		@pPanelistUserType PanelistUserType READONLY
	,@DyniamicRoles DynamicRolesImportFeed READONLY
		,@pCountryId UNIQUEIDENTIFIER
		,@pUser NVARCHAR(200)
		,@pFileId UNIQUEIDENTIFIER
		,@pCultureCode INT
		,@pSystemDate DATETIME
	)
AS
BEGIN
		SET NOCOUNT ON;

	DECLARE @COLUMNNUMBER INT = 0
	DECLARE @Error BIT

		SET @Error = 0
  
		DECLARE @CountryId UNIQUEIDENTIFIER
	DECLARE @GPSUser VARCHAR(100) = 'GPSUser'

	SET @CountryId = @pCountryId;
	SET @GPSUser = @pUser;

	DECLARE @GetDate DATETIME

		SET @GetDate = GETDATE()		
	SET @GetDate = (
			SELECT dbo.GetLocalDateTimeByCountryId(@GetDate, @CountryId)
			)

	DECLARE @dropOutStateValue VARCHAR(100) = 'PANELISTDROPPEDOFFSTATE';
	DECLARE @refusalStateValue VARCHAR(100) = 'PANELISTREFUSALSTATE';

	IF NOT EXISTS (
			SELECT 1
			FROM ImportFile I
			INNER JOIN StateDefinition SD ON SD.Id = I.State_Id
				AND I.GUIDReference = @pFileId
			WHERE SD.Code = 'ImportFileProcessing'
				AND SD.Country_Id = @CountryId
			)
		BEGIN
			INSERT INTO ImportAudit
		VALUES (
			NEWID()
			,1
			,1
			,'File already is processed'
			,@GetDate
			,NULL
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
			)

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@GPSUser
			,@pFileId
			,@CountryId

			RETURN;
		END
	
		/**/
		DECLARE @individualNonParticipent UNIQUEIDENTIFIER = NULL

	SET @individualNonParticipent = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'IndividualNonParticipant'
				AND Country_Id = @CountryId
			)

	DECLARE @PanelistDefaultStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistPresetedStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistLiveStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistDropoutStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistRefusalStateId AS UNIQUEIDENTIFIER
	DECLARE @IndividualCandidate AS UNIQUEIDENTIFIER

	SET @IndividualCandidate = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'IndividualCandidate'
				AND Country_Id = @CountryId
			)

	SELECT @PanelistPresetedStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistPresetedState'
		AND Country_Id = @CountryId

	SELECT @PanelistDefaultStateId = (
			SELECT TOP 1 st.ToState_Id
			FROM statedefinition sd
			INNER JOIN StateDefinitionsTransitions SDT ON SDT.StateDefinition_Id = SD.Id
			INNER JOIN StateTransition st ON st.Id = sdt.AvailableTransition_Id
			INNER JOIN Country C ON C.CountryId = sd.Country_Id
			WHERE sd.code = 'PanelistPresetedState'
				AND c.CountryId = @CountryId
			ORDER BY st.CreationTimeStamp
				,st.[Priority]
			)

	SELECT @PanelistLiveStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistLiveState'
		AND Country_Id = @CountryId

	SELECT @PanelistDropoutStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistDroppedOffState'
		AND Country_Id = @CountryId

	SELECT @PanelistRefusalStateId = Id
		FROM StateDefinition
	WHERE Code = 'PanelistRefusalState'
		AND Country_Id = @CountryId
		
	DECLARE @MainContactGUID UNIQUEIDENTIFIER
		DECLARE @individualAssignedGuid UNIQUEIDENTIFIER

	SET @individualAssignedGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'IndividualAssigned'
				AND Country_Id = @CountryId
			)

	SELECT @MainContactGUID = DR.DynamicRoleId
	FROM DynamicRole DR
			INNER JOIN Translation TR ON DR.Translation_Id = TR.TranslationId 
	WHERE TR.KeyName = 'MainContact'
		AND DR.Country_Id = @CountryId

		DECLARE @individualParticipent UNIQUEIDENTIFIER = NULL

	SET @individualParticipent = (
			SELECT Id
		FROM StateDefinition
		WHERE Code = 'IndividualParticipant'
				AND Country_Id = @CountryId
			)
		
		DECLARE @individualDropOf UNIQUEIDENTIFIER = NULL

	SET @individualDropOf = (
			SELECT Id
		FROM StateDefinition
		WHERE Code = 'IndividualTerminated'
				AND Country_Id = @CountryId
			)

	DECLARE @groupStatusGuid UNIQUEIDENTIFIER
	DECLARE @groupAssignedStatusGuid UNIQUEIDENTIFIER
		DECLARE @groupParticipantStatusGuid UNIQUEIDENTIFIER
	DECLARE @groupTerminatedStatusGuid UNIQUEIDENTIFIER
	DECLARE @existingroupStatusGuid UNIQUEIDENTIFIER

	SET @groupAssignedStatusGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'GroupAssigned'
				AND Country_Id = @CountryId
			)
	SET @groupParticipantStatusGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'GroupParticipant'
				AND Country_Id = @CountryId
			)
	SET @groupTerminatedStatusGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'GroupTerminated'
				AND Country_Id = @CountryId
			)
	SET @groupStatusGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'GroupCandidate'
				AND Country_Id = @CountryId
			)
	SET @existingroupStatusGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'GroupPreseted'
				AND Country_Id = @CountryId
			)

		CREATE TABLE #Panelist (
		RowIndex INT IDENTITY(1, 1)
		,Rownumber INT NULL
		,[IndividualBusinessId] [nvarchar](MAX) Collate Database_Default NOT NULL
		,[PanelCode] [nvarchar](MAX) Collate Database_Default NOT NULL
		,[ExpectedKitCode] [nvarchar](MAX) Collate Database_Default NULL
		,[SignUpDate] [nvarchar](MAX) Collate Database_Default NULL
		,[State] [nvarchar](MAX) Collate Database_Default NULL
		,[CollaborationMethodologyCode] [nvarchar](MAX) Collate Database_Default NULL
		,[CollaborationMethodologyChangeReasonCode] [nvarchar](MAX) Collate Database_Default NULL
		,[CollaborationMethodologyChangeComments] [nvarchar](MAX) Collate Database_Default NULL
		,[StateChangeComments] [nvarchar](MAX) Collate Database_Default NULL
		,[MethodologyChangeDate] [nvarchar](MAX) Collate Database_Default NULL
		,[PanelTaskNameOrCode] [nvarchar](MAX) Collate Database_Default NULL
		,[PanelTaskIsRemoved] [nvarchar](MAX) Collate Database_Default NULL
		,[PanelTaskDateFrom] [nvarchar](MAX) Collate Database_Default NULL
		,PanelTaskDateTo [nvarchar](MAX) Collate Database_Default NULL
		,ReasonCodeForChangeStatus [nvarchar](MAX) Collate Database_Default NULL
		,ReasonForChangeStatus [nvarchar](MAX) Collate Database_Default NULL
		,CollaborateInFuture [nvarchar](MAX) Collate Database_Default NULL
		,StateDefinitionId [NVARCHAR](MAX) Collate Database_Default NULL
		,PanelType VARCHAR(100) Collate Database_Default NULL
		,PanelId VARCHAR(100) Collate Database_Default NULL
		,PanelistId VARCHAR(100) Collate Database_Default NULL
		,NewPanelistId VARCHAR(100) Collate Database_Default NULL
		,IndividualId VARCHAR(100) Collate Database_Default NULL
		,CollaborationMethodologyId VARCHAR(100) Collate Database_Default NULL
		,CollaborationMethodologyReasonId VARCHAR(100) Collate Database_Default NULL
		,ExpectedKitId VARCHAR(100) Collate Database_Default NULL
		,SurveyParticipationTaskId VARCHAR(100) Collate Database_Default NULL
		,PanelSurveyParticipationTask VARCHAR(100) Collate Database_Default NULL
		,PanelSurveyParticipationTaskActiveFromDate DATETIME NULL
		,PanelSurveyParticipationTaskActiveToDate DATETIME NULL
		,GroupId VARCHAR(100) Collate Database_Default NULL
		,IndividualGUID UNIQUEIDENTIFIER NULL
		,GroupGUID UNIQUEIDENTIFIER NULL
		,[StateChangeDate] [nvarchar](MAX) Collate Database_Default NULL
		,[FullRow] [NVARCHAR](MAX) Collate Database_Default NULL
		)

		-- Insert Values to Temp Table
	INSERT INTO #Panelist (
		Rownumber
		,[IndividualBusinessId]
		,[PanelCode]
		,[ExpectedKitCode]
		,[SignUpDate]
		,[State]
		,[CollaborationMethodologyCode]
		,[CollaborationMethodologyChangeReasonCode]
		,[CollaborationMethodologyChangeComments]
		,[StateChangeComments]
		,[MethodologyChangeDate]
		,[PanelTaskNameOrCode]
		,[PanelTaskIsRemoved]
		,[PanelTaskDateFrom]
		,PanelTaskDateTo
		,ReasonCodeForChangeStatus
		,ReasonForChangeStatus
		,CollaborateInFuture
		,[StateChangeDate]
		,[FullRow]
		)
	SELECT Rownumber
		,[IndividualBusinessId]
		,[PanelCode]
		,[ExpectedKitCode]
		,CAST([SignUpDate] AS DATETIME)
		,[State]
		,[CollaborationMethodologyCode]
		,[CollaborationMethodologyChangeReasonCode]
		,[CollaborationMethodologyChangeComments]
		,[StateChangeComments]
		,[MethodologyChangeDate]
		,[PanelTaskNameOrCode]
		,[PanelTaskIsRemoved]
		,[PanelTaskDateFrom]
		,PanelTaskDateTo
		,ReasonCodeForChangeStatus
		,ReasonForChangeStatus
		,CollaborateInFuture
		,[StateChangeDate]
		,[FullRow]
		FROM @pPanelistUserType P

		-- Update Sate Definition to Temp Table
		UPDATE P
			SET StateDefinitionId = SD.Id
		FROM #Panelist P
			INNER JOIN TranslationTerm TT ON TT.Value = P.[State]
			INNER JOIN Statedefinition SD ON SD.Label_Id = TT.Translation_Id
	WHERE SD.Country_Id = @CountryId
		AND TT.CultureCode = @pCultureCode
		AND SD.Code LIKE 'Panelist%'

		-- Update Panel & Panel Type
		UPDATE PL
	SET PL.PanelType = P.[Type]
		,PL.PanelId = P.GUIDReference
		FROM #Panelist PL
			INNER JOIN Panel P ON P.PanelCode = PL.PanelCode
		WHERE P.Country_Id = @CountryId

		UPDATE PL
			SET PL.IndividualGUID = I.GUIDReference
		FROM #Panelist PL
			INNER JOIN Individual I ON I.IndividualId = PL.IndividualBusinessId
		WHERE i.CountryId = @CountryId

		-- Update Panelist GUID , its required to validate only
		UPDATE PL
			SET PL.PanelistId = P.GUIDReference
		FROM #Panelist PL
			INNER JOIN Individual I ON I.IndividualId = PL.IndividualBusinessId
	INNER JOIN Panelist P ON P.PanelMember_Id = I.GUIDReference
		AND P.Panel_Id = PL.PanelId
		WHERE UPPER(PL.PanelType) = UPPER('Individual')
		AND I.CountryId = @CountryId
		
		-- Update Panelist GUID , its required to validate only
		UPDATE PL
			SET PL.PanelistId = P.GUIDReference
		FROM #Panelist PL
			INNER JOIN Individual I ON I.IndividualId = PL.IndividualBusinessId
			INNER JOIN CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
	INNER JOIN Panelist P ON P.PanelMember_Id = CM.Group_Id
		AND P.Panel_Id = PL.PanelId
		WHERE UPPER(PL.PanelType) = UPPER('HouseHold')
		AND I.CountryId = @CountryId

		-- update individual Id to the temp table,if panel is a individual
		UPDATE PL
			SET PL.IndividualId = I.GUIDReference
		FROM #Panelist PL
			INNER JOIN Individual I ON I.IndividualId = PL.IndividualBusinessId
		WHERE UPPER(PL.PanelType) = UPPER('Individual') 
		AND I.CountryId = @CountryId

		-- update group to temp if panel is a House Hold
		UPDATE PL
	SET PL.IndividualId = CM.Group_Id
		,PL.GroupId = CM.Group_Id
		FROM #Panelist PL
			INNER JOIN Individual I ON I.IndividualId = PL.IndividualBusinessId
			INNER JOIN CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
		WHERE UPPER(PL.PanelType) = UPPER('HouseHold') 
		AND I.CountryId = @CountryId

		-- update CollaborationMethodologyReasonId to temp table
		UPDATE PL
			SET PL.CollaborationMethodologyReasonId = CMR.ChangeReasonId
		FROM #Panelist PL
	INNER JOIN CollaborationMethodologyChangeReason CMR ON CMR.Code = PL.CollaborationMethodologyChangeReasonCode
		AND CMR.Country_Id = @CountryId

		-- update CollaborationMethodologyId to temp table
		UPDATE PL
			SET PL.CollaborationMethodologyId = CMR.GUIDReference
		FROM #Panelist PL
	INNER JOIN CollaborationMethodology CMR ON CMR.Code = PL.CollaborationMethodologyCode
		AND CMR.Country_Id = @CountryId

		-- update StockKit to temp table
		UPDATE PL
			SET PL.ExpectedKitId = CMR.GUIDReference
		FROM #Panelist PL
	INNER JOIN StockKit CMR ON CMR.Code = PL.ExpectedKitCode
		AND CMR.Country_Id = @CountryId

		-- update SurveyParticipationTaskId to temp table
		UPDATE PL
			SET PL.SurveyParticipationTaskId = CMR.SurveyParticipationTaskId
		FROM #Panelist PL
	INNER JOIN SurveyParticipationTask CMR ON (
			CMR.Code = PL.PanelTaskNameOrCode
			OR CMR.NAME = PL.PanelTaskNameOrCode
			)
		AND CMR.Country_Id = @CountryId
		AND PL.PanelTaskNameOrCode IS NOT NULL

		UPDATE PL
	SET PL.PanelSurveyParticipationTask = PST.PanelSurveyParticipationTaskId
		,PL.PanelSurveyParticipationTaskActiveFromDate = PST.ActiveFrom
		,PL.PanelSurveyParticipationTaskActiveToDate = PST.ActiveTo
		FROM #Panelist PL
			INNER JOIN SurveyParticipationTask CMR ON CMR.Code = PL.PanelTaskNameOrCode
	INNER JOIN PanelSurveyParticipationTask PST ON PST.Task_Id = CMR.SurveyParticipationTaskId
		AND PST.Panel_Id = PL.PanelId
		AND CMR.Country_Id = @CountryId
		AND PL.PanelTaskNameOrCode IS NOT NULL

		-- Validation 1 : Individual exists validation / Code : VerifyBasicFields Method
	IF EXISTS (
			SELECT 1
			FROM #Panelist P
			LEFT JOIN Individual I ON I.IndividualId = p.IndividualBusinessId
				AND I.CountryId = @CountryId
			WHERE I.IndividualId IS NULL
			)
		BEGIN
			SET @Error = 1

			PRINT '1'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'The individual does not exist At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
			FROM #Panelist P 
		LEFT JOIN Individual I ON I.IndividualId = p.IndividualBusinessId
			AND I.CountryId = @CountryId
			WHERE I.IndividualId IS NULL
		END

		-- Validation 1 :  panel code validation  / Code : VerifyBasicFields Method
	IF EXISTS (
			SELECT 1
			FROM #Panelist P
			LEFT JOIN Panel Pn ON Pn.PanelCode = P.PanelCode
				AND Pn.Country_Id = @CountryId
			WHERE Pn.PanelCode IS NULL
			)
		BEGIN
			SET @Error = 2

			PRINT '2'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'The panel does not exist At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
			FROM #Panelist P 
		LEFT JOIN Panel Pn ON Pn.PanelCode = P.PanelCode
			AND Pn.Country_Id = @CountryId
			WHERE Pn.PanelCode IS NULL
		END

		-- Validation 1 :  validation for given state value if state is passed and that not existed in DB / Code : VerifyBasicFields Method
	IF EXISTS (
			SELECT 1
			FROM @pPanelistUserType
			WHERE [State] IS NOT NULL
				OR LEN([State]) > 0
			)
		AND EXISTS (
			SELECT 1
			FROM #Panelist P
			WHERE P.StateDefinitionId IS NULL
			)
		BEGIN
			SET @Error = 3

			PRINT '3'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'Please provide valid state for individuals At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
		FROM #Panelist P
		WHERE P.StateDefinitionId IS NULL
			AND EXISTS (
				SELECT 1
				FROM @pPanelistUserType
				WHERE [State] IS NOT NULL
					AND LEN([State]) > 0
				)
		END

		-- Validation 1 :  validation for CollaborateInFuture  / Code : VerifyBasicFields Method
	IF EXISTS (
			SELECT 1
		FROM #Panelist P
			WHERE P.[StateDefinitionId] IN (
					@PanelistDropoutStateId
					,@PanelistRefusalStateId
					)
				AND (
					P.CollaborateInFuture IS NOT NULL
					OR LEN(LTRIM(RTRIM(P.CollaborateInFuture))) > 0
					)
				AND UPPER(P.CollaborateInFuture) NOT IN (
					'YES'
					,'NO'
					,'TRUE'
					,'FALSE'
					,'1'
					,'0'
					)
			)
		BEGIN
		SET @Error = 4

		PRINT '4'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'Please provide valid Collaborate In Future value for Drop Out At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
		FROM #Panelist P
		WHERE P.StateDefinitionId IS NULL
		END

		-- Validation 1 :  Collaborate In Future for wrong State  / Code : VerifyBasicFields Method
	IF EXISTS (
			SELECT 1
		FROM #Panelist P
			WHERE P.[StateDefinitionId] NOT IN (
					@PanelistDropoutStateId
					,@PanelistRefusalStateId
					)
				AND (
					P.CollaborateInFuture IS NOT NULL
					OR LEN(LTRIM(RTRIM(P.CollaborateInFuture))) > 0
					)
			)
		BEGIN
		SET @Error = 5

		PRINT '5'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'Collaborate In Future for wrong State At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
		FROM #Panelist P
		WHERE P.StateDefinitionId IS NULL
		END
		
		-- Validation 1 :  Collaborate In Future requires State  / Code : VerifyBasicFields Method
	IF EXISTS (
			SELECT 1
		FROM #Panelist P
		WHERE P.CollaborateInFuture IS NOT NULL
				AND (
					P.[State] IS NULL
					OR LEN(LTRIM(RTRIM(P.[State]))) = 0
					)
			)
		BEGIN
		SET @Error = 6

		PRINT '6'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'Collaborate In Future requires State At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
		FROM #Panelist P
		WHERE P.StateDefinitionId IS NULL
		END

		-- Validation 2 :  Collaborate In Future requires State  / Code : CheckPanelistStateChangeCommentsRequired Method
	IF EXISTS (
			SELECT 1
		FROM #Panelist P
		WHERE P.[StateChangeComments] IS NOT NULL
				AND (
					P.[State] IS NULL
					OR LEN(LTRIM(RTRIM(P.[State]))) = 0
					)
			)
		BEGIN
		SET @Error = 7

		PRINT '7'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'Panelist State is Required At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
		FROM #Panelist P
		WHERE P.[StateChangeComments] IS NOT NULL
			AND (
				P.[State] IS NULL
				OR LEN(LTRIM(RTRIM(P.[State]))) = 0
				)
		END

		-- Validation 3 :  Collaboration Reason Code Missed  / Code : VerifyCollaborationMethodogyFields/CheckCollaborationCode Method
	IF EXISTS (
			SELECT 1
		FROM #Panelist P
			WHERE P.CollaborationMethodologyCode IS NOT NULL
			)
		BEGIN
		IF EXISTS (
				SELECT 1
		FROM #Panelist P
		WHERE P.CollaborationMethodologyChangeReasonCode IS NULL
					OR LEN(RTRIM(LTRIM(P.CollaborationMethodologyChangeReasonCode))) = 0
				)
		BEGIN
		SET @Error = 8

		PRINT '8'

			INSERT INTO ImportAudit (
				GUIDReference
				,Error
				,IsInvalid
				,[Message]
				,[Date]
				,SerializedRowData
				,SerializedRowErrors
				,CreationTimeStamp
				,GPSUser
				,GPSUpdateTimestamp
				,[File_Id]
				)
			SELECT NEWID()
				,1
				,0
				,'Collaboration Reason Code Missed At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
				,@GetDate
				,[FullRow]
				,NULL
				,@GetDate
				,@GPSUser
				,@GetDate
				,@pFileId
		FROM #Panelist P
		WHERE P.[StateChangeComments] IS NOT NULL
				AND (
					P.[State] IS NULL
					OR LEN(LTRIM(RTRIM(P.[State]))) = 0
					)
		END

		IF EXISTS (
				SELECT 1
		FROM #Panelist P
		WHERE P.MethodologyChangeDate IS NULL
					OR LEN(LTRIM(RTRIM(P.MethodologyChangeDate))) = 0
				)
		BEGIN
		SET @Error = 9

		PRINT '9'

			INSERT INTO ImportAudit (
				GUIDReference
				,Error
				,IsInvalid
				,[Message]
				,[Date]
				,SerializedRowData
				,SerializedRowErrors
				,CreationTimeStamp
				,GPSUser
				,GPSUpdateTimestamp
				,[File_Id]
				)
			SELECT NEWID()
				,1
				,0
				,'Collaboration Methodology change date Required At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
				,@GetDate
				,[FullRow]
				,NULL
				,@GetDate
				,@GPSUser
				,@GetDate
				,@pFileId
		FROM #Panelist P
		WHERE P.[StateChangeComments] IS NOT NULL
				AND (
					P.[State] IS NULL
					OR LEN(LTRIM(RTRIM(P.[State]))) = 0
					)
		END
		END

		-- Validation 3 :  Collaboration Methodology change date Required  / Code : VerifyCollaborationMethodogyFields/CheckCollaborationCode Method
	IF EXISTS (
			SELECT 1
		FROM #Panelist P
			WHERE P.CollaborationMethodologyCode IS NOT NULL
			)
		BEGIN
		IF EXISTS (
				SELECT 1
		FROM @pPanelistUserType P
				WHERE P.MethodologyChangeDate IS NULL
				)
		BEGIN
		SET @Error = 10

		PRINT '10'

			INSERT INTO ImportAudit (
				GUIDReference
				,Error
				,IsInvalid
				,[Message]
				,[Date]
				,SerializedRowData
				,SerializedRowErrors
				,CreationTimeStamp
				,GPSUser
				,GPSUpdateTimestamp
				,[File_Id]
				)
			SELECT NEWID()
				,1
				,0
				,'Collaboration Methodology change date Required At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
				,@GetDate
				,[FullRow]
				,NULL
				,@GetDate
				,@GPSUser
				,@GetDate
				,@pFileId
		FROM @pPanelistUserType P
		WHERE P.MethodologyChangeDate IS NULL
		END

		IF EXISTS (
				SELECT 1
		FROM #Panelist P
		WHERE P.MethodologyChangeDate IS NULL
					OR LEN(LTRIM(RTRIM(P.MethodologyChangeDate))) = 0
				)
		BEGIN
		SET @Error = 11

		PRINT '11'

			INSERT INTO ImportAudit (
				GUIDReference
				,Error
				,IsInvalid
				,[Message]
				,[Date]
				,SerializedRowData
				,SerializedRowErrors
				,CreationTimeStamp
				,GPSUser
				,GPSUpdateTimestamp
				,[File_Id]
				)
			SELECT NEWID()
				,1
				,0
				,'Collaboration Methodology change date Required At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
				,@GetDate
				,[FullRow]
				,NULL
				,@GetDate
				,@GPSUser
				,@GetDate
				,@pFileId
		FROM #Panelist P
		WHERE P.[StateChangeComments] IS NOT NULL
				AND (
					P.[State] IS NULL
					OR LEN(LTRIM(RTRIM(P.[State]))) = 0
					)
		END
		END

		-- Validation 3 :   Code : VerifyCollaborationMethodogyFields/CheckCollaborationDate=>1.CheckCollaborationCodeRequired Method
	IF EXISTS (
			SELECT 1
		FROM #Panelist P
			WHERE P.MethodologyChangeDate IS NOT NULL
			)
		BEGIN
		IF EXISTS (
				SELECT 1
		FROM #Panelist P
				WHERE P.CollaborationMethodologyCode IS NULL
				)
		BEGIN
		SET @Error = 12

		PRINT '12'

			INSERT INTO ImportAudit (
				GUIDReference
				,Error
				,IsInvalid
				,[Message]
				,[Date]
				,SerializedRowData
				,SerializedRowErrors
				,CreationTimeStamp
				,GPSUser
				,GPSUpdateTimestamp
				,[File_Id]
				)
			SELECT NEWID()
				,1
				,0
				,'Collaboration Methodology Code Required At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
				,@GetDate
				,[FullRow]
				,NULL
				,@GetDate
				,@GPSUser
				,@GetDate
				,@pFileId
		FROM #Panelist P
		WHERE P.CollaborationMethodologyCode IS NULL
		END

		IF EXISTS (
				SELECT 1
		FROM #Panelist P
				WHERE CAST(P.MethodologyChangeDate AS DATETIME) > @GetDate
				)
		BEGIN
		SET @Error = 13

		PRINT '13'

			INSERT INTO ImportAudit (
				GUIDReference
				,Error
				,IsInvalid
				,[Message]
				,[Date]
				,SerializedRowData
				,SerializedRowErrors
				,CreationTimeStamp
				,GPSUser
				,GPSUpdateTimestamp
				,[File_Id]
				)
			SELECT NEWID()
				,1
				,0
				,'Methodology Change Date cannot be a future date At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
				,@GetDate
				,[FullRow]
				,NULL
				,@GetDate
				,@GPSUser
				,@GetDate
				,@pFileId
		FROM #Panelist P
			WHERE CAST(P.MethodologyChangeDate AS DATETIME) > @GetDate
		END
		END

		-- Validation 3 :  Code : CheckReasonCode/CheckReasonCode/CheckCollaborationCodeRequired Method
	IF EXISTS (
			SELECT 1
		FROM #Panelist P
			WHERE P.CollaborationMethodologyChangeReasonCode IS NOT NULL
			)
		BEGIN
		IF EXISTS (
				SELECT 1
		FROM #Panelist P
				WHERE P.CollaborationMethodologyCode IS NULL
				)
		BEGIN
		SET @Error = 14

		PRINT '14'

			INSERT INTO ImportAudit (
				GUIDReference
				,Error
				,IsInvalid
				,[Message]
				,[Date]
				,SerializedRowData
				,SerializedRowErrors
				,CreationTimeStamp
				,GPSUser
				,GPSUpdateTimestamp
				,[File_Id]
				)
			SELECT NEWID()
				,1
				,0
				,'Collaboration Methodology Code Required At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
				,@GetDate
				,[FullRow]
				,NULL
				,@GetDate
				,@GPSUser
				,@GetDate
				,@pFileId
		FROM #Panelist P
		WHERE P.CollaborationMethodologyCode IS NULL
		END
		END

		-- Validation 3 :  Code : CheckReasonCode/CheckComments/CheckCollaborationCodeRequired Method
	IF EXISTS (
			SELECT 1
		FROM #Panelist P
			WHERE P.CollaborationMethodologyChangeComments IS NOT NULL
			)
		BEGIN
		IF EXISTS (
				SELECT 1
		FROM #Panelist P
				WHERE P.CollaborationMethodologyCode IS NULL
				)
		BEGIN
		SET @Error = 15

		PRINT '15'

			INSERT INTO ImportAudit (
				GUIDReference
				,Error
				,IsInvalid
				,[Message]
				,[Date]
				,SerializedRowData
				,SerializedRowErrors
				,CreationTimeStamp
				,GPSUser
				,GPSUpdateTimestamp
				,[File_Id]
				)
			SELECT NEWID()
				,1
				,0
				,'Collaboration Methodology Code Required At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
				,@GetDate
				,[FullRow]
				,NULL
				,@GetDate
				,@GPSUser
				,@GetDate
				,@pFileId
		FROM #Panelist P
		WHERE P.CollaborationMethodologyCode IS NULL
		END
		END

		-- Validation 4 :  The panelist already exists / Code : EnsurePanelistDoesNotExists Method
	IF EXISTS (
			SELECT 1
			FROM #Panelist P
			WHERE P.PanelistId IS NOT NULL
			)
		BEGIN
		SET @Error = 16

			PRINT '16'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'The panelist already exists At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
		FROM #Panelist P
		WHERE P.PanelistId IS NOT NULL
		END

		---Panel Task Operation Not Recognized
	IF EXISTS (
			SELECT 1
			FROM #Panelist P
			WHERE P.SurveyParticipationTaskId IS NULL
				AND P.PanelTaskNameOrCode IS NOT NULL
			)
		BEGIN
		SET @Error = 17
			
			PRINT '17'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'Panel Task Not Found At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
			FROM #Panelist P
		WHERE P.SurveyParticipationTaskId IS NULL
			AND P.PanelTaskNameOrCode IS NOT NULL
		END

	IF EXISTS (
			SELECT 1
		FROM #Panelist P
		WHERE P.PanelSurveyParticipationTask IS NULL 
				AND P.PanelTaskNameOrCode IS NOT NULL
			)
		BEGIN
		SET @Error = 17

			PRINT '17'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'Panel Task Association Not Found At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
		FROM #Panelist P
		WHERE P.PanelSurveyParticipationTask IS NULL
			AND P.PanelTaskNameOrCode IS NOT NULL
		END

	IF EXISTS (
			SELECT 1
		FROM #Panelist P
		WHERE P.PanelTaskIsRemoved IS NOT NULL
				AND UPPER(P.PanelTaskIsRemoved) NOT IN (
					'1'
					,'0'
					,'YES'
					,'NO'
					,'TRUE'
					,'FASLE'
					)
			)
		BEGIN
		SET @Error = 171

			PRINT '17.1'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'Panel Task Operation Not Recognized At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
			FROM #Panelist P
				WHERE P.PanelTaskIsRemoved IS NOT NULL
			AND UPPER(P.PanelTaskIsRemoved) NOT IN (
				'1'
				,'0'
				,'YES'
				,'NO'
				,'TRUE'
				,'FASLE'
				)
		END

	IF EXISTS (
			SELECT 1
			FROM #Panelist P
			WHERE UPPER(P.PanelTaskIsRemoved) NOT IN (
					'0'
					,'NO'
					,'FASLE'
					)
				AND (
					(
						(P.PanelTaskDateFrom IS NOT NULL)
						AND (P.PanelTaskDateFrom < P.PanelSurveyParticipationTaskActiveFromDate)
						)
					OR (
						(
							P.PanelTaskDateTo IS NOT NULL
							AND P.PanelSurveyParticipationTaskActiveToDate IS NOT NULL
							)
						AND (P.PanelTaskDateTo > P.PanelSurveyParticipationTaskActiveToDate)
						)
					OR (
					(
							P.PanelTaskDateFrom IS NOT NULL
							AND P.PanelTaskDateTo IS NOT NULL
							)
						AND (P.PanelTaskDateFrom > P.PanelTaskDateTo)
						)
					)
		)
		BEGIN
		SET @Error = 172

			PRINT '17.2'
			
		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'The task date assignment is out of the range of the panel task At Row '+  CONVERT(VARCHAR, P.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
		FROM #Panelist P
		WHERE UPPER(P.PanelTaskIsRemoved) NOT IN (
				'0'
				,'NO'
				,'FASLE'
				)
			AND (
				(
					(P.PanelTaskDateFrom IS NOT NULL)
					AND (P.PanelTaskDateFrom < P.PanelSurveyParticipationTaskActiveFromDate)
					)
				OR (
					(
						P.PanelTaskDateTo IS NOT NULL
						AND P.PanelSurveyParticipationTaskActiveToDate IS NOT NULL
						)
					AND (P.PanelTaskDateTo > P.PanelSurveyParticipationTaskActiveToDate)
					)
				OR (
				(
						P.PanelTaskDateFrom IS NOT NULL
						AND P.PanelTaskDateTo IS NOT NULL
						)
					AND (P.PanelTaskDateFrom > P.PanelTaskDateTo)
					)
				)
		END

		-- Validation 5 :  given Collaboration Methodology not exists / Code : AssignCollaborationMethodology Method
	IF EXISTS (
			SELECT 1
			FROM @pPanelistUserType PT
		LEFT JOIN CollaborationMethodology CM ON PT.CollaborationMethodologyCode = CM.Code
				AND CM.Country_Id = @CountryId
			WHERE PT.CollaborationMethodologyCode IS NOT NULL
				AND LEN(PT.CollaborationMethodologyCode) > 0
				AND CM.Code IS NULL
			)
		BEGIN
		SET @Error = 18
		
			PRINT '18'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'Collaboration Methodology not found At Row '+  CONVERT(VARCHAR, PT.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
			FROM @pPanelistUserType PT
		LEFT JOIN CollaborationMethodology CM ON PT.CollaborationMethodologyCode = CM.Code
			AND CM.Country_Id = @CountryId
		WHERE PT.CollaborationMethodologyCode IS NOT NULL
			AND LEN(PT.CollaborationMethodologyCode) > 0
			AND CM.Code IS NULL
		END

		-- Validation 5 :  given Collaboration Methodology Reason not found / Code : AssignCollaborationMethodology Method
	IF EXISTS (
			SELECT 1
			FROM @pPanelistUserType PT
			LEFT JOIN CollaborationMethodologyChangeReason CM ON PT.CollaborationMethodologyChangeReasonCode = CM.Code
				AND CM.Country_Id = @CountryId
			WHERE PT.CollaborationMethodologyChangeReasonCode IS NOT NULL
				AND LEN(PT.CollaborationMethodologyChangeReasonCode) > 0
				AND CM.Code IS NULL
			)
		BEGIN
			SET @Error = 19

			PRINT '19'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'Reason not found At Row '+  CONVERT(VARCHAR, PT.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
			FROM @pPanelistUserType PT
		LEFT JOIN CollaborationMethodologyChangeReason CM ON PT.CollaborationMethodologyChangeReasonCode = CM.Code
			AND CM.Country_Id = @CountryId
		WHERE PT.CollaborationMethodologyChangeReasonCode IS NOT NULL
			AND LEN(PT.CollaborationMethodologyChangeReasonCode) > 0
			AND CM.Code IS NULL
		END

		-- Validation 6 :  ExpectedKit Not Found / Code : AssignExpectedKit Method
	IF EXISTS (
			SELECT 1
			FROM @pPanelistUserType PT
			LEFT JOIN StockKit CM ON PT.ExpectedKitCode = CM.Code
				AND CM.Country_Id = @CountryId
			WHERE PT.ExpectedKitCode IS NOT NULL
				AND LEN(PT.ExpectedKitCode) > 0
				AND CM.Code IS NULL
			)
		BEGIN
			SET @Error = 20

			PRINT '20'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'ExpectedKitCode not found At Row '+  CONVERT(VARCHAR, PT.Rownumber+1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
			FROM @pPanelistUserType PT
		LEFT JOIN StockKit CM ON PT.ExpectedKitCode = CM.Code
			AND CM.Country_Id = @CountryId
		WHERE PT.ExpectedKitCode IS NOT NULL
			AND LEN(PT.ExpectedKitCode) > 0
			AND CM.Code IS NULL
		END

	IF EXISTS (
			SELECT 1
			FROM @DyniamicRoles P
			WHERE P.[DyniamicRoleBuissnessId] IS NOT NULL
				AND UPPER(P.[DyniamicRoleBuissnessId]) NOT IN (
					'TRUE'
					,'FALSE'
					,'1'
					,'0'
					)
			)
		BEGIN
			SET @Error = 15

			PRINT '15'

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,1
			,0
			,'Panel Role Operation Not Recognized At Row '+  CONVERT(VARCHAR, PT.Rownumber +1)
			,@GetDate
			,[FullRow]
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
			FROM @DyniamicRoles P 
			INNER JOIN @pPanelistUserType PT ON PT.Rownumber = P.Rownumber 
			WHERE P.[DyniamicRoleBuissnessId] IS NOT NULL 
			AND UPPER(P.[DyniamicRoleBuissnessId]) NOT IN (
				'TRUE'
				,'FALSE'
				,'1'
				,'0'
				)
		END
		
		-- UPDATE @DyniamicRoles 
		--SET [DyniamicRoleBuissnessId] = CASE WHEN UPPER([DyniamicRoleBuissnessId])  ='TRUE' THEN '1' ELSE '0' END 
		--WHERE 
		--	 [DyniamicRoleBuissnessId] IS NOT NULL 
		--	AND UPPER([DyniamicRoleBuissnessId]) IN ('TRUE','FALSE')
		IF (@Error > 0)
		BEGIN
		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@GPSUser
			,@pFileId
			,@CountryId

			SELECT @Error

			RETURN;
		END
		
		BEGIN TRANSACTION

		BEGIN TRY
		UPDATE #Panelist
		SET NewPanelistId = NEWID()
		WHERE PanelistId IS NULL

		UPDATE P
		SET P.GroupGUID = CMP.Group_Id
			FROM CollectiveMembership CMP 
		INNER JOIN #Panelist P ON P.IndividualGUID = CMP.Individual_Id
			AND CMP.Country_Id = @CountryId

			-- Panelist 
		INSERT INTO Panelist (
			GUIDReference
			,CreationDate
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			,Panel_Id
			,RewardsAccount_Id
			,PanelMember_Id
			,CollaborationMethodology_Id
			,State_Id
			,IncentiveLevel_Id
			,ExpectedKit_Id
			,ChangeReason_Id
			,Country_Id
			)
		SELECT NewPanelistId
			,(
				CASE 
					WHEN SignUpDate IS NULL
						THEN @GetDate
				ELSE SignUpDate
					END
				)
			,@GPSUser
			,@GetDate
			,@GetDate
			,PanelId
			,NULL
			,IndividualId
			,CollaborationMethodologyId
			,ISNULL(StateDefinitionId, @PanelistDefaultStateId)
			,IL.GUIDReference
			,ExpectedKitId
			,CollaborationMethodologyReasonId
			,@CountryId
			FROM #Panelist PL
		LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = PL.PanelId
			AND IL.IsDefault = 1
			WHERE PanelistId IS NULL

			-- To State should come via Inrule
		INSERT INTO StateDefinitionHistory (
			GUIDReference
			,GPSUser
			,CreationDate
			,GPSUpdateTimestamp
			,CreationTimeStamp
			,Comments
			,CollaborateInFuture
			,From_Id
			,To_Id
			,ReasonForchangeState_Id
			,Country_Id
			,Panelist_Id
			)
		SELECT NEWID()
			,@GPSUser
			,IIF(ISNULL(IPL.StateChangeDate, '') != '', IPL.StateChangeDate, @GetDate)
			,ISNULL(SignUpDate, @GetDate)
			,ISNULL(SignUpDate, @GetDate)
			,StateChangeComments
			,ISNULL(CollaborateInFuture, 0)
			,@PanelistPresetedStateId
			,ISNULL(StateDefinitionId, @PanelistDefaultStateId)
			,NULL
			,@CountryId
			,NewPanelistId
		FROM #Panelist IPL --- UPDATE PANELIST PREVIOUS STATE
			
		INSERT INTO CollaborationMethodologyHistory (
			GUIDReference
			,GPSUpdateTimestamp
			,CreationTimeStamp
			,[Date]
			,GPSUser
			,Comments
			,Panelist_Id
			,OldCollaborationMethodology_Id
			,NewCollaborationMethodology_Id
			,Country_Id
			,CollaborationMethodologyChangeReason_Id
			)
		SELECT NEWID()
			,@GetDate
			,@GetDate
			,MethodologyChangeDate
			,@GPSUser
			,CollaborationMethodologyChangeComments
			,NewPanelistId
			,NULL
			,CollaborationMethodologyId
			,@CountryId
			,CollaborationMethodologyReasonId
		FROM #Panelist IPL
		WHERE CollaborationMethodologyId IS NOT NULL
			AND MethodologyChangeDate IS NOT NULL

		INSERT INTO StockKitHistory (
			Id
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			,From_Id
			,To_Id
			,Reason_Id
			,Country_Id
			,Panelist_Id
			)
		SELECT NEWID()
			,@GPSUser
			,@GetDate
			,@GetDate
			,NULL
			,ExpectedKitId
			,NULL
			,@CountryId
			,NewPanelistId
		FROM #Panelist
			WHERE ExpectedKitId IS NOT NULL

			----ChangeAssignedTasks
		INSERT INTO PartyPanelSurveyParticipationTask (
			Panelist_Id
			,PanelTaskAssociation_Id
			,FromDate
			,ToDate
			,Active
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			)
		SELECT NewPanelistId
			,PanelSurveyParticipationTask
			,PanelTaskDateFrom
			,PanelTaskDateTo
			,'1'
			,@GPSUser
			,@GetDate
			,@GetDate
			FROM #Panelist PL 
		WHERE SurveyParticipationTaskId IS NOT NULL
			AND 1 = (
				CASE 
					WHEN (
							PL.PanelTaskIsRemoved IS NULL
							OR LEN(PL.PanelTaskIsRemoved) = 0
							)
						THEN 1
					WHEN (
							PL.PanelTaskIsRemoved IS NOT NULL
							AND LEN(PL.PanelTaskIsRemoved) > 0
							AND PL.PanelTaskIsRemoved IN (
								'0'
								,'NO'
								,'FALSE'
								)
							)
						THEN 1
					ELSE 0
					END
				)

		SELECT NEWID() AS DynamicRoleAssignmentId
			,DR.DynamicRoleId AS DynamicRole_Id
			,IPL.NewPanelistId AS Panelist_Id
			,IPL.IndividualGUID AS Candidate_Id
			,IPL.GroupId AS Group_Id
			,@GetDate AS CreationTimeStamp
			,@GetDate AS GPSUpdateTimestamp
			,@GPSUser AS GPSUser
			,@CountryId AS Country_Id
			INTO #DynamicRoleAssignmentTemp
			FROM #Panelist IPL
				INNER JOIN @DyniamicRoles D ON D.Rownumber = IPL.Rownumber 
				INNER JOIN Translation T ON T.KeyName = D.[DyniamicRoleName] 
				INNER JOIN DynamicRole DR ON T.TranslationId = DR.Translation_Id 
				AND DR.Country_Id = @CountryId  
			WHERE D.[DyniamicRoleBuissnessId] = '1'    

		INSERT INTO DynamicRoleAssignment (
			DynamicRoleAssignmentId
			,DynamicRole_Id
			,Candidate_Id
			,Panelist_Id
			,Group_Id
			,CreationTimeStamp
			,GPSUpdateTimestamp
			,GPSUser
			,Country_Id
			)
		SELECT DynamicRoleAssignmentId
			,DynamicRole_Id
			,Candidate_Id
			,Panelist_Id
			,NULL
			,CreationTimeStamp
			,GPSUpdateTimestamp
			,GPSUser
			,Country_Id
			FROM #DynamicRoleAssignmentTemp

		INSERT INTO DynamicRoleAssignmentHistory (
			GUIDReference
			,DateFrom
			,DateTo
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,DynamicRoleAssignment_Id
			,DynamicRole_Id
			,Candidate_Id
			)
		SELECT NEWID()
			,@GetDate
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,DynamicRoleAssignmentId
			,DynamicRole_Id
			,Candidate_Id
			FROM #DynamicRoleAssignmentTemp

		SELECT DISTINCT C.GUIDReference AS CandidateId
			,C.CandidateStatus AS OldStatus
			,fn.StateID AS NewState
			INTO #NewCandidateStatus
			FROM #Panelist IPL
				INNER JOIN Collective G ON G.GUIDReference = IPL.GroupGUID
				INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = G.GUIDReference
				INNER JOIN Candidate C ON C.GUIDReference = CMP.Individual_Id
				CROSS APPLY dbo.[fnGetIndividualStatus_Tbl](C.GUIDReference) fn 
		WHERE C.Country_Id = @CountryId
			AND C.CandidateStatus <> fn.StateID

		INSERT INTO StateDefinitionHistory (
			GUIDReference
			,GPSUser
			,CreationDate
			,GPSUpdateTimestamp
			,CreationTimeStamp
			,Comments
			,CollaborateInFuture
			,From_Id
			,To_Id
			,ReasonForchangeState_Id
			,Country_Id
			,Candidate_Id
			)
		SELECT NEWID()
			,@GPSUser
			,IIF(ISNULL(T.StateChangeDate, '') != '', T.StateChangeDate, @GetDate)
			,@GetDate
			,@GetDate
			,NULL AS Comments
			,0 AS CollaborateInFuture
			,T.CandidateStatus
			,T.NewStatus
			,NULL AS ReasonForChange
			,@CountryId AS CountryId
			,T.IndividualGuid AS CandidateId
		FROM (
			SELECT DISTINCT C.CandidateStatus
				,NC.NewState AS NewStatus
				,@CountryId AS CountryId
				,IPL.IndividualGuid
				,IPL.StateChangeDate
			FROM #Panelist IPL
				INNER JOIN Collective G ON G.GUIDReference = IPL.GroupGUID
				INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = G.GUIDReference
				INNER JOIN Candidate C ON C.GUIDReference = CMP.Individual_Id
			INNER JOIN #NewCandidateStatus NC ON NC.CandidateId = C.GUIDReference
			WHERE C.Country_Id = @CountryId
			) T

			UPDATE C
		SET C.CandidateStatus = NC.NewState
			,C.GPSUser = @GPSUser
			,C.GPSUpdateTimestamp = @GetDate
			FROM #Panelist IPL
				INNER JOIN Collective G ON G.GUIDReference = IPL.GroupGUID
				INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = G.GUIDReference
				INNER JOIN Candidate C ON C.GUIDReference = CMP.Individual_Id
		INNER JOIN #NewCandidateStatus NC ON NC.CandidateId = C.GUIDReference
			WHERE C.Country_Id = @CountryId

			/* Group Status */
		INSERT INTO StateDefinitionHistory (
			GUIDReference
			,GPSUser
			,CreationDate
			,GPSUpdateTimestamp
			,CreationTimeStamp
			,Comments
			,CollaborateInFuture
			,From_Id
			,To_Id
			,ReasonForchangeState_Id
			,Country_Id
			,Candidate_Id
			)
		SELECT NEWID()
			,@GPSUser
			,IIF(ISNULL(T.StateChangeDate, '') != '', T.StateChangeDate, @GetDate)
			,@GetDate
			,@GetDate
			,NULL
			,0
			,T.CandidateStatus
			,T.NewStatus
			,NULL
			,T.CountryId
			,T.GroupGuid
		FROM (
			SELECT DISTINCT C.CandidateStatus
				,@groupTerminatedStatusGuid AS NewStatus
				,@CountryId AS CountryId
				,IPL.GroupGuid
				,IPL.StateChangeDate
			FROM #Panelist IPL			
			INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
				AND C.Country_Id = @CountryId
			WHERE (
					(
						@individualDropOf = ALL (
							SELECT I.CandidateStatus
					FROM CollectiveMembership CM
							INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
					WHERE CM.Group_Id = C.GUIDReference
								AND I.Country_Id = @CountryId
							)
						)
					OR (
						0 = ALL (
							SELECT IIF(PL.State_Id = @PanelistDropoutStateId, 0, 1)
						 FROM CollectiveMembership CM 
							INNER JOIN Panelist PL ON CM.Individual_Id = PL.PanelMember_Id
							WHERE CM.Group_Id = IPL.GroupGUID
								AND PL.Country_Id = @CountryId
							
						 UNION 
							
							SELECT IIF(PL.State_Id = @PanelistDropoutStateId, 0, 1)
						 FROM CollectiveMembership CM 
							INNER JOIN Panelist PL ON CM.Individual_Id = PL.PanelMember_Id
							WHERE CM.Group_Id = IPL.GroupGUID
								AND PL.Country_Id = @CountryId
							)
						)
					 )
			) AS T

			 UPDATE C
		SET C.CandidateStatus = @groupTerminatedStatusGuid
			,C.GPSUpdateTimestamp = @GetDate
			,C.GPSUser = @GPSUser
				  FROM #Panelist IPL
		INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
			AND C.Country_Id = @CountryId
		WHERE (
				@individualDropOf = ALL (
					SELECT I.CandidateStatus
				  FROM CollectiveMembership CM
					INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
					WHERE CM.Group_Id = C.GUIDReference
						AND I.Country_Id = @CountryId
					)
				)
			OR (
				0 = ALL (
					SELECT IIF(PL.State_Id = @PanelistDropoutStateId, 0, 1)
						 FROM CollectiveMembership CM 
					INNER JOIN Panelist PL ON CM.Individual_Id = PL.PanelMember_Id
					WHERE CM.Group_Id = IPL.GroupGUID
						AND PL.Country_Id = @CountryId
					
						 UNION 
					
					SELECT IIF(PL.State_Id = @PanelistDropoutStateId, 0, 1)
						 FROM CollectiveMembership CM 
					INNER JOIN Panelist PL ON CM.Individual_Id = PL.PanelMember_Id
					WHERE CM.Group_Id = IPL.GroupGUID
						AND PL.Country_Id = @CountryId
					 )
					)

		INSERT INTO StateDefinitionHistory (
			GUIDReference
			,GPSUser
			,CreationDate
			,GPSUpdateTimestamp
			,CreationTimeStamp
			,Comments
			,CollaborateInFuture
			,From_Id
			,To_Id
			,ReasonForchangeState_Id
			,Country_Id
			,Candidate_Id
			)
		SELECT NEWID()
			,@GPSUser
			,IIF(ISNULL(T.StateChangeDate, '') != '', T.StateChangeDate, @GetDate)
			,@GetDate
			,@GetDate
			,NULL
			,0
			,T.CandidateStatus
			,T.NewStatus
			,NULL
			,T.CountryId
			,T.GroupGuid
		FROM (
			SELECT DISTINCT C.CandidateStatus
				,@groupParticipantStatusGuid AS NewStatus
				,@CountryId AS CountryId
				,IPL.GroupGuid
				,IPL.StateChangeDate
			FROM #Panelist IPL
			INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
				AND C.Country_Id = @CountryId
			WHERE @individualParticipent = ANY (
					SELECT I.CandidateStatus
					FROM CollectiveMembership CM
				INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference 
					WHERE CM.Group_Id = C.GUIDReference
						AND I.Country_Id = @CountryId
					)
			) T

			UPDATE C 
		SET C.CandidateStatus = @groupParticipantStatusGuid
			,C.GPSUpdateTimestamp = @GetDate
			,C.GPSUser = @GPSUser
			FROM #Panelist IPL
		INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
			AND C.Country_Id = @CountryId
		WHERE @individualParticipent = ANY (
				SELECT I.CandidateStatus
				FROM CollectiveMembership CM
				INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
				WHERE CM.Group_Id = C.GUIDReference
					AND I.Country_Id = @CountryId
				)

		INSERT INTO StateDefinitionHistory (
			GUIDReference
			,GPSUser
			,CreationDate
			,GPSUpdateTimestamp
			,CreationTimeStamp
			,Comments
			,CollaborateInFuture
			,From_Id
			,To_Id
			,ReasonForchangeState_Id
			,Country_Id
			,Candidate_Id
			)
		SELECT NEWID()
			,@GPSUser
			,IIF(ISNULL(T.StateChangeDate, '') != '', T.StateChangeDate, @GetDate)
			,@GetDate
			,@GetDate
			,NULL
			,0
			,T.CandidateStatus
			,T.NewStatus
			,NULL
			,T.CountryId
			,T.GroupGuid
		FROM (
			SELECT DISTINCT C.CandidateStatus
				,@groupAssignedStatusGuid AS NewStatus
				,@CountryId AS CountryId
				,IPL.GroupGuid
				,IPL.StateChangeDate
			FROM #Panelist IPL
			INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
				AND C.Country_Id = @CountryId
			WHERE EXISTS (
					SELECT 1
				  FROM CollectiveMembership CM
					INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
						AND I.Country_Id = @CountryId
				  WHERE CM.Group_Id = C.GUIDReference
				  AND I.CandidateStatus NOT IN (
				  @individualParticipent
							,@IndividualCandidate
							,@individualDropOf
							)
					)
				AND @individualAssignedGuid = ANY (
					SELECT I.CandidateStatus
				  FROM CollectiveMembership CM
					INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
					WHERE CM.Group_Id = C.GUIDReference
						AND I.Country_Id = @CountryId
					)
				AND @individualParticipent <> ALL (
					SELECT I.CandidateStatus
				  FROM CollectiveMembership CM
					INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
					WHERE CM.Group_Id = C.GUIDReference
						AND I.Country_Id = @CountryId
					)
			) T

			UPDATE C
		SET C.CandidateStatus = @groupAssignedStatusGuid
			,C.GPSUpdateTimestamp = @GetDate
			,C.GPSUser = @GPSUser
				  FROM #Panelist IPL
		INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
			AND C.Country_Id = @CountryId
		WHERE EXISTS (
				SELECT 1
				  FROM CollectiveMembership CM
				INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
				WHERE CM.Group_Id = C.GUIDReference
					AND I.Country_Id = @CountryId
				  AND I.CandidateStatus NOT IN (
				  @individualParticipent
						,@IndividualCandidate
						,@individualDropOf
						)
				)
			AND @individualAssignedGuid = ANY (
				SELECT I.CandidateStatus
				  FROM CollectiveMembership CM
				INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
				WHERE CM.Group_Id = C.GUIDReference
					AND I.Country_Id = @CountryId
				)
			AND @individualParticipent <> ALL (
				SELECT I.CandidateStatus
				  FROM CollectiveMembership CM
				INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
				WHERE CM.Group_Id = C.GUIDReference
					AND I.Country_Id = @CountryId
				)

		EXEC InsertImportFile 'ImportFileSuccess'
			,@pUser
			,@pFileId
			,@pCountryId

		INSERT INTO ImportAudit (
			GUIDReference
			,Error
			,IsInvalid
			,[Message]
			,[Date]
			,SerializedRowData
			,SerializedRowErrors
			,CreationTimeStamp
			,GPSUser
			,GPSUpdateTimestamp
			,[File_Id]
			)
		SELECT NEWID()
			,0
			,0
			,'Panelist created successfully ( ' + ISNULL(IFD.[IndividualBusinessId], '') + ' )'
			,@GetDate
			,Feed.[FullRow]
			,NULL
			,@GetDate
			,@pUser
			,@GetDate
			,@pFileId
		FROM @pPanelistUserType Feed
		INNER JOIN #Panelist IFD ON Feed.[Rownumber] = IFD.Rownumber

			COMMIT TRANSACTION
	END TRY

		BEGIN CATCH
			ROLLBACK TRANSACTION

			INSERT INTO ImportAudit
		VALUES (
			NEWID()
			,1
			,1
			,'Line: ' + cast(ERROR_LINE() AS VARCHAR(100)) + 'Error: ' + ERROR_MESSAGE()
			,@GetDate
			,NULL
			,NULL
			,@GetDate
			,@GPSUser
			,@GetDate
			,@pFileId
			)

		EXEC InsertImportFile 'ImportFileBusinessValidationError'
			,@GPSUser
			,@pFileId
			,@CountryId
		END CATCH
END
