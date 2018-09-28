CREATE VIEW [dbo].[GroupDateAttributesAsRows]
AS
SELECT dbo.FullGroupDateAttributesAsRows.CountryISO2A
	,dbo.FullGroupDateAttributesAsRows.[GroupId]
	,dbo.FullGroupDateAttributesAsRows.[Key]
	,dbo.FullGroupDateAttributesAsRows.[Attribute]
	,dbo.FullGroupDateAttributesAsRows.Value
	,dbo.FullGroupDateAttributesAsRows.GPSUser
	,dbo.FullGroupDateAttributesAsRows.CreationTimeStamp
	,dbo.FullGroupDateAttributesAsRows.GPSUpdateTimestamp
FROM dbo.FullGroupDateAttributesAsRows
INNER JOIN dbo.CountryViewAccess ON dbo.FullGroupDateAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullGroupDateAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country