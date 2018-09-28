CREATE VIEW [dbo].[FullIncentiveGBPrizeWinners]
AS 

select p.CountryISO2A, r.Sequence as GroupId
,n.IndividualId, j.TransactionDate, k.RewardCode, h.Ammount as TransactionValue
from IncentiveAccountTransactionInfo h
join IncentiveAccountTransaction j
on j.TransactionInfo_Id = h.IncentiveAccountTransactionInfoId
Join IncentivePoint k
on k.GUIDReference = h.Point_Id
and k.[Type] = 'Incentive'
Join IncentiveAccount m
on m.IncentiveAccountId = j.Account_Id
Join Individual n
on n.GUIDReference = m.IncentiveAccountId
and k.RewardCode = 14
Join Country p
on p.CountryId = h.Country_Id
and p.CountryISO2A = 'GB'
Join CollectiveMembership q
on q.Individual_Id = n.GUIDReference
Join Collective r
on r.GUIDReference = q.Group_Id