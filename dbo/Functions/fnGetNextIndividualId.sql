CREATE FUNCTION [dbo].[fnGetNextIndividualId]
(
 @FromIndividualId UNIQUEIDENTIFIER
)
RETURNS @tblIndividualStatus TABLE (NextIndividualGUID UNIQUEIDENTIFIER)
BEGIN

	DECLARE @GroupMembershipDeceasedId UNIQUEIDENTIFIER
	DECLARE @CountryId UNIQUEIDENTIFIER
	DECLARE @GroupMembershipNonResidentId UNIQUEIDENTIFIER
	DECLARE @individualDropOf UNIQUEIDENTIFIER
	DECLARE @CollectiveSequence BIGINT

	SELECT @CountryId=CountryId FROM Individual WHERE GUIDReference=@FromIndividualId

	SELECT @GroupMembershipDeceasedId=sd.Id 
	FROM StateDefinition sd 
	INNER JOIN Country c on c.CountryId=sd.Country_Id
	WHERE c.CountryId=@CountryId and sd.Code='GroupMembershipDeceased'

	SELECT @GroupMembershipNonResidentId=sd.Id 
	FROM StateDefinition sd 
	INNER JOIN Country c on c.CountryId=sd.Country_Id
	WHERE c.CountryId=@CountryId and sd.Code='GroupMembershipNonResident'

	--SET @individualDropOf = (
	--SELECT Id
	--FROM StateDefinition
	--WHERE Code = 'IndividualTerminated'
	--	AND Country_Id = @CountryId)
	
	SELECT  @CollectiveSequence=C.Sequence
	FROM CollectiveMembership CMP 
	INNER JOIN Collective C ON C.GUIDReference=CMP.Group_Id AND C.CountryId=CMP.Country_Id
	WHERE CMP.Individual_Id=@FromIndividualId

	INSERT INTO @tblIndividualStatus(NextIndividualGUID)
	SELECT TOP (1) I.GUIDReference AS NextIndividualId
	FROM   CollectiveMembership CMP
	INNER JOIN Individual I ON I.GUIDReference=CMP.Individual_Id
	INNER JOIN Candidate Can ON Can.GUIDReference=I.GUIDReference
	INNER JOIN Collective C ON CMP.Group_Id=C.GUIDReference
	WHERE C.Sequence=@CollectiveSequence AND I.CountryId=@CountryId 
	AND CMP.State_Id NOT IN (@GroupMembershipDeceasedId,@GroupMembershipNonResidentId)
	AND I.GUIDReference<>@FromIndividualId
	--AND Can.CandidateStatus<>@individualDropOf
	ORDER BY CMP.Sequence

	IF NOT EXISTS(SELECT 1 FROM @tblIndividualStatus)
	BEGIN
		INSERT INTO @tblIndividualStatus(NextIndividualGUID) VALUES (@FromIndividualId)
	END

	RETURN ;
END