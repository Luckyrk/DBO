CREATE VIEW [dbo].[GroupAttributesVN]
AS
SELECT    *
FROM         [dbo].[FullGroupAttributesVN] INNER JOIN
                      dbo.CountryViewAccess ON [dbo].[FullGroupAttributesVN].CountryISO2A = dbo.CountryViewAccess.Country
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME()) AND (dbo.CountryViewAccess.AllowPID = 1) AND [dbo].[FullGroupAttributesVN].CountryISO2A = dbo.CountryViewAccess.Country




