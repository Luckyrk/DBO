CREATE PROC [dbo].[UpdateMCAndMSAndMC] (
	@pGCBusinessId VARCHAR(30)
	,@pMSBusinessId VARCHAR(30)
	,@pGroupId varchar(30)
	,@countrycode VARCHAR(30)
	,@panelcode INT
	)
AS
BEGIN
BEGIN TRY 
	--DECLARE @pGroupId VARCHAR(30) = (
	--		SELECT substring(@pGCBusinessId, 0, 7)
	--		)
	DECLARE @countryid UNIQUEIDENTIFIER = (
			SELECT countryid
			FROM Country
			WHERE countryiso2a = @countrycode
			)
	DECLARE @mainShopperGuid UNIQUEIDENTIFIER = (
			SELECT guidreference
			FROM individual
			WHERE individualid = @pMSBusinessId
			)
	DECLARE @groupContactGuid UNIQUEIDENTIFIER = (
			SELECT guidreference
			FROM individual
			WHERE individualid = @pGCBusinessId
			)
	DECLARE @groupId UNIQUEIDENTIFIER = (
			SELECT guidreference
			FROM collective
			WHERE sequence = cast(@pGroupId AS INT)
			)
	DECLARE @panelId UNIQUEIDENTIFIER = (
			SELECT guidreference
			FROM panel
			WHERE (PanelCode = 27 or PanelCode = 45)
				AND country_id = @countryid
			)
	--declare @gcIndividualId uniqueidentifier =(select guidreference from collective where sequence=cast(@pGroupId as int))
	DECLARE @msdynamicRoleId UNIQUEIDENTIFIER
		,@mcdynamicRoleId UNIQUEIDENTIFIER
		,@existingMainShopperId UNIQUEIDENTIFIER
		,@existingGroupContactId UNIQUEIDENTIFIER
		,@existingMainContactId UNIQUEIDENTIFIER
		,@mainContactId UNIQUEIDENTIFIER
		,@panelistGuid UNIQUEIDENTIFIER

	IF (@panelcode = 27 or @panelcode = 45)
	BEGIN
		SET @existingMainShopperId = (
				SELECT dra.Candidate_Id
				FROM DynamicRoleAssignment dra
				JOIN DynamicRole d ON dra.DynamicRole_Id = d.DynamicRoleId
				JOIN Translation T ON d.Translation_Id = T.TranslationId
				JOIN Collective C ON C.GUIDReference = dra.Group_Id
				WHERE dra.Country_Id = @countryid
					AND T.Keyname = 'MainShopperRoleName'
					AND C.guidreference = @groupId
				)

		SELECT @existingMainContactId = dra.Candidate_Id
			,@panelistGuid = dra.Panelist_Id
		FROM DynamicRoleAssignment dra
		JOIN DynamicRole d ON dra.DynamicRole_Id = d.DynamicRoleId
		JOIN Translation T ON d.Translation_Id = T.TranslationId
		JOIN Panelist P ON dra.Panelist_Id = p.GUIDReference
		JOIN Collective C ON C.GUIDReference = P.PanelMember_Id
			AND P.Panel_Id = @panelId
		WHERE dra.Country_Id = @countryid
			AND T.Keyname = 'MainContactRoleName'
			AND C.guidreference = @groupId

		SET @existingGroupContactId = (
				SELECT GroupContact_Id
				FROM collective
				WHERE guidreference = @groupId
				)

		IF (@existingGroupContactId <> @groupContactGuid)
		BEGIN
			UPDATE DynamicRoleAssignment
			SET Candidate_id = @groupContactGuid
			WHERE group_id = @groupId
				AND Candidate_id = @existingMainShopperId

			UPDATE collective
			SET GroupContact_Id = @groupContactGuid
			WHERE guidreference = @groupId

			UPDATE DynamicRoleAssignment
			SET Candidate_id = @groupContactGuid
			WHERE Panelist_Id = @panelistGuid
				AND Candidate_id = @existingMainContactId
		END

		IF (@existingMainShopperId != @mainShopperGuid)
		BEGIN
			UPDATE collective
			SET GroupContact_Id = @mainShopperGuid
			WHERE guidreference = @groupId

			UPDATE DynamicRoleAssignment
			SET Candidate_id = @mainShopperGuid
			WHERE group_id = @groupId
				AND Candidate_id = @existingMainShopperId

			UPDATE DynamicRoleAssignment
			SET Candidate_id = @mainShopperGuid
			WHERE Panelist_Id = @panelistGuid
				AND Candidate_id = @existingMainContactId
		END
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
