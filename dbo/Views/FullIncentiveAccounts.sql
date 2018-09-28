CREATE VIEW [dbo].[FullIncentiveAccounts]
AS
SELECT acc.IncentiveAccountID
	,cnt.CountryISO2A
	,acc.[Type] AS AccountType
	,col.Sequence AS GroupId
	,ind.IndividualId
	,ben.IndividualId AS Beneficiary
	,acc.GPSUser
	,acc.GPSUpdateTimestamp
	,acc.CreationTimeStamp
	,Amount AS [CurrentBalance]
FROM dbo.IncentiveAccount AS acc
INNER JOIN dbo.Individual AS ind ON ind.GUIDReference = acc.IncentiveAccountId
INNER JOIN dbo.Candidate AS can ON can.GUIDReference = ind.GUIDReference
INNER JOIN dbo.Country AS cnt ON cnt.CountryId = can.Country_Id
LEFT JOIN dbo.CollectiveMembership AS mem ON mem.Individual_Id = ind.GUIDReference
LEFT JOIN dbo.Collective AS col ON col.GUIDReference = mem.Group_Id
LEFT JOIN dbo.Individual AS ben ON ben.GUIDReference = acc.Beneficiary_Id
INNER JOIN FullGroupIncentiveBalance f ON f.GroupId = col.Sequence AND f.CountryISO2A=cnt.CountryISO2A AND f.IndividualId = ind.IndividualId