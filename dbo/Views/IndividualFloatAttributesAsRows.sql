CREATE VIEW [dbo].[IndividualFloatAttributesAsRows]
AS
SELECT dbo.FullIndividualFloatAttributesAsRows.CountryISO2A
	,dbo.FullIndividualFloatAttributesAsRows.IndividualId
	,dbo.FullIndividualFloatAttributesAsRows.[Key]
	,dbo.FullIndividualFloatAttributesAsRows.[Attribute]
	,dbo.FullIndividualFloatAttributesAsRows.Value
	,dbo.FullIndividualFloatAttributesAsRows.GPSUser
	,dbo.FullIndividualFloatAttributesAsRows.CreationTimeStamp
	,dbo.FullIndividualFloatAttributesAsRows.GPSUpdateTimestamp
FROM dbo.FullIndividualFloatAttributesAsRows
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualFloatAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullIndividualFloatAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country