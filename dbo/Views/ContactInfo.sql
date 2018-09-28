
CREATE VIEW [dbo].[ContactInfo]
AS
SELECT [CountryISO2A]
	,[MainShopperId]
	,[GroupId]
	,[MainContactName]
	,[PanelCode]
	,[PanelName]
	,[CollaborationMethodology]
	,[PanellistState]
	,[HomePhone]
	,[WorkPhone]
	,[MobilePhone]
	,[EmailAddress]
	,[HomeAddress]
	,[PostalAddress]
	,[Comment]
FROM [dbo].[FullContactInfo]
INNER JOIN dbo.CountryViewAccess ON dbo.FullContactInfo.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullContactInfo.CountryISO2A = dbo.CountryViewAccess.Country