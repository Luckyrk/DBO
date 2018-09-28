CREATE PROCEDURE [dbo].[GetAzureQueueConfigurations] (@pCountryCode NVARCHAR(2))
AS
BEGIN
	DECLARE @countryId UNIQUEIDENTIFIER

	SET @countryId = (
			SELECT CountryId
			FROM [dbo].[Country]
			WHERE CountryISO2A = @pCountryCode
			)

	SELECT ka.KeyName AS [Key]
		,ka.DefaultValue
		,kv.Value
	FROM KeyAppSetting ka
	LEFT OUTER JOIN KeyValueAppSetting kv ON ka.GUIDReference = kv.KeyAppSetting_Id
	AND kv.Country_Id = @countryId
END