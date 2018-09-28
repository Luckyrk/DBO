Create procedure DeletePanelistSummaryDetails_AdminScreen @pPanelCode integer ,@pCountryCode  varchar(50) ,@pyearperiodvalue varchar(100),@pperiodperiodvalue varchar(100),@pweekperiodvalue varchar(100)
AS
BEGIN
BEGIN TRY
       DECLARE @pCountryId UNIQUEIDENTIFIER
       DECLARE @ppanelid UNIQUEIDENTIFIER
       DECLARE @Records INT
       DECLARE @ConfirmMessage VARCHAR(max)
       DECLARE @pcount1 BigInt
       DECLARE @pcount2 BigInt
       DECLARE @ptotalcount BigInt

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

       IF (@pweekperiodvalue='0')
       
              BEGIN
                           set @Records =(select count(*) FROM PanelistSummaryCount ps

                           INNER JOIN Panel pl ON pl.GUIDReference = ps.Panel_Id

                           INNER JOIN (
                           select Distinct periodPeriodId, CalendarID,
                           CountryISO2A,  yearPeriodValue, periodPeriodValue
                           from calendardenorm where  CountryISO2A = @pCountryCode and 
                           yearPeriodValue =  @pyearperiodvalue and  periodPeriodValue = @pperiodperiodvalue
                                  and Panelid = @ppanelid )cd
                     ON cd.CalendarID = ps.CalendarPeriod_CalendarId
                     INNER JOIN summary_category sc ON sc.SummaryCategoryId = ps.SummaryCategoryId
                     AND cd.periodPeriodID = ps.CalendarPeriod_PeriodId
                           and cd.CountryISO2A = @pCountryCode

                                  AND pl.PanelCode = @pPanelCode

                                  AND cd.yearPeriodValue = @pyearperiodvalue

                                  AND cd.periodPeriodValue = @pperiodperiodvalue)
                                                         +

                                 (
       
                           select count(*) FROM PanelistSummaryCount ps

                           INNER JOIN Panel pl ON pl.GUIDReference = ps.Panel_Id

                           INNER JOIN (
                           select Distinct weekPeriodId, CalendarID,
                           CountryISO2A,  yearPeriodValue, periodPeriodValue
                           from calendardenorm where  CountryISO2A = @pCountryCode and 
                           yearPeriodValue =  @pyearperiodvalue and  periodPeriodValue = @pperiodperiodvalue
                                  and Panelid = @ppanelid )cd
                     ON cd.CalendarID = ps.CalendarPeriod_CalendarId
                     INNER JOIN summary_category sc ON sc.SummaryCategoryId = ps.SummaryCategoryId
              AND cd.weekPeriodID = ps.CalendarPeriod_PeriodId
                           and cd.CountryISO2A = @pCountryCode
                                  AND pl.PanelCode = @pPanelCode
                                  AND cd.yearPeriodValue = @pyearperiodvalue
                                  AND cd.periodPeriodValue = @pperiodperiodvalue)
                                --  set @Records = @pcount1 + @pcount2
                                  
              IF (@Records > 0)
              BEGIN
                    Delete PS FROM PanelistSummaryCount ps

                           INNER JOIN Panel pl ON pl.GUIDReference = ps.Panel_Id

                           INNER JOIN (
                           select Distinct periodPeriodId, CalendarID,
                           CountryISO2A,  yearPeriodValue, periodPeriodValue
                           from calendardenorm where  CountryISO2A = @pCountryCode and 
                           yearPeriodValue =  @pyearperiodvalue and  periodPeriodValue = @pperiodperiodvalue
                                  and Panelid = @ppanelid )cd
                     ON cd.CalendarID = ps.CalendarPeriod_CalendarId

                     INNER JOIN summary_category sc ON sc.SummaryCategoryId = ps.SummaryCategoryId
                     AND cd.periodPeriodID = ps.CalendarPeriod_PeriodId
                           and cd.CountryISO2A = @pCountryCode

                                  AND pl.PanelCode = @pPanelCode

                                  AND cd.yearPeriodValue = @pyearperiodvalue

                                  AND cd.periodPeriodValue = @pperiodperiodvalue

                  DELETE ps FROM PanelistSummaryCount ps

                           INNER JOIN Panel pl ON pl.GUIDReference = ps.Panel_Id

                           INNER JOIN (
                           select Distinct weekPeriodId, CalendarID,
                           CountryISO2A,  yearPeriodValue, periodPeriodValue
                           from calendardenorm where  CountryISO2A = @pCountryCode and 
                           yearPeriodValue =  @pyearperiodvalue and  periodPeriodValue = @pperiodperiodvalue
                                  and Panelid = @ppanelid )cd
                     ON cd.CalendarID = ps.CalendarPeriod_CalendarId
                     INNER JOIN summary_category sc ON sc.SummaryCategoryId = ps.SummaryCategoryId
              AND cd.weekPeriodID = ps.CalendarPeriod_PeriodId
                           and cd.CountryISO2A = @pCountryCode
                                  AND pl.PanelCode = @pPanelCode
                                  AND cd.yearPeriodValue = @pyearperiodvalue
                                  AND cd.periodPeriodValue = @pperiodperiodvalue 
                     SET @ConfirmMessage = 'The ' + CAST(@Records AS VARCHAR(100)) + 'panelist summary records are deleted successfully'
                     --SELECT @ConfirmMessage
              END
              ELSE
              BEGIN
                     SET @ConfirmMessage = 'No records are there to delete'
              END
       END
       
       ELSE
       BEGIN
              SET @Records = (
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
                           )

              IF (@Records > 0)
              BEGIN
                     DELETE PS
                     FROM PanelistSummaryCount ps
                     INNER JOIN Panel pl ON pl.GUIDReference = ps.Panel_Id
                     INNER JOIN CalendarDenorm cd ON cd.CalendarID = ps.CalendarPeriod_CalendarId
                           AND cd.weekPeriodID = ps.CalendarPeriod_PeriodId
                     WHERE cd.CountryISO2A = @pCountryCode
                           AND pl.PanelCode = @pPanelCode
                           AND cd.yearPeriodValue = @pyearperiodvalue
                           AND cd.periodPeriodValue = @pperiodperiodvalue
                           AND cd.weekPeriodValue = @pweekperiodvalue

                     SET @ConfirmMessage = 'The ' + CAST(@Records AS VARCHAR(100)) + 'panelist summary records are deleted successfully'
              END
              ELSE
              BEGIN
                     SET @ConfirmMessage = 'No records are there to delete'
              END
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

