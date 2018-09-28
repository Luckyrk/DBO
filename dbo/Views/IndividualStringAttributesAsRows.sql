CREATE VIEW [dbo].[IndividualStringAttributesAsRows]
AS
SELECT dbo.FullIndividualStringAttributesAsRows.CountryISO2A
	,dbo.FullIndividualStringAttributesAsRows.IndividualId
	,dbo.FullIndividualStringAttributesAsRows.[Key]
	,dbo.FullIndividualStringAttributesAsRows.[Attribute]
	,dbo.FullIndividualStringAttributesAsRows.Value
	,dbo.FullIndividualStringAttributesAsRows.GPSUser
	,dbo.FullIndividualStringAttributesAsRows.CreationTimeStamp
	,dbo.FullIndividualStringAttributesAsRows.GPSUpdateTimestamp
FROM dbo.FullIndividualStringAttributesAsRows
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualStringAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullIndividualStringAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country