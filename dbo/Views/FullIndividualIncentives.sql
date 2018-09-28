GO
CREATE VIEW [dbo].[FullIndividualIncentives]
AS
SELECT dbo.Country.CountryISO2A
	,a.IndividualId
	,col.sequence GroupId
	,pan.PanelCode
	,pan.NAME PanelName
	,c.CreationDate
	,c.TransactionDate
	,c.SynchronisationDate
	,dep.IndividualId AS DepositorId
	,d.Ammount Amount
	,f.Code
	,CAST(i.Value AS NVARCHAR(255)) AS Description
	,(dbo.GetLocalValue(Country.CountryISO2A,h.TranslationId)) AS Description_Local
	,c.Balance
	,c.Comments
	,ter.Value AS TransactionSource
	,c.GPSUser
	,c.GPSUpdateTimestamp
	,c.CreationTimeStamp
	,c.BatchId
	,c.TransactionId
	,c.ParentTransactionId
FROM dbo.Candidate
INNER JOIN dbo.Country ON dbo.Candidate.Country_ID = dbo.Country.CountryId
INNER JOIN dbo.Individual AS a ON dbo.Candidate.GUIDReference = a.GUIDReference
	AND a.CountryId = dbo.Country.CountryId
INNER JOIN IncentiveAccount AS b ON b.IncentiveAccountId = a.GUIDReference
	AND b.Country_Id = a.CountryId
INNER JOIN IncentiveAccountTransaction AS c ON c.Account_Id = b.IncentiveAccountId
	AND c.Country_Id = b.Country_Id
	AND c.Type = 'credit'
INNER JOIN IncentiveAccountTransactionInfo AS d ON d.IncentiveAccountTransactionInfoId = c.TransactionInfo_Id
	AND d.Country_Id = c.Country_Id
INNER JOIN IncentivePoint AS f ON f.GUIDReference = d.Point_Id
INNER JOIN IncentivePointAccountEntryType AS g ON g.GUIDReference = f.Type_Id
LEFT JOIN Panel pan ON pan.GUIDReference = c.Panel_Id
INNER JOIN Individual dep ON dep.GUIDReference = c.Account_Id
INNER JOIN CollectiveMembership cmem ON cmem.Individual_Id = a.GuidReference
INNER JOIN Collective col ON col.GuidReference = cmem.Group_Id
INNER JOIN Translation AS h ON h.TranslationId = f.Description_Id
LEFT JOIN (
	SELECT Translation_Id
		,Value
	FROM dbo.TranslationTerm
	WHERE CultureCode = 2057
	) AS i ON i.Translation_Id = h.TranslationId
LEFT JOIN TransactionSource src ON src.TransactionSourceId = c.TransactionSource_Id
LEFT JOIN translation tr ON tr.TranslationId = src.Description_Id
LEFT JOIN (
	SELECT Translation_Id
		,Value
	FROM dbo.TranslationTerm
	WHERE CultureCode = 2057
	) AS ter ON ter.Translation_Id = tr.TranslationId
	--left outer join incentiveSupplier as j on j.IncentiveSupplierId  = f.SupplierId -- 145195
	AND c.Type = 'credit' -- Redundant due to join to packag