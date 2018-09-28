
CREATE VIEW [dbo].[FullIndividualFloatAttributesAsRows]
AS
SELECT IRA.CountryISO2A
	,IRA.IndividualId
	,IRA.[Key]
	,CAST(TYPETERM.Value AS VARCHAR(255)) AS Attribute
	,IRA.Value AS Value
	,IRA.GPSUser
	,IRA.CreationTimeStamp
	,IRA.GPSUpdateTimestamp
FROM [IXV_Individual_ATTRIBUTE_AsRows](NOEXPAND) IRA
INNER JOIN dbo.Translation AS TYPETRANS ON TYPETRANS.TranslationId = IRA.Translation_Id
LEFT JOIN (
	SELECT Translation_Id
		,Value
	FROM dbo.TranslationTerm
	WHERE CultureCode = 2057
	) AS TYPETERM ON TYPETRANS.TranslationId = TYPETERM.Translation_Id
WHERE IRA.[Type] = 'Float'
  GO