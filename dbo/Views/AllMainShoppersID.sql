CREATE VIEW [dbo].[AllMainShoppersID]
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
FROM [dbo].[AllFullMainShoppersID]
INNER JOIN dbo.CountryViewAccess ON dbo.AllFullMainShoppersID.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.AllFullMainShoppersID.CountryISO2A = dbo.CountryViewAccess.Country

GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Country Specific VN only. Provides a list of the ID''s, names panels, sign up, Live dates and Drop off date if relevant of all Main shoppers' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'AllMainShoppersID'
GO

