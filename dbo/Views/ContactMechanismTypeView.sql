
CREATE VIEW [dbo].[ContactMechanismTypeView]
AS
SELECT
	cmt.GUIDReference
	, ContactMechanismCode
	, cmt.GPSUser
	, cmt.GPSUpdateTimeStamp
	, cmt.CreationTimeStamp
	, dbo.GetTranslationValue(TagTranslation_ID,2057) AS TagKeyName
	, dbo.GetTranslationValue(DescriptionTranslation_ID,2057) AS [Description]
	, dbo.GetTranslationValue(TypeTranslation_ID,2057) AS TypeKeyName
	, [Types] AS [Type]
	, cmt.Country_Id
	, c.CountryISO2A
FROM ContactMechanismType cmt
INNER JOIN Country c ON cmt.Country_ID = c.CountryID
