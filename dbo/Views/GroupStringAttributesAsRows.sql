CREATE VIEW [dbo].[GroupStringAttributesAsRows]
AS
SELECT dbo.FullGroupStringAttributesAsRows.CountryISO2A
	,dbo.FullGroupStringAttributesAsRows.[GroupId]
	,dbo.FullGroupStringAttributesAsRows.[Key]
	,dbo.FullGroupStringAttributesAsRows.[Attribute]
	,dbo.FullGroupStringAttributesAsRows.Value
	,dbo.FullGroupStringAttributesAsRows.GPSUser
	,dbo.FullGroupStringAttributesAsRows.CreationTimeStamp
	,dbo.FullGroupStringAttributesAsRows.GPSUpdateTimestamp
FROM dbo.FullGroupStringAttributesAsRows
INNER JOIN dbo.CountryViewAccess ON dbo.FullGroupStringAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullGroupStringAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country