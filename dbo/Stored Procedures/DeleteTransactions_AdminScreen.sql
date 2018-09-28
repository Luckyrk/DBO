CREATE PROCEDURE dbo.DeleteTransactionIncentive_Adminscreen @pCountryISO2A VARCHAR(10)
	,@values VARCHAR(50)
	,@BatchIds INT
	,@Transactions
AS
dbo.TransactionType READONLY AS

BEGIN
	DECLARE @countryid UNIQUEIDENTIFIER = (
			SELECT TOP 1 CountryId
			FROM country
			WHERE CountryISO2A = @pCountryISO2A
			)
	DECLARE @MAINTABLE TABLE (TransactionId UNIQUEIDENTIFIER)
	DECLARE @T1 TABLE (TransactionInfoId UNIQUEIDENTIFIER)
	DECLARE @T2 TABLE (TransactionInfoIdS UNIQUEIDENTIFIER)
	DECLARE @WithBatchId TABLE (IcenTransactionId UNIQUEIDENTIFIER)

	INSERT INTO @WithBatchId
	SELECT INCENTIVEACCOUNTTRANSACTIONID
	FROM INCENTIVEACCOUNTTRANSACTION
	WHERE BatchID = @BatchIds
		AND Country_Id = @countryid

	--few
	IF (@values = 'few')
	BEGIN
		INSERT INTO @MAINTABLE
		SELECT transactionid
		FROM @Transactions

		INSERT INTO @MAINTABLE
		SELECT INCENTIVEACCOUNTTRANSACTIONID
		FROM INCENTIVEACCOUNTTRANSACTION
		WHERE PARENTTRANSACTIONID IN (
				SELECT transactionid
				FROM @Transactions
				)
			AND Country_Id = @countryid
	END

	--all
	IF (@values = 'all')
	BEGIN
		INSERT INTO @MAINTABLE
		SELECT IcenTransactionId
		FROM @WithBatchId
	END

	--exclude
	IF (@values = 'exclude')
	BEGIN
		INSERT INTO @MAINTABLE
		SELECT IcenTransactionId
		FROM @WithBatchId

		DELETE
		FROM @MAINTABLE
		WHERE TransactionId IN (
				SELECT transactionid
				FROM @Transactions
				)

		INSERT INTO @MAINTABLE
		SELECT INCENTIVEACCOUNTTRANSACTIONID
		FROM INCENTIVEACCOUNTTRANSACTION
		WHERE PARENTTRANSACTIONID IN (
				SELECT TransactionId
				FROM @MAINTABLE
				)
			AND Country_Id = @countryid
	END

	INSERT INTO @T1
	SELECT TransactionInfo_Id
	FROM IncentiveAccountTransaction
	WHERE IncentiveAccountTransactionId IN (
			SELECT transactionid
			FROM @MAINTABLE
			)
		AND Country_Id = @countryid

	INSERT INTO @T2
	SELECT GUIDReference
	FROM Package
	WHERE Debit_Id IN (
			SELECT transactionid
			FROM @MAINTABLE
			)
		AND Country_Id = @countryid

	ALTER TABLE StateDefinitionHistory NOCHECK CONSTRAINT ALL

	DELETE
	FROM StateDefinitionHistory
	WHERE Package_Id IN (
			SELECT TransactionInfoIdS
			FROM @T2
			)
		AND Country_Id = @countryid

	ALTER TABLE StateDefinitionHistory CHECK CONSTRAINT ALL

	ALTER TABLE Package NOCHECK CONSTRAINT ALL

	DELETE
	FROM Package
	WHERE Country_Id = @countryid
		AND Debit_Id IN (
			SELECT transactionid
			FROM @MAINTABLE
			)

	ALTER TABLE Package CHECK CONSTRAINT ALL

	ALTER TABLE IncentiveAccountTransaction NOCHECK CONSTRAINT ALL

	DELETE
	FROM IncentiveAccountTransaction
	WHERE Country_Id = @countryid
		AND TransactionInfo_Id IN (
			SELECT TransactionInfoId
			FROM @T1
			)

	ALTER TABLE IncentiveAccountTransaction CHECK CONSTRAINT ALL

	ALTER TABLE IncentiveAccountTransactionInfo NOCHECK CONSTRAINT ALL

	DELETE
	FROM IncentiveAccountTransactionInfo
	WHERE Country_Id = @countryid
		AND IncentiveAccountTransactionInfoId IN (
			SELECT TransactionInfoId
			FROM @T1
			)

	ALTER TABLE IncentiveAccountTransactionInfo CHECK CONSTRAINT ALL
END