
/****** Script for SelectTopNRows command from SSMS  ******/
CREATE VIEW [dbo].[GroupStatusHistory]
AS
SELECT [CountryISO2A]
	,[Sequence]
	,[GPSUser]
	,[Date]
	,[FromState]
	,[ToState]
	,[ReasonCode]
FROM [dbo].[FullGroupStatusHistory]
INNER JOIN dbo.CountryViewAccess ON dbo.FullGroupStatusHistory.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullGroupStatusHistory.CountryISO2A = dbo.CountryViewAccess.Country