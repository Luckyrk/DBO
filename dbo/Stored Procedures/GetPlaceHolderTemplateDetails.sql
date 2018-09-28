CREATE PROCEDURE GetPlaceHolderTemplateDetails (
	@ptemplateId BIGINT
	,@pCountryCode VARCHAR(20)
	,@pBusinessId VARCHAR(max)
	)
AS
BEGIN
BEGIN TRY
	DECLARE @FirstName VARCHAR(20)
	DECLARE @PanelName UNIQUEIDENTIFIER
	DECLARE @pCountryId UNIQUEIDENTIFIER
	DECLARE @templateId INT
	DECLARE @panelid UNIQUEIDENTIFIER
	DECLARE @PanelNumberPlaceHolder VARCHAR(max)
	DECLARE @PanelCode INT
	DECLARE @PanelNumber_Id VARCHAR(max)
	DECLARE @NamedAliasNumber_Id VARCHAR(max)
	DECLARE @ConsumerHouseHold VARCHAR(max)
	DECLARE @PersonalIdentificationIds VARCHAR(max)
	DECLARE @NamedAliasNumber VARCHAR(max)
	DECLARE @GPSEmail VARCHAR(255)

	
DECLARE @HouseHoldNumber AS VARCHAR(10) = @pBusinessId

SET @HouseHoldNumber = substring(@HouseHoldNumber, 0, CHARINDEX('-', @HouseHoldNumber))
SET @pCountryId = (
		SELECT CountryId
		FROM Country
		WHERE CountryISO2A = @pCountryCode
		)
SET @PersonalIdentificationIds = (
		SELECT PersonalIdentificationId
		FROM Individual
		WHERE IndividualId = @pBusinessId
			AND CountryId = @pCountryId
		)

SELECT TOP 1 @panelid = PTMS.panel_id, @GPSEmail = TMS.Email
		FROM PanelTemplateMessageScheme PTMS
		JOIN TemplateMessageScheme TMS ON PTMS.TemplateMessageSchemeId = TMS.TemplateMessageSchemeId
		JOIN Panel p ON PTMS.panel_Id = p.GUIDReference AND p.Country_Id = @pCountryId
		WHERE TMS.TemplateMessageSchemeId = @ptemplateId

SET @PanelCode = (
		SELECT PanelCode
		FROM Panel
		WHERE GUIDreference = @panelid
			AND Country_Id = @pCountryId
		)
SET @NamedAliasNumber = (
		SELECT d.[Key] AS IDNumber
		FROM [NamedAliasContext] a
		INNER JOIN Country b ON b.CountryId = a.Country_Id
			AND b.CountryISO2A = @pCountryCode
			AND a.NAME = 'FoodOnTheGoAlias'
		INNER JOIN Panel c ON c.GUIDReference = a.Panel_Id
			AND c.PanelCode = '6'
		INNER JOIN NamedAlias d ON d.AliasContext_Id = a.NamedAliasContextId
		INNER JOIN Panelist e ON e.Panel_Id = c.GUIDReference
			AND e.PanelMember_Id = d.Candidate_Id
		INNER JOIN Individual f ON f.GUIDReference = e.PanelMember_Id
		WHERE f.IndividualId = @pBusinessId
		)

IF (@PanelCode IS NOT NULL)
BEGIN
	IF (@PanelCode = 6) -- Food on the GO
	BEGIN
		SET @PanelNumberPlaceHolder = @HouseHoldNumber
		SET @FirstName = (
				SELECT FirstOrderedName
				FROM PersonalIdentification
				WHERE PersonalIdentificationId = @PersonalIdentificationIds
				)
		SET @NamedAliasNumber_Id = @NamedAliasNumber
	END
	ELSE IF (@PanelCode = 3) -- Consumer Panel
	BEGIN
		SET @ConsumerHouseHold = (
				SELECT substring(@HouseHoldNumber, patindex('%[^2]%', @HouseHoldNumber), 10)
				)
		SET @PanelNumberPlaceHolder = (
				SELECT substring(@ConsumerHouseHold, patindex('%[^0]%', @ConsumerHouseHold), 10)
				)
		SET @FirstName = (
				SELECT FirstOrderedName
				FROM PersonalIdentification
				WHERE PersonalIdentificationId = @PersonalIdentificationIds
				)
		SET @NamedAliasNumber_Id = NULL
	END
	ELSE
	BEGIN
		SET @PanelNumberPlaceHolder = @HouseHoldNumber
		SET @FirstName = (
				SELECT FirstOrderedName
				FROM PersonalIdentification
				WHERE PersonalIdentificationId = @PersonalIdentificationIds
				)
		SET @NamedAliasNumber_Id = NULL
	END

	SELECT @PanelNumberPlaceHolder AS PanelNumber
		,@FirstName AS Name
		,@NamedAliasNumber_Id AS ID_Number
		,@GPSEmail AS GPSEmail
		,(SELECT TOP 1 ISNULL(kv.Value, ka.DefaultValue)
			FROM KeyAppSetting ka
			JOIN KeyValueAppSetting kv ON ka.GUIDReference = kv.KeyAppSetting_Id
			AND kv.Country_Id = @pCountryId AND ka.KeyName = 'Mailmerge.StartDelimiter') AS StartDelimiter
		,(SELECT TOP 1 ISNULL(kv.Value, ka.DefaultValue)
			FROM KeyAppSetting ka
			JOIN KeyValueAppSetting kv ON ka.GUIDReference = kv.KeyAppSetting_Id
			AND kv.Country_Id = @pCountryId AND ka.KeyName = 'Mailmerge.EndDelimiter') AS EndDelimiter
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