CREATE FUNCTION [dbo].[fn_getCalendarId_DiaryEntry] (
	@panelId UNIQUEIDENTIFIER
	,@createdDatetime DATETIME
	)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @CalendarId UNIQUEIDENTIFIER
	DECLARE @Year INT
	DECLARE @Period INT
	DECLARE @Week INT
	DECLARE @CountryId UNIQUEIDENTIFIER

	IF EXISTS (
			SELECT 1
			FROM Panel
			WHERE GUIDReference = @panelId
			)
	BEGIN
		SELECT @CountryId = Country_Id
		FROM Panel
		WHERE GUIDReference = @PanelId

		IF EXISTS (
				SELECT 1
				FROM PanelCalendarMapping
				WHERE PanelID = @PanelId
				)
		BEGIN
			DECLARE @calendar UNIQUEIDENTIFIER

			SELECT @calendar = CalendarID
			FROM PanelCalendarMapping
			WHERE PanelID = @PanelId

			IF EXISTS (
					SELECT 1
					FROM CalendarPeriodHierarchy cph
					INNER JOIN CalendarPeriod cp ON cp.PeriodTypeId = cph.ParentPeriodTypeId
						AND cp.CalendarId = @calendar
					WHERE cph.SequenceWithinHierarchy = 1
						AND cph.CalendarId = @calendar
						AND @createdDatetime BETWEEN cp.StartDate
							AND cp.EndDate
					)
			BEGIN
				SET @CalendarId = @calendar
			END
			ELSE
				SET @CalendarId = (
						SELECT GUIDReference
						FROM Calendar
						WHERE GUIDReference NOT IN (
								SELECT CalendarID
								FROM PanelCalendarMapping
								)
							AND Country_Id = @CountryId
						)
		END
		ELSE
		BEGIN
			SET @CalendarId = (
					SELECT GUIDReference
					FROM Calendar
					WHERE GUIDReference NOT IN (
							SELECT CalendarID
							FROM PanelCalendarMapping
							)
						AND Country_Id = @CountryId
					)
		END
	END
	ELSE
	BEGIN
		SET @CalendarId = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
	END

	RETURN @CalendarId
END