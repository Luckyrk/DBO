CREATE FUNCTION [dbo].[fnGetIndividualStatus_Tbl](@IndividualGUID UNIQUEIDENTIFIER)  
RETURNS @tblIndividualStatus TABLE (CandidateID UNIQUEIDENTIFIER,StateID UNIQUEIDENTIFIER)
BEGIN

	DECLARE @GroupGUID UNIQUEIDENTIFIER
	DECLARE @GroupContactID UNIQUEIDENTIFIER
	DECLARE @IsGroupContact BIT=0
	DECLARE @MainContactGUID UNIQUEIDENTIFIER
	DECLARE @individualAssignedGuid UNIQUEIDENTIFIER
	DECLARE @PanelistDefaultStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistPresetedStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistLiveStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistPreLiveStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistDropoutStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistRefusalStateId AS UNIQUEIDENTIFIER
	DECLARE @IndividualCandidate AS UNIQUEIDENTIFIER
	DECLARE @ReturnStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistInterestedStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistMaterialSentStateId AS UNIQUEIDENTIFIER
	DECLARE @PanelistInvitedStateId AS UNIQUEIDENTIFIER
	DECLARE	@CountryId	UNIQUEIDENTIFIER
	DECLARE	@GPSUser	VARCHAR(100) = 'GPSUser'
	DECLARE @individualNonParticipent uniqueidentifier = NULL


	SELECT @GroupGUID=Group_Id,@CountryId=Country_Id FROM CollectiveMembership WHERE Individual_Id=@IndividualGUID

	IF EXISTS (SELECT 1 FROM Collective WHERE GUIDReference=@GroupGUID AND GroupContact_Id=@IndividualGUID)
	BEGIN
		SET @IsGroupContact=1
	END


	SET @IndividualCandidate = (SELECT
	Id
	FROM StateDefinition
	WHERE Code = 'IndividualCandidate'
	AND Country_Id = @CountryId)

	SELECT @GroupContactID=GroupContact_Id FROM Collective WHERE GUIDReference=@GroupGUID AND CountryId=@CountryId


	SET @individualNonParticipent = (SELECT
	Id
	FROM StateDefinition
	WHERE Code = 'IndividualNonParticipant'
	AND Country_Id = @CountryId)


	SELECT
	@PanelistPresetedStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistPresetedState'
	AND Country_Id = @CountryId

	SELECT
	@PanelistDefaultStateId = (SELECT TOP 1
		st.ToState_Id
	FROM statedefinition sd
	INNER JOIN StateDefinitionsTransitions SDT
		ON SDT.StateDefinition_Id = SD.Id
	INNER JOIN StateTransition st
		ON st.Id = sdt.AvailableTransition_Id
	INNER JOIN Country C
		ON C.CountryId = sd.Country_Id
	WHERE sd.code = 'PanelistPresetedState'
	AND c.CountryId = @CountryId
	ORDER BY st.CreationTimeStamp, st.[Priority])

	SELECT
	@PanelistLiveStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistLiveState'
	AND Country_Id = @CountryId


	SELECT
	@PanelistInterestedStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistInterestedState'
	AND Country_Id = @CountryId

	SELECT
	@PanelistInvitedStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistInvitedState'
	AND Country_Id = @CountryId


	SELECT
	@PanelistMaterialSentStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistMaterialSentState'
	AND Country_Id = @CountryId

	SELECT
	@PanelistPreLiveStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistPreLiveState'
	AND Country_Id = @CountryId


	SELECT
	@PanelistDropoutStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistDroppedOffState'
	AND Country_Id = @CountryId

	SELECT
	@PanelistRefusalStateId = Id
	FROM StateDefinition
	WHERE Code = 'PanelistRefusalState'
	AND Country_Id = @CountryId

	SET @individualAssignedGuid = (SELECT
	Id
	FROM StateDefinition
	WHERE Code = 'IndividualAssigned'
	AND Country_Id = @CountryId)

	SELECT
	@MainContactGUID = DR.DynamicRoleId
	FROM DynamicRole DR
	INNER JOIN Translation TR
	ON DR.Translation_Id = TR.TranslationId
	WHERE TR.KeyName = 'MainContactRoleName'
	AND DR.Country_Id = @CountryId

	DECLARE @individualParticipent uniqueidentifier = NULL

	SET @individualParticipent = (SELECT
	Id
	FROM StateDefinition
	WHERE Code = 'IndividualParticipant'
	AND Country_Id = @CountryId)

	DECLARE @individualDropOf uniqueidentifier = NULL

	SET @individualDropOf = (SELECT
	Id
	FROM StateDefinition
	WHERE Code = 'IndividualTerminated'
	AND Country_Id = @CountryId)

	IF NOT EXISTS (SELECT 1 FROM Panelist WHERE PanelMember_Id=@IndividualGUID) AND NOT EXISTS (SELECT 1 FROM Panelist WHERE PanelMember_Id=@GroupGUID)
	BEGIN
		SET @ReturnStateId=@IndividualCandidate
			INSERT INTO @tblIndividualStatus(CandidateID,StateID)  VALUES(@IndividualGUID,@ReturnStateId)
		RETURN ;
	END
	ELSE IF EXISTS (SELECT 1 FROM Panelist PL 
				INNER JOIN Panel P ON P.GUIDReference=PL.Panel_Id
				LEFT JOIN DynamicRoleAssignment DRA ON DRA.Panelist_Id=PL.GUIDReference AND DRA.DynamicRole_Id=@MainContactGUID
				WHERE PanelMember_Id=@GroupGUID AND  
				((DRA.DynamicRoleAssignmentId IS NULL AND @GroupContactID=@IndividualGUID) OR (DRA.DynamicRoleAssignmentId IS NOT NULL AND DRA.Candidate_Id=@IndividualGUID)) AND
				 PL.State_Id=@PanelistLiveStateId AND
					 P.[Type]='HouseHold')
	BEGIN
		SET @ReturnStateId=@individualParticipent
			INSERT INTO @tblIndividualStatus(CandidateID,StateID)  VALUES(@IndividualGUID,@ReturnStateId)
		RETURN ;
	END
	ELSE IF EXISTS (SELECT 1 FROM Panelist PL 
					INNER JOIN Panel P ON P.GUIDReference=PL.Panel_Id
					WHERE PanelMember_Id=@IndividualGUID 
					AND PL.State_Id=@PanelistLiveStateId AND P.[Type]='Individual')
	BEGIN
		SET @ReturnStateId=@individualParticipent
		INSERT INTO @tblIndividualStatus(CandidateID,StateID)  VALUES(@IndividualGUID,@ReturnStateId)
		RETURN ;
	END
	ELSE IF EXISTS (SELECT 1 FROM Panelist PL 
					INNER JOIN Panel P ON P.GUIDReference=PL.Panel_Id
					LEFT JOIN DynamicRoleAssignment DRA ON DRA.Panelist_Id=PL.GUIDReference AND DRA.Candidate_Id=@IndividualGUID AND DRA.DynamicRole_Id=@MainContactGUID
					WHERE PanelMember_Id=@GroupGUID 
					AND (DRA.DynamicRoleAssignmentId IS NOT NULL OR @IsGroupContact=1) 
					AND PL.State_Id IN (@PanelistDefaultStateId,@PanelistInterestedStateId,@PanelistInvitedStateId,@PanelistPreLiveStateId,@PanelistPresetedStateId) 
					AND P.[Type]='HouseHold')
	BEGIN
		SET @ReturnStateId=@individualAssignedGuid
			INSERT INTO @tblIndividualStatus(CandidateID,StateID)  VALUES(@IndividualGUID,@ReturnStateId)
		RETURN;
	END
	ELSE IF EXISTS (SELECT 1 FROM Panelist PL 
					INNER JOIN Panel P ON P.GUIDReference=PL.Panel_Id
					WHERE PanelMember_Id=@IndividualGUID 
					AND PL.State_Id IN (@PanelistDefaultStateId,@PanelistInterestedStateId,@PanelistInvitedStateId,@PanelistPreLiveStateId,@PanelistPresetedStateId) 
					AND P.[Type]='Individual')
	BEGIN
		SET @ReturnStateId=@individualAssignedGuid
			INSERT INTO @tblIndividualStatus(CandidateID,StateID)  VALUES(@IndividualGUID,@ReturnStateId)
		RETURN ;
	END
	ELSE IF EXISTS (SELECT PL.State_Id FROM Panelist PL 
					INNER JOIN Panel P ON P.GUIDReference=PL.Panel_Id
					INNER JOIN DynamicRoleAssignment DRA ON DRA.Panelist_Id=PL.GUIDReference AND DRA.Candidate_Id=@IndividualGUID AND DRA.DynamicRole_Id=@MainContactGUID
					WHERE PanelMember_Id=@GroupGUID 
					AND (DRA.DynamicRoleAssignmentId IS NOT NULL OR @IsGroupContact=1) 
					AND P.[Type]='HouseHold'
					AND PL.State_Id = ANY (SELECT @PanelistDropoutStateId UNION SELECT @PanelistRefusalStateId) 
					)
	BEGIN
		SET @ReturnStateId=@individualDropOf
			INSERT INTO @tblIndividualStatus(CandidateID,StateID)  VALUES(@IndividualGUID,@ReturnStateId)
		RETURN ;
	END
	ELSE IF NOT EXISTS (SELECT PL.State_Id FROM Panelist PL 
					INNER JOIN Panel P ON P.GUIDReference=PL.Panel_Id
					WHERE PanelMember_Id=@IndividualGUID 
					AND P.[Type]='Individual'
					AND PL.State_Id NOT IN (SELECT @PanelistDropoutStateId UNION SELECT @PanelistRefusalStateId) 
					)
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM Panelist PL 
					INNER JOIN Panel P ON P.GUIDReference=PL.Panel_Id
					WHERE PanelMember_Id=@GroupGUID 
					AND P.[Type]='HouseHold'
					AND PL.State_Id NOT IN (SELECT @PanelistDropoutStateId UNION SELECT @PanelistRefusalStateId))
		BEGIN
			SET @ReturnStateId=@individualDropOf

		END
		ELSE
		BEGIN
			SET @ReturnStateId=@individualNonParticipent
		END
			INSERT INTO @tblIndividualStatus(CandidateID,StateID)  VALUES(@IndividualGUID,@ReturnStateId)
		RETURN ;
	END
	ELSE 
	BEGIN 
		SET @ReturnStateId=@individualNonParticipent
			INSERT INTO @tblIndividualStatus(CandidateID,StateID)  VALUES(@IndividualGUID,@ReturnStateId)
		RETURN ;
	END
		INSERT INTO @tblIndividualStatus(CandidateID,StateID)  VALUES(@IndividualGUID,@ReturnStateId)
	RETURN ;
END