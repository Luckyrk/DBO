USE [GPS_PM]
GO

/****** Object:  StoredProcedure [dbo].[InsertCalendarDenormAEOnly]    Script Date: 29/07/2016 14:28:05 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[InsertCalendarDenormAEOnly] 
AS
BEGIN
       -- SET NOCOUNT ON added to prevent extra result sets from
       -- interfering with SELECT statements.
	   --Pete Farmer: Added AE Country Filter to get the AE monthly calendars
       SET NOCOUNT ON;
	   DECLARE @CountryID UNIQUEIDENTIFIER = (SELECT CountryID FROM Country WHERE CountryISO2A = 'AE')
	   PRINT @COUntryID
       DELETE FROM [dbo].[CalendarDenorm] WHERE OwnerCountryID = @CountryID

       INSERT INTO [dbo].[CalendarDenorm] (YearPeriodWeek, OwnerCountryID, CountryISO2A, CalendarID, CalendarDescription, PanelID, 
	   yearPeriodID, QuarterPeriodID, MonthPeriodID, periodPeriodID, weekPeriodID, 
	   yearSequenceWithinPeriodType, PeriodSequenceWithinPeriodType, weekSequenceWithinPeriodType, 
	   yearPeriodValue, QuarterPeriodValue, MonthPeriodValue, periodPeriodValue, weekPeriodValue, 
	   yearStartDate, yearEndDate, QuarterStartDate, QuarterEndDate, MonthStartDate, MonthEndDate, 
	   periodStartDate, periodEndDate, weekStartDate, weekEndDate,
	   yearPeriodTypeCode, periodPeriodTypeCode, weekPeriodTypeCode, 
	   yearPeriodTypeDescription, periodPeriodTypeDescription, weekPeriodTypeDescription, 
	   yearQuantityOfUnits, periodQuantityOfUnits, weekQuantityOfUnits, 
	   yearParentTypeID, yearChildPeriodTypeID, periodParentTypeID, periodChildPeriodTypeID, weekParentTypeID, weekChildPeriodTypeID, 
	   yearPeriodGroup, periodPeriodGroup, weekPeriodGroup, yearSequenceWithinHierarchy, periodSequenceWithinHierarchy, weekSequenceWithinHierarchy)

       SELECT  			  
							CASE 
								WHEN monthPeriodValue IS NOT NULL THEN CONVERT(NVARCHAR(5), yearPeriodValue) + '.' + CONVERT(NVARCHAR(5), MonthPeriodValue)
                                  WHEN weekPeriodValue IS NULL THEN CONVERT(NVARCHAR(5), yearPeriodValue) + '.' + CONVERT(NVARCHAR(5), PeriodPeriodValue)
                                  ELSE CONVERT(NVARCHAR(5), yearPeriodValue) + '.' + CONVERT(NVARCHAR(5), periodPeriodValue) + '.' + CONVERT(NVARCHAR(8), weekPeriodValue)
                           END AS YearPeriodWeek, 
                           yp.OwnerCountryID, yp.CountryISO2A, YearCalendarID AS CalendarID,  CalendarDescription, PanelID, 
						   yearPeriodID, 
						   quarterPeriodID,
						   monthPeriodID,
						   periodPeriodID, 
						   weekPeriodID,
						   yearSequenceWithinPeriodType,
						   --QuarterSequenceWithinPeriodType,
						   PeriodSequenceWithinPeriodType, weekSequenceWithinPeriodType,
						   yearPeriodValue,
						   quarterPeriodValue,
						   monthPeriodValue,
						   periodPeriodValue, weekPeriodValue,
						   yearStartDate, yearEndDate,
						   QuarterStartDate, QuarterEndDate,
						   MonthStartDate, MonthEndDate,
						   periodStartDate, periodEndDate, weekStartDate, weekEndDate, 
						   yearPeriodTypeCode,
						   --QuarterPeriodTypeCode,
						   periodPeriodTypeCode, weekPeriodTypeCode, 
						   yearPeriodTypeDescription,
						   --QuarterPeriodTypeDescription,
						   periodPeriodTypeDescription, weekPeriodTypeDescription,  
						   yearQuantityOfUnits,
						   --QuarterQuantityOfUnits,
						   periodQuantityOfUnits, weekQuantityOfUnits, 
						   yearParentTypeID, yearChildPeriodTypeID,
						   --QuarterParentTypeID, QuarterChildPeriodTypeID,
						   periodParentTypeID, periodChildPeriodTypeID, weekParentTypeID, weekChildPeriodTypeID,
						   yearPeriodGroup,
						   --QuarterPeriodGroup,
						   periodPeriodGroup, weekPeriodGroup,
						   yearSequenceWithinHierarchy,
						   --QuarterSequenceWithinHierarchy,
						   periodSequenceWithinHierarchy, weekSequenceWithinHierarchy
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
                     PeriodTypeCode IN (1,5)
					 AND c.Country_Id = @CountryID
                     --ORDER BY cpYear.CalendarID, cpYear.PeriodValue
              ) yp
			  /*************************************
              Getting the Quarters
              *************************************/
              LEFT JOIN
              (
                     SELECT 
                           cpPeriod.CalendarID AS QuarterCalendarID
                           , cpPeriod.PeriodID AS QuarterPeriodID
                           , cpPeriod.SequenceWithinPeriodType AS QuarterSequenceWithinPeriodType
                           , cpPeriod.PeriodValue AS QuarterPeriodValue
                           , cpPeriod.StartDate AS QuarterStartDate
                           , cpPeriod.EndDate AS QuarterEndDate
                           , cpPeriod.PeriodTypeID As QuarterPeriodTypeID
                           , cpPeriod.OwnerCountryId
                           --, c.CalendarDescription
                           , pt3.PeriodTypeCode AS QuarterPeriodTypeCode
                           , pt3.PeriodTypeDescription AS QuarterPeriodTypeDescription
                           , pt3.DefaultQuantityOfUnits AS QuarterQuantityOfUnits
                           , pt3.PeriodGroup AS QuarterPeriodGroup
                           , pt3.PeriodGroupSequence AS QuarterPeriodGroupSequence
                           , ParentPeriodTypeId AS QuarterParentTypeID
                           , ChildPeriodTypeID AS QuarterChildPeriodTypeID
                           , SequenceWithinHierarchy AS QuarterSequenceWithinHierarchy
                     FROM CalendarPeriod cpPeriod
                           INNER JOIN Calendar c ON cpPeriod.CalendarID = c.GUIDReference
                           INNER JOIN PeriodType pt3 ON cpPeriod.PeriodTypeId = pt3.PeriodTypeId
                           INNER JOIN CalendarPeriodHierarchy cph ON pt3.PeriodTypeID = cph.ChildPeriodTypeID AND cpPeriod.CalendarID = cph.CalendarId
                     WHERE PeriodTypeCode IN (4)
					 AND c.Country_Id = @CountryID
                     --ORDER BY periodCalendarID, periodStartDate
              ) qp ON yp.yearCalendarID = qp.QuarterCalendarID 
                                                       AND qp.QuarterPeriodTypeId = yp.YearChildPeriodTypeId
                                                       AND qp.QuarterStartDate >= yp.yearStartDate
                                                       AND qp.QuarterEndDate <= yp.yearEndDate

              --ORDER BY periodCalendarID, yearPeriodValue, periodStartDate

			  /*************************************
              Getting the Months
              *************************************/
              LEFT JOIN
              (
                     SELECT 
                           cpPeriod.CalendarID AS MonthCalendarID
                           , cpPeriod.PeriodID AS MonthPeriodID
                           , cpPeriod.SequenceWithinPeriodType AS MonthSequenceWithinPeriodType
                           , cpPeriod.PeriodValue AS MonthPeriodValue
                           , cpPeriod.StartDate AS MonthStartDate
                           , cpPeriod.EndDate AS MonthEndDate
                           , cpPeriod.PeriodTypeID As MonthPeriodTypeID
                           , cpPeriod.OwnerCountryId
                           --, c.CalendarDescription
                           , pt3.PeriodTypeCode AS MonthPeriodTypeCode
                           , pt3.PeriodTypeDescription AS MonthPeriodTypeDescription
                           , pt3.DefaultQuantityOfUnits AS MonthQuantityOfUnits
                           , pt3.PeriodGroup AS MonthPeriodGroup
                           , pt3.PeriodGroupSequence AS MonthPeriodGroupSequence
                           , ParentPeriodTypeId AS MonthParentTypeID
                           , ChildPeriodTypeID AS MonthChildPeriodTypeID
                           , SequenceWithinHierarchy AS MOnthSequenceWithinHierarchy
                     FROM CalendarPeriod cpPeriod
                           INNER JOIN Calendar c ON cpPeriod.CalendarID = c.GUIDReference
                           INNER JOIN PeriodType pt3 ON cpPeriod.PeriodTypeId = pt3.PeriodTypeId
                           INNER JOIN CalendarPeriodHierarchy cph ON pt3.PeriodTypeID = cph.ChildPeriodTypeID AND cpPeriod.CalendarID = cph.CalendarId
                     WHERE PeriodTypeCode IN (6)
					 AND c.Country_Id = @CountryID
                     --ORDER BY periodCalendarID, periodStartDate
              ) mp ON yp.yearCalendarID = mp.MonthCalendarID 
                                                       AND mp.MonthPeriodTypeId = yp.YearChildPeriodTypeId
                                                       AND mp.MonthStartDate >= yp.yearStartDate
                                                       AND mp.MonthEndDate <= yp.yearEndDate
              --ORDER BY periodCalendarID, yearPeriodValue, periodStartDate
              /*************************************
              Getting the Periods
              *************************************/

              LEFT JOIN
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
					 AND c.Country_Id = @CountryID
                     --ORDER BY periodCalendarID, periodStartDate
              ) pp ON qp.QuarterCalendarID = pp.periodCalendarID 
                                                       AND pp.PeriodParentTypeId = qp.QuarterChildPeriodTypeId
                                                       AND pp.periodStartDate >= qp.QuarterStartDate
                                                       AND pp.periodEndDate <= qp.QuarterEndDate

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
					 AND c.Country_Id = @CountryID
              ) wp ON pp.periodCalendarID = wp.weekCalendarID 
                                                       AND wp.weekParentTypeId = pp.periodChildPeriodTypeId
                                                       AND wp.weekStartDate >= pp.periodStartDate
                                                       AND wp.weekEndDate <= pp.periodEndDate
			 WHERE YearPeriodValue IS NOT NULL
			 --Week, Quarter, Month and Period Values could be NULL and should be allowed
              ORDER BY CalendarID, YearPeriodWeek, periodCalendarID, yearPeriodValue, periodStartDate, weekStartDate

END

--2001.9.1, a63069c3-0101-4ede-a45e-76cf22754297, de733db6-e3ba-4a80-ba9e-6bb92fa7d157

--SELECT * FROM COuntry WHERE CountryID = 'a63069c3-0101-4ede-a45e-76cf22754297'


--DELETE FROM CalendarPeriod WHERE PeriodId = '6B76E5D9-D34D-47B9-A31B-F35055E65A2C'




--GO

