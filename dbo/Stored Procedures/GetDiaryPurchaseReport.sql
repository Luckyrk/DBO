/*##########################################################################    
-- Name                           : GetDiaryPurchaseReport.sql  
-- Date             : 2014-05-20    
-- Author           : Kattamuri Sunil Kumar    
-- Company          : Cognizant Technology Solution    
-- Purpose          : Gets the Diary history and purchase history results  
-- Usage   : From the UI once we click on the Diary history Button (the data is rendered from report)    
-- Impact   : Change on this procedure the report (DiaryPurchaseHistoryReport) gets impacted.    
-- Required grants  :     
-- Called by        : DiaryPurchaseHistoryReport      
-- Params Defintion :    
    @businessId VARCHAR(20)  -- Business Id will be passed from UI    
 @panelId UNIQUEIDENTIFIER        -- Panel Guid Will be passed from UI  
 @fromDate VARCHAR(20)      -- from date will be passed form UI   
 @toDatee VARCHAR(20)             -- to date will be passed form UI 
-- Sample Execution :    
 exec [GetDiaryPurchaseReport] 2002,1,1,2003,1,1,'51801201-01','5929775A-E319-C1C6-04CA-08D1162CBE15'         
##########################################################################    
-- ver  user               date        change   
-- 1.0  Kattamuri     2014-05-20   initial    
-- 1.1  Kattamrui      2014-11-03   Revised as per Bug 31809
-- 1.2	FarmerP			2015-05-21	Added join on Panel to 2 places to eliminate duplicate 
##########################################################################*/
GO
CREATE PROCEDURE [dbo].[GetDiaryPurchaseReport] 
	@fromYear INT
	,@fromperiod INT = NULL
	,@fromWeek INT = NULL
	,@toyear INT
	,@toperiod INT = NULL
	,@toweek INT = NULL
	,@businessId VARCHAR(30)
	,@panelId UNIQUEIDENTIFIER
