--WARNING! ERRORS ENCOUNTERED DURING SQL PARSING!
--EXEC SP_UpdateGroupMembershipStatus '111290-01','GroupMembershipDeceased','ID','Ravi.Madhogarhia@kantar.com'
CREATE PROCEDURE [dbo].[SP_UpdateGroupMembershipStatus] (
	@pBusinessId NVARCHAR(200)
	,@pIndividualStatus NVARCHAR(200)
	,@pCountryCode NVARCHAR(200)
	,@pUser NVARCHAR(200)
	)
AS
BEGIN
	DECLARE @GetDate DATETIME
	DECLARE @COUNTRYGUID UNIQUEIDENTIFIER

	SELECT @COUNTRYGUID = CountryId
	FROM COUNTRY
	WHERE CountryISO2A = @pCountryCode

	SET @GetDate = (
			SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @COUNTRYGUID)
			)

	DECLARE @GroupMembershipStateGuid UNIQUEIDENTIFIER
		,@CountryId UNIQUEIDENTIFIER
	DECLARE @GroupMembershipNonResidentId UNIQUEIDENTIFIER
	DECLARE @GroupMembershipDeceasedId UNIQUEIDENTIFIER
	DECLARE @PanelistDroppedOffStateId UNIQUEIDENTIFIER
	DECLARE @pIndividualStatusGuid UNIQUEIDENTIFIER

	SET @pIndividualStatusGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'IndividualCandidate'
				AND Country_Id = @COUNTRYGUID
			)

	SELECT @GroupMembershipNonResidentId = sd.Id
	FROM StateDefinition sd
	INNER JOIN Country c ON c.CountryId = sd.Country_Id
	WHERE c.CountryId = @COUNTRYGUID
		AND sd.Code = 'GroupMembershipNonResident'

	SELECT @GroupMembershipDeceasedId = sd.Id
	FROM StateDefinition sd
	INNER JOIN Country c ON c.CountryId = sd.Country_Id
	WHERE c.CountryId = @COUNTRYGUID
		AND sd.Code = 'GroupMembershipDeceased'

	SELECT @PanelistDroppedOffStateId = sd.Id
	FROM StateDefinition sd
	INNER JOIN Country c ON c.CountryId = sd.Country_Id
	WHERE c.CountryId = @COUNTRYGUID
		AND sd.Code = 'PanelistDroppedOffState'

	SELECT @CountryId = CountryId
	FROM COUNTRY
	WHERE CountryISO2A = @pCountryCode

	SELECT @GroupMembershipStateGuid = SD.Id
	FROM STATEMODEL SM
	JOIN COUNTRY C ON SM.Country_Id = C.CountryId
	JOIN STATEDEFINITION SD ON SM.GUIDReference = SD.STATEMODEL_ID
	WHERE SM.[TYPE] = 'Domain.PanelManagement.Candidates.Groups.GroupMembership'
		AND C.CountryISO2A = 'ID'
		AND SD.CODE = @pIndividualStatus

	DECLARE @PanelistDefaultStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistPresetedStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistLiveStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistDropoutStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistRefusalStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistPreLiveStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistSelectedStateId AS UNIQUEIDENTIFIER

	SELECT @PanelistLiveStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistLiveState'
		AND Country_Id = @CountryId

	SELECT @PanelistPreLiveStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistPreLiveState'
		AND Country_Id = @CountryId

	SELECT @PanelistDropoutStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistDroppedOffState'
		AND Country_Id = @CountryId

	SELECT @PanelistSelectedStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistSelectedState'
		AND Country_Id = @CountryId

	SELECT @PanelistRefusalStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistRefusalState'
		AND Country_Id = @CountryId

	SELECT @PanelistDefaultStateId = (
			SELECT TOP 1 st.ToState_Id
			FROM statedefinition sd
			INNER JOIN StateDefinitionsTransitions SDT ON SDT.StateDefinition_Id = SD.Id
			INNER JOIN StateTransition st ON st.Id = sdt.AvailableTransition_Id
				AND sd.Country_Id = @CountryId
			WHERE sd.code = 'PanelistPresetedState'
			ORDER BY st.[Priority]
				,IsAdmin
			)

	SELECT @PanelistPresetedStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistPresetedState'
		AND Country_Id = @CountryId

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
		,GroupMembership_Id
		)
	SELECT NEWID()
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,CM.State_Id
		,@GroupMembershipStateGuid
		,NULL
		,@CountryId
		,CM.CollectiveMembershipId
	FROM Individual I
	INNER JOIN CollectiveMembership CM ON I.GUIDReference = CM.Individual_Id
	WHERE CM.State_Id <> @GroupMembershipStateGuid
		AND I.IndividualId = @pBusinessId

	UPDATE DH
	SET DH.DateTo = @GetDate
		,DH.GPSUpdateTimestamp = @GetDate
		,DH.GPSUser = @pUser
	FROM Individual I
	INNER JOIN CollectiveMembership CM ON I.GUIDReference = CM.Individual_Id
	INNER JOIN DynamicRoleAssignment D ON D.Candidate_Id = CM.Individual_Id
	INNER JOIN DynamicRoleAssignmentHistory DH ON DH.DynamicRoleAssignment_Id = D.DynamicRoleAssignmentId
	WHERE CM.State_Id <> @GroupMembershipStateGuid
		AND @GroupMembershipStateGuid = @GroupMembershipDeceasedId
		AND I.IndividualId = @pBusinessId

	UPDATE D
	SET D.Candidate_Id = NULL
		,D.GPSUpdateTimestamp = @GetDate
		,D.GPSUser = @pUser
	FROM Individual I
	INNER JOIN CollectiveMembership CM ON I.GUIDReference = CM.Individual_Id
	INNER JOIN DynamicRoleAssignment D ON D.Candidate_Id = CM.Individual_Id
	WHERE CM.State_Id <> @GroupMembershipStateGuid
		AND @GroupMembershipStateGuid = @GroupMembershipDeceasedId
		AND I.IndividualId = @pBusinessId

	IF EXISTS (
			SELECT 1
			FROM Individual I
			INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = I.GUIDReference
			INNER JOIN Collective C ON C.GUIDReference = CMP.Group_Id
			INNER JOIN StateDefinition SD ON @GroupMembershipStateGuid = SD.Id
				AND SD.Country_Id = @COUNTRYGUID
			WHERE SD.Code IS NOT NULL
				AND SD.Id = @GroupMembershipNonResidentId
				AND C.GroupContact_Id = I.GUIDReference
				AND I.IndividualId = @pBusinessId
			)
	BEGIN
		DECLARE @JOBAUDITID BIGINT
		DECLARE @CorrelationToken UNIQUEIDENTIFIER

		SELECT TOP 1 @JOBAUDITID = JobAuditId
			,@CorrelationToken = CorrelationToken
		FROM [dbo].[SqlJobRuleActionAudit]
		WHERE RuleActionName = 'UpdateGroupMembershipStatusAction'
			AND BusinessId = @pBusinessId
		ORDER BY GPSUpdateTimestamp DESC

		UPDATE [dbo].[SqlJobAudit]
		SET error_info = 'GroupContact cannot be Non-Resident : Change the GroupContact'
			,statuscode = 0
		WHERE jobauditid = @JOBAUDITID

		RAISERROR('GroupContact cannot be Non-Resident : Change the GroupContact', 11,11)

		--UPDATE GPS_PM_Supplementary.dbo.GPSRuleActionQueue
		--SET error_info = 'GroupContact cannot be Non-Resident : Change the GroupContact',SUBQUEUE = 'F'
		--WHERE CORRELATION_ID = @CorrelationToken
	END
	ELSE
	BEGIN
		UPDATE DH
		SET DH.DateTo = @GetDate
			,DH.GPSUpdateTimestamp = @GetDate
			,DH.GPSUser = @pUser
		FROM Individual I
		INNER JOIN CollectiveMembership CM ON I.GUIDReference = CM.Individual_Id
		INNER JOIN DynamicRoleAssignment D ON D.Candidate_Id = CM.Individual_Id
		INNER JOIN DynamicRoleAssignmentHistory DH ON DH.DynamicRoleAssignment_Id = D.DynamicRoleAssignmentId
		WHERE CM.State_Id <> @GroupMembershipStateGuid
			AND @GroupMembershipStateGuid = @GroupMembershipNonResidentId
			AND I.IndividualId = @pBusinessId

		UPDATE D
		SET D.Candidate_Id = NULL
			,D.GPSUpdateTimestamp = @GetDate
			,D.GPSUser = @pUser
		FROM Individual I
		INNER JOIN CollectiveMembership CM ON I.GUIDReference = CM.Individual_Id
		INNER JOIN DynamicRoleAssignment D ON D.Candidate_Id = CM.Individual_Id
		WHERE CM.State_Id <> @GroupMembershipStateGuid
			AND @GroupMembershipStateGuid = @GroupMembershipNonResidentId
			AND I.IndividualId = @pBusinessId
	END

	UPDATE C
	SET C.GroupContact_Id = fn.NextIndividualGUID
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM Individual I
	INNER JOIN CollectiveMembership CM ON I.GUIDReference = CM.Individual_Id
	INNER JOIN Collective C ON CM.Group_Id = C.GUIDReference
	CROSS APPLY dbo.[fnGetNextIndividualId](CM.Individual_Id) fn
	WHERE CM.State_Id <> @GroupMembershipStateGuid
		AND @GroupMembershipStateGuid = @GroupMembershipDeceasedId
		AND C.GroupContact_Id = I.GUIDReference
		AND fn.NextIndividualGUID IS NOT NULL
		AND fn.NextIndividualGUID <> C.GroupContact_Id
		AND I.IndividualId = @pBusinessId

	UPDATE CM
	SET CM.State_Id = @GroupMembershipDeceasedId
		,CM.GPSUpdateTimestamp = @GetDate
		,CM.GPSUser = @pUser
	FROM Individual I
	INNER JOIN CollectiveMembership CM ON I.GUIDReference = CM.Individual_Id
	WHERE CM.State_Id <> @GroupMembershipStateGuid
		AND @GroupMembershipStateGuid = @GroupMembershipDeceasedId
		AND I.IndividualId = @pBusinessId

	UPDATE C
	SET C.CandidateStatus = @pIndividualStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM Individual I
	INNER JOIN CollectiveMembership CM ON I.GUIDReference = CM.Individual_Id
	INNER JOIN Candidate C ON C.GUIDReference = CM.Individual_Id
		AND I.GUIDReference = C.GUIDreference
	WHERE --CM.State_Id <> Feed.GroupMembershipStateGuid AND 
		@GroupMembershipStateGuid = @GroupMembershipNonResidentId
		AND C.CandidateStatus <> @pIndividualStatusGuid
		AND I.IndividualId = @pBusinessId

	UPDATE CM
	SET CM.State_Id = @GroupMembershipStateGuid
		,CM.GPSUpdateTimestamp = @GetDate
		,CM.GPSUser = @pUser
	FROM Individual I
	INNER JOIN CollectiveMembership CM ON I.GUIDReference = CM.Individual_Id
	WHERE CM.State_Id <> @GroupMembershipStateGuid
		AND @GroupMembershipStateGuid <> @GroupMembershipDeceasedId
		AND @GroupMembershipStateGuid <> @GroupMembershipNonResidentId
		AND I.IndividualId = @pBusinessId

	UPDATE CM
	SET CM.State_Id = @GroupMembershipStateGuid
		,CM.GPSUpdateTimestamp = @GetDate
		,CM.GPSUser = @pUser
	FROM Individual I
	INNER JOIN CollectiveMembership CM ON I.GUIDReference = CM.Individual_Id
	WHERE CM.State_Id <> @GroupMembershipStateGuid
		AND @GroupMembershipStateGuid = @GroupMembershipNonResidentId
		AND I.IndividualId = @pBusinessId
		AND NOT EXISTS (
			SELECT 1
			FROM Collective C
			WHERE C.GUIDReference = CM.Group_Id
				AND C.GroupContact_Id = I.GUIDReference
			)

	IF OBJECT_ID('tempdb..#Update_Panelist') IS NOT NULL
		DROP TABLE #Update_Panelist

	CREATE TABLE #Update_Panelist (
		PanelistGUID UNIQUEIDENTIFIER NOT NULL
		,PanelGUID UNIQUEIDENTIFIER NULL
		,PanelType NVARCHAR(200) NULL
		,GroupGUID UNIQUEIDENTIFIER NULL
		,IndividualGuid UNIQUEIDENTIFIER NULL
		,PanelStateId UNIQUEIDENTIFIER NULL
		,CommunicationMethodologyGUID UNIQUEIDENTIFIER NULL
		,ChangeReasonId UNIQUEIDENTIFIER NULL
		,MethodologyChangeComment NVARCHAR(MAX) NULL
		,PanelRoleCode INT NULL
		,GroupRoleCode INT NULL
		)

	INSERT INTO #Update_Panelist (
		PanelistGUID
		,PanelGUID
		,PanelType
		,IndividualGuid
		,PanelStateId
		,GroupGUID
		)
	SELECT TOP 1 PL.GUIDReference
		,PL.Panel_Id
		,P.[Type]
		,I.GUIDReference
		,PL.State_Id
		,CM.group_id
	FROM Individual I
	INNER JOIN COLLECTIVEMEMBERSHIP CM ON I.GUIDREFERENCE = CM.INDIVIDUAL_ID
	INNER JOIN Panelist PL(NOLOCK) ON I.GUIDReference = PL.PanelMember_Id
	INNER JOIN Panel P(NOLOCK) ON P.GUIDReference = PL.Panel_Id
	INNER JOIN Country CO(NOLOCK) ON CO.CountryId = I.CountryId
	WHERE I.IndividualId = @pBusinessId
		AND CO.CountryISO2A = @pCountryCode

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,PL.State_Id
		,PanelStateId
		,NULL
		,@CountryId
		,PanelistGUID
	FROM Panelist PL
	INNER JOIN #Update_Panelist IPL ON PL.GUIDReference = IPL.PanelistGUID
	INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = IPL.IndividualGuid
	LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
		AND IL.[Description] = 'DEFAULT'
		AND IL.IsDefault = 1
		AND IL.Country_Id = @CountryId
	WHERE IPL.PanelType = 'Individual'
		AND IPL.PanelStateId IS NOT NULL
		AND CMP.State_Id <> @GroupMembershipDeceasedId
		AND CMP.State_Id <> @GroupMembershipNonResidentId
		AND PL.State_Id <> PanelStateId

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,PL.State_Id
		,IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
		,NULL
		,@CountryId
		,PanelistGUID
	FROM Panelist PL
	INNER JOIN #Update_Panelist IPL ON PL.GUIDReference = IPL.PanelistGUID
	INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = IPL.IndividualGuid
	LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
		AND IL.[Description] = 'DEFAULT'
		AND IL.IsDefault = 1
		AND IL.Country_Id = @CountryId
	WHERE IPL.PanelType = 'Individual'
		AND IPL.PanelStateId IS NOT NULL
		AND CMP.State_Id IN (
			@GroupMembershipDeceasedId
			,@GroupMembershipNonResidentId
			)
		AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,PL.State_Id
		,IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
		,NULL
		,@CountryId
		,PL.GUIDReference
	FROM Individual I
	INNER JOIN Panelist PL ON PL.PanelMember_Id = I.GUIDReference
	INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id
	INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = I.GUIDReference
	WHERE I.IndividualId = @pBusinessId
		AND P.[Type] = 'Individual'
		AND CMP.State_Id IN (
			@GroupMembershipDeceasedId
			,@GroupMembershipNonResidentId
			)
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = I.GUIDReference
			)
		AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

	UPDATE PL
	SET State_Id = IPL.PanelStateId
		,PL.GPSUpdateTimestamp = @GetDate
		,PL.GPSUser = @pUser
	FROM Panelist PL
	INNER JOIN #Update_Panelist IPL ON PL.GUIDReference = IPL.PanelistGUID
	INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = IPL.IndividualGuid
	LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
		AND IL.[Description] = 'DEFAULT'
		AND IL.IsDefault = 1
		AND IL.Country_Id = @CountryId
	WHERE IPL.PanelType = 'Individual'
		AND IPL.PanelStateId IS NOT NULL
		AND CMP.State_Id <> @GroupMembershipDeceasedId
		AND CMP.State_Id <> @GroupMembershipNonResidentId
		AND PL.State_Id <> IPL.PanelStateId

	UPDATE PL
	SET State_Id = IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
		,PL.GPSUpdateTimestamp = @GetDate
		,PL.GPSUser = @pUser
	FROM Panelist PL
	INNER JOIN #Update_Panelist IPL ON PL.GUIDReference = IPL.PanelistGUID
	INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = IPL.IndividualGuid
	LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
		AND IL.[Description] = 'DEFAULT'
		AND IL.IsDefault = 1
		AND IL.Country_Id = @CountryId
	WHERE IPL.PanelType = 'Individual'
		AND IPL.PanelStateId IS NOT NULL
		AND CMP.State_Id IN (
			@GroupMembershipDeceasedId
			,@GroupMembershipNonResidentId
			)
		AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

	UPDATE PL
	SET State_Id = IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
		,PL.GPSUpdateTimestamp = @GetDate
		,PL.GPSUser = @pUser
	FROM Individual I
	INNER JOIN Panelist PL ON PL.PanelMember_Id = I.GUIDReference
	INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id
	INNER JOIN CollectiveMembership CMP ON CMP.Individual_Id = I.GUIDReference
	WHERE I.IndividualId = @pBusinessId
		AND P.[Type] = 'Individual'
		AND CMP.State_Id IN (
			@GroupMembershipDeceasedId
			,@GroupMembershipNonResidentId
			)
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = I.GUIDReference
			)
		AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,PL.State_Id
		,PanelStateId
		,NULL
		,@CountryId
		,PanelistGUID
	FROM Panelist PL
	INNER JOIN #Update_Panelist IPL ON PL.Panel_Id = IPL.PanelGUID
		AND PL.PanelMember_Id = IPL.GroupGUID
	LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
		AND IL.[Description] = 'DEFAULT'
		AND IL.IsDefault = 1
		AND IL.Country_Id = @CountryId
	WHERE IPL.PanelType = 'HouseHold'
		AND IPL.PanelStateId IS NOT NULL
		AND 0 = ANY (
			SELECT IIF(CMP.State_Id <> @GroupMembershipDeceasedId
					AND CMP.State_Id <> @GroupMembershipNonResidentId, 0, 1)
			FROM Collective C
			INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = C.GUIDReference
			WHERE C.GUIDReference = IPL.GroupGUID
			)
		AND PL.State_Id <> PanelStateId

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,PL.State_Id
		,IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
		,NULL
		,@CountryId
		,PanelistGUID
	FROM Panelist PL
	INNER JOIN #Update_Panelist IPL ON PL.Panel_Id = IPL.PanelGUID
		AND PL.PanelMember_Id = IPL.GroupGUID
	LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
		AND IL.[Description] = 'DEFAULT'
		AND IL.IsDefault = 1
		AND IL.Country_Id = @CountryId
	WHERE IPL.PanelType = 'HouseHold'
		AND IPL.PanelStateId IS NOT NULL
		AND 1 = ALL (
			SELECT IIF(CMP.State_Id <> @GroupMembershipDeceasedId
					AND CMP.State_Id <> @GroupMembershipNonResidentId, 0, 1)
			FROM Collective C
			INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = C.GUIDReference
			WHERE C.GUIDReference = IPL.GroupGUID
			)
		AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

	UPDATE PL
	SET State_Id = IPL.PanelStateId
		,PL.GPSUpdateTimestamp = @GetDate
		,PL.GPSUser = @pUser
	FROM Panelist PL
	INNER JOIN #Update_Panelist IPL ON PL.Panel_Id = IPL.PanelGUID
		AND PL.PanelMember_Id = IPL.GroupGUID
	LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
		AND IL.[Description] = 'DEFAULT'
		AND IL.IsDefault = 1
		AND IL.Country_Id = @CountryId
	WHERE IPL.PanelType = 'HouseHold'
		AND IPL.PanelStateId IS NOT NULL
		AND 0 = ANY (
			SELECT IIF(CMP.State_Id <> @GroupMembershipDeceasedId
					AND CMP.State_Id <> @GroupMembershipNonResidentId, 0, 1)
			FROM Collective C
			INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = C.GUIDReference
			WHERE C.GUIDReference = IPL.GroupGUID
			)
		AND PL.State_Id <> IPL.PanelStateId

	UPDATE PL
	SET State_Id = IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
		,PL.GPSUpdateTimestamp = @GetDate
		,PL.GPSUser = @pUser
	FROM Panelist PL
	INNER JOIN #Update_Panelist IPL ON PL.Panel_Id = IPL.PanelGUID
		AND PL.PanelMember_Id = IPL.GroupGUID
	LEFT JOIN IncentiveLevel IL ON IL.Panel_Id = IPL.PanelGUID
		AND IL.[Description] = 'DEFAULT'
		AND IL.IsDefault = 1
		AND IL.Country_Id = @CountryId
	WHERE IPL.PanelType = 'HouseHold'
		AND IPL.PanelStateId IS NOT NULL
		AND 1 = ALL (
			SELECT IIF(CMP.State_Id <> @GroupMembershipDeceasedId
					AND CMP.State_Id <> @GroupMembershipNonResidentId, 0, 1)
			FROM Collective C
			INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = C.GUIDReference
			WHERE C.GUIDReference = IPL.GroupGUID
			)
		AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

	DECLARE @GROUPID UNIQUEIDENTIFIER
		,@INDIVIDUALGUID UNIQUEIDENTIFIER

	SELECT TOP 1 @GROUPID = CM.GROUP_ID
		,@INDIVIDUALGUID = I.GUIDREFERENCE
	FROM INDIVIDUAL I
	INNER JOIN COLLECTIVEMEMBERSHIP CM ON I.GUIDREFERENCE = CM.INDIVIDUAL_ID
	WHERE I.INDIVIDUALID = @pBusinessId

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,PL.State_Id
		,IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
		,NULL
		,@CountryId
		,PL.GUIDReference
	FROM Panelist PL
	INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id
		AND P.Country_Id = @CountryId
	WHERE PL.PanelMember_Id = @GROUPID
		AND P.[Type] = 'HouseHold'
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = @INDIVIDUALGUID
			)
		AND 1 = ALL (
			SELECT IIF(CMP.State_Id <> @GroupMembershipDeceasedId
					AND CMP.State_Id <> @GroupMembershipNonResidentId, 0, 1)
			FROM Collective C
			INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = C.GUIDReference
			WHERE C.GUIDReference = @GROUPID
			)
		AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

	UPDATE PL
	SET State_Id = IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)
		,PL.GPSUpdateTimestamp = @GetDate
		,PL.GPSUser = @pUser
	FROM Panelist PL
	INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id
		AND P.Country_Id = @CountryId
	WHERE P.[Type] = 'HouseHold'
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = @INDIVIDUALGUID
			)
		AND 1 = ALL (
			SELECT IIF(CMP.State_Id <> @GroupMembershipDeceasedId
					AND CMP.State_Id <> @GroupMembershipNonResidentId, 0, 1)
			FROM Collective C
			INNER JOIN CollectiveMembership CMP ON CMP.Group_Id = C.GUIDReference
			WHERE C.GUIDReference = @GROUPID
			)
		AND PL.State_Id <> IIF(PL.State_Id <> @PanelistPreLiveStateId
			AND PL.State_Id <> @PanelistLiveStateId, @PanelistRefusalStateId, @PanelistDropoutStateId)

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
	SELECT *
	FROM (
		SELECT NEWID() AS GUIDReference
			,@pUser AS UserId
			,@GetDate AS CreationDate
			,@GetDate AS GPSUpdateTimestamp
			,@GetDate AS CreationTimestamp
			,NULL AS Comments
			,0 AS CollaborateInFuture
			,C.CandidateStatus AS StateFrom
			,fns.[NextStatus] AS StateTo
			,NULL AS ReasonForChange
			,@CountryId AS CountryId
			,IPL.IndividualGuid AS CandidateId
		FROM #Update_Panelist IPL
		INNER JOIN CollectiveMembership CMP ON IPL.GroupGUID = CMP.Group_Id
		INNER JOIN Candidate C ON CMP.Individual_Id = C.GUIDReference
		CROSS APPLY [fnGetIndividualStatusTbl](CMP.Individual_Id) fns
		) AS St
	WHERE StateFrom <> StateTo

	UPDATE C
	SET C.CandidateStatus = fns.[NextStatus]
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM #Update_Panelist IPL
	INNER JOIN CollectiveMembership CMP ON IPL.GroupGUID = CMP.Group_Id
	INNER JOIN Candidate C ON CMP.Individual_Id = C.GUIDReference
	CROSS APPLY [fnGetIndividualStatusTbl](CMP.Individual_Id) fns
	WHERE C.CandidateStatus <> fns.[NextStatus]

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
	SELECT *
	FROM (
		SELECT NEWID() AS GUIDReference
			,@pUser AS UserId
			,@GetDate AS CreationDate
			,@GetDate AS GPSUpdateTimestamp
			,@GetDate AS CreationTimestamp
			,NULL AS Comments
			,0 AS CollaborateInFuture
			,C.CandidateStatus AS StateFrom
			,fns.[NextStatus] AS StateTo
			,NULL AS ReasonForChange
			,@CountryId AS CountryId
			,C.GUIDReference AS CandidateId
		FROM CollectiveMembership CMP
		INNER JOIN Candidate C ON C.GUIDReference = CMP.Individual_Id
		CROSS APPLY [fnGetIndividualStatusTbl](CMP.Individual_Id) fns
		WHERE CMP.GROUP_ID = @GROUPID
			AND NOT EXISTS (
				SELECT 1
				FROM #Update_Panelist UPL
				WHERE UPL.IndividualGuid = CMP.Individual_Id
				)
			AND C.CandidateStatus <> fns.[NextStatus]
		) AS St
	WHERE StateFrom <> StateTo

	UPDATE C
	SET C.CandidateStatus = CASE 
			WHEN CMP.State_Id = @GroupMembershipNonResidentId
				THEN @pIndividualStatusGuid
			ELSE fns.[NextStatus]
			END
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM CollectiveMembership CMP
	INNER JOIN Candidate C ON C.GUIDReference = CMP.Individual_Id
	CROSS APPLY [fnGetIndividualStatusTbl](CMP.Individual_Id) fns
	WHERE CMP.GROUP_ID = @GROUPID
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = CMP.Individual_Id
			)
		AND C.CandidateStatus <> fns.[NextStatus]

	DECLARE @individualDeceasedGuid UNIQUEIDENTIFIER
	DECLARE @individualAssignedGuid UNIQUEIDENTIFIER
	DECLARE @individualNonParticipent UNIQUEIDENTIFIER
	DECLARE @individualParticipent UNIQUEIDENTIFIER
	DECLARE @PanelImportStatus UNIQUEIDENTIFIER
	DECLARE @ImportBusinessId VARCHAR(50)
	DECLARE @individualDropOf UNIQUEIDENTIFIER = NULL

	SET @individualDeceasedGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'IndividualDeceased'
				AND Country_Id = @CountryId
			)
	SET @individualDropOf = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'IndividualTerminated'
				AND Country_Id = @CountryId
			)
	SET @pIndividualStatusGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'IndividualCandidate'
				AND Country_Id = @CountryId
			)
	SET @individualAssignedGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'IndividualAssigned'
				AND Country_Id = @CountryId
			)
	SET @individualNonParticipent = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'IndividualNonParticipant'
				AND Country_Id = @CountryId
			)
	SET @individualParticipent = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'IndividualParticipant'
				AND Country_Id = @CountryId
			)

	DECLARE @FromStateIndividualGuid UNIQUEIDENTIFIER

	SET @FromStateIndividualGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'IndividualPreseted'
				AND Country_Id = @CountryId
			)

	DECLARE @groupStatusGuid UNIQUEIDENTIFIER
	DECLARE @groupAssignedStatusGuid UNIQUEIDENTIFIER
	DECLARE @groupParticipantStatusGuid UNIQUEIDENTIFIER
	DECLARE @groupTerminatedStatusGuid UNIQUEIDENTIFIER
	DECLARE @groupDeceasedStatusGuid UNIQUEIDENTIFIER

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
	SET @groupDeceasedStatusGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'GroupDeceased'
				AND Country_Id = @CountryId
			)
	SET @groupStatusGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'GroupCandidate'
				AND Country_Id = @CountryId
			)

	DECLARE @existingroupStatusGuid UNIQUEIDENTIFIER

	SET @existingroupStatusGuid = (
			SELECT Id
			FROM StateDefinition
			WHERE Code = 'GroupPreseted'
				AND Country_Id = @CountryId
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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupTerminatedStatusGuid
		,NULL
		,@CountryId
		,IPL.GroupGuid
	FROM #Update_Panelist IPL
	INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
	WHERE @individualDropOf = ALL (
			SELECT I.CandidateStatus
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupTerminatedStatusGuid

	UPDATE C
	SET C.CandidateStatus = @groupTerminatedStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM #Update_Panelist IPL
	INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
	WHERE @individualDropOf = ALL (
			SELECT I.CandidateStatus
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupTerminatedStatusGuid
		,NULL
		,@CountryId
		,IPL.GroupGuid
	FROM #Update_Panelist IPL
	INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
	WHERE C.CandidateStatus <> @groupTerminatedStatusGuid
		AND 1 = ALL (
			SELECT IIF(CM.State_Id <> @GroupMembershipDeceasedId
					AND CM.State_Id <> @GroupMembershipNonResidentId, 0, 1)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND 1 = ANY (
			SELECT IIF(CM.State_Id = @GroupMembershipNonResidentId, 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)

	UPDATE C
	SET C.CandidateStatus = @groupTerminatedStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM #Update_Panelist IPL
	INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
	WHERE C.CandidateStatus <> @groupTerminatedStatusGuid
		AND 1 = ALL (
			SELECT IIF(CM.State_Id <> @GroupMembershipDeceasedId
					AND CM.State_Id <> @GroupMembershipNonResidentId, 0, 1)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND 1 = ANY (
			SELECT IIF(CM.State_Id = @GroupMembershipNonResidentId, 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupDeceasedStatusGuid
		,NULL
		,@CountryId
		,IPL.GroupGuid
	FROM #Update_Panelist IPL
	INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
	WHERE C.CandidateStatus <> @groupDeceasedStatusGuid
		AND 0 = ALL (
			SELECT IIF(CM.State_Id = @GroupMembershipDeceasedId, 0, 1)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)

	UPDATE C
	SET C.CandidateStatus = @groupDeceasedStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM #Update_Panelist IPL
	INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
	WHERE C.CandidateStatus <> @groupDeceasedStatusGuid
		AND 0 = ALL (
			SELECT IIF(CM.State_Id = @GroupMembershipDeceasedId, 0, 1)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupParticipantStatusGuid
		,NULL
		,@CountryId
		,IPL.GroupGuid
	FROM #Update_Panelist IPL
	INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
	WHERE @individualParticipent = ANY (
			SELECT I.CandidateStatus
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupParticipantStatusGuid

	UPDATE C
	SET C.CandidateStatus = @groupParticipantStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM #Update_Panelist IPL
	INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
	WHERE @individualParticipent = ANY (
			SELECT I.CandidateStatus
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupParticipantStatusGuid

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupAssignedStatusGuid
		,NULL
		,@CountryId
		,IPL.GroupGuid
	FROM #Update_Panelist IPL
	INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
	WHERE EXISTS (
			SELECT 1
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
				AND I.CandidateStatus NOT IN (
					@individualParticipent
					,@pIndividualStatusGuid
					,@individualDropOf
					)
			)
		AND @individualAssignedGuid = ANY (
			SELECT I.CandidateStatus
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupAssignedStatusGuid

	UPDATE C
	SET C.CandidateStatus = @groupAssignedStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM #Update_Panelist IPL
	INNER JOIN Candidate C ON IPL.GroupGUID = C.GUIDReference
	WHERE EXISTS (
			SELECT 1
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
				AND I.CandidateStatus NOT IN (
					@individualParticipent
					,@pIndividualStatusGuid
					,@individualDropOf
					)
			)
		AND @individualAssignedGuid = ANY (
			SELECT I.CandidateStatus
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupAssignedStatusGuid

	-------------------------------------------------------------
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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupTerminatedStatusGuid
		,NULL
		,@CountryId
		,CM.Group_Id
	FROM Candidate C
	INNER JOIN COLLECTIVEMEMBERSHIP CM ON C.GUIDReference = CM.Individual_Id
	WHERE C.GUIDReference = @GROUPID
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = C.GUIDReference
			)
		AND @individualDropOf = ALL (
			SELECT I.CandidateStatus
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupTerminatedStatusGuid

	UPDATE C
	SET C.CandidateStatus = @groupTerminatedStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM Candidate C
	INNER JOIN COLLECTIVEMEMBERSHIP CM ON C.GUIDReference = CM.Individual_Id
	WHERE C.GUIDReference = @GROUPID
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = C.GUIDReference
			)
		AND @individualDropOf = ALL (
			SELECT I.CandidateStatus
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupTerminatedStatusGuid

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupTerminatedStatusGuid
		,NULL
		,@CountryId
		,CM.Group_id
	FROM Candidate C
	INNER JOIN COLLECTIVEMEMBERSHIP CM ON C.GUIDReference = CM.Individual_Id
	WHERE C.GUIDReference = @GROUPID
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = C.GUIDReference
			)
		AND 1 = ALL (
			SELECT IIF(CM.State_Id <> @GroupMembershipDeceasedId
					AND CM.State_Id <> @GroupMembershipNonResidentId, 0, 1)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND 1 = ANY (
			SELECT IIF(CM.State_Id = @GroupMembershipNonResidentId, 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupTerminatedStatusGuid

	UPDATE C
	SET C.CandidateStatus = @groupTerminatedStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM Candidate C
	INNER JOIN COLLECTIVEMEMBERSHIP CM ON C.GUIDReference = CM.Individual_Id
	WHERE C.GUIDReference = @GROUPID
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = C.GUIDReference
			)
		AND 1 = ALL (
			SELECT IIF(CM.State_Id <> @GroupMembershipDeceasedId
					AND CM.State_Id <> @GroupMembershipNonResidentId, 0, 1)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND 1 = ANY (
			SELECT IIF(CM.State_Id = @GroupMembershipNonResidentId, 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupTerminatedStatusGuid

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupDeceasedStatusGuid
		,NULL
		,@CountryId
		,CM.Group_id
	FROM Candidate C
	INNER JOIN COLLECTIVEMEMBERSHIP CM ON C.GUIDReference = CM.Individual_Id
	WHERE C.GUIDReference = @GROUPID
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = C.GUIDReference
			)
		AND 0 = ALL (
			SELECT IIF(CM.State_Id = @GroupMembershipDeceasedId, 0, 1)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupDeceasedStatusGuid

	UPDATE C
	SET C.CandidateStatus = @groupDeceasedStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM Candidate C
	INNER JOIN COLLECTIVEMEMBERSHIP CM ON C.GUIDReference = CM.Individual_Id
	WHERE C.GUIDReference = @GROUPID
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = C.GUIDReference
			)
		AND 0 = ALL (
			SELECT IIF(CM.State_Id = @GroupMembershipDeceasedId, 0, 1)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupDeceasedStatusGuid

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupParticipantStatusGuid
		,NULL
		,@CountryId
		,CM.Group_id
	FROM Candidate C
	INNER JOIN COLLECTIVEMEMBERSHIP CM ON C.GUIDReference = CM.Individual_Id
	WHERE C.GUIDReference = @GROUPID
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = C.GUIDReference
			)
		AND @individualParticipent = ANY (
			SELECT I.CandidateStatus
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupParticipantStatusGuid

	UPDATE C
	SET C.CandidateStatus = @groupParticipantStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM Candidate C
	INNER JOIN COLLECTIVEMEMBERSHIP CM ON C.GUIDReference = CM.Individual_Id
	WHERE C.GUIDReference = @GROUPID
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = C.GUIDReference
			)
		AND @individualParticipent = ANY (
			SELECT I.CandidateStatus
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupParticipantStatusGuid

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupAssignedStatusGuid
		,NULL
		,@CountryId
		,CM.Group_id
	FROM Candidate C
	INNER JOIN COLLECTIVEMEMBERSHIP CM ON C.GUIDReference = CM.Individual_Id
	WHERE C.GUIDReference = @GROUPID
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = C.GUIDReference
			)
		AND EXISTS (
			SELECT 1
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
				AND I.CandidateStatus NOT IN (
					@individualParticipent
					,@pIndividualStatusGuid
					,@individualDropOf
					)
			)
		AND @individualAssignedGuid = ANY (
			SELECT I.CandidateStatus
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupAssignedStatusGuid

	UPDATE C
	SET C.CandidateStatus = @groupAssignedStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM Candidate C
	INNER JOIN COLLECTIVEMEMBERSHIP CM ON C.GUIDReference = CM.Individual_Id
	WHERE C.GUIDReference = @GROUPID
		AND NOT EXISTS (
			SELECT 1
			FROM #Update_Panelist UPL
			WHERE UPL.IndividualGuid = C.GUIDReference
			)
		AND EXISTS (
			SELECT 1
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
				AND I.CandidateStatus NOT IN (
					@individualParticipent
					,@pIndividualStatusGuid
					,@individualDropOf
					)
			)
		AND @individualAssignedGuid = ANY (
			SELECT I.CandidateStatus
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupAssignedStatusGuid

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupTerminatedStatusGuid
		,NULL
		,@CountryId
		,@GROUPID
	FROM Candidate C
	WHERE C.GUIDReference = @GROUPID
		AND 1 = ALL (
			SELECT IIF(I.CandidateStatus IN (
						@pIndividualStatusGuid
						,@individualDropOf
						,@individualDeceasedGuid
						), 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND 1 = ANY (
			SELECT IIF(I.CandidateStatus IN (
						@individualDropOf
						,@individualDeceasedGuid
						), 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND 1 = ANY (
			SELECT IIF(I.CandidateStatus <> @individualDeceasedGuid, 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupTerminatedStatusGuid

	UPDATE C
	SET C.CandidateStatus = @groupTerminatedStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM Candidate C
	WHERE C.GUIDReference = @GROUPID
		AND 1 = ALL (
			SELECT IIF(I.CandidateStatus IN (
						@pIndividualStatusGuid
						,@individualDropOf
						,@individualDeceasedGuid
						), 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND 1 = ANY (
			SELECT IIF(I.CandidateStatus IN (
						@individualDropOf
						,@individualDeceasedGuid
						), 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND 1 = ANY (
			SELECT IIF(I.CandidateStatus <> @individualDeceasedGuid, 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupTerminatedStatusGuid

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupDeceasedStatusGuid
		,NULL
		,@CountryId
		,@GROUPID
	FROM Candidate C
	WHERE C.GUIDReference = @GROUPID
		AND 0 = ALL (
			SELECT IIF(I.CandidateStatus <> @individualDeceasedGuid, 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupDeceasedStatusGuid

	UPDATE C
	SET C.CandidateStatus = @groupDeceasedStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM Candidate C
	WHERE C.GUIDReference = @GROUPID
		AND 0 = ALL (
			SELECT IIF(I.CandidateStatus <> @individualDeceasedGuid, 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupDeceasedStatusGuid

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
		,@pUser
		,@GetDate
		,@GetDate
		,@GetDate
		,NULL
		,0
		,C.CandidateStatus
		,@groupStatusGuid
		,NULL
		,@CountryId
		,@GROUPID
	FROM Candidate C
	WHERE C.GUIDReference = @GROUPID
		AND 1 = ALL (
			SELECT IIF(I.CandidateStatus = @pIndividualStatusGuid, 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupStatusGuid

	UPDATE C
	SET C.CandidateStatus = @groupStatusGuid
		,C.GPSUpdateTimestamp = @GetDate
		,C.GPSUser = @pUser
	FROM Candidate C
	WHERE C.GUIDReference = @GROUPID
		AND 1 = ALL (
			SELECT IIF(I.CandidateStatus = @pIndividualStatusGuid, 1, 0)
			FROM CollectiveMembership CM
			INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
			WHERE CM.Group_Id = C.GUIDReference
			)
		AND C.CandidateStatus <> @groupStatusGuid

	INSERT INTO DynamicRoleAssignment (
		DynamicRoleAssignmentId
		,DynamicRole_Id
		,Candidate_Id
		,Group_Id
		,CreationTimeStamp
		,GPSUpdateTimestamp
		,GPSUser
		,Country_Id
		)
	SELECT NEWID()
		,DR.DynamicRoleId
		,IPL.IndividualGuid
		,IPL.GroupGUID
		,@GetDate
		,@GetDate
		,@pUser
		,@CountryId
	FROM #Update_Panelist IPL
	INNER JOIN DynamicRole DR ON IPL.[GroupRoleCode] = DR.[Code]
		AND DR.Country_Id = @CountryId
	WHERE DR.Country_Id = @CountryId
		AND NOT EXISTS (
			SELECT 1
			FROM DynamicRoleAssignment DRA
			WHERE DRA.DynamicRole_Id = DR.DynamicRoleId
				AND DRA.Candidate_Id = IPL.IndividualGuid
				AND DRA.Group_Id = IPL.GroupGUID
			)
END

GO


