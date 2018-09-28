CREATE PROCEDURE [dbo].[GetIndividualAccountWithCharitySubscription] @pIndividualId UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pIsMainContactInUK BIT
	,@pCurrentUserName NVARCHAR(200)
AS
BEGIN
	BEGIN TRY
		DECLARE @NullGUID UNIQUEIDENTIFIER
			,@RelatedAccount NVARCHAR(200) = 'RelatedAccount'
			,@OwnAccount NVARCHAR(200) = 'OwnAccount'
			,@GroupId UNIQUEIDENTIFIER

		SET @NullGUID = '00000000-0000-0000-0000-000000000000'

		DECLARE @COUNTRYCONTEXTNAME VARCHAR(100)
			,@LinkAccountUserAccess BIT
			,@IsAccountLinkVisible BIT

		SELECT @COUNTRYCONTEXTNAME = 'Country' + CountryISO2A
		FROM COUNTRY
		WHERE CountryId = @pCountryId

		IF EXISTS (
				SELECT 1
				FROM IDENTITYUSER IU
				JOIN SYSTEMUSERROLE SUR ON IU.Id = SUR.IDENTITYUSERID
					AND SUR.CountryId = @pCountryId
				JOIN AccessRights AR ON SUR.SystemRoleTypeId = AR.SystemRoleTypeId
				INNER JOIN AccessContext AC ON AC.AccessContextId = AR.AccessContextId
				INNER JOIN RestrictedAccessArea RA ON RA.RestrictedAccessAreaId = AR.RestrictedAccessAreaId
				INNER JOIN RestrictedAccessAreaSubType RST ON RA.RestrictedAccessAreaTypeId = RST.RestrictedAccessAreaTypeId
				INNER JOIN RestrictedAccessSystemArea RASA ON RASA.RestrictedAccessAreaId = RA.RestrictedAccessAreaId
					AND RA.RestrictedAccessAreaSubTypeId = RST.RestrictedAccessAreaSubTypeId
				JOIN TRANSLATIONTERM TT ON RASA.NAME = TT.VALUE
					AND TT.CULTURECODE = 2057
				JOIN TRANSLATION T ON TT.TRANSLATION_ID = T.TRANSLATIONID
				WHERE IU.USERNAME = @pCurrentUserName
					AND RST.Description = 'System - Field'
					AND AR.IsPermissionGranted = 1
					AND AC.[Description] = @COUNTRYCONTEXTNAME
					AND T.KEYNAME = 'LinkAccount'
				)
			SET @LinkAccountUserAccess = 1
		ELSE
			SET @LinkAccountUserAccess = 0

		IF (@pIsMainContactInUK = 1)
		BEGIN
			EXEC UpdateAccountTransactions @pIndividualId
		END

		SELECT IOwnner.GUIDReference AS ID
			,IOwnner.GUIDReference AS IndividualId
			,CASE 
				WHEN IA.Type = @RelatedAccount
					THEN 0
				ELSE isnull(IAT.Balance, 0)
				END AS Balance
			,IOwnner.IndividualId AS BusinessId
			,CASE 
				WHEN IA.Type = @OwnAccount
					THEN IOwnner.GUIDReference
				ELSE IA.Beneficiary_Id
				END AS BeneficiaryId
			,CASE 
				WHEN IA.Type = @RelatedAccount
					THEN 1
				ELSE 0
				END AS IsRelatedAccount
			,CASE 
				WHEN IA.Type = @OwnAccount
					THEN IOwnner.IndividualId
				ELSE IBenif.IndividualId
				END AS BeneficiaryBusinessId
		FROM Individual IOwnner
		LEFT JOIN IncentiveAccount IA ON IA.IncentiveAccountId = IOwnner.GUIDReference
		LEFT JOIN Individual IBenif ON IA.Beneficiary_Id = IBenif.GUIDReference
		LEFT JOIN (
			SELECT IA.IncentiveAccountId AS Account_Id
				,ISNULL(SUM(CASE IAT.[Type]
							WHEN 'Debit'
								THEN (- 1 * (ISNULL(Ammount, 0)))
							ELSE ISNULL(info.Ammount, 0)
							END), 0) AS Balance
			FROM IncentiveAccount IA
			LEFT JOIN IncentiveAccountTransaction IAT ON IA.IncentiveAccountId = IAT.Account_Id
				AND IA.IncentiveAccountId = @pIndividualId
			LEFT JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = Info.IncentiveAccountTransactionInfoId
			WHERE IA.IncentiveAccountId = @pIndividualId
			GROUP BY IA.IncentiveAccountId
				--ORDER BY CreationTimeStamp DESC, GPSUpdateTimestamp DESC, Balance DESC
			) AS IAT ON IAT.Account_Id = IA.IncentiveAccountId
		WHERE IOwnner.GUIDReference = @pIndividualId

		SELECT ISNULL(CS.Id, @NullGUID) AS Id
			,ISNULL(CA.Value, 0) AS AmountValue
			,ISNULL(CA.GUIDReference, @NullGUID) AS Ammount
			,CASE 
				WHEN ISNULL(CA.Value, 0) = 0
					THEN 0
				ELSE 1
				END AS Subscribed
		FROM Individual I
		LEFT JOIN CharitySubscription CS ON CS.Id = I.CharitySubscription_Id
		LEFT JOIN CharityAmount CA ON CA.GUIDReference = CS.Amount_Id
		WHERE I.GUIDReference = @pIndividualId

		SELECT (
				SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'addDebitsBtn', 0)
				) AS IsGiftRedemptionFeatureEnabled

		SELECT (
				SELECT dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'CharitySubscription.Subscribed', 0)
				) AS IsCharityFeatureEnabled

		SELECT GUIDReference AS Id
			,Value
		FROM CharityAmount
		WHERE Country_Id = @pCountryId
			AND Subscription = 'Subscribed'

		SELECT @IsAccountLinkVisible = dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'AccountLinkVisible', 0)

		IF (
				@IsAccountLinkVisible = 1
				AND @LinkAccountUserAccess = 1
				)
			SELECT CONVERT(BIT,1) AS IsAccountLinkVisible
		ELSE
			SELECT CONVERT(BIT,0) AS IsAccountLinkVisible
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE();

		RAISERROR (
				@ErrorMessage
				,-- Message text.
				@ErrorSeverity
				,-- Severity.
				@ErrorState -- State.
				);
	END CATCH
END
