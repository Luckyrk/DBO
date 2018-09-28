GO
--EXEC GetFrequenterPanUSIFolderPathDetails 'FrequenterPanUSI','FR'
CREATE PROCEDURE GetFrequenterPanUSIFolderPathDetails(
	@pImportType VARCHAR(50) = 'FrequenterPanUSI'
	,@pCountryCode VARCHAR(50) = 'FR'
	)
AS
BEGIN
BEGIN TRY 
DECLARE @countryId UNIQUEIDENTIFIER
SET @countryId = (
			SELECT CountryID
			FROM [dbo].[Country]
			WHERE CountryISO2A = @pCountryCode
			)

  SELECT 'FilePath' as KeyName,FilePath as Value,NULL as DefaultValue from SSISFileImportsConfig where ImportType=@pImportType and CountryCode=@pCountryCode
  UNION
  SELECT 'LogFilePath' as KeyName,LogFilePath,NULL  as DefaultValue from SSISFileImportsConfig where ImportType=@pImportType and CountryCode=@pCountryCode
  UNION
  SELECT 'TblFrequenterPanUSISchema'	 as KeyName
		,kv.Value as TblHitlistSchema,ka.DefaultValue  as DefaultValue
	FROM KeyAppSetting ka
	LEFT OUTER JOIN KeyValueAppSetting kv ON ka.GUIDReference = kv.KeyAppSetting_Id
	AND kv.Country_Id = @countryId
	WHERE KeyName in ('TblFrequenterPanUSISchema')
	UNION
   SELECT 'TblFrequenterPanUSIName' as KeyName	
		,kv.Value as TblHitlistName,ka.DefaultValue as DefaultValue
	FROM KeyAppSetting ka
	LEFT OUTER JOIN KeyValueAppSetting kv ON ka.GUIDReference = kv.KeyAppSetting_Id
	AND kv.Country_Id = @countryId
	WHERE KeyName in ('TblFrequenterPanUSIName')
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

Go