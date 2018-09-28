
CREATE VIEW [dbo].[GetIncentiveReasonTypes]
AS
SELECT c.CountryISO2A
	,ip.Code
	,tt.Value
FROM IncentivePoint ip
INNER JOIN IncentivePointAccountEntryType Ipt ON ip.Type_Id = Ipt.GUIDReference
INNER JOIN Country c ON c.CountryId = Ipt.Country_Id
INNER JOIN TranslationTerm tt ON tt.Translation_Id = ip.Description_Id
WHERE Ipt.[Type] = 'IncentiveType'

UNION

SELECT 'DUMMY' AS CountryISO2A
	,'0' AS Code
	,'DummyIncentiveType' AS Value