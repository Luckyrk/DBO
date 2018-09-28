
CREATE VIEW [dbo].[GroupCreationDateWho]
	WITH SCHEMABINDING
AS
SELECT Sequence AS BusinessID
	,c.GUIDReference AS GroupID
	,c.GPSUser
	,c.CreationTimeStamp AS GroupCreationDate
FROM dbo.Collective c
INNER JOIN dbo.Country cty ON cty.CountryID = c.CountryID
INNER JOIN dbo.CountryViewAccess cva ON cva.Country = cty.CountryISO2A
WHERE cva.UserId = SUSER_SNAME()