GO

CREATE VIEW [dbo].[MainShoppersAE]
AS
SELECT [CountryISO2A]
	,[MainShopperId]
	,GroupId
	,[DateOfBirth]
	,[SexCode]
	,[SexDescription]
	,[TitleDescription]
	,[FirstOrderedName]
	,[PanelCode]
	,[PanelName]
	,[PanellistState]
	,[SignupDate]
	,[LiveDate]
FROM [dbo].[FullMainShoppersAE]
INNER JOIN dbo.CountryViewAccess ON dbo.FullMainShoppersAE.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullMainShoppersAE.CountryISO2A = dbo.CountryViewAccess.Country


GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CountryISO2A  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'CountryISO2A'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'MainShopperId  - For Countries using Main Shopper at Panel Level. This column holds the BusinessID for the Main Shopper on the Panel eg: 123456-01.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'MainShopperId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GroupId  - Holds the Business ID for the Group eg: 123456.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'GroupId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'DateOfBirth  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'DateOfBirth'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SexCode  - Holds the GenderID for the Individual. 1 = Male, 2 = Female and 3 = Unknown.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'SexCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SexDescription  - Holds the Gender for the Individual.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'SexDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'TitleDescription  - Holds the Title of an Individual, where specified.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'TitleDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'FirstOrderedName  - Holds the first name of an Individual. Some countries may not use this value' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'FirstOrderedName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelCode  - PanelCode and PanelName for each Panel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'PanelCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanelName  - PanelCode and PanelName for each Panel' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'PanelName'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'PanellistState  - a Panellist can have many different states during their life time eg: Interested, Live, dropped off. Holds the current state fo the panellist.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'PanellistState'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SignupDate  - the date a Panellist joined KWP and became eligible to join panels. SOme countires may have different definitions on this value.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'SignupDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'LiveDate  - the date a Panellist joined the Panel, and started returning data.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE', @level2type=N'COLUMN',@level2name=N'LiveDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'Holds details of the associated Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Holds details of the Business Area of data in the View.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Country Specific. Optimized view of MainShoppers for ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersAE'
GO


--GRANT SELECT ON MainShoppersAE TO GPSBusiness

--GO
