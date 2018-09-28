Create procedure GetcalendarperiodsbyPanelid_AdminScreen
@pPanelCode int,@pCountryCode varchar(50)
AS
BEGIN
	DECLARE @pCountryId UNIQUEIDENTIFIER
	DECLARE @ppanelid UNIQUEIDENTIFIER
	DECLARE @pYearperiod INT
	DECLARE @pperiodperiod INT
	DECLARE @pweekperiod INT

	SET @pCountryId = (
			SELECT CountryId
			FROM Country
			WHERE CountryISO2A = @pCountryCode
			)
	SET @ppanelid = (
			SELECT GUIDReference
			FROM panel
			WHERE PanelCode = @pPanelCode
				AND Country_Id = @pCountryId
			)

	SELECT DISTINCT (yearPeriodValue) AS YearPeriodValue
	FROM CalendarDenorm
	WHERE PanelID = @ppanelid
		AND CountryISO2A = @pCountryCode
	ORDER BY yearPeriodValue DESC

	SELECT DISTINCT (periodPeriodValue) AS PeriodPeriodValue
	FROM CalendarDenorm
	WHERE PanelID = @ppanelid
		AND CountryISO2A = @pCountryCode
	ORDER BY periodPeriodValue DESC

	SELECT DISTINCT (weekPeriodValue) AS WeekPeriodValue
	FROM CalendarDenorm
	WHERE PanelID = @ppanelid
		AND CountryISO2A = @pCountryCode
	ORDER BY weekPeriodValue DESC
END