/*##########################################################################

-- Name             : GetPanelCalendarPeriod
-- Date             : 2014-12-02
-- Author           : Ramana
-- Company          : Cognizant Technology Solution
-- Purpose          : 
-- Usage            :
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
				@pPaneId UNIQUEIDENTIFIER  --  GUID of Panel
				,@pCountryId UNIQUEIDENTIFIER  --Guid of Country
				,@pProcessingDate DATETIME
			
      
-- Sample Execution :

##########################################################################
Change History:
-- ver  user               date        change 
-- 1.0  Ramana		    2014-12-02		initial
-- 2.0	Pete Farmer		2015-04-13		Changed the function to use the CalendarDenorm rahter than having to build the whole calendar yy pp ww on the fly
										Changed the function to return yyyy.pp when the calendar uses only yyyy and month information eg: SSW calendar
										Removed the ISNULL check at the end of the function, but set the default value at the start to 'Calendar not found'
			

##########################################################################*/
CREATE FUNCTION [dbo].[GetPanelCalendarPeriod] (
       @pCountryId UNIQUEIDENTIFIER
       ,@pPanelId UNIQUEIDENTIFIER
       ,@pProcessingDate DATETIME
       )
RETURNS NVARCHAR(500)
AS
BEGIN
        DECLARE @CalendarID AS UNIQUEIDENTIFIER
       DECLARE @YearPeriodId AS UNIQUEIDENTIFIER
       DECLARE @MonthPeriodId AS UNIQUEIDENTIFIER
       DECLARE @WeekPeriodId AS UNIQUEIDENTIFIER
       DECLARE @ProcessingDatePeriod AS VARCHAR(100)
       DECLARE @CalendareRececiedDatePeriod AS VARCHAR(10)
       DECLARE @IsYpwCalendar AS INT

	   SET @ProcessingDatePeriod = 'Calendar not found'

       SET @CalendarID = (
                     SELECT TOP 1 CalendarID
                     FROM PanelCalendarMapping
                     WHERE OwnerCountryId = @pCountryId
                           AND PanelID = @pPanelId
                     ORDER BY CalendarID DESC
                     )

       IF (@CalendarID IS NULL)
       BEGIN
              SET @CalendarID = (
                           SELECT TOP 1 CalendarID
                           FROM CountryCalendarMapping
                           WHERE CountryId = @pCountryId
                                  AND CalendarId NOT IN (
                                         SELECT CalendarID
                                         FROM PanelCalendarMapping
                                         WHERE OwnerCountryId = @pCountryId
                                         )
                           )
       END

       SELECT @IsYpwCalendar = count(SequenceWithinHierarchy)
		FROM CalendarPeriodHierarchy
       WHERE CalendarId = @CalendarID


	   IF (@IsYpwCalendar = 1) --yyyy.pp monthly calendar
		   BEGIN
				SELECT @ProcessingDatePeriod = YearPeriodWeek FROM CalendarDenorm 
					WHERE @pProcessingDate BETWEEN periodStartDate AND periodEndDate
					AND CalendarID = @CalendarID
		   END
	   ELSE IF (@IsYpwCalendar = 2) --yyyy.pp.ww weekly calendar
		   BEGIN
				SELECT @ProcessingDatePeriod = YearPeriodWeek FROM CalendarDenorm 
					WHERE @pProcessingDate BETWEEN weekStartDate AND weekEndDate
					AND CalendarID = @CalendarID
		   END

	   RETURN @ProcessingDatePeriod
END
