CREATE VIEW [dbo].[GroupIncentiveBalance]
AS
select dbo.FullGroupIncentiveBalance.CountryISO2A, dbo.FullGroupIncentiveBalance.GroupId, dbo.FullGroupIncentiveBalance.[Amount]
From  [dbo].[FullGroupIncentiveBalance] CROSS JOIN
                      dbo.CountryViewAccess
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME()) AND dbo.FullGroupIncentiveBalance.CountryISO2A = dbo.CountryViewAccess.Country