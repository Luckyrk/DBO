
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[AllMainShoppersTW]
AS
SELECT [CountryISO2A]
      ,[MainShopperId]
      ,[GroupId]
      ,[PanelCode]
      ,[PanelName]
      ,[PanellistState]
      ,[SignupDate]
	  , LiveDate
      ,DropoffDate
FROM [dbo].[AllFullMainShoppersTW]
INNER JOIN dbo.CountryViewAccess ON dbo.AllFullMainShoppersTW.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.AllFullMainShoppersTW.CountryISO2A = dbo.CountryViewAccess.Country
GO

--GRANT SELECT ON [AllMainShoppersTW] TO GPSBusiness

--GO
