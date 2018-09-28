CREATE PROCEDURE GetCheckOrderedGiftMonth
@pIndividualId UNIQUEIDENTIFIER,
@pGiftId UNIQUEIDENTIFIER
AS
BEGIN
BEGIN TRY 
		DECLARE @GetDate DATETIME
		DECLARE @CountryId UNIQUEIDENTIFIER
		SET @CountryId=(select CountryId from individual where GUIDReference=@pIndividualId )
		SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryId))

Declare @startDate DateTime=(SELECT DATEADD(mm, DATEDIFF(mm, 0, @GetDate), 0))
Declare @endDate DateTime=(SELECT DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @GetDate) + 1, 0)))
 
IF EXISTS(Select  IncentiveAccountTransactionId from IncentiveAccountTransaction IAT
join IncentiveAccountTransactionInfo info on IAT.TransactionInfo_Id=info.IncentiveAccountTransactionInfoId
join IncentivePoint IP on info.Point_Id =IP.GUIDReference
where IAT.Account_Id=@pIndividualId and ip.GUIDReference=@pGiftId
and IAT.TransactionDate >=@startDate and IAT.TransactionDate<=@endDate)
BEGIN
SELECT 0
END
ELSE
BEGIN
SELECT 1
END
END TRY 
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH
END