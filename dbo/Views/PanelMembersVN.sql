GO

/****** Script for SelectTopNRows command from SSMS  ******/
CREATE view [dbo].[PanelMembersVN]
as
SELECT [CountryISO2A]
      ,[IndividualId]
      ,[DateOfBirth]
      ,[SexCode]
      ,[SexDescription]
      ,[TitleDescription]
      ,[FirstOrderedName]
      ,[PanelCode]
      ,[PanelName]
      ,[PanellistState]
      ,[MainShopperId]
      ,[SignupDate]
      ,[LiveDate]
  FROM [dbo].[FullPanelMembersVN]
  INNER JOIN
       dbo.CountryViewAccess ON dbo.FullPanelMembersVN.CountryISO2A = dbo.CountryViewAccess.Country
  WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME()) 
          AND dbo.FullPanelMembersVN.CountryISO2A = dbo.CountryViewAccess.Country




GO

--GRANT SELECT ON PanelMembersVN TO GPSBusiness
--GO
