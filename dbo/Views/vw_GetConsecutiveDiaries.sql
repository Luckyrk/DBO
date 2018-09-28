
CREATE view [dbo].[vw_GetConsecutiveDiaries]
as

SELECT DISTINCT i.IndividualId AS BusinessId
       ,pl.PanelCode AS PanelCode
       ,pl.Name AS PanelName
       ,c.CountryISO2A AS CountryCode
       ,sd.Code AS PanelistState
       ,de.ReceivedDate
       ,Count(*) AS NoofConsecutiveDiaries
FROM vwDiaryEntry_PeriodId de
INNER JOIN Individual i ON i.IndividualId = de.BusinessId
INNER JOIN Panel pl ON pl.GUIDReference = de.PanelId
INNER JOIN Country C ON C.CountryId = pl.Country_Id
INNER JOIN Panelist p ON p.PanelMember_Id = de.PanelMember_Id and c.CountryId=pl.Country_Id
INNER JOIN StateDefinition sd ON p.State_Id = sd.Id and sd.Country_Id=c.CountryId
WHERE de.NumberOfDaysEarly <> 1
       AND de.NumberOfDaysLate <> 1
GROUP BY i.IndividualId
       ,pl.PanelCode
       ,c.CountryISO2A
       ,sd.Code
       ,pl.Name
       ,de.ReceivedDate