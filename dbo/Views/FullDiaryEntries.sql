
CREATE VIEW [dbo].[FullDiaryEntries]
AS
SELECT dbo.Country.CountryISO2A
	,dbo.Panel.PanelCode AS PanelCode
	,dbo.Panel.NAME AS PanelName
	,dbo.DiaryEntry.BusinessId AS IndividualID
	,dbo.DiaryEntry.Points
	,dbo.DiaryEntry.DiaryDateYear
	,dbo.DiaryEntry.DiaryDatePeriod
	,dbo.DiaryEntry.DiaryDateWeek
	,dbo.DiaryEntry.NumberOfDaysLate
	,dbo.DiaryEntry.NumberOfDaysEarly
	,dbo.DiaryEntry.DiaryState
	,dbo.DiaryEntry.ReceivedDate
	,dbo.DiaryEntry.GPSUser
	,dbo.DiaryEntry.GPSUpdateTimestamp
	,dbo.DiaryEntry.CreationTimeStamp
	,dbo.DiaryEntry.DiarySourceFull
	,dbo.DiaryEntry.ConsecutiveEntriesReceived
	,dbo.DiaryEntry.Together
	,dbo.DiaryEntry.IncentiveCode
	,dbo.DiaryEntry.ClaimFlag
FROM dbo.DiaryEntry
INNER JOIN dbo.Panel ON dbo.Panel.GUIDReference = dbo.DiaryEntry.PanelId
INNER JOIN dbo.Country ON dbo.Country.CountryId = dbo.Panel.Country_Id

UNION ALL

SELECT dbo.Country.CountryISO2A
	,dbo.Panel.PanelCode AS PanelCode
	,dbo.Panel.NAME AS PanelName
	,dbo.MissingDiaries.BusinessId AS IndividualID
	,0
	,dbo.MissingDiaries.DiaryDateYear
	,dbo.MissingDiaries.DiaryDatePeriod
	,dbo.MissingDiaries.DiaryDateWeek
	,dbo.MissingDiaries.NumberOfDaysLate
	,dbo.MissingDiaries.NumberOfDaysEarly
	,NULL
	,dbo.MissingDiaries.ReceivedDate
	,dbo.MissingDiaries.GPSUser
	,dbo.MissingDiaries.GPSUpdateTimestamp
	,dbo.MissingDiaries.CreationTimeStamp
	,dbo.MissingDiaries.DiarySourceFull
	,NULL
	,NULL
	,NULL
	,dbo.MissingDiaries.ClaimFlag
FROM dbo.MissingDiaries
INNER JOIN dbo.Panel ON dbo.Panel.GUIDReference = dbo.MissingDiaries.PanelId
INNER JOIN dbo.Country ON dbo.Country.CountryId = dbo.Panel.Country_Id  