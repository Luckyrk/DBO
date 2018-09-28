
ALTER VIEW [dbo].[GroupEnumAttributesAsRows]
AS
SELECT dbo.FullGroupEnumAttributesAsRows.CountryISO2A
	,dbo.FullGroupEnumAttributesAsRows.[GroupId]
	,dbo.FullGroupEnumAttributesAsRows.Attribute
	,dbo.FullGroupEnumAttributesAsRows.Value
	,dbo.FullGroupEnumAttributesAsRows.[Key]
	,dbo.FullGroupEnumAttributesAsRows.ValueDesc
	,dbo.FullGroupEnumAttributesAsRows.Description_Local
	,dbo.FullGroupEnumAttributesAsRows.GPSUser
	,dbo.FullGroupEnumAttributesAsRows.CreationTimeStamp
	,dbo.FullGroupEnumAttributesAsRows.GPSUpdateTimestamp	
FROM dbo.FullGroupEnumAttributesAsRows
INNER JOIN dbo.CountryViewAccess ON dbo.FullGroupEnumAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullGroupEnumAttributesAsRows.CountryISO2A = dbo.CountryViewAccess.Country
