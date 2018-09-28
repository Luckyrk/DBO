
CREATE VIEW [dbo].[LivePanelMembers]
AS
SELECT [CountryISO2A]
	,[GroupId]
	,[IndividualId]
	,[DateOfBirth]
	,[SexCode]
	,[SexDescription]
	,[TitleDescription]
	,[FirstOrderedName]
	,[LastOrderedName]
	,[PanelCode]
	,[PanelName]
	,[SignupDate]
	,[LiveDate]
	,[DroppedOffDate]
FROM [dbo].[FullLivePanelMembers]
INNER JOIN dbo.CountryViewAccess ON dbo.FullLivePanelMembers.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullLivePanelMembers.CountryISO2A = dbo.CountryViewAccess.Country