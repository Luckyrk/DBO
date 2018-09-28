CREATE PROC UpdatePanelRoleByCode (
	@pBusinessId VARCHAR(30)
	,@pPanelCode VARCHAR(30)
	,@pDynamicRoleCode INT
	,@pCountrycode VARCHAR(30)
	)
AS
BEGIN
BEGIN TRY 
	DECLARE @countryid UNIQUEIDENTIFIER = (
			SELECT countryid
			FROM Country
			WHERE countryiso2a = @pCountrycode
			)
	DECLARE @individualId UNIQUEIDENTIFIER = (
			SELECT guidreference
			FROM individual
			WHERE individualid = @pBusinessId
			)
	DECLARE @groupId UNIQUEIDENTIFIER = (
			SELECT TOP 1 CM.Group_Id
			FROM CollectiveMembership CM
			JOIN Collective C ON CM.Group_Id = c.GUIDReference
			JOIN Individual I ON CM.Individual_Id = I.GUIDReference
			WHERE individualid = @pBusinessId
			)
	DECLARE @dynamicRoleId UNIQUEIDENTIFIER = (
			SELECT DynamicRoleId
			FROM DynamicRole
			WHERE code = @pDynamicRoleCode
				AND Country_Id = @countryid
			)
	DECLARE @panelId UNIQUEIDENTIFIER
		,@panelistId UNIQUEIDENTIFIER
		,@panelType VARCHAR(50)

	SELECT @panelId = guidreference
		,@panelType = [Type]
	FROM Panel
	WHERE Country_Id = @countryid
		AND PanelCode = @pPanelCode

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

	UPDATE DynamicRoleAssignment
	SET Candidate_Id = @individualId
	WHERE DynamicRole_Id = @dynamicRoleId
		AND Panelist_Id = @panelistId
END TRY 
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH 
END
