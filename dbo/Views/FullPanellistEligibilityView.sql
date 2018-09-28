

CREATE VIEW [dbo].[FullPanellistEligibilityView]
AS
SELECT ct.CountryISO2A
	,pn.PanelCode
	,pn.NAME PanelName
	,PAN.PanelMemberID
	,PAN.GroupID
	,pe.[IsEligible]
	,ycp.PeriodValue Year
	,cp.PeriodValue
	,cpt.PeriodTypeDescription as PeriodType
	,efr.Description EligibilityFailureReason
	,pe.DemographicWeight
	,pe.[GPSUser]
	,pe.[GPSUpdateTimestamp]
	,pe.[CreationTimeStamp]
FROM dbo.PanelistEligibility pe
INNER JOIN dbo.Country ct ON ct.CountryId = pe.Country_Id
INNER JOIN dbo.panelist pt ON pt.GUIDReference = pe.PanelistId
INNER JOIN dbo.Panel pn ON pn.GUIDReference = pt.Panel_Id
INNER JOIN dbo.EligibilityFailureReason efr ON efr.Country_Id = ct.CountryId
	AND efr.EligibilityFailureReasonId = pe.[EligibilityFailureReasonId]


INNER JOIN dbo.CalendarPeriod cp ON cp.OwnerCountryId = ct.CountryId
	AND cp.CalendarId = pe.CalendarPeriod_CalendarId
	AND cp.PeriodId = pe.CalendarPeriod_PeriodId

JOIN PeriodType cpt ON cpt.PeriodTypeId=cp.PeriodTypeId

INNER JOIN dbo.CalendarPeriod ycp ON ycp.OwnerCountryId = ct.CountryId
	AND ycp.CalendarId = pe.CalendarPeriod_CalendarId
	AND ycp.PeriodTypeId IN (
		SELECT PeriodTypeId
		FROM dbo.PeriodType pti
		WHERE pti.PeriodTypeDescription = 'Year'
			AND pti.ownercountry_id = ycp.OwnerCountryId
		)
	AND cp.StartDate BETWEEN ycp.StartDate
		AND ycp.EndDate

INNER JOIN (
	SELECT GUIDReference
		,Ind.IndividualId PanelMemberID
		,isp.GroupID
	FROM dbo.Individual ind
	INNER JOIN dbo.IndividualIdSplitter isp ON isp.IndividualId = Ind.IndividualId
	
	UNION
	
	SELECT GUIDReference
		,CONVERT(VARCHAR, Sequence) PanelMemberID
		,CONVERT(VARCHAR, Sequence) GroupID
	FROM dbo.Collective cl
	) AS PAN ON PAN.GUIDReference = pt.PanelMember_Id