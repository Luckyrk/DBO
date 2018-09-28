--SELECT * FROM fn_GetActualCalendarYearPeriodWeek('17d348d8-a08d-ce7a-cb8c-08cf81794a86','b92e0956-6188-ca75-b566-08d11b00446d','2015-09-01 00:00:00','2015-09-08 00:00:00'
--,'7CAE99B5-161C-4E42-A34F-19335318FF28','063926F3-2FB0-469C-8B38-C09D5F58E4A0','CA95BFA0-866E-4B61-8267-A398078A7639')

CREATE FUNCTION [dbo].[fn_GetActualCalendarYearPeriodWeek](
	 @pCountryID UNIQUEIDENTIFIER
	,@pPanelId UNIQUEIDENTIFIER
	,@pProcessingDate DATETIME
	,@pCalendareRececiedDate DATETIME
	,@YearPeriodId UNIQUEIDENTIFIER
	,@MonthPeriodId UNIQUEIDENTIFIER
	,@WeekPeriodId UNIQUEIDENTIFIER
)
RETURNS @ActualCalendarYearPeriodWeek TABLE (
PanelId UNIQUEIDENTIFIER,
   CalendarId       UNIQUEIDENTIFIER ,
   IsYpwCalendar   INT ,
   ProcessingDatePeriod VARCHAR(100),
   ProcessingDatePeriodDiaryReport VARCHAR(100),
   CalendareRececiedDatePeriod VARCHAR(100),
   CalendareRececiedDatePeriodYear VARCHAR(100),
   CalendareRececiedDatePeriodPeriod VARCHAR(100),
   CalendareRececiedDatePeriodWeek VARCHAR(100),
   StartDate DATETIME,
   EndDate DATETIME
) 
AS
BEGIN
DECLARE @CalendarID AS UNIQUEIDENTIFIER,@StartDate DATETIME,@EndDate DATETIME
	DECLARE @ProcessingDatePeriod AS VARCHAR(10)
	DECLARE @ProcessingDatePeriodDiaryReport as VARCHAR(10)
	DECLARE @CalendareRececiedDatePeriod AS VARCHAR(10),@CalendareRececiedDatePeriodYear VARCHAR(100),@CalendareRececiedDatePeriodPeriod VARCHAR(100),@CalendareRececiedDatePeriodWeek VARCHAR(100)
	DECLARE @IsYpwCalendar AS INT
	SET @CalendarID = (
			SELECT TOP 1 CalendarID
			FROM PanelCalendarMapping
			WHERE OwnerCountryId = @pCountryID
				AND PanelID = @pPanelId
			ORDER BY CalendarID DESC
			)

	IF (@CalendarID IS NULL)
	BEGIN
		SET @CalendarID = (
				SELECT TOP 1 CalendarId
				FROM CountryCalendarMapping
				WHERE CountryId = @pCountryID
					AND CalendarId NOT IN (
						SELECT CalendarID
						FROM PanelCalendarMapping
						WHERE OwnerCountryId = @pCountryID
						)
				)
	END

	DECLARE @dummyTable TABLE (
			DiaryYear VARCHAR(20)
			,DiaryPeriod VARCHAR(20)
			,StartDate DATETIME
			,EndDate DATETIME
			,DiaryWeek VARCHAR(30)
			,RowNum INT
			)

