
CREATE VIEW [dbo].[FullCalendars]
AS
SELECT CountryISO2A
	,CAST(CalendarDescription AS VARCHAR(255)) AS CalendarDescription
	,CAST(PeriodTypeDescription AS VARCHAR(255)) AS PeriodTypeDescription
	,CASE 
		WHEN ChildPeriodLevel = 1
			THEN Convert(VARCHAR, PeriodValue)
		WHEN ChildPeriodLevel = 2
			THEN CONCAT (
					Convert(VARCHAR, Sum(PeriodLevelOne))
					,'.'
					,Convert(VARCHAR, PeriodValue)
					)
		WHEN ChildPeriodLevel = 3
			THEN CONCAT (
					Convert(VARCHAR, Sum(PeriodLevelOne))
					,'.'
					,Convert(VARCHAR, Sum(PeriodLevelTwo))
					,'.'
					,Convert(VARCHAR, PeriodValue)
					)
		WHEN ChildPeriodLevel = 4
			THEN CONCAT (
					Convert(VARCHAR, Sum(PeriodLevelOne))
					,'.'
					,Convert(VARCHAR, Sum(PeriodLevelTwo))
					,'.'
					,Convert(VARCHAR, Sum(PeriodLevelThree))
					,'.'
					,Convert(VARCHAR, PeriodValue)
					)
		ELSE 'Unknown' -- Too many levels in hierachy that have been coded for
		END AS FullPeriod
	,CASE 
		WHEN ChildPeriodLevel = 1
			THEN PeriodValue
		ELSE CASE 
				WHEN Sum(PeriodLevelOne) = 0
					THEN NULL
				ELSE Convert(VARCHAR, Sum(PeriodLevelOne))
				END
		END AS Year
	,CASE 
		WHEN ChildPeriodLevel = 2
			THEN PeriodValue
		ELSE CASE 
				WHEN Sum(PeriodLevelTwo) = 0
					THEN NULL
				ELSE Convert(VARCHAR, Sum(PeriodLevelTwo))
				END
		END AS Period
	,CASE 
		WHEN ChildPeriodLevel = 3
			THEN PeriodValue
		ELSE CASE 
				WHEN Sum(PeriodLevelThree) = 0
					THEN NULL
				ELSE Convert(VARCHAR, Sum(PeriodLevelThree))
				END
		END AS Week
	,CASE 
		WHEN ChildPeriodLevel = 4
			THEN PeriodValue
		ELSE CASE 
				WHEN Sum(PeriodLevelFour) = 0
					THEN NULL
				ELSE Convert(VARCHAR, Sum(PeriodLevelFour))
				END
		END AS PeriodLevelFour
	,StartDate
	,EndDate
	,PanelCode
	,PanelName
	,Id AS CalendarId
	,CASE 
		WHEN ChildPeriodLevel = 1
			THEN PeriodId
		ELSE CASE 
				WHEN Max(PeriodLevelOne) = 0
					THEN NULL
				ELSE Max(PeriodLevelOneId)
				END
		END AS YearId
	,CASE 
		WHEN ChildPeriodLevel = 2
			THEN PeriodId
		ELSE CASE 
				WHEN Max(PeriodLevelTwo) = 0
					THEN NULL
				ELSE Max(PeriodLevelTwoId)
				END
		END AS PeriodId
	,CASE 
		WHEN ChildPeriodLevel = 3
			THEN PeriodId
		ELSE CASE 
				WHEN Max(PeriodLevelThree) = 0
					THEN NULL
				ELSE Max(PeriodLevelThreeId)
				END
		END AS WeekId
	,CASE 
		WHEN ChildPeriodLevel = 4
			THEN PeriodId
		ELSE CASE 
				WHEN Max(PeriodLevelFour) = 0
					THEN NULL
				ELSE Max(PeriodLevelFourId)
				END
		END AS PeriodLevelFourId
FROM (
	SELECT e.[GUIDReference] AS Id
		,b.CountryISO2A
		,e.CalendarDescription
		,p.PeriodTypeDescription
		,g.SequenceWithinHierarchy + 1 AS ChildPeriodLevel -- +1 as Child
		,f.PeriodValue
		,f.PeriodId
		,f.StartDate
		,f.EndDate
		,CASE 
			WHEN h.SequenceWithinHierarchy = 1
				THEN i.PeriodValue
			ELSE 0
			END AS PeriodLevelOne
		,CASE 
			WHEN h.SequenceWithinHierarchy = 2
				THEN i.PeriodValue
			ELSE 0
			END AS PeriodLevelTwo
		,CASE 
			WHEN h.SequenceWithinHierarchy = 3
				THEN i.PeriodValue
			ELSE 0
			END AS PeriodLevelThree
		,CASE 
			WHEN h.SequenceWithinHierarchy = 4
				THEN i.PeriodValue
			ELSE 0
			END AS PeriodLevelFour
		,CASE 
			WHEN h.SequenceWithinHierarchy = 1
				THEN i.PeriodId
			END AS PeriodLevelOneId
		,CASE 
			WHEN h.SequenceWithinHierarchy = 2
				THEN i.PeriodId
			END AS PeriodLevelTwoId
		,CASE 
			WHEN h.SequenceWithinHierarchy = 3
				THEN i.PeriodId
			END AS PeriodLevelThreeId
		,CASE 
			WHEN h.SequenceWithinHierarchy = 4
				THEN i.PeriodId
			END AS PeriodLevelFourId
		,i.StartDate AS ParentStartDate
		,i.EndDate AS ParentEndDate
		,i.PeriodValue AS ParentPeriodValue
		,l.PanelCode
		,l.NAME AS PanelName
	FROM dbo.Country b
	INNER JOIN dbo.Calendar e ON b.CountryId = e.Country_Id
	LEFT JOIN dbo.PanelCalendarMapping m ON e.GUIDReference = m.CalendarID
	LEFT JOIN dbo.Panel l ON l.GUIDReference = m.PanelID
	INNER JOIN dbo.calendarperiod f ON f.CalendarId = e.GUIDReference
		AND f.OwnerCountryId = e.Country_Id
	INNER JOIN dbo.PeriodType p ON p.PeriodTypeId = f.PeriodTypeId
	LEFT JOIN dbo.CalendarPeriodHierarchy g ON g.CalendarId = e.GUIDReference
		AND g.ChildPeriodTypeId = f.PeriodTypeId
	LEFT JOIN dbo.CalendarPeriodHierarchy h ON h.CalendarId = e.GUIDReference
	LEFT JOIN dbo.CalendarPeriod i ON i.OwnerCountryId = e.Country_Id
		AND i.CalendarId = e.GUIDReference
		AND i.PeriodTypeId = h.ParentPeriodTypeId
		AND i.PeriodTypeId != f.PeriodTypeId
		AND i.StartDate <= f.StartDate
		AND i.EndDate >= f.endDate
	) a
GROUP BY Id
	,CountryISO2A
	,CalendarDescription
	,PeriodTypeDescription
	,ChildPeriodLevel
	,PeriodValue
	,PeriodId
	,StartDate
	,EndDate
	,PanelCode
	,PanelName