

CREATE FUNCTION [dbo].[fn_GetPeriodId_DiaryEntry] (
	@PanelId UNIQUEIDENTIFIER
	,@CreatedDateTime DATETIME
	,@year INT
	,@period INT
	,@week INT
	)
RETURNS UNIQUEIDENTIFIER
AS
BEGIN
	DECLARE @PeriodId UNIQUEIDENTIFIER
	DECLARE @calendarId UNIQUEIDENTIFIER

	SELECT @calendarId = [dbo].[fn_getCalendarId_DiaryEntry](@PanelId, @CreatedDateTime)
	if(@calendarId <> CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER))
	begin
	DECLARE @Periodtypeid UNIQUEIDENTIFIER

	SELECT @Periodtypeid = ParentPeriodTypeId
	FROM CalendarPeriodHierarchy
	WHERE CalendarId = @calendarid
		AND SequenceWithinHierarchy = 2

	DECLARE @weekTupeId UNIQUEIDENTIFIER

	SELECT @weekTupeId = ChildPeriodTypeId
	FROM CalendarPeriodHierarchy
	WHERE CalendarId = @calendarid
		AND SequenceWithinHierarchy = 2

	DECLARE @periodvalue INT

	SET @periodvalue = ((@period - 1) * 4) + @week
	SET @PeriodId = (
			SELECT TOP 1 PeriodId
			FROM CalendarPeriod
			WHERE PeriodValue = @period
				AND CalendarId = @calendarId
				AND PeriodTypeId = @Periodtypeid
				AND YEAR(StartDate) = @year
			)

	RETURN @PeriodId
	end
	Return CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
END