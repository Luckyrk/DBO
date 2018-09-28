CREATE VIEW [dbo].[FullDiaryEntries_NEW]
AS 
SELECT dbo.Country.CountryISO2A, dbo.Panel.PanelCode as PanelCode, dbo.Panel.Name as PanelName, dbo.DiaryEntry.BusinessId as IndividualID, dbo.DiaryEntry.Points, dbo.DiaryEntry.DiaryDateYear,
dbo.DiaryEntry.DiaryDatePeriod, dbo.DiaryEntry.DiaryDateWeek, dbo.DiaryEntry.NumberOfDaysLate,
dbo.DiaryEntry.NumberOfDaysEarly,
dbo.DiaryEntry.DiaryState, dbo.DiaryEntry.ReceivedDate, dbo.DiaryEntry.GPSUser, dbo.DiaryEntry.GPSUpdateTimestamp, dbo.DiaryEntry.CreationTimeStamp, dbo.DiaryEntry.DiarySourceFull, 
dbo.DiaryEntry.ConsecutiveEntriesReceived, dbo.DiaryEntry.Together, dbo.DiaryEntry.IncentiveCode, dbo.MissingDiaries.ClaimFlag
FROM dbo.DiaryEntry inner join dbo.Panel on dbo.Panel.GUIDReference = dbo.DiaryEntry.PanelId
inner join dbo.Country on dbo.Country.CountryId = dbo.Panel.Country_Id
left outer join dbo.MissingDiaries  ON 
dbo.DiaryEntry.BusinessId = dbo.MissingDiaries.BusinessId
and dbo.DiaryEntry.PanelId = dbo.MissingDiaries.PanelId and dbo.DiaryEntry.DiaryDatePeriod = dbo.MissingDiaries.DiaryDatePeriod
and dbo.DiaryEntry.DiaryDateWeek = dbo.MissingDiaries.DiaryDateWeek and dbo.DiaryEntry.DiaryDateYear = dbo.MissingDiaries.DiaryDateYear

UNION 

SELECT dbo.Country.CountryISO2A
,dbo.Panel.PanelCode as PanelCode,dbo.Panel.Name as PanelName
,dbo.MissingDiaries.BusinessId as IndividualID
,NULL,dbo.MissingDiaries.DiaryDateYear ,dbo.MissingDiaries.DiaryDatePeriod
,dbo.MissingDiaries.DiaryDateWeek,NULL
,NULL,NULL
,NULL,NULL,NULL
,NULL,NULL ,
NULL,NULL,NULL
,dbo.MissingDiaries.ClaimFlag
FROM dbo.MissingDiaries inner join dbo.Panel 
on dbo.Panel.GUIDReference = dbo.MissingDiaries.PanelId
inner join dbo.Country on dbo.Country.CountryId = dbo.Panel.Country_Id
AND dbo.MissingDiaries.Id not in ( Select dbo.MissingDiaries.Id from dbo.MissingDiaries , dbo.DiaryEntry  where
dbo.MissingDiaries.BusinessId = dbo.DiaryEntry.BusinessId
and dbo.MissingDiaries.PanelId = dbo.DiaryEntry.PanelId and dbo.MissingDiaries.DiaryDatePeriod = dbo.DiaryEntry.DiaryDatePeriod
and dbo.MissingDiaries.DiaryDateWeek = dbo.DiaryEntry.DiaryDateWeek and dbo.MissingDiaries.DiaryDateYear = dbo.DiaryEntry.DiaryDateYear)