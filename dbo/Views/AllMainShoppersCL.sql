
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[AllMainShoppersCL]
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
FROM [dbo].[AllFullMainShoppersCL]
INNER JOIN dbo.CountryViewAccess ON dbo.AllFullMainShoppersCL.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.AllFullMainShoppersCL.CountryISO2A = dbo.CountryViewAccess.Country

GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CountryISO2A  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersCL', @level2type=N'COLUMN',@level2name=N'CountryISO2A'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'MainShopperId  - For Countries using Main Shopper at Panel Level. This column holds the BusinessID for the Main Shopper on the Panel eg: 123456-01.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersCL', @level2type=N'COLUMN',@level2name=N'MainShopperId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GroupId  - Holds the Business ID for the Group eg: 123456.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersCL', @level2type=N'COLUMN',@level2name=N'GroupId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelCode  - PanelCode and PanelName for each Panel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersCL', @level2type=N'COLUMN',@level2name=N'PanelCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelName  - PanelCode and PanelName for each Panel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersCL', @level2type=N'COLUMN',@level2name=N'PanelName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanellistState  - a Panellist can have many different states during their life time eg: Interested, Live, dropped off. Holds the current state fo the panellist.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersCL', @level2type=N'COLUMN',@level2name=N'PanellistState'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SignupDate  - the date a Panellist joined KWP and became eligible to join panels. SOme countires may have different definitions on this value.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersCL', @level2type=N'COLUMN',@level2name=N'SignupDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'LiveDate  - the date a Panellist joined the Panel, and started returning data.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersCL', @level2type=N'COLUMN',@level2name=N'LiveDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'DropoffDate  - the date a Panellist was removed from a Panel.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersCL', @level2type=N'COLUMN',@level2name=N'DropoffDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'AllFullMainShoppersMY, AllMainShoppersCL,' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersCL'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Panellist roles' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersCL'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Country Specific MY only. Provides a list of the ID''s, names panels, sign up, Live dates and Drop off date if relevant of all Main shoppers. Data will be restricted via CountryViewAccess for the User and data in AllFullMainShoppersMY' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersCL'
GO

--GRANT SELECT ON AllMainShoppersCL TO GPSBusiness

--GO
