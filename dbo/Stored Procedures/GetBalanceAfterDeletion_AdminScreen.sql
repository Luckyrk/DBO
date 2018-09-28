CREATE PROCEDURE GetBalanceAfterDeletion_AdminScreen (
	@paccountid UNIQUEIDENTIFIER
	,@pdeletablerecords VARCHAR(max)
	)
AS
BEGIN
	BEGIN TRY
		DECLARE @tempaccounttable TABLE (
			Account_id UNIQUEIDENTIFIER
			,IncentiveAccountTransactionId UNIQUEIDENTIFIER
			,IncentiveAccountTransactionInfoId UNIQUEIDENTIFIER
			,[Type] VARCHAR(40)
			,amount INT
			)
		DECLARE @Balance INT

		INSERT INTO @tempaccounttable
		SELECT IA.IncentiveAccountId AS Account_Id
			,iat.IncentiveAccountTransactionId
			,info.IncentiveAccountTransactionInfoId
			,iat.[Type]
			,info.Ammount
		FROM IncentiveAccount IA
		LEFT JOIN IncentiveAccountTransaction IAT ON IA.IncentiveAccountId = IAT.Account_Id
			AND IA.IncentiveAccountId = @paccountid
		LEFT JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = Info.IncentiveAccountTransactionInfoId
		WHERE IA.IncentiveAccountId = @paccountid

		DELETE stateDefHistory
		FROM StateDefinitionHistory stateDefHistory
		JOIN Package package ON package.GUIDReference = stateDefHistory.Package_Id
		JOIN @tempaccounttable acc ON acc.IncentiveAccountTransactionId = package.Debit_Id
		WHERE acc.IncentiveAccountTransactionId IN (
				SELECT Item
				FROM dbo.SplitString(@pdeletablerecords, ',')
				)

		DELETE package
		FROM Package package
		JOIN @tempaccounttable acc ON acc.IncentiveAccountTransactionId = package.Debit_Id
		WHERE acc.IncentiveAccountTransactionId IN (
				SELECT Item
				FROM dbo.SplitString(@pdeletablerecords, ',')
				)


		DELETE incentive
		FROM IncentiveAccountTransaction incentive
		JOIN @tempaccounttable acc ON acc.IncentiveAccountTransactionId = incentive.IncentiveAccountTransactionId
		WHERE acc.IncentiveAccountTransactionId IN (
				SELECT Item
				FROM dbo.SplitString(@pdeletablerecords, ',')
				)

		DELETE info
		FROM IncentiveAccountTransactionInfo info
		JOIN @tempaccounttable acc ON acc.IncentiveAccountTransactionInfoId = info.IncentiveAccountTransactionInfoId
		WHERE acc.IncentiveAccountTransactionId IN (
				SELECT Item
				FROM dbo.SplitString(@pdeletablerecords, ',')
				)

		DELETE
		FROM @tempaccounttable
		WHERE IncentiveAccountTransactionId IN (
				SELECT Item
				FROM dbo.SplitString(@pdeletablerecords, ',')
				)

		SET @Balance = (
				SELECT ISNULL(SUM(CASE [Type]
								WHEN 'Debit'
									THEN (- 1 * ((ISNULL(amount, 0))))
								ELSE ISNULL(amount, 0)
								END), 0) AS Balance
				FROM @tempaccounttable
				GROUP BY Account_Id
				)

		SELECT ISNULL(@Balance, 0) AS Balance
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE()
			,@Severity = ERROR_SEVERITY()
			,@State = ERROR_STATE();

		RAISERROR (
				@ErrorMsg
				,-- Message text.
				@Severity
				,-- Severity.
				@State -- State.
				);
	END CATCH
END
