CREATE VIEW [dbo].[IndividualEnumAttributesAsRows]
AS
SELECT dbo.FullIndividualEnumAttributesAsRows.CountryISO2A
	,dbo.FullIndividualEnumAttributesAsRows.IndividualId
	,dbo.FullIndividualEnumAttributesAsRows.[Key]
	,dbo.FullIndividualEnumAttributesAsRows.[Attribute]
	,dbo.FullIndividualEnumAttributesAsRows.Value
	,dbo.FullIndividualEnumAttributesAsRows.KeyName
	,dbo.FullIndividualEnumAttributesAsRows.Description
	,dbo.FullIndividualEnumAttributesAsRows.Description_Local
	,dbo.FullIndividualEnumAttributesAsRows.GPSUser
	,dbo.FullIndividualEnumAttributesAsRows.CreationTimeStamp
	,dbo.FullIndividualEnumAttributesAsRows.GPSUpdateTimestamp
FROM dbo.FullIndividualEnumAttributesAsRows
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualEnumAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullIndividualEnumAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country