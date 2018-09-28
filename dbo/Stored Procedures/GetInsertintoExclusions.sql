CREATE PROCEDURE GetInsertintoExclusions (
	@pRange_From DATETIME
	,@pRange_To DATETIME
	,@pAllIndividuals BIT
	,@pAllPanels BIT
	,@pIsClosed BIT
	,@pGPSUser VARCHAR(50)
	,@pType_Id UNIQUEIDENTIFIER
	,@pPanelCodes VARCHAR(50)
	,@pIndividual_Id VARCHAR(100)
	,@pCountryCode VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON
BEGIN TRY 
	DECLARE @exclusionGUId UNIQUEIDENTIFIER = NewId();
		 DECLARE @getdate DATETIME; 
	 SET @getdate = (select dbo.GetLocalDateTime(GETDATE(),@pCountryCode))

	DECLARE @GetTime DATETIME = @getdate;
	DECLARE @Panelist_Id UNIQUEIDENTIFIER;
	DECLARE @Paneltype NVARCHAR(50);
	DECLARE @Paneltypehouseholdmemberid NVARCHAR(50);
	DECLARE @pcountryid UNIQUEIDENTIFIER;
	DECLARE @panelguidreference UNIQUEIDENTIFIER;
	DECLARE @PanelistIds TABLE (Panelistid UNIQUEIDENTIFIER)

	SET @pcountryid = (
			SELECT [CountryId]
			FROM Country
			WHERE CountryISO2A = @pCountryCode
			)

	DECLARE @pIndividualguid UNIQUEIDENTIFIER = (
			SELECT TOP 1 guidreference
			FROM Individual
			WHERE IndividualId = @pIndividual_Id
				AND CountryId = @pcountryid
			)

	INSERT INTO @PanelistIds
	SELECT GUIDReference
	FROM Panelist
	WHERE Panel_Id IN (
			SELECT GUIDReference
			FROM Panel
			WHERE PanelCode IN (
					SELECT Item
					FROM SplitString(@pPanelCodes, ',')
					)
				AND Country_Id = @pcountryid
			)
		AND PanelMember_Id = @pIndividualguid

	--IF (@Paneltype = 'HouseHold')
	--BEGIN
	--       SET @Panelist_Id = (
	--                       SELECT Group_Id
	--                       FROM CollectiveMembership
	--                       WHERE Individual_Id = @pIndividual_Id
	--                       )
	--END
	DECLARE @groupid UNIQUEIDENTIFIER = (
			SELECT Group_Id
			FROM CollectiveMembership
			WHERE Individual_Id = @pIndividualguid
			)

	INSERT INTO @PanelistIds
	SELECT GUIDReference
	FROM Panelist
	WHERE Panel_Id IN (
			SELECT GUIDReference
			FROM Panel
			WHERE PanelCode IN (
					SELECT Item
					FROM SplitString(@pPanelCodes, ',')
					)
				AND Country_Id = @pcountryid
			)
		AND PanelMember_Id = @groupid

	INSERT INTO [dbo].[Exclusion] (
		[GUIDReference]
		,[Range_From]
		,[Range_To]
		,[AllIndividuals]
		,[AllPanels]
		,[IsClosed]
		,[GPSUser]
		,[GPSUpdateTimestamp]
		,[CreationTimeStamp]
		,[Type_Id]
		,[Parent_Id]
		)
	VALUES (
		@exclusionGUId
		,@pRange_From
		,@pRange_To
		,@pAllIndividuals
		,@pAllPanels
		,@pIsClosed
		,@pGPSUser
		,@GetTime
		,@GetTime
		,@pType_Id
		,@pIndividualguid
		)

	IF (@pAllIndividuals = 1)
	BEGIN
		INSERT INTO ExclusionIndividual
		SELECT @exclusionGUId
			,Individual_Id
			,@pGPSUser
			,@GetTime
			,@GetTime
		FROM CollectiveMembership
		WHERE Group_Id = @groupid
	END
	ELSE
		INSERT INTO ExclusionIndividual
		SELECT @exclusionGUId
			,@pindividualguid
			,@pGPSUser
			,@GetTime
			,@GetTime
	
	INSERT INTO [dbo].ExclusionPanelist (
		[Exclusion_Id]
		,[Panelist_Id]
		,[GPSUser]
		,[GPSUpdateTimestamp]
		,[CreationTimeStamp]
		)
	SELECT @exclusionGUId
		,Panelistid
		,@pGPSUser
		,@GetTime
		,@GetTime
	FROM @PanelistIds
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