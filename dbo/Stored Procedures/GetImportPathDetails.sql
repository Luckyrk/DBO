CREATE PROCEDURE GetImportPathDetails(
	@pImportType VARCHAR(50) = ''
	,@pCountryCode VARCHAR(50) = '',
	@pSchemaName VARCHAR(100)='',
	@pTableName VARCHAR(100)=''
	)
AS
BEGIN
DECLARE @countryId UNIQUEIDENTIFIER
SET @countryId = (
			SELECT CountryID
			FROM [dbo].[Country]
			WHERE CountryISO2A = @pCountryCode
			)
			 
  SELECT 'FilePath' as KeyName,FilePath AS Value,NULL as DefaultValue  --'D:\PBI37903\' as Value
  from SSISFileImportsConfig where ImportType=@pImportType and CountryCode=@pCountryCode
  UNION
  SELECT 'LogFilePath' as KeyName, LogFilePath,NULL  as DefaultValue --'D:\PBI37903\CL' AS
  from SSISFileImportsConfig where ImportType=@pImportType and CountryCode=@pCountryCode
  UNION
  SELECT KeyName as KeyName
		,kv.Value as TblSchema,ka.DefaultValue  as DefaultValue
	FROM KeyAppSetting ka
	LEFT OUTER JOIN KeyValueAppSetting kv ON ka.GUIDReference = kv.KeyAppSetting_Id
	AND kv.Country_Id = @countryId
	WHERE KeyName IN (@pschemaName,@ptableName)
	--UNION
 --  SELECT 'TblFrequenterPanUSIName' as KeyName	
	--	,kv.Value as TblHitlistName,ka.DefaultValue as DefaultValue
	--FROM KeyAppSetting ka
	--LEFT OUTER JOIN KeyValueAppSetting kv ON ka.GUIDReference = kv.KeyAppSetting_Id
	--AND kv.Country_Id = @countryId
	--WHERE KeyName =@pKeyName
END

Go