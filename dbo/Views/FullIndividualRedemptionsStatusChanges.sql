CREATE VIEW [dbo].[FullIndividualRedemptionsStatusChanges]
AS
SELECT dbo.Country.CountryISO2A
	,a.IndividualId
	,col.sequence GroupId
	,pan.PanelCode
	,pan.NAME PanelName
	,c.CreationDate
	,c.TransactionDate
	,(- 1 * ((ISNULL(d.Ammount,0)))) AS Amount
	,f.RewardCode AS Code
	,CAST(i.Value AS NVARCHAR(255)) AS Description
	,fromsd.Code AS FromCode
	,Tosd.Code AS ToCode
	,sdh.CreationDate AS ChangedDate
	,sdh.GPSUser
FROM dbo.Candidate
INNER JOIN dbo.Country ON dbo.Candidate.Country_ID = dbo.Country.CountryId
INNER JOIN dbo.Individual AS a ON dbo.Candidate.GUIDReference = a.GUIDReference
	AND a.CountryId = Candidate.Country_Id
INNER JOIN IncentiveAccount AS b ON b.IncentiveAccountId = a.GUIDReference
	AND b.Country_Id = a.CountryId
INNER JOIN IncentiveAccountTransaction AS c ON c.Account_Id = b.IncentiveAccountId
	AND c.Country_Id = b.Country_Id
	AND c.Type = 'debit'
INNER JOIN IncentiveAccountTransactionInfo AS d ON d.IncentiveAccountTransactionInfoId = c.TransactionInfo_Id
	AND d.Country_Id = c.Country_Id
INNER JOIN IncentivePoint AS f ON f.GUIDReference = d.Point_Id
INNER JOIN IncentivePointAccountEntryType AS g ON g.GUIDReference = f.Type_Id
LEFT JOIN Panel pan ON pan.GUIDReference = c.Panel_Id
INNER JOIN CollectiveMembership cmem ON cmem.Individual_Id = a.GuidReference
INNER JOIN Collective col ON col.GuidReference = cmem.Group_Id
INNER JOIN Translation AS h ON h.TranslationId = f.Description_Id
LEFT JOIN TranslationTerm AS i ON i.Translation_Id = h.TranslationId
	AND i.CultureCode = 2057
LEFT JOIN Package pkg ON pkg.GUIDReference = c.PackageId
	AND pkg.Country_Id = Country.CountryId
LEFT JOIN StateDefinitionHistory sdh ON sdh.Package_Id = pkg.GUIDReference
LEFT JOIN StateDefinition fromsd ON fromsd.Id = sdh.From_Id
LEFT JOIN StateDefinition tosd ON tosd.Id = sdh.To_Id
