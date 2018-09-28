CREATE PROC GetGroupRolesByGroupId 
	(
	@pGroupId UNIQUEIDENTIFIER,
	@pCountryCode CHAR(2)
	)
AS
BEGIN

	DECLARE @GroupContactId UNIQUEIDENTIFIER
		,@MainshopperId UNIQUEIDENTIFIER
		,@GroupContactBusinessId VARCHAR(50)
		,@MainshopperBusinessId VARCHAR(50)
		,@countryid UNIQUEIDENTIFIER

	SET @countryid = (
			SELECT CountryId
			FROM country
			WHERE countryiso2a = @pCountryCode
			)
	SET @GroupContactId = (
			SELECT GroupContact_Id
			FROM collective
			WHERE guidreference = @pGroupId
			)
	SET @GroupContactBusinessId = (
			SELECT IndividualId
			FROM Individual
			WHERE guidreference = @GroupContactId
			)
	
	SET @MainshopperId = (
			SELECT dra.Candidate_Id
			FROM DynamicRoleAssignment dra
			JOIN DynamicRole d ON dra.DynamicRole_Id = d.DynamicRoleId
			JOIN Translation T ON d.Translation_Id = T.TranslationId
			JOIN Collective C ON C.GUIDReference = dra.Group_Id
			WHERE dra.Country_Id = @countryid
				AND T.Keyname = 'MainShopperRoleName'
				AND C.guidreference = @pGroupId
			)
	SET @MainshopperBusinessId = (
			SELECT IndividualId
			FROM Individual
			WHERE guidreference = @MainshopperId
			)

	SELECT @GroupContactId AS GroupContactGuid
		,@GroupContactBusinessId AS GroupContactBusinessId
		,@MainshopperId AS MainshopperGuid
		,@MainshopperBusinessId AS MainshopperBusinessId
END
