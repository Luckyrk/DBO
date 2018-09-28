

CREATE VIEW [dbo].FullRedemptionPackageHistory
AS
SELECT
	--pg.GUIDReference
	--, pg.Reward_Id
	pg.Debit_Id
	--, pg.Country_Id
	, c.CountryISO2A
	, i.IndividualId
	, pg.CreationTimeStamp
	, ip.Code
	, ip.Value 
	--, t.KeyName
	, tt.Value AS GiftDescription
	--, sdh.GUIDReference
	, sdh.CreationDate StateChangeDate
	--, sdh.From_Id
	--, sdh.To_ID
	, sdf.Code AS FromStateCode
	, sdt.Code AS ToStateCode
	--, sd.Label_Id
	--, iat.IncentiveAccountTransactionId
	--, iat.CreationDate
	, iat.TransactionDate
	, iat.Balance
	--, iat.TransactionInfo_Id
	--, iat.DeliveryAddress_Id
	--, iat.Account_Id
	--, IncentiveAccountId
	--, i.GUIDReference

	FROM Package pg
	INNER JOIN Country c ON pg.Country_Id = c.CountryId
	INNER JOIN IncentivePoint ip ON pg.Reward_Id = ip.GUIDReference
	INNER JOIN Translation t ON ip.Description_Id = t.TranslationId
	LEFT JOIN TranslationTerm tt ON tt.Translation_Id = t.TranslationId
		AND cast(tt.CultureCode AS VARCHAR) IN (
			CASE c.CountryISO2A
				WHEN 'TW'
					THEN '1028'
				WHEN 'FR'
					THEN '1036'
				WHEN 'ES'
					THEN '3082,1034'
				WHEN 'GB'
					THEN '2057'
				WHEN 'PH'
					THEN '1124,13321'
				WHEN 'MY'
					THEN '17417,1086'
				END
			)
	INNER JOIN StateDefinitionHistory sdh ON pg.GUIDReference = sdh.Package_Id
	INNER JOIN StateDefinition sdt ON sdh.To_Id = sdt.ID
	INNER JOIN StateDefinition sdf ON sdh.From_Id = sdf.ID
	--INNER JOIN IncentiveAccountTransaction iat ON pg.GUIDReference = iat.PackageId
	INNER JOIN IncentiveAccountTransaction iat ON pg.Debit_Id = iat.IncentiveAccountTransactionId
	INNER JOIN IncentiveAccount ia ON iat.Account_Id = ia.IncentiveAccountId
	INNER JOIN Individual i ON ia.IncentiveAccountId = i.GUIDReference
--WHERE pg.GUIDReference IN (
--'AFBD5023-60CE-CDFC-79E3-08D2A223D328',
--'F30E4FE1-6C05-C841-393A-08D2D36D7DDF',
--'A6CA6645-E4CE-C40E-0C92-08D2E5B001E3',
--'844D8D8E-8C54-C398-38E5-08D2E5B14155',
--'99408B26-E56F-CE66-9C2D-08D2E5B14200',
--'1A097CA2-5AC6-C5A3-1890-08D2E5B142A0')
--ORDER By pg.GUIDReference, sdh.CreationDate

