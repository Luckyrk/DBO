CREATE PROCEDURE [dbo].[DropPanelistActionFromInRule] (
	@pCountryCode VARCHAR(10)
	,@pBusinessId VARCHAR(20)
	,@pStateCode VARCHAR(400)
	,@pPanelCode INT
	,@pReasonCode INT
	,@pComment VARCHAR(400)
	,@pUser VARCHAR(200) = 'InRule'
	)
AS
-- exec DropPanelistActionFromInRule 'TW','5071253-01','PanelistDroppedOffState',3,2,'Test','testuser'
BEGIN
	SET NOCOUNT ON
BEGIN TRY
	DECLARE @GetDate DATETIME = GETDATE()
		DECLARE @panelistId UNIQUEIDENTIFIER
		DECLARE @countryId UNIQUEIDENTIFIER
		DECLARE @panelId UNIQUEIDENTIFIER
		DECLARE @individualId UNIQUEIDENTIFIER
		DECLARE @groupId UNIQUEIDENTIFIER
		DECLARE @panelType VARCHAR(20)
		DECLARE @statedefinitionId UNIQUEIDENTIFIER
		DECLARE @panelistCount INT
		DECLARE @terminatedPanelistCount INT
		DECLARE @terminatedIndividual UNIQUEIDENTIFIER
		DECLARE @terminatedGroupId UNIQUEIDENTIFIER
		DECLARE @individualsinGroupCount INT
		DECLARE @terminatedindividualsinGroup INT
		DECLARE @participantindividualStatus UNIQUEIDENTIFIER
		DECLARE @nonparticipantIndividualStatus UNIQUEIDENTIFIER
		DECLARE @groupIndividuals TABLE (individualid UNIQUEIDENTIFIER)
	DECLARE @terminatedIndividuals TABLE (individualid UNIQUEIDENTIFIER)
	DECLARE @nonterminatedIndividuals TABLE (individualid UNIQUEIDENTIFIER)
	DECLARE @temppanelistIndividuals TABLE (
		panelistid UNIQUEIDENTIFIER
		,individualid UNIQUEIDENTIFIER
		)
	DECLARE @panelistIndividuals TABLE (
		panelistid UNIQUEIDENTIFIER
		,individualid UNIQUEIDENTIFIER
		)
		DECLARE @maincontactId UNIQUEIDENTIFIER
		DECLARE @isMaincontactexists BIT = 0
		DECLARE @livePaneliststatusId UNIQUEIDENTIFIER
		DECLARE @CurrentDateTime DATETIME = getdate()
		DECLARE @reasonforChangeGuid UNIQUEIDENTIFIER
	DECLARE @tempIndividualId UNIQUEIDENTIFIER

		SET @countryId = (
				SELECT TOP 1 CountryId
				FROM Country
				WHERE CountryISO2A = @pCountryCode
				)
		SET @panelId = (
				SELECT TOP 1 GUIDReference
				FROM Panel
				WHERE PanelCode = @pPanelCode
					AND Country_Id = @countryId
				)
		SET @individualId = (
				SELECT TOP 1 GUIDReference
				FROM Individual
				WHERE IndividualId = @pBusinessId
					AND CountryId = @countryId
				)
		SET @groupId = (
				SELECT TOP 1 Group_Id
				FROM CollectiveMembership
				WHERE Individual_Id = @individualId
				)
		SET @panelType = (
				SELECT TOP 1 [Type]
				FROM Panel
				WHERE GUIDReference = @panelId
				)
		SET @terminatedIndividual = (
				SELECT TOP 1 Id
				FROM StateDefinition
				WHERE Code = 'IndividualTerminated'
					AND Country_Id = @countryId
				)
		SET @individualsinGroupCount = (
				SELECT count(*)
				FROM CollectiveMembership
				WHERE Group_Id = @groupId
				)
		SET @terminatedindividualsinGroup = (
				SELECT count(*)
				FROM Candidate
				WHERE GUIDReference IN (
						SELECT Individual_Id
						FROM CollectiveMembership
						WHERE Group_Id = @groupId
						)
					AND CandidateStatus = @terminatedIndividual
				)
		SET @terminatedGroupId = (
				SELECT TOP 1 Id
				FROM StateDefinition
				WHERE code = 'GroupTerminated'
					AND Country_Id = @countryId
				)
		SET @participantindividualStatus = (
				SELECT TOP 1 Id
				FROM StateDefinition
				WHERE code = 'IndividualParticipant'
					AND Country_Id = @countryId
				)
		SET @nonparticipantIndividualStatus = (
				SELECT TOP 1 Id
				FROM StateDefinition
				WHERE code = 'IndividualNonParticipant'
					AND Country_Id = @countryId
				)
	SET @statedefinitionId = (
			SELECT TOP 1 Id
			FROM StateDefinition
			WHERE Code = 'PanelistDroppedOffState'
				AND Country_Id = @countryId
			)

		INSERT INTO @groupIndividuals
		SELECT Individual_Id
		FROM CollectiveMembership
		WHERE Group_Id = @groupId

		IF (@panelType = 'HouseHold')
		BEGIN
			SET @panelistId = (
					SELECT TOP 1 GUIDReference
					FROM Panelist
					WHERE Panel_Id = @panelId
						AND PanelMember_Id = @groupId
					)
		END
		ELSE
			SET @panelistId = (
					SELECT TOP 1 GUIDReference
					FROM Panelist
					WHERE Panel_Id = @panelId
						AND PanelMember_Id = @individualId
					)

		DECLARE @PanelistError VARCHAR(max) = 'Panelist Not Found for Indivdiual : ' + @pBusinessId + ' With Panel Code ' + convert(VARCHAR(10), @pPanelCode)

		IF (@panelistId IS NULL)
		BEGIN
			RAISERROR (
					@PanelistError
					,16
					,1
					);
		END

		DECLARE @reasonForChangeStateError VARCHAR(max) = 'Reason for Change state doesnt exist for the Reason : ' + convert(VARCHAR(10), @pReasonCode)

		SET @reasonforChangeGuid = (
				SELECT TOP 1 Id
				FROM ReasonForChangeState rc
				WHERE rc.Code = @pReasonCode
					AND rc.Country_Id = @countryId
				)

		IF (@reasonforChangeGuid IS NULL)
		BEGIN
			RAISERROR (
					@reasonForChangeStateError
					,16
					,1
					);
		END

	INSERT INTO @temppanelistIndividuals
	SELECT b.guidreference
		,NULL
	FROM (
		SELECT p.guidreference
		FROM panelist p
		JOIN collective c ON p.PanelMember_Id = c.guidreference
		JOIN StateDefinition sd ON p.State_Id = sd.Id
		WHERE c.guidreference = @groupId
			AND sd.Code NOT IN (
				'PanelistDroppedOffState'
				,'PanelistRefusalState'
				)

		UNION

		SELECT p.guidreference
		FROM panelist p
		JOIN individual i ON p.PanelMember_Id = i.guidreference
		JOIN StateDefinition sd ON p.State_Id = sd.Id
		WHERE i.guidreference IN (
				SELECT individualid
				FROM @groupIndividuals
				)
			AND sd.Code NOT IN (
				'PanelistDroppedOffState'
				,'PanelistRefusalState'
				)
		) b

	UPDATE a
	SET a.individualid = I.guidreference
	FROM @temppanelistIndividuals a
	JOIN DynamicRoleAssignment b ON a.panelistid = b.Panelist_Id
	JOIN Individual I ON b.Candidate_Id = I.guidreference
	
	SET XACT_ABORT ON

	BEGIN TRANSACTION

	BEGIN TRY
		IF ((@pPanelCode = 27 AND @pCountryCode = 'GB')	OR (@pPanelCode = 45 AND @pCountryCode = 'IE'))
		BEGIN
			INSERT INTO @panelistIndividuals
			SELECT panelistid
				,individualid
			FROM @temppanelistIndividuals
		END
		ELSE
			INSERT INTO @panelistIndividuals
			SELECT panelistid
				,individualid
			FROM @temppanelistIndividuals
			WHERE individualid = @individualId
				AND panelistid = @panelistId

		--SELECT *
		--FROM @panelistIndividuals
		INSERT INTO [dbo].[StateDefinitionHistory] (
			[GUIDReference]
			,[GPSUser]
			,[CreationDate]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Comments]
			,[CollaborateInFuture]
			,[From_Id]
			,[To_Id]
			,[ReasonForchangeState_Id]
			,[Country_Id]
			,[Candidate_Id]
			,[GroupMembership_Id]
			,[Belonging_Id]
			,[Panelist_Id]
			,[Order_Id]
			,[Order_Country_Id]
			,[Package_Id]
			,[ImportFile_Id]
			,[ImportFilePendingRecord_Id]
			,[Action_Id]
			)
		SELECT newid()
			,@pUser
			,@CurrentDateTime
			,@CurrentDateTime
			,@CurrentDateTime
			,@pComment
			,0
			,(
				SELECT State_Id
				FROM Panelist
				WHERE GUIDReference = p.panelistid
				)
			,@statedefinitionId
			,@reasonforChangeGuid
			,@countryId
			,NULL
			,NULL
			,NULL
			,p.panelistid
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
		FROM @panelistIndividuals p

		UPDATE Panelist
		SET State_Id = @statedefinitionId
			,GPSUpdateTimestamp = @GetDate
			,GPSUser = @pUser
		WHERE GUIDReference IN (
				SELECT panelistid
				FROM @panelistIndividuals
				)

				INSERT INTO [dbo].[StateDefinitionHistory] (
					[GUIDReference]
					,[GPSUser]
					,[CreationDate]
					,[GPSUpdateTimestamp]
					,[CreationTimeStamp]
					,[Comments]
					,[CollaborateInFuture]
					,[From_Id]
					,[To_Id]
					,[ReasonForchangeState_Id]
					,[Country_Id]
					,[Candidate_Id]
					,[GroupMembership_Id]
					,[Belonging_Id]
					,[Panelist_Id]
					,[Order_Id]
					,[Order_Country_Id]
					,[Package_Id]
					,[ImportFile_Id]
					,[ImportFilePendingRecord_Id]
					,[Action_Id]
					)
		SELECT newid()
					,@pUser
					,@CurrentDateTime
					,@CurrentDateTime
					,@CurrentDateTime
					,@pComment
					,0
					,(
						SELECT CandidateStatus
						FROM Candidate
				WHERE GUIDReference = p.individualid
						)
			,@terminatedIndividual
					,@reasonforChangeGuid
					,@countryId
			,p.individualid
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
		FROM @panelistIndividuals p

		UPDATE Candidate
		SET CandidateStatus = @terminatedIndividual
			,GPSUpdateTimestamp = @GetDate
			,GPSUser = @pUser
		WHERE GUIDReference IN (
				SELECT individualid
				FROM @panelistIndividuals
					)

		INSERT INTO @terminatedIndividuals
		SELECT GUIDReference
		FROM Candidate
		WHERE GUIDReference IN (
				SELECT Individual_Id
				FROM CollectiveMembership
				WHERE Group_Id = @groupId
				)
			AND CandidateStatus = @terminatedIndividual

		IF NOT EXISTS (
						SELECT 1
				FROM @groupIndividuals
				WHERE individualid NOT IN (
						SELECT individualid
						FROM @terminatedIndividuals
						)
					)
			BEGIN
				INSERT INTO [dbo].[StateDefinitionHistory] (
					[GUIDReference]
					,[GPSUser]
					,[CreationDate]
					,[GPSUpdateTimestamp]
					,[CreationTimeStamp]
					,[Comments]
					,[CollaborateInFuture]
					,[From_Id]
					,[To_Id]
					,[ReasonForchangeState_Id]
					,[Country_Id]
					,[Candidate_Id]
					,[GroupMembership_Id]
					,[Belonging_Id]
					,[Panelist_Id]
					,[Order_Id]
					,[Order_Country_Id]
					,[Package_Id]
					,[ImportFile_Id]
					,[ImportFilePendingRecord_Id]
					,[Action_Id]
					)
				VALUES (
					newid()
					,@pUser
					,@CurrentDateTime
					,@CurrentDateTime
					,@CurrentDateTime
					,@pComment
					,0
					,(
						SELECT CandidateStatus
						FROM Candidate
					WHERE GUIDReference = @groupId
						)
				,@statedefinitionId
					,@reasonforChangeGuid
					,@countryId
				,(
					SELECT TOP 1 GroupContact_Id
					FROM Collective
					WHERE GUIDReference = @groupId
					)
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					)

				UPDATE Candidate
			SET CandidateStatus = @terminatedGroupId
				,GPSUpdateTimestamp = @GetDate
				,GPSUser = @pUser
			WHERE GUIDReference = @groupId
		END
		ELSE
		BEGIN
			INSERT INTO @nonterminatedIndividuals
			SELECT individualid
			FROM @groupIndividuals
			WHERE individualid NOT IN (
					SELECT individualid
					FROM @terminatedIndividuals
					)

			WHILE EXISTS (
					SELECT 1
					FROM @nonterminatedIndividuals
					)
			BEGIN
				SET @tempIndividualId = (
						SELECT TOP 1 individualid
						FROM @nonterminatedIndividuals
						)

				IF EXISTS (
						(
							SELECT 1
							FROM Panelist p
							INNER JOIN Individual i ON p.PanelMember_Id = i.GUIDReference
							INNER JOIN StateDefinition sd ON sd.Id = p.State_Id
							WHERE i.GUIDReference = @tempIndividualId
								AND sd.Code = 'PanelistLiveState'

							UNION

							SELECT 1
							FROM Panelist p
							INNER JOIN CollectiveMembership cm ON cm.Group_Id = p.PanelMember_Id
							INNER JOIN StateDefinition sd ON sd.Id = p.State_Id
							WHERE cm.Group_Id = @groupId
								AND sd.Code = 'PanelistLiveState'
							)
						)
				BEGIN
				INSERT INTO [dbo].[StateDefinitionHistory] (
					[GUIDReference]
					,[GPSUser]
					,[CreationDate]
					,[GPSUpdateTimestamp]
					,[CreationTimeStamp]
					,[Comments]
					,[CollaborateInFuture]
					,[From_Id]
					,[To_Id]
					,[ReasonForchangeState_Id]
					,[Country_Id]
					,[Candidate_Id]
					,[GroupMembership_Id]
					,[Belonging_Id]
					,[Panelist_Id]
					,[Order_Id]
					,[Order_Country_Id]
					,[Package_Id]
					,[ImportFile_Id]
					,[ImportFilePendingRecord_Id]
					,[Action_Id]
					)
				VALUES (
					newid()
					,@pUser
					,@CurrentDateTime
					,@CurrentDateTime
					,@CurrentDateTime
					,@pComment
					,0
					,(
						SELECT CandidateStatus
						FROM Candidate
						WHERE GUIDReference = @tempIndividualId
						)
						,@participantindividualStatus
					,@reasonforChangeGuid
					,@countryId
					,@tempIndividualId
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					,NULL
					)

			UPDATE Candidate
					SET CandidateStatus = @participantindividualStatus
						,GPSUpdateTimestamp = @GetDate
						,GPSUser = @pUser
			WHERE GUIDReference = @tempIndividualId
		END
				ELSE
		BEGIN
			INSERT INTO [dbo].[StateDefinitionHistory] (
				[GUIDReference]
				,[GPSUser]
				,[CreationDate]
				,[GPSUpdateTimestamp]
				,[CreationTimeStamp]
				,[Comments]
				,[CollaborateInFuture]
				,[From_Id]
				,[To_Id]
				,[ReasonForchangeState_Id]
				,[Country_Id]
				,[Candidate_Id]
				,[GroupMembership_Id]
				,[Belonging_Id]
				,[Panelist_Id]
				,[Order_Id]
				,[Order_Country_Id]
				,[Package_Id]
				,[ImportFile_Id]
				,[ImportFilePendingRecord_Id]
				,[Action_Id]
				)
			VALUES (
				newid()
				,@pUser
				,@CurrentDateTime
				,@CurrentDateTime
				,@CurrentDateTime
				,@pComment
				,0
				,(
					SELECT CandidateStatus
					FROM Candidate
							WHERE GUIDReference = @tempIndividualId
					)
						,@nonparticipantIndividualStatus
				,@reasonforChangeGuid
				,@countryId
				,@tempIndividualId
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				)

			UPDATE Candidate
					SET CandidateStatus = @nonparticipantIndividualStatus
						,GPSUpdateTimestamp = @GetDate
						,GPSUser = @pUser
					WHERE GUIDReference = @tempIndividualId
				END

				DELETE
				FROM @nonterminatedIndividuals
				WHERE individualid = @tempIndividualId
		END
	END

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		DECLARE @error NVARCHAR(max) = (
				SELECT ERROR_MESSAGE()
				)

		RAISERROR (
				@error
				,16
				,1
				)

		ROLLBACK TRANSACTION
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