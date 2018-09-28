CREATE procedure GetCurrentperiod_AdminScreen  @pPanelCode integer, @pCountryCode varchar(50)
As 
BEGIN
	DECLARE @pyearperiod INT
	DECLARE @pweekperiod INT
	DECLARE @pperiodperiod INT
	DECLARE @ppanelid UNIQUEIDENTIFIER
	DECLARE @pCountryid UNIQUEIDENTIFIER
	DECLARE @GetDate datetime
	DECLARE @tempId UNIQUEIDENTIFIER = NEWID()

	SET @pCountryid = (
			SELECT Countryid
			FROM Country
			WHERE CountryISO2A = @pCountryCode
			)
SET @ppanelid = (
			SELECT a.GUIDReference
			FROM Panel a
			JOIN PanelCalendarMapping b ON a.GUIDReference = b.PanelID
			JOIN Calendar c ON b.CalendarID = c.GUIDReference
			WHERE a.PanelCode = @pPanelCode
				AND a.Country_Id = @pCountryid
			)

			
  SET @GetDate = (SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(), @pCountryId))

	SELECT DISTINCT yearperiodvalue
	FROM CalendarDenorm
	WHERE @GetDate BETWEEN yearStartDate
			AND yearEndDate
		AND CountryISO2A = @pCountryCode
		AND ISNULL(Panelid, @tempId) = ISNULL(@ppanelid, @tempId)

	SELECT DISTINCT periodPeriodValue
	FROM CalendarDenorm
	WHERE @GetDate BETWEEN periodStartDate
			AND periodEndDate
		AND CountryISO2A = @pCountryCode
		AND ISNULL(Panelid, @tempId) = ISNULL(@ppanelid, @tempId)

	SELECT DISTINCT weekPeriodValue
	FROM CalendarDenorm
	WHERE @GetDate BETWEEN weekStartDate
			AND weekEndDate
		AND CountryISO2A = @pCountryCode
		AND ISNULL(Panelid, @tempId) = ISNULL(@ppanelid, @tempId)
END