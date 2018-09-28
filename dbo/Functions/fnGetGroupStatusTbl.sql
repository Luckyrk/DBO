CREATE FUNCTION [dbo].[fnGetGroupStatusTbl] (@GroupGUID uniqueidentifier)
RETURNS @tblGroupStatus TABLE (
  NextStatus uniqueidentifier
)
BEGIN

  DECLARE @groupStatusGuid uniqueidentifier
  DECLARE @groupAssignedStatusGuid uniqueidentifier
  DECLARE @groupParticipantStatusGuid uniqueidentifier
  DECLARE @groupTerminatedStatusGuid uniqueidentifier
  DECLARE @groupDeceasedStatusGuid uniqueidentifier
  DECLARE @individualDropOf uniqueidentifier = NULL
  DECLARE @individualStatusGuid uniqueidentifier
  DECLARE @individualAssignedGuid uniqueidentifier
  DECLARE @individualParticipent uniqueidentifier
  DECLARE @ReturnStateId AS uniqueidentifier
  DECLARE @GroupMembershipNonResidentId uniqueidentifier
  DECLARE @individualNonParticipant uniqueidentifier
  DECLARE @GroupMembershipDeceasedId uniqueidentifier
  DECLARE @CountryId uniqueidentifier
  DECLARE @GPSUser varchar(100) = 'GPSUser'

  SELECT
    @CountryId = Country_Id
  FROM CollectiveMembership
  WHERE Group_Id = @GroupGUID

  SELECT
    @GroupMembershipNonResidentId = sd.Id
  FROM StateDefinition sd
  INNER JOIN Country c
    ON c.CountryId = sd.Country_Id
  WHERE c.CountryId = @CountryId
  AND sd.Code = 'GroupMembershipNonResident'

  SELECT
    @GroupMembershipDeceasedId = sd.Id
  FROM StateDefinition sd
  INNER JOIN Country c
    ON c.CountryId = sd.Country_Id
  WHERE c.CountryId = @CountryId
  AND sd.Code = 'GroupMembershipDeceased'


  SET @groupAssignedStatusGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'GroupAssigned'
  AND Country_Id = @CountryId)
  SET @groupParticipantStatusGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'GroupParticipant'
  AND Country_Id = @CountryId)
  SET @groupTerminatedStatusGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'GroupTerminated'
  AND Country_Id = @CountryId)
  SET @groupDeceasedStatusGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'GroupDeceased'
  AND Country_Id = @CountryId)
  SET @groupStatusGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'GroupCandidate'
  AND Country_Id = @CountryId)

  SET @individualDropOf = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'IndividualTerminated'
  AND Country_Id = @CountryId)
  SET @individualStatusGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'IndividualCandidate'
  AND Country_Id = @CountryId)
  SET @individualAssignedGuid = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'IndividualAssigned'
  AND Country_Id = @CountryId)

  SET @individualParticipent = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'IndividualParticipant'
  AND Country_Id = @CountryId)

   SET @individualNonParticipant = (SELECT
    Id
  FROM StateDefinition
  WHERE Code = 'IndividualNonParticipant'
  AND Country_Id = @CountryId)



  IF EXISTS (SELECT
      1
    FROM Candidate C
    WHERE C.GUIDReference = @GroupGUID
    AND @individualDropOf = ALL (SELECT
      I.CandidateStatus
    FROM CollectiveMembership CM
    INNER JOIN Candidate I
      ON CM.Individual_Id = I.GUIDReference
    WHERE CM.Group_Id = C.GUIDReference))
  BEGIN
    SET @ReturnStateId = @groupTerminatedStatusGuid

    INSERT INTO @tblGroupStatus
      SELECT
        @ReturnStateId;
    RETURN;
  END

  IF EXISTS (SELECT
      1
    FROM Candidate C
    WHERE C.GUIDReference = @GroupGUID
    AND 1 = ALL (SELECT
      IIF(I.CandidateStatus<>@individualDropOf AND I.CandidateStatus<>@individualNonParticipant,0,1)
    FROM CollectiveMembership CM
    INNER JOIN Candidate I ON CM.Individual_Id = I.GUIDReference
    WHERE CM.Group_Id = C.GUIDReference))
  BEGIN
    SET @ReturnStateId = @groupTerminatedStatusGuid

    INSERT INTO @tblGroupStatus
      SELECT
        @ReturnStateId;
    RETURN;
  END


  IF EXISTS (SELECT
      1
    FROM Candidate C
    WHERE C.GUIDReference = @GroupGUID
    AND C.CandidateStatus <> @groupTerminatedStatusGuid
    AND 1 = ALL (SELECT
      IIF(CM.State_Id <> @GroupMembershipDeceasedId AND CM.State_Id <> @GroupMembershipNonResidentId, 0, 1)
    FROM CollectiveMembership CM
    INNER JOIN Candidate I
      ON CM.Individual_Id = I.GUIDReference
    WHERE CM.Group_Id = C.GUIDReference)
    AND 1 = ANY (SELECT
      IIF(CM.State_Id = @GroupMembershipNonResidentId, 1, 0)
    FROM CollectiveMembership CM
    INNER JOIN Candidate I
      ON CM.Individual_Id = I.GUIDReference
    WHERE CM.Group_Id = C.GUIDReference))
  BEGIN
    SET @ReturnStateId = @groupTerminatedStatusGuid
    INSERT INTO @tblGroupStatus
      SELECT
        @ReturnStateId;
    RETURN;
  END



  IF EXISTS (SELECT
      1
    FROM Candidate C
    WHERE C.GUIDReference = @GroupGUID
    AND C.CandidateStatus <> @groupDeceasedStatusGuid
    AND 0 = ALL (SELECT
      IIF(CM.State_Id = @GroupMembershipDeceasedId, 0, 1)
    FROM CollectiveMembership CM
    INNER JOIN Candidate I
      ON CM.Individual_Id = I.GUIDReference
    WHERE CM.Group_Id = C.GUIDReference))
  BEGIN
    SET @ReturnStateId = @groupDeceasedStatusGuid
    INSERT INTO @tblGroupStatus
      SELECT
        @ReturnStateId;
    RETURN;
  END



  IF EXISTS (SELECT
      1
    FROM Candidate C
    WHERE C.GUIDReference = @GroupGUID
    AND @individualParticipent = ANY (SELECT
      I.CandidateStatus
    FROM CollectiveMembership CM
    INNER JOIN Candidate I
      ON CM.Individual_Id = I.GUIDReference
    WHERE CM.Group_Id = C.GUIDReference)
    AND C.CandidateStatus <> @groupParticipantStatusGuid)
  BEGIN
    SET @ReturnStateId = @groupParticipantStatusGuid
    INSERT INTO @tblGroupStatus
      SELECT
        @ReturnStateId;
    RETURN;
  END



  IF EXISTS (SELECT
      1
    FROM Candidate C
    WHERE C.GUIDReference = @GroupGUID
    AND EXISTS (SELECT
      1
    FROM CollectiveMembership CM
    INNER JOIN Candidate I
      ON CM.Individual_Id = I.GUIDReference
    WHERE CM.Group_Id = C.GUIDReference
    AND I.CandidateStatus NOT IN (
    @individualParticipent
    , @individualStatusGuid
    , @individualDropOf
    ))
    AND @individualAssignedGuid = ANY (SELECT
      I.CandidateStatus
    FROM CollectiveMembership CM
    INNER JOIN Candidate I
      ON CM.Individual_Id = I.GUIDReference
    WHERE CM.Group_Id = C.GUIDReference)
    AND C.CandidateStatus <> @groupAssignedStatusGuid)
  BEGIN
    SET @ReturnStateId = @groupAssignedStatusGuid
    INSERT INTO @tblGroupStatus
      SELECT
        @ReturnStateId;
    RETURN;
  END

  INSERT INTO @tblGroupStatus
    SELECT
      @ReturnStateId;
  RETURN;

END