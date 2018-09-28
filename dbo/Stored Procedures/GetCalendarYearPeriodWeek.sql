CREATE PROCEDURE [dbo].[GetCalendarYearPeriodWeek] (

	 @pCountryID UNIQUEIDENTIFIER

	,@pPanelId UNIQUEIDENTIFIER

	,@pProcessingDate DATETIME

	,@pCalendareRececiedDate DATETIME

	)

AS

BEGIN
BEGIN TRY
	DECLARE @CalendarID AS UNIQUEIDENTIFIER

	DECLARE @YearPeriodId AS UNIQUEIDENTIFIER

	DECLARE @MonthPeriodId AS UNIQUEIDENTIFIER

	DECLARE @WeekPeriodId AS UNIQUEIDENTIFIER

	DECLARE @ProcessingDatePeriod AS VARCHAR(10)
	DECLARE @ProcessingDatePeriodDiaryReport as VARCHAR(10)

	DECLARE @CalendareRececiedDatePeriod AS VARCHAR(10)

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



	SELECT @IsYpwCalendar = count(SequenceWithinHierarchy)

	FROM CalendarPeriodHierarchy

	WHERE CalendarId = @CalendarID



	IF (@IsYpwCalendar < 2)

	BEGIN

		SELECT 0 AS IsYpwCalendar



		RETURN

	END

	ELSE

	BEGIN

		SELECT 1 AS IsYpwCalendar



		SELECT @YearPeriodId = PeriodTypeId

		FROM PeriodType

		WHERE OwnerCountry_Id = @pCountryID

			AND PeriodGroup = 1

			AND PeriodGroupSequence = 1 -- year



		SELECT @MonthPeriodId = PeriodTypeId

		FROM PeriodType

		WHERE OwnerCountry_Id = @pCountryID

			AND PeriodGroup = 1

			AND PeriodGroupSequence = 2 -- period



		SELECT @WeekPeriodId = PeriodTypeId

		FROM PeriodType

		WHERE OwnerCountry_Id = @pCountryID

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

		WHERE a.CalendarId = @CalendarID

			AND a.PeriodTypeId = @YearPeriodId

			AND b.PeriodTypeId = @MonthPeriodId

			AND c.PeriodTypeId = @WeekPeriodId



		SELECT DiaryYear

			,DiaryPeriod

			,(

				CASE 

					WHEN DiaryWeek % 4 = 0

						AND RowNum <> 5

						THEN 4

					WHEN DiaryWeek % 4 <> 0

						AND RowNum = 5

						THEN 5

					ELSE DiaryWeek % 4

					END

				) AS DiaryWeek

		FROM @dummyTable



		SELECT @ProcessingDatePeriod = Convert(VARCHAR, DiaryYear) + '.' + Convert(VARCHAR, DiaryPeriod) + '.' + Convert(VARCHAR, (

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

		WHERE DATEADD(week, 0, CONVERT(DATE, @pProcessingDate)) BETWEEN CONVERT(DATE, t.StartDate)

				AND CONVERT(DATE, t.EndDate)



		SELECT @CalendareRececiedDatePeriod = Convert(VARCHAR, DiaryYear) + '.' + Convert(VARCHAR, DiaryPeriod) + '.' + Convert(VARCHAR, (

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

		WHERE DATEADD(week, 0, CONVERT(DATE, @pCalendareRececiedDate)) BETWEEN CONVERT(DATE, t.StartDate)

				AND CONVERT(DATE, t.EndDate)

		IF ( @ProcessingDatePeriod is not null and LEN(LTRIM(RTRIM(@ProcessingDatePeriod)))>0)
		begin
		    set @ProcessingDatePeriodDiaryReport= @ProcessingDatePeriod
		end
		else
		begin
			set @ProcessingDatePeriodDiaryReport=(select top 1 Convert(VARCHAR, DiaryYear) + '.' + Convert(VARCHAR, DiaryPeriod) + '.' + Convert(VARCHAR, (

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

		FROM @dummyTable t order by StartDate)
		
		end

		SELECT @ProcessingDatePeriod AS ProcessingDatePeriod
		select @ProcessingDatePeriodDiaryReport as  ProcessingDatePeriodDiaryReport


		SELECT @CalendareRececiedDatePeriod AS CalenadarDatePeriod



		SELECT @CalendarID AS CalenadarId



		select Min(StartDate) as StartDate from CalendarPeriod where CalendarId=@CalendarID

        select max(EndDate) as EndDate from CalendarPeriod where CalendarId=@CalendarID



	END
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH
END