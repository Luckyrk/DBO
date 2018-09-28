CREATE procedure DeletePanelistEligibilityDetails_AdminScreen @pPanelCode integer ,@pCountryCode  varchar(50) ,@pyearperiodvalue varchar(100),@pperiodperiodvalue varchar(100),@pweekperiodvalue varchar(100)
AS
BEGIN
BEGIN TRY
DECLARE @pCountryId UNIQUEIDENTIFIER
DECLARE @ppanelid UNIQUEIDENTIFIER
DECLARE @Records INT
DECLARE @ConfirmMessage VARCHAR(250)
DECLARE @tempId UNIQUEIDENTIFIER = NEWID()

SET @pCountryId = (
              SELECT CountryId
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


       SET @Records = (
                           SELECT count(*) AS NoofRecords
              FROM PanelistEligibility ps
              INNER JOIN Panel pl ON pl.GUIDReference = ps.Panel_Id
              INNER JOIN (
                     SELECT DISTINCT periodPeriodID
                           ,CalendarID
                           ,CountryISO2A
                           ,yearPeriodValue
                           ,periodPeriodValue
                     FROM calendardenorm
                     WHERE CountryISO2A = @pCountryCode
                           AND yearPeriodValue = @pyearperiodvalue
                           AND periodPeriodValue = @pperiodperiodvalue
                           AND ISNULL(Panelid,@tempId) = ISNULL(@ppanelid,@tempId)
                     ) cd ON cd.CalendarID = ps.CalendarPeriod_CalendarId
                     AND cd.periodPeriodID = ps.CalendarPeriod_PeriodId
                     AND cd.CountryISO2A =@pCountryCode
                     AND pl.PanelCode =@pPanelCode
                     AND cd.yearPeriodValue = @pyearperiodvalue
                     AND cd.periodPeriodValue = @pperiodperiodvalue

                     )

       IF (@Records > 0)
       BEGIN
                     DELETE PS
              FROM PanelistEligibility ps
              INNER JOIN Panel pl ON pl.GUIDReference = ps.Panel_Id
              INNER JOIN (
                     SELECT DISTINCT periodPeriodID
                           ,CalendarID
                           ,CountryISO2A
                           ,yearPeriodValue
                           ,periodPeriodValue
                     FROM calendardenorm
                     WHERE CountryISO2A = @pCountryCode
                           AND yearPeriodValue = @pyearperiodvalue
                           AND periodPeriodValue = @pperiodperiodvalue
                           AND ISNULL(Panelid,@tempId) = ISNULL(@ppanelid,@tempId)
                     ) cd ON cd.CalendarID = ps.CalendarPeriod_CalendarId
                     AND cd.periodPeriodID = ps.CalendarPeriod_PeriodId
                     AND cd.CountryISO2A =@pCountryCode
                     AND pl.PanelCode =@pPanelCode
                     AND cd.yearPeriodValue = @pyearperiodvalue
                     AND cd.periodPeriodValue = @pperiodperiodvalue


              SET @ConfirmMessage = 'The ' + CAST(@Records AS VARCHAR(100)) + 'panelist eligibilty records are deleted successfully'
       END
       ELSE
       BEGIN
              SET @ConfirmMessage = 'No records are there to delete'
       END



SELECT @ConfirmMessage
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


