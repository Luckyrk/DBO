CREATE FUNCTION [dbo].[fn_GetNumberofWeeksInPeriod_TBL] (@PanelId UNIQUEIDENTIFIER)
RETURNS @Result TABLE (
	PanelId UNIQUEIDENTIFIER NOT NULL
	,WeekCount INT
	)
AS
BEGIN
	DECLARE @WeekCount INT = 0

	IF EXISTS (
			SELECT 1
			FROM PanelCalendarMapping
			WHERE PanelID = @PanelId
			)
	BEGIN
		SET @WeekCount = (
				SELECT TOP 1 Round((ptperiod.DefaultQuantityOfUnits / ptWeek.DefaultQuantityOfUnits), 0)
				FROM DiaryEntry d
				INNER JOIN PanelCalendarMapping pc ON pc.PanelID = d.PanelId
				INNER JOIN CalendarPeriodHierarchy cph ON cph.CalendarId = pc.CalendarID
					AND cph.SequenceWithinHierarchy = 2
				INNER JOIN PeriodType ptperiod ON ptperiod.PeriodTypeId = cph.ParentPeriodTypeId
					AND ptperiod.OwnerCountry_Id = cph.OwnerCountry_Id
				INNER JOIN PeriodType ptWeek ON ptWeek.PeriodTypeId = cph.ChildPeriodTypeId
					AND ptWeek.OwnerCountry_Id = cph.OwnerCountry_Id
				WHERE d.PanelId = @PanelId
				)
	END
	ELSE
		SET @WeekCount = (
				SELECT TOP 1 Round((ptperiod.DefaultQuantityOfUnits / ptWeek.DefaultQuantityOfUnits), 0)
				FROM DiaryEntry d
				INNER JOIN Panel p ON p.GUIDReference = d.PanelId
				INNER JOIN CountryCalendarMapping pc ON pc.CountryId = p.Country_Id
				INNER JOIN CalendarPeriodHierarchy cph ON cph.CalendarId = pc.CalendarId
					AND cph.SequenceWithinHierarchy = 2
				INNER JOIN PeriodType ptperiod ON ptperiod.PeriodTypeId = cph.ParentPeriodTypeId
					AND ptperiod.OwnerCountry_Id = cph.OwnerCountry_Id
				INNER JOIN PeriodType ptWeek ON ptWeek.PeriodTypeId = cph.ChildPeriodTypeId
					AND ptWeek.OwnerCountry_Id = cph.OwnerCountry_Id
				WHERE d.PanelId = @PanelId
				)

	INSERT INTO @Result
	VALUES (
		@PanelId
		,@WeekCount
		)

	RETURN;
END