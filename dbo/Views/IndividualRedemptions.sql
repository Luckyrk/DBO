
CREATE VIEW [dbo].[IndividualRedemptions]
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
	,[StateCode]
	,[GPSUser]
	,[GPSUpdateTimestamp]
	,[CreationTimeStamp]
	,[GiftPrice]
	,[CostPrice]
FROM dbo.FullIndividualRedemptions
INNER JOIN dbo.CountryViewAccess ON dbo.FullIndividualRedemptions.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND (dbo.CountryViewAccess.AllowPID = 1)
	AND dbo.FullIndividualRedemptions.CountryISO2A = dbo.CountryViewAccess.Country