
CREATE VIEW [dbo].[DiaryEntries]
AS
SELECT [CountryISO2A]
	,[PanelCode]
	,[PanelName]
	,[IndividualId]
	,[Points]
	,[DiaryDateYear]
	,[DiaryDatePeriod]
	,[DiaryDateWeek]
	,[NumberOfDaysLate]
	,[NumberOfDaysEarly]
	,[DiaryState]
	,[ReceivedDate]
	,[GPSUser]
	,[GPSUpdateTimestamp]
	,[CreationTimeStamp]
	,[DiarySourceFull]
	,[ConsecutiveEntriesReceived]
	,[Together]
	,[IncentiveCode]
	,[ClaimFlag]
FROM [dbo].[FullDiaryEntries]
INNER JOIN dbo.CountryViewAccess ON dbo.FullDiaryEntries.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullDiaryEntries.CountryISO2A = dbo.CountryViewAccess.Country 