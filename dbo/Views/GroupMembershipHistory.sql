
CREATE VIEW [dbo].[GroupMembershipHistory]
AS
SELECT [CountryISO2A]
	,[Sequence]
	,[IndividualId]
	,[GPSUser]
	,[Date]
	,[FromState]
	,[ToState]
	,[ReasonCode]
FROM [dbo].[FullGroupMembershipHistory]
INNER JOIN dbo.CountryViewAccess ON dbo.FullGroupMembershipHistory.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullGroupMembershipHistory.CountryISO2A = dbo.CountryViewAccess.Country