
CREATE VIEW [dbo].[GetDiaryCount]
AS
SELECT c.CountryIso2a
	,p.PanelCode
	,de.PanelId
	,de.BusinessId
	,DiaryDateYear
	,DiaryDatePeriod
FROM DiaryEntry de
INNER JOIN panel p ON p.GUIDReference = de.PanelId
INNER JOIN country c ON c.Countryid = p.Country_id