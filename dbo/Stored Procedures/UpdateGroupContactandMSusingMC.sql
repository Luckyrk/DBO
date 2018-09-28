CREATE PROCEDURE [dbo].[UpdateGroupContactandMSusingMC] (
	@pMainContactBusinessId VARCHAR(30)
	,@pGroupId VARCHAR(30)
	,@countrycode VARCHAR(30)
	)
AS
BEGIN
BEGIN TRY 
	DECLARE @countryid UNIQUEIDENTIFIER = (
			SELECT countryid
			FROM Country
			WHERE countryiso2a = @countrycode
			)
	DECLARE @mcIndividualId UNIQUEIDENTIFIER = (
			SELECT guidreference
			FROM individual
			WHERE individualid = @pMainContactBusinessId
			)
	DECLARE @gcIndividualId UNIQUEIDENTIFIER = (
			SELECT guidreference
			FROM collective
			WHERE sequence = cast(@pGroupId AS INT)
			)
	DECLARE @dynamicRoleId UNIQUEIDENTIFIER
		,@mainShopperId UNIQUEIDENTIFIER

	SET @dynamicRoleId = (
			SELECT d.DynamicRoleId
			FROM DynamicRoleAssignment dra
			INNER JOIN DynamicRole d ON dra.DynamicRole_Id = d.DynamicRoleId
			INNER JOIN Translation T ON d.Translation_Id = T.TranslationId
			INNER JOIN Collective C ON C.GUIDReference = dra.Group_Id
			WHERE dra.Country_Id = @countryid
				AND T.Keyname = 'MainShopperRoleName'
				AND C.guidreference = @gcIndividualId
			)

	IF (@mcIndividualId != @gcIndividualId)
		UPDATE collective
		SET GroupContact_Id = @mcIndividualId
		WHERE guidreference = @gcIndividualId

	SET @mainShopperId = (
			SELECT dra.Candidate_Id
			FROM DynamicRoleAssignment dra
			INNER JOIN DynamicRole d ON dra.DynamicRole_Id = d.DynamicRoleId
			INNER JOIN Translation T ON d.Translation_Id = T.TranslationId
			INNER JOIN Collective C ON C.GUIDReference = dra.Group_Id
			WHERE dra.Country_Id = @countryid
				AND T.Keyname = 'MainShopperRoleName'
				AND C.guidreference = @gcIndividualId
			)

	IF (@mcIndividualId != @mainShopperId)
		UPDATE DynamicRoleAssignment
		SET Candidate_id = @mcIndividualId
		WHERE group_id = @gcIndividualId
			AND DynamicRole_Id = @dynamicRoleId
			AND Candidate_id = @mainShopperId
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
