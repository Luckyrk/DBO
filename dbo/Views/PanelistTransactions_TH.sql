CREATE VIEW [dbo].[PanelistTransactions_TH]
AS
WITH TEMP AS (
SELECT I.GUIDReference,I.IndividualId,C.CountryISO2A,P.FirstOrderedName,P.LastOrderedName,P.MiddleOrderedName
, Substring(I.individualid, 0, Charindex('-', I.individualid, 0)) AS GroupId
,CAST(TITTRAN.KeyName AS NVARCHAR(255)) AS TitleDescription
,I.CountryId
FROM Individual I
INNER JOIN COuntry C ON C.CountryId=I.CountryId
INNER JOIN PersonalIdentification P ON I.PersonalIdentificationId = P.PersonalIdentificationId
LEFT JOIN dbo.IndividualTitle IT ON P.TitleId = IT.GUIDReference
LEFT JOIN dbo.Translation AS TITTRAN ON IT.Translation_Id = TITTRAN.TranslationId
WHERE C.CountryId='814036A1-CD8E-4FCB-8B59-E15F3F60F952'
)

SELECT * FROM (
SELECT T.countryiso2a, 
         T.individualid,          
            T.GroupId, 
         T.titledescription, 
         T.firstorderedname, 
         T.middleorderedname,
		 T.lastorderedname,  
		  TT.creationdate, 
		 TT.TransactionDate,
         TT.code, 
         TT.description, 
         TT.type, 
         Isnull(TT.amount, 0) AS Amount, 
         TT.gpsuser 
FROM TEMP T
LEFT JOIN (
SELECT 
T.GUIDReference,
IAT.CreationDate, 
		 IAT.TransactionDate,
         IP.code, 
         i.Value AS [description], 
         'Incentive' AS [Type], 
         Isnull(IATI.ammount, 0) AS Amount, 
         IAT.gpsuser 
FROM
IncentiveAccount IA
INNER JOIN TEMP T ON T.GUIDReference=IA.IncentiveAccountId AND IA.Country_Id=T.CountryId
INNER JOIN IncentiveAccountTransaction AS IAT ON IAT.Account_Id = IA.IncentiveAccountId AND IAT.Country_Id = IA.Country_Id
	AND IAT.Type = 'credit'
INNER JOIN IncentiveAccountTransactionInfo AS IATI ON IATI.IncentiveAccountTransactionInfoId = IAT.TransactionInfo_Id AND IATI.Country_Id = IAT.Country_Id
INNER JOIN IncentivePoint AS IP ON IP.GUIDReference = IATI.Point_Id
LEFT JOIN (
	SELECT Translation_Id
		,Value
	FROM dbo.TranslationTerm
	WHERE CultureCode = 2057
	) AS i ON i.Translation_Id = IP.Description_Id
	UNION ALL
	SELECT 
		T.GUIDReference,
		 IAT.CreationDate, 
		 IAT.TransactionDate,
         IP.RewardCode, 
         i.Value as [description], 
         'Redemption' AS [Type], 
         -Isnull(IATI.ammount, 0) AS Amount, 
         IAT.gpsuser 
FROM
IncentiveAccount IA
INNER JOIN TEMP T ON T.GUIDReference=IA.IncentiveAccountId AND IA.Country_Id=T.CountryId
INNER JOIN IncentiveAccountTransaction AS IAT ON IAT.Account_Id = IA.IncentiveAccountId AND IAT.Country_Id = IA.Country_Id
	AND IAT.Type = 'debit'
INNER JOIN IncentiveAccountTransactionInfo AS IATI ON IATI.IncentiveAccountTransactionInfoId = IAT.TransactionInfo_Id AND IATI.Country_Id = IAT.Country_Id
INNER JOIN IncentivePoint AS IP ON IP.GUIDReference = IATI.Point_Id
LEFT JOIN (
	SELECT Translation_Id
		,Value
	FROM dbo.TranslationTerm
	WHERE CultureCode = 2057
	) AS i ON i.Translation_Id = IP.Description_Id
	) AS TT ON TT.GUIDReference=T.GUIDReference
	
	) TT 


GO