AS
BEGIN
		Declare @IndividualId UniqueIdentifier ,@CountryId  UniqueIdentifier
	SELECT TOP 1 @CountryId = Country_Id FROM Panel WHERE GUIDReference = @panelId
	SELECT TOP 1 @IndividualId = GUIDReference FROM Individual WHERE IndividualId = @businessId and CountryId = @CountryId
	CREATE TABLE #DiaryEntryPurchaseTable (
		Diary_Date VARCHAR(18)
		,diaryDateYear INT
		,diarydateperiod INT
		,diarydateweek INT
		,DiaryState NVARCHAR(300)
		,ReceivedDate DATETIME
		,DiarySourceFull NVARCHAR(60)
		,ClaimFlag INT
		,NumberOfDaysEarly INT
		,NumberOfDaysLate INT
		,Together INT
		,individualid VARCHAR(20)
		,CountryCode VARCHAR(6)
		,SummaryCount INT
		,SummaryDescription VARCHAR(250)
		,panelistid UNIQUEIDENTIFIER
		,CountryId UNIQUEIDENTIFIER
		,panelid UNIQUEIDENTIFIER
		,weekmultiplier DECIMAL
		,periodmultiplier INT
		)
	CREATE NONCLUSTERED INDEX [IX_IndvId] ON #DiaryEntryPurchaseTable ([individualid])
	CREATE NONCLUSTERED INDEX [IX_PeriodMulti] ON #DiaryEntryPurchaseTable ([periodmultiplier])
	CREATE NONCLUSTERED INDEX [IX_WeekMulti] ON #DiaryEntryPurchaseTable ([weekmultiplier])

	INSERT INTO #DiaryEntryPurchaseTable
	SELECT CONVERT(VARCHAR(20), de.DiaryDateYear) + '.' + CONVERT(VARCHAR(10), de.DiaryDatePeriod) + '.' + CONVERT(VARCHAR(10), de.DiaryDateWeek) AS 'Diary_Date'
		,de.DiaryDateYear
		,de.DiaryDatePeriod
		,de.DiaryDateWeek
		,de.DiaryState
		,de.ReceivedDate
		,de.DiarySourceFull
		,ISNULL(md.ClaimFlag, 0) AS ClaimFlag
		,de.NumberOfDaysEarly
		,de.NumberOfDaysLate
		,Together
		,i.IndividualId
		,ct.CountryISO2A
		,NULL
		,NULL
		,pl.GUIDReference
		,ct.CountryId
		,p.GUIDReference
		,(de.DiaryDateYear * 1000) + (de.DiaryDatePeriod * 10) + de.DiaryDateWeek
		,(de.DiaryDateYear * 100) + de.DiaryDatePeriod
	FROM Individual i
	INNER JOIN Country ct ON ct.CountryId = i.CountryId
	INNER JOIN CollectiveMembership cm ON cm.Individual_Id = i.GUIDReference
	INNER JOIN DiaryEntry de ON i.IndividualId = de.BusinessId
	LEFT JOIN MissingDiaries md ON de.BusinessId = md.BusinessId AND de.PanelId = md.PanelId AND de.DiaryDateYear = md.DiaryDateYear 
		AND de.DiaryDatePeriod = md.DiaryDatePeriod AND de.DiaryDateWeek = md.DiaryDateWeek
	INNER JOIN Panel p ON p.GUIDReference = de.PanelId	
	INNER JOIN Panelist pl
		ON pl.PanelMember_Id = IIF(p.Type = 'HouseHold', cm.Group_Id, cm.Individual_Id)
		AND pl.Country_Id = ct.CountryId
		AND pl.Panel_ID = p.GUIDReference
	WHERE i.IndividualId = @businessId
		AND p.GUIDReference = @panelId
		AND de.DiaryDateYear >= @fromYear
		AND de.DiaryDateYear <= @toyear
		AND ((de.DiaryDateYear * 10000) + (de.DiaryDatePeriod * 100)  + de.DiaryDateWeek >= ((@fromYear * 10000) + @fromperiod *100 + @fromWeek ))

	INSERT INTO #DiaryEntryPurchaseTable
	SELECT CONVERT(VARCHAR(20), de.DiaryDateYear) + '.' + CONVERT(VARCHAR(10), de.DiaryDatePeriod) + '.' + CONVERT(VARCHAR(10), de.DiaryDateWeek) AS 'Diary_Date'
		,de.DiaryDateYear
		,de.DiaryDatePeriod
		,de.DiaryDateWeek
		,NULL
		,ReceivedDate
		,DiarySourceFull
		,ClaimFlag
		,NumberOfDaysEarly
		,NumberOfDaysLate
		,NULL
		,i.IndividualId
		,ct.CountryISO2A
		,NULL
		,NULL
		,pl.GUIDReference
		,ct.CountryId
		,p.GUIDReference
		,(de.DiaryDateYear * 1000) + (de.DiaryDatePeriod * 10) + de.DiaryDateWeek
		,(de.DiaryDateYear * 100) + de.DiaryDatePeriod
	FROM Individual i 
	INNER JOIN Country ct ON ct.CountryId = i.CountryId
	INNER JOIN CollectiveMembership cm ON cm.Individual_Id = i.GUIDReference
	INNER JOIN MissingDiaries de ON i.IndividualId = de.BusinessId
	INNER JOIN Panel p ON p.GUIDReference = de.PanelId		
	INNER JOIN Panelist pl 
		ON  pl.PanelMember_Id = IIF(p.Type = 'HouseHold', cm.Group_Id, cm.Individual_Id)
		AND pl.Country_Id = ct.CountryId
		AND pl.Panel_ID = p.GUIDReference
	WHERE i.IndividualId = @businessId
		AND p.GUIDReference = @panelId
		--AND de.ReceivedDate IS NULL
		AND de.DiaryDateYear >= @fromYear
		AND de.DiaryDateYear <= @toyear
		AND ((de.DiaryDateYear * 10000) + (de.DiaryDatePeriod * 100)  + de.DiaryDateWeek >= ((@fromYear * 10000) + @fromperiod *100 + @fromWeek ))
		AND NOT EXISTS (
			SELECT *
			FROM DiaryEntry B
			WHERE de.BusinessId = B.BusinessId
				AND de.PanelId = B.PanelId
				AND de.DiaryDatePeriod = B.DiaryDatePeriod
				AND de.DiaryDateWeek = B.DiaryDateWeek
				AND de.DiaryDateYear = B.DiaryDateYear
			)	 

	CREATE TABLE #WeekPurchaseTable (
		SummaryCount INT
		,WeekPeriod INT
		,MonthPeriod INT
		,YearPeriod INT
		,panelistid UNIQUEIDENTIFIER
		,panelid UNIQUEIDENTIFIER
		)

	INSERT INTO #WeekPurchaseTable
	SELECT sum(ps.SummaryCount)
		,cpWeek.PeriodValue
		,cpperiod.PeriodValue
		,cpyear.PeriodValue
		,ps.PanelistId
		,ps.Panel_Id
	FROM #DiaryEntryPurchaseTable dp
	INNER JOIN PanelistSummaryCount ps ON ps.Panel_Id = @panelId
		AND dp.panelistid = ps.PanelistId
		AND ps.Country_Id = dp.CountryId
	INNER JOIN CalendarPeriodHierarchy cph ON cph.CalendarId = ps.CalendarPeriod_CalendarId
		AND cph.SequenceWithinHierarchy = 2
	INNER JOIN CalendarPeriod cpWeek ON cpweek.CalendarId = ps.CalendarPeriod_CalendarId
		AND cpweek.PeriodId = ps.CalendarPeriod_PeriodId
		AND cpWeek.PeriodTypeId = cph.ChildPeriodTypeId
		AND cpWeek.PeriodValue = dp.diarydateweek
	INNER JOIN CalendarPeriod cpperiod ON cpperiod.CalendarId = ps.CalendarPeriod_CalendarId
		AND cpperiod.PeriodTypeId = cph.ParentPeriodTypeId
		AND cpperiod.PeriodValue = dp.diarydateperiod
		AND cpperiod.StartDate <= cpWeek.StartDate
		AND cpperiod.EndDate >= cpWeek.EndDate
	INNER JOIN CalendarPeriodHierarchy cphyear ON cphyear.CalendarId = ps.CalendarPeriod_CalendarId
		AND cphyear.SequenceWithinHierarchy = 1
	INNER JOIN CalendarPeriod cpyear ON cpyear.CalendarId = ps.CalendarPeriod_CalendarId
		AND cpyear.PeriodValue = dp.diaryDateYear
		AND cpyear.StartDate <= cpperiod.StartDate
		AND cpyear.EndDate >= cpperiod.EndDate
	INNER JOIN Summary_Category sc ON sc.SummaryCategoryId = ps.SummaryCategoryId
		AND sc.Country_Id = dp.CountryId
		WHERE sc.Code = 'S_COMALI'
	GROUP BY dp.diarydateweek
		,cpWeek.PeriodValue
		,cpperiod.PeriodValue
		,cpyear.PeriodValue
		,ps.CalendarPeriod_PeriodId
		,ps.PanelistId
		,ps.Panel_Id

		ALTER TABLE #DiaryEntryPurchaseTable ADD WEEKStartDate DATETIME 
		ALTER TABLE #DiaryEntryPurchaseTable ADD WEEKEndDate DATETIME 

	UPDATE #DiaryEntryPurchaseTable
	SET SummaryCount = wt.SummaryCount
	FROM #DiaryEntryPurchaseTable dt
	INNER JOIN #WeekPurchaseTable wt ON wt.panelid = dt.panelid
		AND wt.panelistid = dt.panelistid
		AND wt.WeekPeriod = dt.diarydateweek
		AND wt.MonthPeriod = dt.diarydateperiod
		AND wt.YearPeriod = dt.diaryDateYear



		UPDATE #DiaryEntryPurchaseTable
	SET WEEKStartDate=cd.weekStartDate,WEEKEndDate=cd.WeekEndDate
	FROM #DiaryEntryPurchaseTable dt
	INNER JOIN CalendarDenorm cd ON cd.PanelId = dt.panelid
		AND cd.weekPeriodValue = dt.diarydateweek
		AND cd.periodPeriodValue = dt.diarydateperiod
		AND cd.yearPeriodValue = dt.diaryDateYear
	WHERE cd.PanelId=@panelId

	--	UPDATE #DiaryEntryPurchaseTable
	--SET WEEKStartDate=cd.weekStartDate,WEEKEndDate=cd.WeekEndDate
	--FROM #DiaryEntryPurchaseTable dt
	--INNER JOIN CalendarDenorm cd ON cd.PanelId = dt.panelid
	--	AND cd.weekPeriodValue = dt.diarydateweek
	--	AND cd.periodPeriodValue = dt.diarydateperiod
	--	AND cd.yearPeriodValue = dt.diaryDateYear
	--WHERE cd.PanelId=@panelId

	DECLARE @weekMultiFrom 	INT = IIF(@fromWeek IS NOT NULL AND 	@fromperiod IS NOT NULL, 	(@fromYear * 1000) + (@fromperiod * 10) + @fromWeek, -1);
	DECLARE @weekMultiTo 	INT = IIF(@toweek IS NOT NULL AND 	@toperiod IS NOT NULL, 		(@toyear * 1000) + (@toperiod * 10) + @toWeek, -1);
	DECLARE @periodMulti 	INT = IIF(@toperiod IS NOT NULL, (@toyear * 100) + @toperiod, -1);

	SELECT DISTINCT Diary_Date
		,diaryDateYear
		,diarydateperiod
		,diarydateweek
		,CONVERT(VARCHAR(10), ReceivedDate, 103) AS ReceivedDate
		,DiarySourceFull
		,ClaimFlag
		,NumberOfDaysEarly
		,NumberOfDaysLate
		,Together
		,SummaryCount AS 'Summary Count'
		,individualid
		,weekmultiplier
		,periodmultiplier
		,Ex.Exclusions
	FROM #DiaryEntryPurchaseTable
	OUTER APPLY dbo.ExclusionListInDateRange(WeekStartDate,WeekEndDate,@IndividualId,@CountryId) Ex    
	WHERE 	(@weekMultiFrom = -1 OR weekmultiplier >= @weekMultiFrom )
		AND (@weekMultiTo = -1 OR weekmultiplier <= @weekMultiTo )
		AND (@periodMulti = -1 OR periodmultiplier <= @periodMulti )
	ORDER BY diaryDateYear DESC
		,diarydateperiod DESC
		,diarydateweek DESC

	DROP TABLE #DiaryEntryPurchaseTable
	DROP TABLE #WeekPurchaseTable
END


