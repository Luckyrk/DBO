CREATE VIEW FullIndividualIncentives_Recom_ES
AS 
SELECT 
    DISTINCT C.CountryISO2A
	,col.sequence GroupId
	,IP.Code
FROM dbo.Individual Ind
INNER JOIN dbo.Country C ON Ind.CountryID = C.CountryId
INNER JOIN IncentiveAccount AS IA ON IA.IncentiveAccountId = Ind.GUIDReference
	AND IA.Country_Id = Ind.CountryId
INNER JOIN IncentiveAccountTransaction AS IAT ON IAT.Account_Id = IA.IncentiveAccountId
	AND IAT.Country_Id = IA.Country_Id
	AND IAT.Type = 'credit'
INNER JOIN IncentiveAccountTransactionInfo AS IATI ON IATI.IncentiveAccountTransactionInfoId = IAT.TransactionInfo_Id
	AND IATI.Country_Id = IAT.Country_Id
INNER JOIN IncentivePoint AS IP ON IP.GUIDReference = IATI.Point_Id
INNER JOIN CollectiveMembership cmem ON cmem.Individual_Id = Ind.GuidReference
INNER JOIN Collective col ON col.GuidReference = cmem.Group_Id
WHERE C.CountryISO2A='ES' 
GO
--GRANT SELECT ON FullIndividualIncentives_Recom_ES TO GPSBusiness
--GRANT SELECT ON FullIndividualIncentives_Recom_ES TO GPSBusiness_Full
--GO