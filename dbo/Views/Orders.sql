
CREATE VIEW [dbo].[Orders]
AS
SELECT *
FROM dbo.FullOrders
CROSS JOIN dbo.CountryViewAccess
WHERE (
		dbo.CountryViewAccess.UserId = SUSER_SNAME()
		AND dbo.FullOrders.CountryISO2A = dbo.CountryViewAccess.Country
		)