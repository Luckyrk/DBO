CREATE FUNCTION [dbo].GetConsecutiveEntriesReceivedMultiplePeriods (
	-- Add the parameters for the function here
	 @IndividualId VARCHAR(50)
	,@TargetPeriod INT
	,@DiaryDateYear INT
	,@PanelCode INT
	,@CountryCode NVARCHAR(4)
	,@PeriodComparisonCount INT
	)
RETURNS INT
AS
BEGIN
	DECLARE @output INT = 0
	DECLARE @PrevDiaryDateYear INT
		,@PrePeriod INT
		,@TotalPeriods INT

	SET @PeriodComparisonCount = @PeriodComparisonCount-1;
	SET @TotalPeriods = 13

	SET @PrePeriod = @TargetPeriod + IIF(@TargetPeriod - @PeriodComparisonCount <= 0, @TotalPeriods - @PeriodComparisonCount%@TotalPeriods, -1 * @PeriodComparisonCount);
	SET @PrevDiaryDateYear = @DiaryDateYear - (@PeriodComparisonCount/@TotalPeriods)
	
	DECLARE @diarytable TABLE (
		rownumber INT
		,Id UNIQUEIDENTIFIER
		,CountryISO2A VARCHAR(10)
		,PanelCode INT
		,PanelId UNIQUEIDENTIFIER
		,IndividualID VARCHAR(30)
		,ClaimFlag INT
		,DiaryDateYear INT
		,DiaryDatePeriod INT
		,DiaryDateWeek INT
		,c1 INT
		,ConsecutiveDiary INT)

	INSERT INTO @diarytable
	SELECT Row_number() OVER(ORDER BY diarydateyear
				,diarydateperiod
				,diarydateweek)
		,Id
		,CountryISO2A
		,PanelCode
		,PanelId
		,IndividualID
		,ClaimFlag
		,DiaryDateYear
		,DiaryDatePeriod
		,DiaryDateWeek
		,(
			CASE 
				WHEN DiaryDatePeriod = @PrePeriod
					AND TT.DiaryDateWeek = 1
					THEN 0
				WHEN DiaryDatePeriod = 1
					AND TT.DiaryDateWeek = 1
					THEN (
							SELECT count(*)
							FROM DiaryEntry d
							CROSS APPLY [dbo].[fn_GetNumberofWeeksInPeriod_TBL](d.PanelId) AS T7
							WHERE d.DiaryDateYear = TT.DiaryDateYear - 1
								AND d.DiaryDatePeriod = 13
								AND (d.DiaryDateWeek = (T7.WeekCount))
								AND d.BusinessId = TT.IndividualID
								AND d.PanelId = TT.PanelId
								AND d.ClaimFlag = 0
							)
				WHEN TT.DiaryDateWeek <> 1
					THEN (
							SELECT count(*)
							FROM DiaryEntry d
							WHERE d.DiaryDateYear = TT.DiaryDateYear
								AND d.DiaryDatePeriod = TT.DiaryDatePeriod
								AND (d.DiaryDateWeek = (TT.DiaryDateWeek - 1))
								AND d.BusinessId = TT.IndividualID
								AND d.PanelId = TT.PanelId
								AND d.ClaimFlag = 0
							)
				ELSE (
						SELECT count(*)
						FROM DiaryEntry d
						CROSS APPLY [dbo].[fn_GetNumberofWeeksInPeriod_TBL](d.PanelId) AS T4
						WHERE d.DiaryDateYear = TT.DiaryDateYear
							AND d.DiaryDatePeriod = (TT.DiaryDatePeriod - 1)
							AND (d.DiaryDateWeek = T4.WeekCount)
							AND d.BusinessId = TT.IndividualID
							AND d.PanelId = TT.PanelId
							AND d.ClaimFlag = 0
						)
				END
			) AS C1
		,NULL
	FROM (
		SELECT dbo.Country.CountryISO2A
			,dbo.Panel.PanelCode AS PanelCode
			,dbo.Panel.Name AS PanelName
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
			,dbo.DiaryEntry.Together
			,dbo.DiaryEntry.IncentiveCode
			,dbo.DiaryEntry.ClaimFlag
			,dbo.DiaryEntry.PanelId
			,dbo.DiaryEntry.Id
		FROM dbo.DiaryEntry
		INNER JOIN dbo.Panel ON dbo.Panel.GUIDReference = dbo.DiaryEntry.PanelId
		INNER JOIN dbo.Country ON dbo.Country.CountryId = dbo.Panel.Country_Id
		WHERE Country.CountryISO2A = @CountryCode
		AND Panel.PanelCode = @PanelCode
		) AS TT
	WHERE tt.IndividualID = @IndividualId
		AND (tt.DiaryDateYear + tt.DiaryDatePeriod*0.01) BETWEEN (@PrevDiaryDateYear+@PrePeriod*0.01) AND (@DiaryDateYear+@TargetPeriod*0.01)
	ORDER BY diarydateyear
		,diarydateperiod
		,diarydateweek

	DECLARE @countmax INT = (
			SELECT count(*)
			FROM @diarytable
			) + 1
	DECLARE @rowcount INT = 1
	DECLARE @consecutive INT = 0

	WHILE (@rowcount != @countmax)
	BEGIN
		IF (
				(
					SELECT c1
					FROM @diarytable
					WHERE rownumber = @rowcount
					) > 0
				AND (
					SELECT ClaimFlag
					FROM @diarytable
					WHERE rownumber = @rowcount
					) = 0
				)
		BEGIN
			SET @consecutive = @consecutive + 1

			UPDATE @diarytable
			SET ConsecutiveDiary = @consecutive
			WHERE rownumber = @rowcount
		END
		ELSE
			SET @consecutive = 0

		UPDATE @diarytable
		SET ConsecutiveDiary = @consecutive
		WHERE rownumber = @rowcount

		SET @rowcount = @rowcount + 1
	END

	SELECT @output = max(ConsecutiveDiary)
	FROM @diarytable

	RETURN @output
END
