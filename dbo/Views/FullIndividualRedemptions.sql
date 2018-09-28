
CREATE VIEW [dbo].[FullIndividualRedemptions]
AS
SELECT dbo.Country.CountryISO2A
	,a.IndividualId
	,col.sequence GroupId
	,pan.PanelCode
	,pan.NAME PanelName
	,c.CreationDate
	,c.TransactionDate
	,c.SynchronisationDate
	,(- 1 * ((ISNULL(d.Ammount,0)))) AS Amount
	,f.RewardCode AS Code
	,CAST(i.Value AS NVARCHAR(255)) AS Description
	,(dbo.GetLocalValue(Country.CountryISO2A,h.TranslationId)) AS Description_Local
	,c.Balance
	,c.Comments
	,ter.Value AS TransactionSource
	,j.Code SupplierCode
	,j.Description SupplierDescription
	,sd.Code AS StateCode
	,c.GPSUser
	,c.GPSUpdateTimestamp
	,c.CreationTimeStamp
	,c.GiftPrice
	,c.CostPrice
	,c.BatchId
	,c.TransactionId
	,c.ParentTransactionId
FROM dbo.Candidate
INNER JOIN dbo.Country ON dbo.Candidate.Country_ID = dbo.Country.CountryId
INNER JOIN dbo.Individual AS a ON dbo.Candidate.GUIDReference = a.GUIDReference
INNER JOIN IncentiveAccount AS b ON b.IncentiveAccountId = a.GUIDReference
INNER JOIN IncentiveAccountTransaction AS c ON c.Account_Id = b.IncentiveAccountId
	AND c.Type = 'debit'
INNER JOIN IncentiveAccountTransactionInfo AS d ON d.IncentiveAccountTransactionInfoId = c.TransactionInfo_Id
INNER JOIN IncentivePoint AS f ON f.GUIDReference = d.Point_Id
LEFT JOIN IncentiveSupplier AS j ON j.IncentiveSupplierId = f.SupplierId
INNER JOIN IncentivePointAccountEntryType AS g ON g.GUIDReference = f.Type_Id
LEFT JOIN Panel pan ON pan.GUIDReference = c.Panel_Id
INNER JOIN CollectiveMembership cmem ON cmem.Individual_Id = a.GuidReference
INNER JOIN Collective col ON col.GuidReference = cmem.Group_Id
INNER JOIN Translation AS h ON h.TranslationId = f.Description_Id
LEFT JOIN TranslationTerm AS i ON i.Translation_Id = h.TranslationId
	AND i.CultureCode = 2057
LEFT JOIN TransactionSource src ON src.TransactionSourceId = c.TransactionSource_Id
LEFT JOIN translation tr ON tr.TranslationId = src.Description_Id
LEFT JOIN translationterm ter ON ter.Translation_Id = tr.TranslationId
	AND ter.CultureCode = 2057
LEFT JOIN Package pkg ON pkg.GUIDReference = c.PackageId
	AND pkg.Country_Id = Country.CountryId
LEFT JOIN StateDefinition sd ON sd.Id = pkg.State_Id
