

--EXEC GetHitListFolderPathDetails 'HitListImport','GB'
CREATE PROCEDURE GetHitListFolderPathDetails(
	@pImportType VARCHAR(50) = 'HitListImport'
	,@pCountryCode VARCHAR(50) = 'GB'
	)
AS
BEGIN
DECLARE @countryId UNIQUEIDENTIFIER
SET @countryId = (

			SELECT CountryID

			FROM [dbo].[Country]

			WHERE CountryISO2A = 'GB'

			)
			

  SELECT 'FilePath' as KeyName,FilePath as Value,NULL as DefaultValue from SSISFileImportsConfig where ImportType=@pImportType and CountryCode=@pCountryCode

  UNION
  
  SELECT 'LogFilePath' as KeyName,LogFilePath,NULL  as DefaultValue from SSISFileImportsConfig where ImportType=@pImportType and CountryCode=@pCountryCode

  UNION

  SELECT 'TblHitlistSchema'	 as KeyName

		,kv.Value as TblHitlistSchema,ka.DefaultValue  as DefaultValue

	FROM KeyAppSetting ka

	LEFT OUTER JOIN KeyValueAppSetting kv ON ka.GUIDReference = kv.KeyAppSetting_Id

	AND kv.Country_Id = @countryId

	WHERE KeyName in ('TblHitlistSchema')
	
	UNION
  
  SELECT 'TblHitlistName' as KeyName	

		,kv.Value as TblHitlistName,ka.DefaultValue as DefaultValue

	FROM KeyAppSetting ka

	LEFT OUTER JOIN KeyValueAppSetting kv ON ka.GUIDReference = kv.KeyAppSetting_Id

	AND kv.Country_Id = @countryId

	WHERE KeyName in ('TblHitlistName')

END





