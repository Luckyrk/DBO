
CREATE VIEW [dbo].[FullIndividualEnumAttributesAsRows]
AS
SELECT IRA.CountryISO2A
	,IRA.IndividualId
	,IRA.[Key]
	,CAST(TYPETERM.Value AS NVARCHAR(255)) AS Attribute
	,ED.Value AS Value --IRA.Value
	,ED.Value + ' - ' + EDTT.Value AS Description
	,ED.Value + ' - ' + CAST(EDL.Value AS NVARCHAR(255)) AS Description_Local
	,'' AS KeyName
	,IRA.GPSUser
	,IRA.CreationTimeStamp
	,IRA.GPSUpdateTimestamp
FROM [IXV_Individual_ATTRIBUTE_AsRows](NOEXPAND) IRA
LEFT JOIN EnumDefinition ED ON IRA.EnumDefinition_Id = ED.Id
LEFT JOIN Translation EDT ON ED.Translation_Id = EDT.TranslationId
LEFT JOIN TranslationTerm EDTT ON EDT.TranslationId = EDTT.Translation_Id AND CultureCode = 2057
LEFT JOIN TranslationTerm EDL ON EDT.TranslationId = EDL.Translation_Id 
		AND cast(EDL.CultureCode AS VARCHAR) IN (
       SELECT items FROM dbo.Split(
              CASE IRA.CountryISO2A
                     WHEN 'TW'
                           THEN '1028'
                     WHEN 'FR'
                           THEN '1036'
                     WHEN 'ES'
                           THEN '3082,1034'
                     WHEN 'GB'
                           THEN '2057'
                     WHEN 'PH'
                           THEN '1124,13321'
                     WHEN 'MY'
                           THEN '17417,1086'
                     END,',')
              )
INNER JOIN dbo.Translation AS TYPETRANS ON TYPETRANS.TranslationId = IRA.Translation_Id
LEFT JOIN (
	SELECT Translation_Id
		,Value
	FROM dbo.TranslationTerm
	WHERE (CultureCode = 2057)
	) AS TYPETERM ON TYPETRANS.TranslationId = TYPETERM.Translation_Id
WHERE IRA.[Type] = 'Enum'
GO