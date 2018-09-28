--DML SCRIPTS END
/*****************************************************************************************************************/
--FUNCTION's SCRIPTS START
--FUNCTION's SCRIPTS END
/*****************************************************************************************************************/
--VIEWS SCRIPTS START
CREATE VIEW [dbo].[IncentiveAccountBalance_ByPanel]
AS
SELECT cnt.CountryISO2A
	,pl.NAME
	,ind.IndividualId
	,ISNULL(sum(CASE IAT.[Type]
        WHEN 'Debit'
			THEN (- 1 * ((ISNULL(Ammount,0))))
        ELSE ISNULL(info.Ammount,0)
			END), 0) AS Amount
FROM dbo.IncentiveAccount AS ia
INNER JOIN dbo.IncentiveAccountTransaction AS iat ON iat.Account_Id = ia.IncentiveAccountId
	AND iat.Country_Id = ia.Country_Id
LEFT JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = Info.IncentiveAccountTransactionInfoId
INNER JOIN dbo.Individual AS ind ON ia.IncentiveAccountId = ind.GUIDReference
INNER JOIN dbo.Country AS cnt ON ind.CountryId = cnt.CountryId
INNER JOIN dbo.Panelist p ON ind.GUIDReference = p.PanelMember_ID
INNER JOIN dbo.Panel pl ON p.Panel_Id = pl.GUIDReference
GROUP BY cnt.CountryISO2A,pl.NAME,ind.IndividualId