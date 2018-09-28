
CREATE VIEW [dbo].[GetConsecutiveDiaries]
AS
SELECT c.CountryISO2A
	,de.BusinessId
	,p.PanelCode
	,de.ReceivedDate
FROM diaryentry de
INNER JOIN Panel P ON p.guidreference = de.panelid
INNER JOIN country c ON c.countryid = p.Country_id
WHERE de.NumberOfDaysEarly <> 1
	AND de.NumberOfDaysLate <> 1