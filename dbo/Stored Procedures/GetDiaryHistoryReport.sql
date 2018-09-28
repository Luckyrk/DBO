CREATE PROCEDURE [dbo].[GetDiaryHistoryReport]  
 -- SAMPLE Call  exec GetDiaryHistoryReport '05-16-2009','08-21-2014','00000007-00',2
/*
       PF 7 Apr 2015 
              - Update to use CalendarDenorm table to improve performance   
              - Changed sp to remove dynamic SQL process to improve performance
              - Changed the if statements at the end of the Query to explicitely used the parameters passed in
              

*/  
@fromDate VARCHAR(100)  

,@toDate VARCHAR(100)  

,@IndividualId VARCHAR(30)  
,@PanelCode int
,@CountryCode varchar(5)
AS  

BEGIN  
BEGIN TRY 
Select CONVERT(VARCHAR(20), DiaryDateYear) + '.' + CONVERT(VARCHAR(10), DiaryDatePeriod) AS 'Diary_Date'
       ,de.DiaryState
       ,ReceivedDate
       ,DiarySourceFull
       ,ClaimFlag
       ,NumberOfDaysEarly
       ,NumberOfDaysLate
       ,Together
       ,sc.Description
       ,SUM(ps.SummaryCount) AS 'Summary Count'
       ,i.IndividualId
       ,ct.CountryISO2A from DiaryEntry de 
INNER JOIN Individual i ON i.IndividualId = de.BusinessId
INNER JOIN Panel p ON p.GUIDReference = de.PanelId
INNER JOIN Country ct ON ct.CountryId = p.Country_Id
INNER JOIN CollectiveMembership cm ON cm.Individual_id = i.guidreference
INNER JOIN Panelist pl ON pl.PanelMember_Id IN (
              CASE 
                     WHEN p.Type = ' HouseHold '
                           THEN (
                                         SELECT cm.Group_id
                                         )
                     ELSE (
                                  SELECT i.guidreference
                                  )
                     END
              )
LEFT JOIN PanelistSummaryCount ps ON de.PanelId = ps.Panel_Id
       AND ps.Panelistid = pl.GuidReference
INNER JOIN CalendarDenorm cd ON ps.CalendarPeriod_CalendarID = cd.CalendarID 
       AND ps.CalendarPeriod_PeriodId = cd.periodPeriodID
       AND ps.Country_Id = cd.OwnerCountryID
       AND ps.Panel_Id = cd.PanelID
       AND de.DiaryDatePeriod = cd.periodPeriodValue
       AND de.DiaryDateYear = cd.yearPeriodValue
       AND de.DiaryDateWeek = cd.weekPeriodValue

LEFT JOIN Summary_Category sc ON sc.SummaryCategoryId = ps.SummaryCategoryId

GROUP BY DiaryDatePeriod
       ,de.DiaryState
       ,de.DiaryDateWeek
       ,DiaryDateYear
       ,ReceivedDate
       ,ClaimFlag
       ,NumberOfDaysEarly
       ,NumberOfDaysLate
       ,Together
       ,sc.Description
       ,ps.SummaryCount
       ,i.IndividualId
       ,DiarySourceFull
       ,p.NAME
       ,de.PanelId
       ,ct.CountryISO2A
       ,de.BusinessId
       ,p.PanelCode
       having (  de.ReceivedDate BETWEEN @fromDate AND  @toDate )
       and i.IndividualId= @IndividualId
       and  p.PanelCode= CONVERT(varchar(10), @PanelCode)
       and ct.CountryISO2A= @CountryCode
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