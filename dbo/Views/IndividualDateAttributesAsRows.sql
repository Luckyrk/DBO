CREATE VIEW [dbo].[IndividualDateAttributesAsRows]
AS
SELECT dbo.FullIndividualDateAttributesAsRows.CountryISO2A
	,dbo.FullIndividualDateAttributesAsRows.IndividualId
	,dbo.FullIndividualDateAttributesAsRows.[Key]
	,dbo.FullIndividualDateAttributesAsRows.[Attribute]
	,dbo.FullIndividualDateAttributesAsRows.Value
	,dbo.FullIndividualDateAttributesAsRows.GPSUser
	,dbo.FullIndividualDateAttributesAsRows.CreationTimeStamp
	,dbo.FullIndividualDateAttributesAsRows.GPSUpdateTimestamp
FROM dbo.FullIndividualDateAttributesAsRows
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualDateAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullIndividualDateAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country