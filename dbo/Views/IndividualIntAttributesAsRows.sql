CREATE VIEW [dbo].[IndividualIntAttributesAsRows]
AS
SELECT dbo.FullIndividualIntAttributesAsRows.CountryISO2A
	,dbo.FullIndividualIntAttributesAsRows.IndividualId
	,dbo.FullIndividualIntAttributesAsRows.[Key]
	,dbo.FullIndividualIntAttributesAsRows.[Attribute]
	,dbo.FullIndividualIntAttributesAsRows.Value
	,dbo.FullIndividualIntAttributesAsRows.GPSUser
	,dbo.FullIndividualIntAttributesAsRows.CreationTimeStamp
	,dbo.FullIndividualIntAttributesAsRows.GPSUpdateTimestamp
FROM dbo.FullIndividualIntAttributesAsRows
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualIntAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullIndividualIntAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country