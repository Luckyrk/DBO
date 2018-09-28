
CREATE PROCEDURE [dbo].[PanelistEligibilityReport] @IndividualId VARCHAR(30)
	,@fromDate VARCHAR(100)
	,@toDate VARCHAR(100)
	,@isEligible VARCHAR(6)
	,@CountryCode VARCHAR(6)
AS
BEGIN
BEGIN TRY
	DECLARE @Eligible INT

	IF (@isEligible = 'true')
	BEGIN
		SET @Eligible = 1
	END
	ELSE
		SET @Eligible = 0

	SELECT dbo.Country.CountryISO2A
		,i.IndividualId AS BusinessId
		,dbo.Panel.Name PanelName
		,dbo.EligibilityFailureReason.[Description]
		,dbo.PanelistEligibility.[DemographicWeight]
		,[dbo].[GetDiaryPeriodWeekByDate](dbo.CalendarPeriod.StartDate, dbo.CalendarPeriod.CalendarId) AS Period
	FROM dbo.PanelistEligibility
	INNER JOIN dbo.Country ON dbo.PanelistEligibility.Country_Id = dbo.Country.CountryId
	INNER JOIN dbo.Panelist ON dbo.Panelist.GUIDReference = dbo.PanelistEligibility.PanelistId
	INNER JOIN dbo.Panel ON dbo.Panel.GUIDReference = dbo.PanelistEligibility.[Panel_Id]
	INNER JOIN dbo.EligibilityFailureReason ON dbo.EligibilityFailureReason.Country_Id = dbo.Country.CountryId
		AND dbo.EligibilityFailureReason.EligibilityFailureReasonId = dbo.PanelistEligibility.[EligibilityFailureReasonId]
	INNER JOIN dbo.CalendarPeriod ON dbo.CalendarPeriod.OwnerCountryId = dbo.Country.CountryId
		AND dbo.CalendarPeriod.CalendarId = dbo.PanelistEligibility.CalendarPeriod_CalendarId
		AND dbo.CalendarPeriod.PeriodId = dbo.PanelistEligibility.CalendarPeriod_PeriodId
	INNER JOIN dbo.Candidate c ON c.GUIDReference = dbo.Panelist.PanelMember_Id
		AND dbo.Country.CountryId = dbo.PanelistEligibility.Country_Id
	INNER JOIN dbo.Individual i ON i.GUIDReference = c.GUIDReference
	AND i.IndividualId = @IndividualId
	WHERE dbo.CalendarPeriod.StartDate >= @fromDate
		AND dbo.CalendarPeriod.EndDate <= @toDate
		AND dbo.PanelistEligibility.IsEligible = @Eligible
		AND dbo.Country.CountryISO2A = @CountryCode	
	UNION
	
	SELECT dbo.Country.CountryISO2A
		,i.IndividualId AS BusinessId
		,dbo.Panel.Name PanelName
		,dbo.EligibilityFailureReason.[Description]
		,dbo.PanelistEligibility.[DemographicWeight]
		,[dbo].[GetDiaryPeriodWeekByDate](dbo.CalendarPeriod.StartDate, dbo.CalendarPeriod.CalendarId) AS Period
	FROM dbo.PanelistEligibility
	INNER JOIN dbo.Country ON dbo.PanelistEligibility.Country_Id = dbo.Country.CountryId
	INNER JOIN dbo.Panelist ON dbo.Panelist.GUIDReference = dbo.PanelistEligibility.PanelistId
	INNER JOIN dbo.Panel ON dbo.Panel.GUIDReference = dbo.PanelistEligibility.[Panel_Id]
	INNER JOIN dbo.EligibilityFailureReason ON dbo.EligibilityFailureReason.Country_Id = dbo.Country.CountryId
		AND dbo.EligibilityFailureReason.EligibilityFailureReasonId = dbo.PanelistEligibility.[EligibilityFailureReasonId]
	INNER JOIN dbo.CalendarPeriod ON dbo.CalendarPeriod.OwnerCountryId = dbo.Country.CountryId
		AND dbo.CalendarPeriod.CalendarId = dbo.PanelistEligibility.CalendarPeriod_CalendarId
		AND dbo.CalendarPeriod.PeriodId = dbo.PanelistEligibility.CalendarPeriod_PeriodId
	INNER JOIN dbo.Candidate c ON c.GUIDReference = dbo.Panelist.PanelMember_Id
		AND dbo.Country.CountryId = dbo.PanelistEligibility.Country_Id
	INNER JOIN dbo.CollectiveMembership cm ON cm.Group_Id = c.GUIDReference
	INNER JOIN dbo.Individual i ON i.GUIDReference = cm.Individual_Id
	AND i.IndividualId = @IndividualId
	WHERE dbo.CalendarPeriod.StartDate >= @fromDate
		AND dbo.CalendarPeriod.EndDate <= @toDate
		AND dbo.PanelistEligibility.IsEligible = @Eligible
		AND dbo.Country.CountryISO2A = @CountryCode		
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