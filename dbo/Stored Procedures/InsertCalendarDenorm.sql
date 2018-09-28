/****** Object:  StoredProcedure [dbo].[InsertCalendarDenorm]    Script Date: 29/02/2016 08:08:59 ******/

CREATE PROCEDURE [dbo].[InsertCalendarDenorm] 
AS
BEGIN
BEGIN TRY
        --SET NOCOUNT ON added to prevent extra result sets from
        --interfering with SELECT statements.
       SET NOCOUNT ON;

       TRUNCATE TABLE [dbo].[CalendarDenorm]

       INSERT INTO [dbo].[CalendarDenorm](YearPeriodWeek, OwnerCountryID, CountryISO2A, CalendarID, CalendarDescription,
					 PanelID, yearPeriodID, periodPeriodID, weekPeriodID, yearSequenceWithinPeriodType,
					 PeriodSequenceWithinPeriodType, weekSequenceWithinPeriodType, yearPeriodValue, periodPeriodValue,
					 weekPeriodValue, yearStartDate, yearEndDate, periodStartDate, periodEndDate, weekStartDate, weekEndDate, 
					 yearPeriodTypeCode, periodPeriodTypeCode, weekPeriodTypeCode, yearPeriodTypeDescription, periodPeriodTypeDescription, 
					 weekPeriodTypeDescription, yearQuantityOfUnits, periodQuantityOfUnits, weekQuantityOfUnits, yearParentTypeID, yearChildPeriodTypeID, 
					 periodParentTypeID, periodChildPeriodTypeID, weekParentTypeID, weekChildPeriodTypeID, yearPeriodGroup, 
					 periodPeriodGroup, weekPeriodGroup, yearSequenceWithinHierarchy, periodSequenceWithinHierarchy, 
					 weekSequenceWithinHierarchy)
              SELECT        CASE 
                                  WHEN weekPeriodValue IS NULL THEN CONVERT(NVARCHAR(5), yearPeriodValue) + '.' + CONVERT(NVARCHAR(5), periodPeriodValue)
                                  ELSE CONVERT(NVARCHAR(5), yearPeriodValue) + '.' + CONVERT(NVARCHAR(5), periodPeriodValue) + '.' + CONVERT(NVARCHAR(5), weekPeriodValue)
                           END AS YearPeriodWeek
						   , yp.OwnerCountryID
						   , yp.CountryISO2A
						   , YearCalendarID AS CalendarID
						   , CalendarDescription
						   , PanelID
						   , yearPeriodID
						   , periodPeriodID
						   , weekPeriodID
						   , yearSequenceWithinPeriodType 
                           , PeriodSequenceWithinPeriodType
						   , weekSequenceWithinPeriodType
						   , yearPeriodValue
						   , periodPeriodValue
						   , weekPeriodValue
						   , yearStartDate
						   , yearEndDate
						   , periodStartDate
						   , periodEndDate
						   , weekStartDate
						   , weekEndDate
						   , yearPeriodTypeCode
						   , periodPeriodTypeCode
						   , weekPeriodTypeCode
						   , yearPeriodTypeDescription
						   , periodPeriodTypeDescription
						   , weekPeriodTypeDescription
						   , yearQuantityOfUnits
						   , periodQuantityOfUnits
						   , weekQuantityOfUnits
						   , yearParentTypeID
						   , yearChildPeriodTypeID
						   , periodParentTypeID
						   , periodChildPeriodTypeID
						   , weekParentTypeID
						   , weekChildPeriodTypeID
						   , yearPeriodGroup
						   , periodPeriodGroup
						   , weekPeriodGroup
						   , yearSequenceWithinHierarchy
						   , periodSequenceWithinHierarchy
						   , weekSequenceWithinHierarchy
              FROM
              (
              /*************************************
              Getting the Years
              *************************************/
                     SELECT 
                           cpYear.CalendarID AS YearCalendarID
                           , cpYear.PeriodID AS yearPeriodID
                           , cpYear.SequenceWithinPeriodType AS yearSequenceWithinPeriodType
                           , cpYear.PeriodValue AS yearPeriodValue
                           , cpYear.StartDate AS yearStartDate
                           , cpYear.EndDate AS yearEndDate
                           , cpYear.PeriodTypeID As yearPeriodTypeID
                           , cpYear.OwnerCountryId
                           , ct.CountryISO2A
                           , pcm.PanelID
                           , c.CalendarDescription
                           , pt3.PeriodTypeCode AS yearPeriodTypeCode
                           , pt3.PeriodTypeDescription AS yearPeriodTypeDescription
                           , pt3.DefaultQuantityOfUnits AS yearQuantityOfUnits
                           , pt3.PeriodGroup AS yearPeriodGroup
                           , pt3.PeriodGroupSequence AS yearPeriodGroupSequence
                           , ParentPeriodTypeId AS yearParentTypeID
                           , ChildPeriodTypeID AS yearChildPeriodTypeID
                           , SequenceWithinHierarchy AS yearSequenceWithinHierarchy
                     FROM CalendarPeriod cpYear
                           INNER JOIN Calendar c ON cpYear.CalendarID = c.GUIDReference
                           LEFT JOIN PanelCalendarMapping pcm ON pcm.CalendarID = c.GUIDReference
                           INNER JOIN PeriodType pt3 ON cpYear.PeriodTypeId = pt3.PeriodTypeId
                           INNER JOIN CalendarPeriodHierarchy cph ON pt3.PeriodTypeID = cph.ParentPeriodTypeID     AND cpYear.CalendarID = cph.CalendarId
                           INNER JOIN Country ct ON cpYear.OwnerCountryID = ct.CountryID
                     WHERE
                     PeriodTypeCode IN (1, 7)
                     --ORDER BY cpYear.CalendarID, cpYear.PeriodValue
              ) yp
              /*************************************
              Getting the Periods
              *************************************/
              INNER JOIN
              (
                     SELECT 
                           cpPeriod.CalendarID AS periodCalendarID
                           , cpPeriod.PeriodID AS periodPeriodID
                           , cpPeriod.SequenceWithinPeriodType AS PeriodSequenceWithinPeriodType
                           , cpPeriod.PeriodValue AS periodPeriodValue
                           , cpPeriod.StartDate AS periodStartDate
                           , cpPeriod.EndDate AS periodEndDate
                           , cpPeriod.PeriodTypeID As periodPeriodTypeID
                           , cpPeriod.OwnerCountryId
                           --, c.CalendarDescription
                           , pt3.PeriodTypeCode AS periodPeriodTypeCode
                           , pt3.PeriodTypeDescription AS periodPeriodTypeDescription
                           , pt3.DefaultQuantityOfUnits AS periodQuantityOfUnits
                           , pt3.PeriodGroup AS periodPeriodGroup
                           , pt3.PeriodGroupSequence AS periodPeriodGroupSequence
                           , ParentPeriodTypeId AS periodParentTypeID
                           , ChildPeriodTypeID AS periodChildPeriodTypeID
                           , SequenceWithinHierarchy AS periodSequenceWithinHierarchy
                     FROM CalendarPeriod cpPeriod
                           INNER JOIN Calendar c ON cpPeriod.CalendarID = c.GUIDReference
                           INNER JOIN PeriodType pt3 ON cpPeriod.PeriodTypeId = pt3.PeriodTypeId
                           INNER JOIN CalendarPeriodHierarchy cph ON pt3.PeriodTypeID = cph.ChildPeriodTypeID AND cpPeriod.CalendarID = cph.CalendarId
                     WHERE PeriodTypeCode IN (2, 6)
                     --ORDER BY periodCalendarID, periodStartDate
              ) pp ON yp.yearCalendarID = pp.periodCalendarID 
                                                       AND pp.periodPeriodTypeId = yp.YearChildPeriodTypeId
                                                       AND pp.periodStartDate >= yp.yearStartDate
                                                       AND pp.periodEndDate <= yp.yearEndDate

              --ORDER BY periodCalendarID, yearPeriodValue, periodStartDate
              LEFT JOIN
              (
              /*************************************
              Getting the weeks
              *************************************/
                     SELECT 
                           cpWeek.CalendarID AS weekCalendarID
                           , cpWeek.PeriodID AS weekPeriodID
                           , cpWeek.SequenceWithinPeriodType AS weekSequenceWithinPeriodType
                           , cpWeek.PeriodValue AS weekPeriodValue
                           , cpWeek.StartDate AS WeekStartDate
                           , cpWeek.EndDate AS WeekEndDate
                           , cpWeek.PeriodTypeID As WeekPeriodTypeID
                           , cpWeek.OwnerCountryId
                           --, c.CalendarDescription AS weekCalendarDescription
                           , pt3.PeriodTypeCode AS weekPeriodTypeCode
                           , pt3.PeriodTypeDescription AS weekPeriodTypeDescription
                           , pt3.DefaultQuantityOfUnits AS weekQuantityOfUnits
                           , pt3.PeriodGroup AS weekPeriodGroup
                           , pt3.PeriodGroupSequence AS weekPeriodGroupSequence
                           , ParentPeriodTypeId AS weekParentTypeID
                           , ChildPeriodTypeID AS weekChildPeriodTypeID
                           , SequenceWithinHierarchy AS weekSequenceWithinHierarchy
                     FROM CalendarPeriod cpWeek
                           INNER JOIN Calendar c ON cpWeek.CalendarID = c.GUIDReference
                           INNER JOIN PeriodType pt3 ON cpWeek.PeriodTypeId = pt3.PeriodTypeId
                           INNER JOIN CalendarPeriodHierarchy cph ON pt3.PeriodTypeID = cph.ChildPeriodTypeID AND cpWeek.CalendarID = cph.CalendarId
                     WHERE PeriodTypeCode = 3 
              ) wp ON pp.periodCalendarID = wp.weekCalendarID 
                                                       AND wp.weekParentTypeId = pp.periodChildPeriodTypeId
                                                       AND wp.weekStartDate >= pp.periodStartDate
                                                       AND wp.weekEndDate <= pp.periodEndDate
              ORDER BY periodCalendarID, yearPeriodValue, periodStartDate, weekStartDate
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

GO

