
CREATE VIEW [dbo].[IncentivesList]
AS
SELECT iaet.[Type]
	,iaet.Code AS TypeCode
	,t.Value AS TypeDescription
	,c.CountryISO2A AS CountryCode
	,ip.Code AS IncentiveCode
	,ip.RewardCode
	,ip.[Type] AS PointType
	,tpointdesc.Value PointDescription
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