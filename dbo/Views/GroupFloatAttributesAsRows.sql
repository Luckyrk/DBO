CREATE VIEW [dbo].[GroupFloatAttributesAsRows]
AS
SELECT dbo.FullGroupFloatAttributesAsRows.CountryISO2A
	,dbo.FullGroupFloatAttributesAsRows.[GroupId]
	,dbo.FullGroupFloatAttributesAsRows.[Key]
	,dbo.FullGroupFloatAttributesAsRows.[Attribute]
	,dbo.FullGroupFloatAttributesAsRows.Value
	,dbo.FullGroupFloatAttributesAsRows.GPSUser
	,dbo.FullGroupFloatAttributesAsRows.CreationTimeStamp
	,dbo.FullGroupFloatAttributesAsRows.GPSUpdateTimestamp
FROM dbo.FullGroupFloatAttributesAsRows
INNER JOIN dbo.CountryViewAccess ON dbo.FullGroupFloatAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullGroupFloatAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country