CREATE VIEW [dbo].[IndividualKey]
AS
select dbo.FullIndividualKey.CountryISO2A, dbo.FullIndividualKey.IndividualId, dbo.FullIndividualKey.[IndividualKey]
From  [dbo].[FullIndividualKey] CROSS JOIN
                      dbo.CountryViewAccess
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME()) AND dbo.FullIndividualKey.CountryISO2A = dbo.CountryViewAccess.Country