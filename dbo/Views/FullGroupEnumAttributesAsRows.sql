CREATE VIEW [dbo].[FullGroupEnumAttributesAsRows]
AS
SELECT IXV.CountryISO2A
	,IXV.Sequence [GroupId]
	,IXV.[Key]
	,CAST(TYPETERM.Value AS NVARCHAR(255)) AS Attribute
	,ED.Value AS Value --IXV.Value AS VALUE
	,ED.Value + ' - ' + EDTT.Value AS ValueDesc
	,ED.Value + ' - ' + CAST(EDL.Value AS NVARCHAR(255)) AS Description_Local
	,IXV.GPSUser
	,IXV.CreationTimeStamp
	,IXV.GPSUpdateTimestamp	
FROM IX_FullGroupAttributeAsRows(NOEXPAND) IXV
LEFT JOIN EnumDefinition ED ON IXV.EnumDefinition_Id = ED.Id
LEFT JOIN Translation EDT ON ED.Translation_Id = EDT.TranslationId
LEFT JOIN TranslationTerm EDTT ON EDT.TranslationId = EDTT.Translation_Id AND EDTT.CultureCode = 2057
LEFT JOIN TranslationTerm EDL ON EDT.TranslationId = EDL.Translation_Id 
		AND cast(EDL.CultureCode AS VARCHAR) IN (
       SELECT items FROM dbo.Split(
              CASE IXV.CountryISO2A
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
INNER JOIN dbo.Translation AS TYPETRANS ON TYPETRANS.TranslationId = IXV.attribute_translation_id
LEFT JOIN (SELECT *
	FROM TranslationTerm
	WHERE CultureCode = 2057
	) AS TYPETERM ON TYPETRANS.TranslationId = TYPETERM.Translation_Id
WHERE IXV.[Type] = 'Enum'
