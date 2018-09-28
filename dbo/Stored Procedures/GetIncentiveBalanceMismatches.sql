/*----------------------------------------------------------------------------------------------------------
Created By -  Suresh
Purpose: This method is useful to know the cummulative balance is equal to sum of Incentive Balance.
Retrives all those individuals for the given country, who has mismatch in balances.

EXEC GetIncentiveBalanceMismatches 'TW', 'Lady Panel'
-----------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[GetIncentiveBalanceMismatches]
(
@CountryCode NVARCHAR(10) =  'TW',
@PanelName NVARCHAR(100) =  'Lady Panel'
)
AS 
BEGIN


DECLARE @CountryId uniqueidentifier  = (SELECT CountryID FROM Country WHERE CountryISO2A = @CountryCode)
DECLARE @PanelId uniqueidentifier = (SELECT GUIDReference from Panel Where Name = @PanelName and Country_Id = @CountryId) 

DECLARE @PanelType Varchar(20) = (SELECT [Type] from Panel Where Name = @PanelName and Country_Id = @CountryId)

IF @PanelType = 'Individual' 
begin 
 select    IndividualID, TransactionDate,   Balance, TrueBalance
  from 
 (
	 SELECT 
	TransactionDate, I.IndividualID, Ammount, Balance,
	 sum(Case IAT.[Type] when 'Debit' then (- 1 * ((ISNULL(Ammount,0))))  else info.Ammount end) OVER (PARTITION BY   I.IndividualID
	ORDER BY  I.IndividualID, TransactionDate
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TrueBalance
	, ROW_NUMBER() OVER(PARTITION BY  I.IndividualID ORDER BY TransactionDate DESC)  as RowID
	from IncentiveAccountTransaction IAT
	JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = IncentiveAccountTransactionInfoId
	join Individual I ON IAT.Account_Id = I.GUIDReference and CountryId = @CountryId -- and IndividualId like '%3-%'
	Join Panelist P ON P.PanelMember_Id = I.GUIDReference and P.Panel_Id = @PanelId
	JOIN IncentivePoint IP ON IP.GUIDReference = Info.Point_Id
	--where   IndividualID = '1660013-01'
	group by TransactionDate, I.IndividualID, Ammount, Balance, IAT.[Type]
) V1
 where    Balance <> TrueBalance and RowID = 1
 order by IndividualiD, TransactionDate DESC
end
else 
begin 
select    IndividualID, TransactionDate, Code, Ammount,  Balance, TrueBalance  
  from 
 (
	 SELECT 
	TransactionDate, I.IndividualID, Ammount, Balance, IP.Code,
	--sum(Case IAT.[Type] when 'Debit' then (-1* Ammount) else info.Ammount end)
	 sum(Ammount)
	  OVER (PARTITION BY   I.IndividualID
	ORDER BY  I.IndividualID, TransactionDate
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TrueBalance
	, ROW_NUMBER() OVER(PARTITION BY  I.IndividualID ORDER BY TransactionDate DESC)  as RowID
	from IncentiveAccountTransaction IAT
	JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = IncentiveAccountTransactionInfoId
	JOIN CollectiveMembership CM ON CM.Individual_Id =  IAT.Account_Id
	JOIN Collective C ON C.GUIDReference  = CM.Group_Id
	join Individual I ON IAT.Account_Id = I.GUIDReference and I.CountryId = @CountryId
	Join Panelist P ON P.PanelMember_Id = C.GUIDReference and P.Panel_Id = @PanelId

	JOIN IncentivePoint IP ON IP.GUIDReference = Info.Point_Id
	--where   IndividualID = '1001071-02'
	group by TransactionDate, I.IndividualID, Ammount, Balance, IAT.[Type], IP.Code
) V1
 where   Balance <> TrueBalance --and RowID = 1
 order by IndividualiD, TransactionDate DESC

END
END 

