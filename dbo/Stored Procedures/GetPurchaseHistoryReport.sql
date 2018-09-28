/*##########################################################################  

-- Name    : GetPurchaseHistoryReport.sql  

-- Date             : 2014-10-21  

-- Author           : Kattamuri Sunil Kumar  

-- Company          : Cognizant Technology Solution  

-- Purpose          : Gets the purchase history result  

-- Usage   : From the UI once we click on the Purchase history Button (the data is rendered from report)  

-- Impact   : Change on this procedure the report (PurchaseHistoryReport) gets impacted.  

-- Required grants  :   

-- Called by        : Purchase History Report    

-- Params Defintion :  

    @mainshopperId VARCHAR(20)  -- Business Id will be passed from UI  

 @CollaborationMethodology VARCHAR(100) = NULL  -- Collobartion Methodology Code will be passed  

 @Period VARCHAR(10) = NULL   -- period (2014.1.1) will be passed  

 @CountryCode VARCHAR(5)  -- Country (TW,ES..)  

 @Panelcode VARCHAR(100) = NULL   -- Panelcode has to enter (3,4,5)  

-- Sample Execution :  

 exec [GetPurchaseHistoryReport] '0000009-01',null,null,'TW',null    

##########################################################################  

-- ver  user    date        change   

-- 1.0  Kattamuri     2014-10-21  initial  

##########################################################################*/



CREATE PROCEDURE [dbo].[GetPurchaseHistoryReport] @mainshopperId VARCHAR(20)
	,@CollaborationMethodology VARCHAR(100) = NULL
	,@Period VARCHAR(10) = NULL
	,@CountryCode VARCHAR(5)
	,@Panelcode VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;
