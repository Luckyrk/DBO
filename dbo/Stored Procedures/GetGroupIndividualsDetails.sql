/*
**************************************************************************
-- Name				: GetGroupIndividualsDetails
-- Date             : 2015-03-20
-- Author           : Ramana
-- Purpose          : Gets individual details present in the group
  --param definitions
	-- Usage            : 
	-- Impact           : 
	-- Required grants  : 
	-- Called by        : Called from UI
	-- PARAM Definitions
	-- @pGroupMembershipId UNIQUEIDENTIFIER
	--,@pCountryId UNIQUEIDENTIFIER

EXEC GetGroupIndividualsDetails '8C009AA7-FD3D-C79A-6D36-08D11B00469E' ,2057
##########################################################################
-- ver  user        date			change 
-- 1.0  Ramana    2015-03-20		initial
########################################################################## 
*/
CREATE PROCEDURE [dbo].[GetGroupIndividualsDetails] @pGroupMembershipId UNIQUEIDENTIFIER
	,@pCultureCode INT
AS
BEGIN
	DECLARE @PresetedStateDefinitionId UNIQUEIDENTIFIER
		,@IndvidualId UNIQUEIDENTIFIER
		,@GroupId UNIQUEIDENTIFIER
		,@CollectiveMembershipStateId UNIQUEIDENTIFIER
		,@pCountryId UNIQUEIDENTIFIER
		,@IsFutureDateOfBirthAllowed BIT

	SELECT @CollectiveMembershipStateId = State_Id
		,@IndvidualId = Individual_Id
		,@GroupId = Group_Id
		,@pCountryId = CountryId
	FROM CollectiveMembership cmp
	INNER JOIN Collective c ON cmp.Group_Id = c.GUIDReference
	WHERE CollectiveMembershipid = @pGroupMembershipId

	SELECT @IsFutureDateOfBirthAllowed = dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'FutureDateOfBirth', 1)

	SELECT cmp.CollectiveMembershipId
		,c.GUIDReference
		,(
			CASE 
				WHEN REPLICATE('0', CountryConfiguration.GroupBusinessIdDigits - LEN(CONVERT(NVARCHAR, c.Sequence))) + CONVERT(NVARCHAR, c.Sequence) IS NULL
					THEN CONVERT(NVARCHAR, c.Sequence)
				ELSE REPLICATE('0', CountryConfiguration.GroupBusinessIdDigits - LEN(CONVERT(NVARCHAR, c.Sequence))) + CONVERT(NVARCHAR, c.Sequence)
				END
			) AS HouseholdBusinessId
		,ind.GUIDReference AS Id
		,IIF(ind.IsAnonymized = 1, 'XXXXXXXXX', p.LAStOrderedName) AS LastName
		,ind.IndividualId AS BusinessId
		,IIF(ind.IsAnonymized = 1, 'XXXXXXXXX', p.MiddleOrderedName) AS MiddleName
		,IIF(ind.IsAnonymized = 1, 'XXXXXXXXX', p.FirstOrderedName) AS FirstName
		,p.DateOfBirth AS DateOfBirth
		,IT.Code AS Code
		,dbo.[GetTranslationValue](IT.Translation_Id, @pCultureCode) AS NAME
		,@IsFutureDateOfBirthAllowed
	FROM collectivemembership cmp
	INNER JOIN Collective c ON cmp.Group_Id = c.GUIDReference
	INNER JOIN Candidate cand ON cand.GUIDReference = c.GUIDReference
	INNER JOIN Country ON Country.CountryId = cand.Country_Id
	INNER JOIN CountryConfiguration ON CountryConfiguration.Id = Country.Configuration_Id
	INNER JOIN Individual ind ON ind.GUIDReference = cmp.Individual_Id
	INNER JOIN PersonalIdentification p ON p.PersonalIdentificationId = ind.PersonalIdentificationId
	INNER JOIN IndividualTitle IT ON IT.GUIDReference = P.TitleId
	WHERE cmp.group_id = @pGroupMembershipId 
	ORDER BY BusinessId
END