SELECT @IsYpwCalendar = count(SequenceWithinHierarchy)
	FROM CalendarPeriodHierarchy
	WHERE CalendarId = @CalendarID


	IF (@IsYpwCalendar < 2)
	BEGIN
		SET @IsYpwCalendar=0 
	END
	ELSE
	BEGIN
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
				b.StartDate BETWEEN a.StartDate AND a.EndDate
				)
				AND (a.CalendarId = b.CalendarId)
		INNER JOIN CalendarPeriod c ON (
				c.StartDate BETWEEN b.StartDate
					AND b.EndDate
					)
			AND (c.CalendarId = b.CalendarId)
		WHERE a.CalendarId = @CalendarID
			AND a.PeriodTypeId = @YearPeriodId
			AND b.PeriodTypeId = @MonthPeriodId
			AND c.PeriodTypeId = @WeekPeriodId


			SELECT @ProcessingDatePeriod = Convert(VARCHAR, DiaryYear) + '.' + Convert(VARCHAR, DiaryPeriod) + '.' + Convert(VARCHAR, (
					CASE 
					WHEN DiaryWeek % 4 = 0 AND RowNum <> 5 THEN 4 
					WHEN DiaryWeek % 4 <> 0 AND RowNum = 5 THEN 5 
					ELSE DiaryWeek % 4 
					END
					))
		FROM @dummyTable t
		WHERE DATEADD(week, 0, CONVERT(DATE, @pProcessingDate)) BETWEEN CONVERT(DATE, t.StartDate)
				AND CONVERT(DATE, t.EndDate)

		SELECT @CalendareRececiedDatePeriod = 
		Convert(VARCHAR, DiaryYear) + '.' + Convert(VARCHAR, DiaryPeriod) + '.' + 
		Convert(VARCHAR, (CASE WHEN DiaryWeek % 4 = 0 AND RowNum <> 5 THEN 4 
								WHEN DiaryWeek % 4 <> 0 AND RowNum = 5 THEN 5
								ELSE DiaryWeek % 4
						END
					)),@CalendareRececiedDatePeriodYear=Convert(VARCHAR, DiaryYear) ,@CalendareRececiedDatePeriodPeriod=Convert(VARCHAR, DiaryPeriod),
					@CalendareRececiedDatePeriodWeek=	Convert(VARCHAR, (CASE WHEN DiaryWeek % 4 = 0 AND RowNum <> 5 THEN 4 
								WHEN DiaryWeek % 4 <> 0 AND RowNum = 5 THEN 5
								ELSE DiaryWeek % 4
						END
					))
		FROM @dummyTable t
		WHERE DATEADD(week, 0, CONVERT(DATE, @pCalendareRececiedDate)) BETWEEN CONVERT(DATE, t.StartDate)
				AND CONVERT(DATE, t.EndDate)
		IF ( @ProcessingDatePeriod is not null and LEN(LTRIM(RTRIM(@ProcessingDatePeriod)))>0)
		begin
		    set @ProcessingDatePeriodDiaryReport= @ProcessingDatePeriod
		end
		else
		begin
			set @ProcessingDatePeriodDiaryReport=(select top 1 Convert(VARCHAR, DiaryYear) + '.' + Convert(VARCHAR, DiaryPeriod) + '.' + Convert(VARCHAR, (
					CASE  WHEN DiaryWeek % 4 = 0 AND RowNum <> 5 THEN 4 
						  WHEN DiaryWeek % 4 <> 0 AND RowNum = 5 THEN 5 
						  ELSE DiaryWeek % 4 
						  END
					))

		FROM @dummyTable t order by StartDate)
		end

 END
 select @StartDate=Min(StartDate),@EndDate= max(EndDate) from CalendarPeriod where CalendarId=@CalendarID
 
 INSERT INTO @ActualCalendarYearPeriodWeek(PanelId,CalendarId,IsYpwCalendar,
   ProcessingDatePeriod,
   ProcessingDatePeriodDiaryReport,
   CalendareRececiedDatePeriod,StartDate,EndDate,CalendareRececiedDatePeriodYear,CalendareRececiedDatePeriodPeriod,CalendareRececiedDatePeriodWeek)
   VALUES(@pPanelId,@CalendarID,@IsYpwCalendar,@ProcessingDatePeriod,@ProcessingDatePeriodDiaryReport,@CalendareRececiedDatePeriod,@StartDate,@EndDate,@CalendareRececiedDatePeriodYear,@CalendareRececiedDatePeriodPeriod,@CalendareRececiedDatePeriodWeek)  
   RETURN;
END;
GO