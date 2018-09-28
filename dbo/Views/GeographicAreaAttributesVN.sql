CREATE VIEW [dbo].[GeographicAreaAttributesVN]
AS
SELECT    *
FROM [dbo].[FullGeographicAreaAttributesVN] INNER JOIN
dbo.CountryViewAccess ON [dbo].[FullGeographicAreaAttributesVN].CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME()) AND [FullGeographicAreaAttributesVN].[CountryISO2A] = dbo.CountryViewAccess.Country








