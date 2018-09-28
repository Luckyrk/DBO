GO

CREATE VIEW [dbo].[MainShoppersID]
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
FROM [dbo].[FullMainShoppersID]
INNER JOIN dbo.CountryViewAccess ON dbo.FullMainShoppersID.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullMainShoppersID.CountryISO2A = dbo.CountryViewAccess.Country

GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Country Specific. Optimized view of MainShoppers for ID' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'MainShoppersID'
GO

