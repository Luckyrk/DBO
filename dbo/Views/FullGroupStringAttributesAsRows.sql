
CREATE VIEW [dbo].[FullGroupStringAttributesAsRows]
AS
SELECT ixv.CountryISO2A
	,IXV.Sequence [GroupId]
	,IXV.[Key]
	,CAST(TYPETERM.Value AS NVARCHAR(255)) AS Attribute
	,IXV.Value AS VALUE
	,IXV.GPSUser
	,IXV.CreationTimeStamp
	,IXV.GPSUpdateTimestamp
FROM IX_FullGroupAttributeAsRows(NOEXPAND) ixv
INNER JOIN dbo.Translation AS TYPETRANS ON TYPETRANS.TranslationId = ixv.attribute_translation_id
LEFT JOIN (
	SELECT *
	FROM TranslationTerm
	WHERE CultureCode = 2057
	) AS TYPETERM ON TYPETRANS.TranslationId = TYPETERM.Translation_Id
WHERE IXV.[Type] = 'String'

GO