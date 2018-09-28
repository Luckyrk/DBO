
CREATE VIEW [dbo].[vwDiaryEntry_PeriodId]
AS
SELECT Id
	,Points
	,DiaryDateYear
	,DiaryDatePeriod
	,DiaryDateWeek
	,(
		SELECT TOP 1 v.CalendarID
		FROM (
			SELECT TOP 1 CalendarID
			FROM PanelCalendarMapping PCM
			WHERE PCM.PanelID = de.PanelId
			
			UNION
			
			SELECT TOP 1 CalendarId
			FROM CountryCalendarMapping
			WHERE CalendarId NOT IN (
					SELECT CalendarID
					FROM PanelCalendarMapping PCM
					)
				AND CountryId = (
					SELECT Country_Id
					FROM Panel P
					WHERE P.GUIDReference = de.PanelId
					)
			) v
		) AS CalendarId
	,
	--(select dbo.fn_getCalendarId_DiaryEntry(PanelId,CreationTimeStamp)) as CalendarId,  
	(
		SELECT [dbo].[fn_GetPeriodId_DiaryEntry](de.PanelId, de.CreationTimeStamp, DiaryDateYear, DiaryDatePeriod, DiaryDateWeek)
		) AS periodid
	,(
		SELECT dbo.fn_GetWeekPeriodId_DiaryEntry(de.PanelId, de.CreationTimeStamp, DiaryDateYear, DiaryDatePeriod, DiaryDateWeek)
		) AS weekPeriod
	,
	--(select [dbo].[fn_PanelMember_id_businessId](PanelId,BusinessId)) as PanelMember_Id,  
	(
		CASE 
			WHEN p.[Type] = 'HouseHold'
				THEN (
						SELECT TOP 1 cm.Group_Id AS PanelMemberId
						FROM Individual il
						INNER JOIN Candidate c ON c.GUIDReference = il.GUIDReference
						INNER JOIN CollectiveMembership cm ON cm.Individual_Id = c.GUIDReference
						INNER JOIN Panel p ON p.GUIDReference = de.PanelId
						INNER JOIN Country ct ON ct.CountryId = p.Country_Id
						)
			WHEN p.[Type] = 'Individual'
				THEN (
						SELECT TOP 1 il.GUIDReference AS PanelMemberId
						FROM Individual il
						INNER JOIN Candidate c ON il.GUIDReference = c.GUIDReference
						INNER JOIN Panel p ON p.GUIDReference = de.PanelId
						INNER JOIN Country ct ON ct.CountryId = p.Country_Id
						)
			END
		) AS panelMember_Id
	,NumberOfDaysLate
	,NumberOfDaysEarly
	,DiaryState
	,ReceivedDate
	,de.GPSUser
	,de.GPSUpdateTimestamp
	,de.CreationTimeStamp
	,DiarySourceFull
	,BusinessId
	,Together
	,PanelId
	,IncentiveCode
	,ClaimFlag
	,ConsecutiveEntriesReceived
FROM DiaryEntry de
INNER JOIN Panel p ON p.GUIDReference = de.PanelId