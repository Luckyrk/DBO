
CREATE VIEW [dbo].[FullIndividualRedemptions_Package]
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
	,CAST(iloc.Value AS NVARCHAR(255)) AS Description_Local
	,c.Balance
	,c.Comments
	,ter.Value AS TransactionSource
	,j.Code SupplierCode
	,j.Description SupplierDescription
	,rdt.Code AS RewardDeliveryCode
	,sd.Code AS StateCode
	,trterm.Value AS StateDescription
	,pkg.DateSent AS SentDate
	,addr.AddressType
	,trm4.Value + 'AddressType' AS AddressTypeDescription
	,ocm.[Order]
	,addr.[AddressLine1]
	,addr.[AddressLine2]
	,addr.[AddressLine3]
	,addr.[AddressLine4]
	,addr.[PostCode]    
	,c.GPSUser
	,c.GPSUpdateTimestamp
	,c.CreationTimeStamp
	,f.GiftPrice
	,f.CostPrice
FROM dbo.Candidate
INNER JOIN dbo.Country ON dbo.Candidate.Country_ID = dbo.Country.CountryId
INNER JOIN dbo.Individual AS a ON dbo.Candidate.GUIDReference = a.GUIDReference
	AND a.CountryId = Candidate.Country_Id
INNER JOIN IncentiveAccount AS b ON b.IncentiveAccountId = a.GUIDReference
	AND b.Country_Id = a.CountryId -- 191353
INNER JOIN IncentiveAccountTransaction AS c ON c.Account_Id = b.IncentiveAccountId
	AND c.Country_Id = b.Country_Id
	AND c.Type = 'debit' -- 5369427 -- select count(*) from IncentiveAccountTransaction
INNER JOIN IncentiveAccountTransactionInfo AS d ON d.IncentiveAccountTransactionInfoId = c.TransactionInfo_Id
	AND d.Country_Id = c.Country_Id --5369427
INNER JOIN IncentivePoint AS f ON f.GUIDReference = d.Point_Id -- 145195
LEFT JOIN IncentiveSupplier AS j ON j.IncentiveSupplierId = f.SupplierId
INNER JOIN IncentivePointAccountEntryType AS g ON g.GUIDReference = f.Type_Id -- 145195
LEFT JOIN Panel pan ON pan.GUIDReference = c.Panel_Id
INNER JOIN CollectiveMembership cmem ON cmem.Individual_Id = a.GuidReference
INNER JOIN Collective col ON col.GuidReference = cmem.Group_Id
INNER JOIN Translation AS h ON h.TranslationId = f.Description_Id
LEFT JOIN TranslationTerm AS i ON i.Translation_Id = h.TranslationId
	AND i.CultureCode = 2057
LEFT JOIN TranslationTerm AS iloc ON iloc.Translation_Id = h.TranslationId
	AND cast(iloc.CultureCode AS VARCHAR) IN (
		SELECT items FROM dbo.Split(
              CASE dbo.Country.CountryISO2A
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
                     END,',')
              )
LEFT JOIN TransactionSource src ON src.TransactionSourceId = c.TransactionSource_Id
LEFT JOIN translation tr ON tr.TranslationId = src.Description_Id
LEFT JOIN translationterm ter ON ter.Translation_Id = tr.TranslationId
	AND ter.CultureCode = 2057
LEFT JOIN RewardDeliveryType rdt ON rdt.RewardDeliveryTypeId = d.RewardDeliveryType_Id
LEFT JOIN Package pkg ON pkg.GUIDReference = c.PackageId
	AND pkg.Country_Id = Country.CountryId
LEFT JOIN StateDefinition sd ON sd.Id = pkg.State_Id
LEFT JOIN translationterm trterm ON trterm.Translation_Id = sd.Label_Id
	AND trterm.CultureCode = 2057
LEFT JOIN Address addr ON addr.GUIDReference = c.DeliveryAddress_Id
LEFT JOIN OrderedContactMechanism ocm ON ocm.Address_Id = addr.GUIDReference AND a.GUIDReference = ocm.Candidate_Id
LEFT JOIN AddressType Adtyp ON Adtyp.Id = addr.[Type_Id]
LEFT JOIN TranslationTerm trm4 ON trm4.Translation_Id = Adtyp.Description_Id
	AND trm4.CultureCode = 2057