BEGIN TRY
	DECLARE @CalendarID AS UNIQUEIDENTIFIER
	DECLARE @CountryId UNIQUEIDENTIFIER
	DECLARE @PanelGUID UNIQUEIDENTIFIER
	DECLARE @YearPeriodTypeId AS UNIQUEIDENTIFIER
	DECLARE @MonthPeriodTypeId AS UNIQUEIDENTIFIER
	DECLARE @WeekPeriodTypeId AS UNIQUEIDENTIFIER

	SELECT @CountryId = CountryId
	FROM COuntry
	WHERE CountryISO2A = @CountryCode

	SELECT @PanelGUID = GUIDReference
	FROM Panel
	WHERE PanelCode = @PanelCode
		AND Country_Id = @CountryId

	SET @CalendarID = (
			SELECT TOP 1 CalendarID
			FROM PanelCalendarMapping
			WHERE OwnerCountryId = @CountryId
				AND PanelID = @PanelGUID
			ORDER BY CalendarID DESC
			)

	IF (@CalendarID IS NULL)
	BEGIN
		SET @CalendarID = (
				SELECT TOP 1 CalendarID
				FROM CountryCalendarMapping
				WHERE CountryId = @CountryId
					AND CalendarId NOT IN (
						SELECT CalendarID
						FROM PanelCalendarMapping
						WHERE OwnerCountryId = @CountryId
						)
				)
	END

	IF (@CalendarID IS NULL)
	BEGIN
		SET @CalendarID = (
				SELECT TOP 1 CalendarID
				FROM CountryCalendarMapping
				WHERE CountryId = @CountryId
				)
	END

	SELECT @YearPeriodTypeId = CH.ParentPeriodTypeId
		,@MonthPeriodTypeId = CH.ChildPeriodTypeId
	FROM CalendarPeriod Cp
	INNER JOIN CalendarPeriodHierarchy CH ON Cp.CalendarId = CH.CalendarId
	WHERE Cp.CalendarId = @CalendarID
		AND CH.SequenceWithinHierarchy IN (1)

	SELECT @WeekPeriodTypeId = CH.ChildPeriodTypeId
	FROM CalendarPeriod Cp
	INNER JOIN CalendarPeriodHierarchy CH ON Cp.CalendarId = CH.CalendarId
	WHERE Cp.CalendarId = @CalendarID
		AND CH.SequenceWithinHierarchy IN (2)

	DECLARE @StartDate DATETIME
		,@EndDate DATETIME

	SELECT @StartDate = MIN(cp.StartDate)
		,@EndDate = MAX(cp.EndDate)
	FROM PanelistSummaryCount psc
	INNER JOIN Panelist pl ON pl.GUIDReference = psc.PanelistId
	INNER JOIN CalendarPeriod cp ON psc.CalendarPeriod_CalendarId = cp.CalendarId
		AND psc.CalendarPeriod_PeriodId = cp.PeriodId
	INNER JOIN CollectiveMembership CM ON CM.Group_Id = pl.PanelMember_Id
	INNER JOIN Collective C ON C.GUIDReference = CM.Group_Id
	INNER JOIN Individual I ON I.GUIDReference = CM.Individual_Id
	WHERE I.IndividualId = @mainshopperId

	IF @StartDate IS NULL
	BEGIN
		SELECT @StartDate = MIN(cp.StartDate)
			,@EndDate = MAX(cp.EndDate)
		FROM PanelistSummaryCount psc
		INNER JOIN Panelist pl ON pl.GUIDReference = psc.PanelistId
		INNER JOIN Individual I ON I.GUIDReference = pl.PanelMember_Id
		INNER JOIN CalendarPeriod cp ON psc.CalendarPeriod_CalendarId = cp.CalendarId
			AND psc.CalendarPeriod_PeriodId = cp.PeriodId
		WHERE I.IndividualId = @mainshopperId
	END

	DECLARE @CAL AS TABLE (
		[Year] INT
		,[Period] INT
		,[Week] INT
		,CalPeriod VARCHAR(100)
		)

	INSERT INTO @CAL
	SELECT YYYY
		,PP
		,WK
		,ISNULL(YYYY, '') + ISNULL('.' + PP, '') + ISNULL('.' + WK, '')
	FROM (
		SELECT CAST(y.PeriodValue AS VARCHAR) YYYY
			,CAST(p.PeriodValue AS VARCHAR) PP
			,CAST(w.PeriodValue AS VARCHAR) WK
		FROM CalendarPeriod y
		INNER JOIN CalendarPeriod p ON p.StartDate BETWEEN y.StartDate
				AND y.EndDate
		INNER JOIN CalendarPeriod w ON w.StartDate BETWEEN p.StartDate
				AND p.EndDate
		WHERE y.CalendarId = @CalendarID
			AND y.OwnerCountryId = @CountryId
			AND y.PeriodTypeId = @YearPeriodTypeId
			AND p.PeriodTypeId = @MonthPeriodTypeId
			AND w.PeriodTypeId = @WeekPeriodTypeId
			AND p.StartDate >= @StartDate
			AND p.StartDate < @EndDate
		
		UNION
		
		SELECT CAST(y.PeriodValue AS VARCHAR) YYYY
			,CAST(p.PeriodValue AS VARCHAR) PP
			,NULL AS WK
		FROM CalendarPeriod y
		INNER JOIN CalendarPeriod p ON p.StartDate BETWEEN y.StartDate
				AND y.EndDate
		WHERE y.CalendarId = @CalendarID
			AND y.OwnerCountryId = @CountryId
			AND y.PeriodTypeId = @YearPeriodTypeId
			AND p.PeriodTypeId = @MonthPeriodTypeId
			AND p.StartDate >= @StartDate
			AND p.StartDate < @EndDate
		) Tmp
	ORDER BY YYYY
		,PP
		,WK

	DECLARE @tmpTable TABLE (
		testDescription VARCHAR(128)
		,SummaryCount INT
		,CalendarPeriod_PeriodId UNIQUEIDENTIFIER
		,CalendarPeriod_CalendarId UNIQUEIDENTIFIER
		,PanelCode INT
		,NAME NVARCHAR(100)
		,Code NVARCHAR(20)
		,Country_Id UNIQUEIDENTIFIER
		)

	INSERT INTO @tmpTable
	SELECT (
			CASE 
				WHEN sc.Description LIKE 'Selected category purchase count by week%'
					THEN 1
				WHEN sc.Description LIKE 'Total Purchase Count%'
					THEN 2
				WHEN sc.Description LIKE 'DPE count'
					THEN 3
				WHEN sc.Description LIKE 'DPR count'
					THEN 4
				ELSE 5
				END
			) AS Description
		,ps.SummaryCount
		,ps.CalendarPeriod_PeriodId
		,ps.CalendarPeriod_CalendarId
		,p.PanelCode
		,p.Name
		,cm.Code
		,ps.Country_Id
	FROM PanelistSummaryCount ps
	INNER JOIN Summary_Category sc ON sc.SummaryCategoryId = ps.SummaryCategoryId
		AND sc.Country_Id = ps.Country_Id
	INNER JOIN Panelist pl ON pl.GUIDReference = ps.PanelistId
		AND pl.Country_Id = ps.Country_Id
		AND pl.Panel_Id = ps.Panel_Id
	INNER JOIN Panel p ON p.GUIDReference = ps.Panel_Id
		AND p.Country_Id = ps.Country_Id
	INNER JOIN DynamicRole dr ON dr.Country_Id = ps.Country_Id
		AND dr.Code = 2
	INNER JOIN DynamicRoleAssignment dra ON dra.DynamicRole_Id = dr.DynamicRoleId
		AND dra.Panelist_Id = ps.PanelistId
	INNER JOIN Individual i ON i.GUIDReference = dra.Candidate_Id
		AND i.IndividualId = @mainshopperId
	LEFT JOIN CollaborationMethodology cm ON cm.GUIDReference = ps.CollaborationMethodology_Id
		AND cm.Country_Id = ps.Country_Id
	INNER JOIN Country c ON c.CountryId = ps.Country_Id
	WHERE c.CountryISO2A = @CountryCode
		AND (
			sc.Description LIKE 'Selected category purchase count by week%'
			OR sc.Description LIKE 'Total Purchase Count%'
			OR sc.Description LIKE 'DPE count'
			OR sc.Description LIKE 'DPR count'
			)
		AND i.IndividualId = @mainshopperId

	DECLARE @compsttemp TABLE (
		Description VARCHAR(200)
		,SummaryCount INT
		,period VARCHAR(50)
		,periodgroup VARCHAR(50)
		,periodorder INT
		,yearperiodvalue INT
		,weekperiodvalue INT
		,PanelCode INT
		,NAME VARCHAR(100)
		,Code VARCHAR(100)
		)
	DECLARE @compstpivottemp TABLE (
		Period VARCHAR(10)
		,Periodvalue VARCHAR(10)
		,yearperiodvalue INT
		,weekperiodvalue INT
		,periodorder INT
		,[Selected summary count(compst)] INT
		,[SummaryCount(compst)] INT
		,[Sent DPs(DPE)] INT
		,[Rece DPs(DPR)] INT
		,NAME VARCHAR(100)
		,[Collaboration Methodology] VARCHAR(100)
		,PanelCode INT
		)

	INSERT INTO @compsttemp
	SELECT testDescription
		,SummaryCount
		,convert(VARCHAR(10), cpyear.PeriodValue) + '.' + convert(VARCHAR(10), cpPeriod.PeriodValue) + '.' + convert(VARCHAR(10), cp.PeriodValue) AS period
		,convert(VARCHAR(10), cpyear.PeriodValue) + '.' + convert(VARCHAR(10), cpPeriod.PeriodValue)
		,cpperiod.PeriodValue
		,cpYear.PeriodValue
		,cp.PeriodValue
		,PanelCode
		,NAME
		,Code
	FROM @tmpTable ps
	INNER JOIN CalendarPeriodHierarchy cphyear ON cphyear.CalendarId = ps.CalendarPeriod_CalendarId
		AND cphyear.SequenceWithinHierarchy = 1
		AND cphyear.OwnerCountry_Id = ps.Country_Id
	INNER JOIN CalendarPeriodHierarchy cph ON cph.CalendarId = ps.CalendarPeriod_CalendarId
		AND cph.SequenceWithinHierarchy = 2
		AND cph.OwnerCountry_Id = ps.Country_Id
	INNER JOIN CalendarPeriod cp ON cp.PeriodId = ps.CalendarPeriod_PeriodId
		AND cp.CalendarId = ps.CalendarPeriod_CalendarId
		AND cp.OwnerCountryId = ps.Country_Id
		AND cp.PeriodTypeId = cph.ChildPeriodTypeId
	INNER JOIN CalendarPeriod cpPeriod ON cpPeriod.CalendarId = cp.CalendarId
		AND cpPeriod.OwnerCountryId = ps.Country_Id
		AND cp.StartDate >= cpPeriod.StartDate
		AND cp.EndDate <= cpperiod.EndDate
		AND cpPeriod.PeriodTypeId = cph.ParentPeriodTypeId
	INNER JOIN CalendarPeriod cpYear ON cpYear.CalendarId = cp.CalendarId
		AND cpYear.OwnerCountryId = ps.Country_Id
		AND cpYear.PeriodTypeId = cphyear.ParentPeriodTypeId
		AND cp.StartDate >= cpYear.StartDate
		AND cp.EndDate <= cpYear.EndDate
	WHERE ps.testDescription IN (
			1
			,2
			)

	INSERT INTO @compsttemp
	SELECT testDescription
		,SummaryCount
		,convert(VARCHAR(10), cpyear.PeriodValue) + '.' + convert(VARCHAR(10), cp.PeriodValue) AS period
		,convert(VARCHAR(10), cpyear.PeriodValue) + '.' + convert(VARCHAR(10), cp.PeriodValue)
		,cp.PeriodValue
		,cpyear.PeriodValue
		,NULL
		,PanelCode
		,NAME
		,Code
	FROM @tmpTable ps
	INNER JOIN CalendarPeriodHierarchy cph ON cph.CalendarId = ps.CalendarPeriod_CalendarId
		AND cph.OwnerCountry_Id = ps.Country_Id
		AND SequenceWithinHierarchy = 1
	INNER JOIN CalendarPeriod cp ON cp.PeriodId = ps.CalendarPeriod_PeriodId
		AND cp.CalendarId = ps.CalendarPeriod_CalendarId
		AND cp.OwnerCountryId = ps.Country_Id
	INNER JOIN CalendarPeriod cpyear ON cpyear.CalendarId = cp.CalendarId
		AND cpyear.OwnerCountryId = ps.Country_Id
		AND cpyear.PeriodTypeId = cph.ParentPeriodTypeId
		AND cp.StartDate >= cpyear.StartDate
		AND cp.EndDate <= cpyear.EndDate
	WHERE ps.testDescription IN (
			3
			,4
			)

	INSERT INTO @compstpivottemp
	SELECT period
		,periodgroup
		,yearperiodvalue
		,weekperiodvalue
		,periodorder
		,[1] AS 'Selected summary count(compst)'
		,[2] AS 'SummaryCount(compst)'
		,[3] AS 'Sent DPs(DPE)'
		,[4] AS 'Rece DPs(DPR)'
		,NAME
		,Code AS 'Collaboration Methodology'
		,PanelCode
	FROM @compsttemp
	PIVOT(SUM(SummaryCount) FOR [Description] IN (
				[1]
				,[2]
				,[3]
				,[4]
				)) AS PivotTable

	DECLARE @summarycount TABLE (
		SumValue INT
		,periodvalue VARCHAR(10)
		,CollaborationMethodology VARCHAR(10)
		)

	INSERT INTO @summarycount
	SELECT SUM([SummaryCount(compst)])
		,Periodvalue
		,[Collaboration Methodology]
	FROM @compstpivottemp
	WHERE [SummaryCount(compst)] IS NOT NULL
	GROUP BY Periodvalue
		,[Collaboration Methodology]

	UPDATE ct
	SET [SummaryCount(compst)] = sc.SumValue
	FROM @compstpivottemp ct
	INNER JOIN @summarycount sc ON sc.periodvalue = ct.Periodvalue
		AND (
			sc.CollaborationMethodology IS NULL
			OR sc.CollaborationMethodology = ct.[Collaboration Methodology]
			)
	WHERE ct.[SummaryCount(compst)] IS NULL

	DELETE
	FROM @summarycount

	INSERT INTO @summarycount
	SELECT SUM([Selected summary count(compst)])
		,Periodvalue
		,[Collaboration Methodology]
	FROM @compstpivottemp
	WHERE [Selected summary count(compst)] IS NOT NULL
	GROUP BY Periodvalue
		,[Collaboration Methodology]

	UPDATE ct
	SET [Selected summary count(compst)] = sc.SumValue
	FROM @compstpivottemp ct
	INNER JOIN @summarycount sc ON sc.periodvalue = ct.Periodvalue
		AND (
			sc.CollaborationMethodology IS NULL
			OR sc.CollaborationMethodology = ct.[Collaboration Methodology]
			)
	WHERE ct.[Selected summary count(compst)] IS NULL

	SELECT C.CAlPeriod AS Period
		,periodvalue
		,[Selected summary count(compst)]
		,[SummaryCount(compst)]
		,[Sent DPs(DPE)]
		,[Rece DPs(DPR)]
		,NAME
		,[Collaboration Methodology] INTO #compstpivottemp
	FROM (
		SELECT c.periodorder
			,C.Period
			,periodvalue
			,[Selected summary count(compst)]
			,[SummaryCount(compst)]
			,[Sent DPs(DPE)]
			,[Rece DPs(DPR)]
			,NAME
			,[Collaboration Methodology]
		FROM @compstpivottemp c
		WHERE (
				@CollaborationMethodology IS NULL
				OR c.[Collaboration Methodology] = @CollaborationMethodology
				)
			AND (
				@Panelcode IS NULL
				OR c.PanelCode = @panelcode
				)
			AND (
				@Period IS NULL
				OR c.periodorder = @Period
				)
		) R
	RIGHT JOIN @Cal C ON C.CAlPeriod = R.Period
	WHERE (
			@Period IS NULL
			OR periodorder = @Period
			)
	ORDER BY C.[Year] DESC
		,C.[Period] DESC
		,C.[Week] DESC



