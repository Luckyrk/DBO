Create procedure GetPanelistSummaryRecords_AdminScreen @pPanelCode integer ,@pCountryCode  varchar(50) ,@pyearperiodvalue varchar(100),@pperiodperiodvalue varchar(100),@pweekperiodvalue varchar(100)
AS
BEGIN
BEGIN TRY 
DECLARE @pcount INT
DECLARE @pCountryId UNIQUEIDENTIFIER
DECLARE @ppanelid UNIQUEIDENTIFIER
DECLARE @pcount1 BIGINT
DECLARE @pcount2 BIGINT
DECLARE @ptotalcount BIGINT

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

IF (@pweekperiodvalue = '0')
BEGIN
	SET @pcount = (
			SELECT count(*)
			FROM PanelistSummaryCount ps
			INNER JOIN Panel pl ON pl.GUIDReference = ps.Panel_Id
			INNER JOIN (
				SELECT DISTINCT periodPeriodId
					,CalendarID
					,CountryISO2A
					,yearPeriodValue
					,periodPeriodValue
				FROM calendardenorm
				WHERE CountryISO2A = @pCountryCode
					AND yearPeriodValue = @pyearperiodvalue
					AND periodPeriodValue = @pperiodperiodvalue
					AND Panelid = @ppanelid
				) cd ON cd.CalendarID = ps.CalendarPeriod_CalendarId
			INNER JOIN summary_category sc ON sc.SummaryCategoryId = ps.SummaryCategoryId
				AND cd.periodPeriodID = ps.CalendarPeriod_PeriodId
				AND cd.CountryISO2A = @pCountryCode
				AND pl.PanelCode = @pPanelCode
				AND cd.yearPeriodValue = @pyearperiodvalue
				AND cd.periodPeriodValue = @pperiodperiodvalue
			) + (
			SELECT count(*)
			FROM PanelistSummaryCount ps
			INNER JOIN Panel pl ON pl.GUIDReference = ps.Panel_Id
			INNER JOIN (
				SELECT DISTINCT weekPeriodId
					,CalendarID
					,CountryISO2A
					,yearPeriodValue
					,periodPeriodValue
				FROM calendardenorm
				WHERE CountryISO2A = @pCountryCode
					AND yearPeriodValue = @pyearperiodvalue
					AND periodPeriodValue = @pperiodperiodvalue
					AND Panelid = @ppanelid
				) cd ON cd.CalendarID = ps.CalendarPeriod_CalendarId
			INNER JOIN summary_category sc ON sc.SummaryCategoryId = ps.SummaryCategoryId
				--AND cd.periodPeriodID = ps.CalendarPeriod_PeriodId
				AND cd.weekPeriodID = ps.CalendarPeriod_PeriodId
				--     WHERE ps.Country_Id = '3558A18E-CCEB-CADC-CB8C-08CF81794A86'
				AND cd.CountryISO2A = @pCountryCode
				AND pl.PanelCode = @pPanelCode
				AND cd.yearPeriodValue = @pyearperiodvalue
				AND cd.periodPeriodValue = @pperiodperiodvalue
			)

	--  set @ptotalcount = @pcount1 + @pcount2
	SELECT @pcount AS NoofRecords
END
ELSE
BEGIN

SELECT Count(*) AS NoofRecords
FROM PanelistSummaryCount ps
INNER JOIN Panel pl ON pl.GUIDReference = ps.Panel_Id
INNER JOIN CalendarDenorm cd ON cd.CalendarID = ps.CalendarPeriod_CalendarId
	AND cd.weekPeriodID = ps.CalendarPeriod_PeriodId
WHERE cd.CountryISO2A = @pCountryCode
	AND pl.PanelCode = @pPanelCode
	AND cd.yearPeriodValue = @pyearperiodvalue
	AND cd.periodPeriodValue = @pperiodperiodvalue
	AND cd.weekPeriodValue = @pweekperiodvalue

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