
CREATE VIEW [dbo].[FullGroupDateAttributesAsRows]
AS
SELECT IXV.CountryISO2A
	,IXV.Sequence [GroupId]
	,IXV.[Key]
	,CAST(TYPETERM.Value AS NVARCHAR(255)) AS Attribute
	,FORMAT(TRY_PARSE(IXV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss') AS VALUE
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
WHERE IXV.[Type] = 'Date'

GO