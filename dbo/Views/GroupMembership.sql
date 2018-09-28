
CREATE VIEW [dbo].[GroupMembership]
AS
SELECT dbo.FullGroupMembership.CountryISO2A
	,dbo.FullGroupMembership.GroupId
	,dbo.FullGroupMembership.IndividualId
	,dbo.FullGroupMembership.STATE
	,dbo.FullGroupMembership.SignUpDate
	,dbo.FullGroupMembership.DeletedDate
	,dbo.FullGroupMembership.ChangeDate
FROM dbo.FullGroupMembership
CROSS JOIN dbo.CountryViewAccess
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullGroupMembership.CountryISO2A = dbo.CountryViewAccess.Country