Update T1 SET T1.[Selected summary count(compst)]=T2.[Selected summary count(compst)],T1.[SummaryCount(compst)]=T2.[SummaryCount(compst)] 
,T1.[Sent DPs(DPE)]=T2.[Sent DPs(DPE)],T1.[Rece DPs(DPR)]=T2.[Rece DPs(DPR)]
,T1.Periodvalue=T2.Periodvalue
,T1.Name=T2.Name
,T1.[Collaboration Methodology]=T2.[Collaboration Methodology]
FROM #compstpivottemp T1
JOIN (

SELECT SUM(T2.[Selected summary count(compst)]) AS [Selected summary count(compst)],SUM(T2.[SummaryCount(compst)])  AS [SummaryCount(compst)]
,SUM(T2.[Sent DPs(DPE)]) AS [Sent DPs(DPE)],SUM(T2.[Rece DPs(DPR)]) AS  [Rece DPs(DPR)] ,T2.periodvalue,T2.Name,T2.[Collaboration Methodology]
  FROM (Select * FROM #compstpivottemp WHERE Periodvalue IS NULL) T
  JOIN #compstpivottemp T2 ON T2.Periodvalue=T.Period
--WHERE periodvalue is null
Group BY T2.periodValue,T2.Name,T2.[Collaboration Methodology]

) T2 ON T1.Period=T2.Periodvalue

SELECT * FROM #compstpivottemp
DROP TABLE #compstpivottemp
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