﻿
CREATE VIEW [dbo].[FullIndividualIncentiveBalances]
AS
SELECT cnt.CountryISO2A
	,ind.IndividualId
	,ISNULL(sum(CASE IAT.[Type]
        WHEN 'Debit'
			THEN (- 1 * ((ISNULL(Ammount,0))))
        ELSE ISNULL(info.Ammount,0)
			END), 0) AS Amount
FROM IncentiveAccount AS ia
INNER JOIN IncentiveAccountTransaction AS iat ON iat.Account_Id = ia.IncentiveAccountId
		AND iat.Country_Id = ia.Country_Id
LEFT JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = Info.IncentiveAccountTransactionInfoId
INNER JOIN Individual AS ind ON ia.IncentiveAccountId = ind.GUIDReference
INNER JOIN dbo.Country cnt ON ind.CountryID = cnt.CountryId
GROUP BY cnt.CountryISO2A,ind.IndividualId