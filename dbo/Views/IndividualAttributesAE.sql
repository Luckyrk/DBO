GO


CREATE VIEW [dbo].[IndividualAttributesAE]
AS
SELECT    *
FROM         [dbo].[FullIndividualAttributesAE] INNER JOIN
                      dbo.CountryViewAccess ON [dbo].[FullIndividualAttributesAE].CountryISO2A = dbo.CountryViewAccess.Country
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME()) AND (dbo.CountryViewAccess.AllowPID = 1) AND [dbo].[FullIndividualAttributesAE].CountryISO2A = dbo.CountryViewAccess.Country




GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CountryISO2A  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualAttributesAE', @level2type=N'COLUMN',@level2name=N'CountryISO2A'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'IndividualId  - Holds the Business ID for the Individual, based on the format specified by a Country eg: 1234567-01.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualAttributesAE', @level2type=N'COLUMN',@level2name=N'IndividualId'
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'Holds details of the associated Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualAttributesAE'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Holds details of the Business Area of data in the View.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualAttributesAE'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Country Specific. List of Individual Attributes (Demograhics) as Columns (BR). Dynamically recreated is a Demographic is added, changed or deleted via the UI or database script' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'IndividualAttributesAE'
GO

--GRANT SELECT ON [IndividualAttributesAE] TO GPSBusiness

--GO
