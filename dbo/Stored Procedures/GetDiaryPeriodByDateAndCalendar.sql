CREATE PROCEDURE [dbo].[GetDiaryPeriodByDateAndCalendar] (
	 @pTargetDate DATETIME
	,@pCalendarId UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	)
AS
BEGIN
BEGIN TRY 
	DECLARE @YearPeriodId UNIQUEIDENTIFIER
		,@MonthPeriodId UNIQUEIDENTIFIER
		,@WeekPeriodId UNIQUEIDENTIFIER
		,@DiaryPeriod VARCHAR(20)
		
	SELECT @YearPeriodId = PeriodTypeId
	FROM PeriodType
	WHERE OwnerCountry_Id = @pCountryId
		AND PeriodGroup = 1
		AND PeriodGroupSequence = 1 -- year

	SELECT @MonthPeriodId = PeriodTypeId
	FROM PeriodType
	WHERE OwnerCountry_Id = @pCountryId
		AND PeriodGroup = 1
		AND PeriodGroupSequence = 2 -- period

	SELECT @WeekPeriodId = PeriodTypeId
	FROM PeriodType
	WHERE OwnerCountry_Id = @pCountryId
		AND PeriodGroup = 1
		AND PeriodGroupSequence = 3 -- week

	DECLARE @dummyTable TABLE (
		DiaryYear VARCHAR(20)
		,DiaryPeriod VARCHAR(20)
		,StartDate DATETIME
		,EndDate DATETIME
		,DiaryWeek VARCHAR(30)
		,RowNum INT
		)

	INSERT INTO @dummyTable
	SELECT a.PeriodValue AS [year]
		,b.PeriodValue AS period
		,c.StartDate
		,c.EndDate
		,c.PeriodValue AS [week]
		,row_number() OVER (
			PARTITION BY a.PeriodValue
			,b.PeriodValue ORDER BY c.PeriodValue
			) AS id
	FROM CalendarPeriod a
	INNER JOIN CalendarPeriod b ON (
			b.StartDate BETWEEN a.StartDate
				AND a.EndDate
			)
		AND (a.CalendarId = b.CalendarId)
	INNER JOIN CalendarPeriod c ON (
			c.StartDate BETWEEN b.StartDate
				AND b.EndDate
			)
		AND (c.CalendarId = b.CalendarId)
	WHERE a.CalendarId = @pCalendarId
		AND a.PeriodTypeId = @YearPeriodId
		AND b.PeriodTypeId = @MonthPeriodId
		AND c.PeriodTypeId = @WeekPeriodId

	SELECT @DiaryPeriod = Convert(VARCHAR, DiaryYear) + '.' + Convert(VARCHAR, DiaryPeriod) + '.' + Convert(VARCHAR, (
				CASE 
					WHEN DiaryWeek % 4 = 0
						AND RowNum <> 5
						THEN 4
					WHEN DiaryWeek % 4 <> 0
						AND RowNum = 5
						THEN 5
					ELSE DiaryWeek % 4
					END
				))
	FROM @dummyTable t
	WHERE DATEADD(week, 0, CONVERT(DATE, @pTargetDate)) BETWEEN CONVERT(DATE, t.StartDate)
			AND CONVERT(DATE, t.EndDate)

	SELECT @DiaryPeriod AS DiaryPeriod
END TRY 
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH
END