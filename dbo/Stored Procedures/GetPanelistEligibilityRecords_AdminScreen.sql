create PROCEDURE [dbo].[GetPanelistEligibilityRecords_Adminscreen] @pPanelCode INT
       ,@pCountryCode VARCHAR(50)
       ,@pyearperiodvalue VARCHAR(100)
       ,@pperiodperiodvalue VARCHAR(100)
       ,@pweekperiodvalue VARCHAR(100)
AS
BEGIN
BEGIN TRY 
       DECLARE @pcount INT
       DECLARE @pCountryId UNIQUEIDENTIFIER
       DECLARE @ppanelid UNIQUEIDENTIFIER

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

       --set @pweekperiodid = (select weekPeriodID from CalendarDenorm where YearPeriodWeek = @pweekperiod and PanelId = @ppanelid and CountryISO2A = @pCountryCode)

      set @pcount =    ( SELECT count(*) AS NoofRecords
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
									   AND Panelid = @ppanelid
								 ) cd ON cd.CalendarID = ps.CalendarPeriod_CalendarId
								 AND cd.periodPeriodID = ps.CalendarPeriod_PeriodId
								 AND cd.CountryISO2A =@pCountryCode
								 AND pl.PanelCode =@pPanelCode
								 AND cd.yearPeriodValue = @pyearperiodvalue
								 AND cd.periodPeriodValue = @pperiodperiodvalue)
   
 

       SELECT @pcount AS NoofRecords
END TRY 
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH      
END
