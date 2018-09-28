CREATE VIEW [dbo].[FullIndividualReferers]
AS 
SELECT b.[CountryISO2A]
      ,a.[IndividualId]
	  ,c.IndividualId as RefererId
  FROM [Individual] a
  JOIN Country b ON b.CountryId = a.CountryId
  JOIN Individual c ON c.GUIDReference = a.Referer

GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Shows Referers of individuals.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullIndividualReferers'
GO

