

CREATE VIEW [dbo].[GroupAliasES]
AS
SELECT    *
FROM         [dbo].[FullGroupAliasES] INNER JOIN
                      dbo.CountryViewAccess ON [dbo].[FullGroupAliasES].CountryISO2A = dbo.CountryViewAccess.Country
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME()) AND (dbo.CountryViewAccess.AllowPID = 1) AND [dbo].[FullGroupAliasES].CountryISO2A = dbo.CountryViewAccess.Country