CREATE VIEW [dbo].[GroupBooleanAttributesAsRows]
AS
SELECT dbo.FullGroupBooleanAttributesAsRows.CountryISO2A
	,dbo.FullGroupBooleanAttributesAsRows.[GroupId]
	,dbo.FullGroupBooleanAttributesAsRows.[Key]
	,dbo.FullGroupBooleanAttributesAsRows.[Attribute]
	,dbo.FullGroupBooleanAttributesAsRows.Value
	,dbo.FullGroupBooleanAttributesAsRows.GPSUser
	,dbo.FullGroupBooleanAttributesAsRows.CreationTimeStamp
	,dbo.FullGroupBooleanAttributesAsRows.GPSUpdateTimestamp
FROM dbo.FullGroupBooleanAttributesAsRows
INNER JOIN dbo.CountryViewAccess ON dbo.FullGroupBooleanAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullGroupBooleanAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country