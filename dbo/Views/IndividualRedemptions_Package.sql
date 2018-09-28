﻿CREATE VIEW [dbo].[IndividualRedemptions_Package]
AS
SELECT [CountryISO2A]
	,[IndividualId]
	,[GroupId]
	,[PanelCode]
	,[PanelName]
	,[CreationDate]
	,[TransactionDate]
	,[Amount]
	,[Code]
	,[Description]
	,[Description_Local]
	,[Balance]
	,[Comments]
	,[TransactionSource]
	,[SupplierCode]
	,[SupplierDescription]
	,[RewardDeliveryCode]
	,[StateCode]
	,[StateDescription]
	,[SentDate]
	,[AddressType]
	,[AddressTypeDescription]
	,[Order]
	,[GPSUser]
	,[GPSUpdateTimestamp]
	,[CreationTimeStamp]
	,[GiftPrice]
	,[CostPrice]
FROM dbo.FullIndividualRedemptions_package
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualRedemptions_package.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullIndividualRedemptions_package.CountryISO2A = dbo.CountryViewAccess.Country