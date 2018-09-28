
/*##########################################################################    
 Author:  	VENKATA RAMANA CHAMCHALA
 Create date: 12/16/2014
 Description: 
 PARAM Definitions:
 @pCountryID guid reference of Individual
 @pPanelId guid refernece of panellist
 ,@pYear INT
 ,@pMonth INT
 ,@pWeek INT
 Sample:
 SELECT dbo.[GetPeriodIdByYearPeriodWeek]('F7B748F5-8CD3-45E4-B45D-4681AB6A6B2F','5929775A-E319-C1C6-04CA-08D1162CBE15',2012,1,4)
 SELECT dbo.[GetPeriodIdByYearPeriodWeek]('F7B748F5-8CD3-45E4-B45D-4681AB6A6B2F','5929775A-E319-C1C6-04CA-08D1162CBE15',2012,1,NULL)
 SELECT dbo.[GetPeriodIdByYearPeriodWeek]('F7B748F5-8CD3-45E4-B45D-4681AB6A6B2F','5929775A-E319-C1C6-04CA-08D1162CBE15',2012,NULL,NULL)
##########################################################################    
-- ver  user			date        change     
-- 1.0  GopiChand     2014-12-23   initial    
##########################################################################*/
CREATE FUNCTION [dbo].[GetPeriodIdByYearPeriodWeek] (
	@pCountryID UNIQUEIDENTIFIER
	,@pPanelId UNIQUEIDENTIFIER
	,@pYear INT
	,@pMonth INT
	,@pWeek INT
	)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @PeriodIDOUTPUT UNIQUEIDENTIFIER
		,@DefaultPeriodID UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
	DECLARE @CalendarID AS UNIQUEIDENTIFIER
	DECLARE @YearPeriodTypeId AS UNIQUEIDENTIFIER
	DECLARE @MonthPeriodTypeId AS UNIQUEIDENTIFIER
	DECLARE @WeekPeriodTypeId AS UNIQUEIDENTIFIER

	SET @pMonth = ISNULL(@pMonth, 0)
	SET @pWeek = ISNULL(@pWeek, 0)
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

	SELECT @YearPeriodTypeId = CH.ParentPeriodTypeId
		,@MonthPeriodTypeId = CH.ChildPeriodTypeId
	FROM CalendarPeriod Cp
	INNER JOIN CalendarPeriodHierarchy CH ON Cp.CalendarId = CH.CalendarId
	WHERE Cp.CalendarId = @CalendarID
		AND CH.SequenceWithinHierarchy IN (1)
		AND Cp.PeriodValue = @pYear

	SELECT @WeekPeriodTypeId = CH.ChildPeriodTypeId
	FROM CalendarPeriod Cp
	INNER JOIN CalendarPeriodHierarchy CH ON Cp.CalendarId = CH.CalendarId
	WHERE Cp.CalendarId = @CalendarID
		AND CH.SequenceWithinHierarchy IN (2)
		AND Cp.PeriodValue = @pYear

	SET @PeriodIDOUTPUT = (
			SELECT TOP 1 CASE 
					WHEN @pWeek <> 0
						THEN C.PeriodId
					WHEN @pMonth <> 0
						THEN b.PeriodId
					WHEN @pYear <> 0
						THEN a.PeriodId
					END AS PeriodId
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
				AND a.OwnerCountryId = @pCountryID
				AND a.PeriodTypeId = @YearPeriodTypeId
				AND b.PeriodTypeId = @MonthPeriodTypeId
				AND c.PeriodTypeId = @WeekPeriodTypeId
				AND a.PeriodValue = @pYear
				AND b.PeriodValue = CASE 
					WHEN @pMonth = 0
						THEN b.PeriodValue
					ELSE @pMonth
					END
				AND C.PeriodValue = CASE 
					WHEN @pWeek = 0
						THEN c.PeriodValue
					ELSE @pWeek
					END
			)

	RETURN ISNULL(@PeriodIDOUTPUT, @DefaultPeriodID)
END