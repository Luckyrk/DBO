
CREATE VIEW [dbo].[IncentiveLevelSet]
AS
SELECT il.Code
	,il.Description
	,p.NAME
	,p.PanelCode
	,c.CountryISO2A AS CountryCode
FROM incentivelevel il
INNER JOIN Country c ON c.CountryId = il.Country_Id
INNER JOIN Panel p ON p.GUIDReference = il.Panel_Id