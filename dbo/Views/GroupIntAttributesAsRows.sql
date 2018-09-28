CREATE VIEW [dbo].[GroupIntAttributesAsRows]
AS
SELECT dbo.FullGroupIntAttributesAsRows.CountryISO2A
	,dbo.FullGroupIntAttributesAsRows.[GroupId]
	,dbo.FullGroupIntAttributesAsRows.[Key]
	,dbo.FullGroupIntAttributesAsRows.[Attribute]
	,dbo.FullGroupIntAttributesAsRows.Value
	,dbo.FullGroupIntAttributesAsRows.GPSUser
	,dbo.FullGroupIntAttributesAsRows.CreationTimeStamp
	,dbo.FullGroupIntAttributesAsRows.GPSUpdateTimestamp
FROM dbo.FullGroupIntAttributesAsRows
INNER JOIN dbo.CountryViewAccess ON dbo.FullGroupIntAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullGroupIntAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country