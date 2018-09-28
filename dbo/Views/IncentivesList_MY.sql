CREATE VIEW [dbo].[IncentivesList_MY]
AS

/**************************************************************************************************
PF 18/01: Created this Country specific View as MY want to link this to Panel via PanelPoint. 
They only have a 1 to 1 relationship with IncentivePoint/Panel so it is possible to add the join to Panel via PanelPoint
Other Countries do not maintain this 1 to 1 relationship can cannot apply this join
****************************************************************************************************/

	SELECT iaet.[Type]
		,iaet.Code AS TypeCode
		,t.Value AS TypeDescription
		,c.CountryISO2A AS CountryCode
		,ip.Code AS IncentiveCode
		,ip.RewardCode
		,ip.[Type] AS PointType
		,tpointdesc.Value PointDescription
		,ip.ValidFrom
		,ip.ValidTo
		, p.PanelCode
		,p.Name
	FROM IncentivePointAccountEntryType iaet
	INNER JOIN IncentivePoint ip ON ip.[Type_Id] = iaet.GUIDReference
	INNER JOIN country c ON c.CountryId = iaet.Country_Id
	INNER JOIN TranslationTerm t ON (
			t.Translation_Id = iaet.TypeName_Id
			AND t.CultureCode = 2057
			)
	INNER JOIN TranslationTerm tpointdesc ON (
			tpointdesc.Translation_Id = ip.Description_Id
			AND tpointdesc.CultureCode = 2057
			)
	INNER JOIN PanelPoint pp ON ip.GUIDReference = pp.Point_Id
	INNER JOIN Panel p ON pp.Panel_Id = p.GUIDReference
	WHERE CountryISO2A = 'MY'
GO

--GRANT SELECT ON IncentivesList_MY TO GPSBusiness

--GO

--SELECT * FROM IncentivePoint ip
--	--INNER JOIN Respondent r ON ip.GUIDReference = r.GUIDReference
--	--INNER JOIN PanelPoint pp ON ip.GUIDReference = pp.Point_Id
--	--INNER JOIN Panel p ON pp.Panel_Id = p.GUIDReference
--WHERE Code = '1400053'

--AND r.CountryID = (SELECT COuntryID FROM Country WHERE CountryISO2A = 'MY')

--SELECT * FROM TranslationTerm WHERE Translation_ID = '7A291A79-4BE4-42A9-BD48-DECFBABDCB33'

--DELETE FROM TranslationTerm WHERE GUIDReference = '4899DC70-8530-C404-A56A-08D2EF462549'