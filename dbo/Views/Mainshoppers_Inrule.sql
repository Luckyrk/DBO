CREATE VIEW [dbo].[Mainshoppers_Inrule]
AS
SELECT CountryISO2A
       ,MainShopperId 
       , GroupId     
       ,PanelCode
       , PanelName
       , PanellistState
       ,  SignupDate  

FROM [dbo].FullMainshoppers_Inrule
INNER JOIN dbo.CountryViewAccess ON dbo.FullMainshoppers_Inrule.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
       AND dbo.FullMainshoppers_Inrule.CountryISO2A = dbo.CountryViewAccess.Country
