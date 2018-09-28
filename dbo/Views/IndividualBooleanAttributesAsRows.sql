CREATE VIEW [dbo].[IndividualBooleanAttributesAsRows]
AS
SELECT dbo.FullIndividualBooleanAttributesAsRows.CountryISO2A
	,dbo.FullIndividualBooleanAttributesAsRows.IndividualId
	,dbo.FullIndividualBooleanAttributesAsRows.[Key]
	,dbo.FullIndividualBooleanAttributesAsRows.[Attribute]
	,dbo.FullIndividualBooleanAttributesAsRows.Value
	,dbo.FullIndividualBooleanAttributesAsRows.GPSUser
	,dbo.FullIndividualBooleanAttributesAsRows.CreationTimeStamp
	,dbo.FullIndividualBooleanAttributesAsRows.GPSUpdateTimestamp
FROM dbo.FullIndividualBooleanAttributesAsRows
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualBooleanAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullIndividualBooleanAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country