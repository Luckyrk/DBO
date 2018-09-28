/*----------------------------------------------------------------------------------------------------------
Created By -  Suresh
Purpose: This method is useful to update the cummulative balance of incentives

EXEC UpdateIncentiveBalanceMismatches 'TW', 'Lady Panel'
-----------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [dbo].[UpdateIncentiveBalanceMismatches]
(
@CountryCode NVARCHAR(10) =  'TW',
@PanelName NVARCHAR(100) =  'Lady Panel'
)
AS 
BEGIN 
DECLARE @CountryId uniqueidentifier  = (SELECT CountryID FROM Country WHERE CountryISO2A = @CountryCode)
DECLARE @GetDate DATETIME
SET @GetDate = (select dbo.GetLocalDateTime(GETDATE(),@CountryCode))
DECLARE @PanelId uniqueidentifier = (SELECT GUIDReference from Panel Where Name = @PanelName and Country_Id = @CountryId) 

 update IncentiveAccountTransaction 
 SET    Balance =  NewBalance,GPSUpdateTimestamp=@GetDate
  from 
 (
	 SELECT 
	 IncentiveAccountTransactionId,  --   , Comments,IncentiveAccountTransactionInfoId,TransactionSource_Id, 
	TransactionDate, I.IndividualID, Ammount, Balance,
	 sum(Case IAT.[Type] when 'Debit' then (- 1 * ((ISNULL(Ammount,0)))) else ISNULL(info.Ammount,0) end) 
	 OVER (PARTITION BY   I.IndividualID
	ORDER BY  I.IndividualID, TransactionDate
	ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS NewBalance

	from IncentiveAccountTransaction IAT
	JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = IncentiveAccountTransactionInfoId
	join Individual I ON IAT.Account_Id = I.GUIDReference and CountryId = @CountryId --  and IndividualId like '%3-%'
	Join Panelist P ON P.PanelMember_Id = I.GUIDReference and P.Panel_Id = @PanelId
	JOIN IncentivePoint IP ON IP.GUIDReference = Info.Point_Id
	group by IncentiveAccountTransactionId,TransactionDate, I.IndividualID, Ammount, Balance,IAT.[Type]
) V1
 where   V1.IncentiveAccountTransactionId = IncentiveAccountTransaction.IncentiveAccountTransactionId
 and V1.Balance <>  NewBalance
 
 END
