--exec GetPurchaseSummaryCountES '000018-00',null,null,'ES',null

CREATE  PROCEDURE GetPurchaseSummaryCountES @mainshopperId VARCHAR(20)
       ,@CollaborationMethodology VARCHAR(100) = NULL
       ,@Period VARCHAR(10) = NULL
       ,@CountryCode VARCHAR(5)
       ,@Panelcode VARCHAR(100) = NULL
AS
BEGIN
BEGIN TRY
       DECLARE @countryId UNIQUEIDENTIFIER
       DECLARE @Individualguiid UNIQUEIDENTIFIER
       DECLARE @groupid UNIQUEIDENTIFIER
       Declare @IndividualId varchar(100)=@mainshopperId
       SET @countryId = (
                     SELECT CountryId
                     FROM Country
                     WHERE CountryISO2A = @countrycode
                     )
       SET @Individualguiid = (
                     SELECT GUIDREFERENCE
                     FROM Individual
                     WHERE IndividualId = @IndividualId
                           AND CountryId = @countryId
                     )
       SET @groupid = (
                     SELECT TOP 1 C.GUIDReference
                     FROM CollectiveMembership CM
                     INNER JOIN Collective C ON CM.Group_Id = C.GUIDReference
                     INNER JOIN StateDefinition SD ON SD.Id = CM.State_Id
                           AND sd.InactiveBehavior = 0
                     WHERE C.CountryId = @countryId
                           AND CM.Individual_Id = @Individualguiid
                     ORDER BY SD.CreationTimeStamp DESC
                     )

       DECLARE @temptableprchase TABLE (
              [Week] INT
              ,YearPeriodWeek VARCHAR(20)
              ,YearPeriod VARCHAR(20)
              ,yearperiodvalue INT
              ,periodperiodvalue INT
              ,weekperiodvalue INT
              ,CallLength Nvarchar(100)
             ,CollaborationMethodologyCode VARCHAR(20)
              ,Panelcode INT
              ,PanelName VARCHAR(100)
              ,Summarycount int
              ,CollaborationMethodologyDesc NVARCHAR(100)
              )

       INSERT INTO @temptableprchase
       SELECT cd.weekPeriodValue AS [Week]
              ,cd.YearPeriodWeek AS [YearPeriodWeek]
              ,convert(VARCHAR(10), cd.yearPeriodValue) + '.' + CONVERT(VARCHAR(10), cd.periodperiodvalue) AS [YearPeriod]
              ,cd.yearperiodvalue
              ,cd.periodperiodvalue
              ,cd.weekperiodvalue
              ,CASE 
                     WHEN (PSC.[CallLength] IS NOT NULL)
                           THEN CASE 
                                         WHEN ((DATEPART(hour, PSC.[CallLength])) > 9)
                                                THEN N''
                                         ELSE N'0'
                                         END + LTRIM(RTRIM(STR(CAST(DATEPART(hour, PSC.[CallLength]) AS FLOAT)))) + N':' + CASE 
                                         WHEN ((DATEPART(minute, PSC.[CallLength])) > 9)
                                                THEN N''
                                         ELSE N'0'
                                         END + LTRIM(RTRIM(STR(CAST(DATEPART(minute, PSC.[CallLength]) AS FLOAT)))) + N':' + CASE 
                                         WHEN ((DATEPART(second, PSC.[CallLength])) > 9)
                                                THEN N''
                                         ELSE N'0'
                                         END + LTRIM(RTRIM(STR(CAST(DATEPART(second, PSC.[CallLength]) AS FLOAT))))
                     ELSE N''
                     END AS CallLength
              ,cml.Code
              ,p.PanelCode
              ,p.NAME
              ,psc.Summarycount
             ,dbo.GetTranslationValue(cml.TranslationId, 3082)
       FROM panelistsummarycount psc
       INNER JOIN calendardenorm cd ON cd.weekPeriodID = psc.calendarperiod_periodid
       INNER JOIN country c ON c.countryid = cd.ownercountryid
       INNER JOIN Panelist pl ON pl.GUIDReference = psc.PanelistId
       INNER JOIN panel p ON p.GUIDReference = pl.Panel_Id
       INNER JOIN Summary_Category sc ON sc.SummaryCategoryId = psc.SummaryCategoryId
       LEFT JOIN CollaborationMethodology cml ON cml.GUIDReference = psc.CollaborationMethodology_Id
       WHERE c.countryid = @countryId
              AND (
                     pl.PanelMember_Id = @groupid
                     OR pl.PanelMember_Id = @Individualguiid
                     )

       SELECT [Week]
              ,YearPeriodWeek
              ,YearPeriod
              ,CallLength
              ,CollaborationMethodologyCode
              ,Panelcode
              ,yearperiodvalue
              ,periodperiodvalue
              ,weekperiodvalue
              ,PanelName
              ,SummaryCount
              ,CollaborationMethodologyDesc
       FROM @temptableprchase c
       WHERE (
                     @CollaborationMethodology IS NULL
                     OR c.CollaborationMethodologyCode = @CollaborationMethodology
                     )
              AND (
                     @Panelcode IS NULL
                     OR c.PanelCode = @panelcode
                     )
              AND (
                     @Period IS NULL
                     OR c.periodperiodvalue = @Period
                     )
       ORDER BY yearperiodvalue DESC
              ,periodperiodvalue DESC
              ,weekperiodvalue DESC
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

