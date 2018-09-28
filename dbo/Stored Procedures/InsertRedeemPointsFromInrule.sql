/*##########################################################################    

-- Name    : InsertRedeemPointsFromInrule.sql    

-- Date             : 2014-11-26

-- Author           : Kattamuri Sunil Kumar    

-- Company          : Cognizant Technology Solution    

-- Purpose          : Inserts data to Diary Entry Screen

-- Usage   : From the Inrule 

-- Impact   : Change on this procedure SaveDiaryEntry Rule gets impacted.    

-- Required grants  :     

-- Called by        : Inrule      

-- Params Defintion :    

   @pCountryCode VARCHAR(10) -- Countrycode has to pass

	,@pBusinessId VARCHAR(20) -- IndividualId has to pass

	,@pPanelCode INT -- Panelcode from panel table.



	,@pUser VARCHAR(500) -- User name



	,@pAddressType VARCHAR(100) -- Address type, HomeAddressType



	,@pPackageStatus VARCHAR(100) -- Packagesent by default from Inrule

	

	,@pPoints INT -- Points user is giving



	,@pRedemptionTypeCode INT -- Redemptontypecode

	 

	,@pRedemptionPointType INT -- redemptionpointypecode



	,@pDeliveryType INT -- deliverytype not required for taiwan

  

-- Sample Execution :

set statistics time on   

 

	set statistics time off  

##########################################################################    

-- ver  user			date        change     

-- 1.0  Kattamuri     2014-01-27   initial    

##########################################################################*/
CREATE PROCEDURE [dbo].[InsertRedeemPointsFromInrule] (
	@pCountryCode VARCHAR(10)
	,@pBusinessId VARCHAR(20)
	,@pPanelCode INT
	,@pUser VARCHAR(500) = 'InRule'
	,@pAddressType VARCHAR(100)
	,@pPackageStatus VARCHAR(100)
	,@pPoints INT
	,@pRedemptionTypeCode INT
	,@pRedemptionPointType INT
	,@pDeliveryType INT
	)
AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON
	SET XACT_ABORT ON
	DECLARE @GetDate DATETIME
	SET @GetDate = (select dbo.GetLocalDateTime(GETDATE(),@pCountryCode))
	BEGIN TRANSACTION

	BEGIN TRY
		DECLARE @rewardDeliveryTypeId UNIQUEIDENTIFIER
		DECLARE @pointId UNIQUEIDENTIFIER
		DECLARE @giftId FLOAT
		DECLARE @countryid UNIQUEIDENTIFIER
		DECLARE @panelid UNIQUEIDENTIFIER
		DECLARE @pointsexist INT = 0
		DECLARE @incentiveaccountinfoid UNIQUEIDENTIFIER = newid()
		DECLARE @incentiveaccounttransactionid UNIQUEIDENTIFIER = newid()
		DECLARE @currentDate DATETIME = @GetDate
		DECLARE @transactionsourceid UNIQUEIDENTIFIER
		DECLARE @individualid UNIQUEIDENTIFIER
		DECLARE @accountid UNIQUEIDENTIFIER
		DECLARE @addressid UNIQUEIDENTIFIER
		DECLARE @packageid UNIQUEIDENTIFIER = newid()
		DECLARE @statedefinitionid UNIQUEIDENTIFIER = newid()
		DECLARE @incentivepointnotexist VARCHAR(max)
		DECLARE @AddressnotExist VARCHAR(max)
		DECLARE @nooverride VARCHAR(max)
		DECLARE @pointoverride INT
		DECLARE @pointupdate BIT

		SET @incentivepointnotexist = 'Redemption Point doesnot exist : ' + convert(VARCHAR(10), @pRedemptionPointType)
		SET @AddressnotExist = 'Adress doesnot exist for the individual having BusinessId : ' + @pBusinessId + ' having Adress type : ' + @pAddressType
		SET @nooverride = 'Redemption Point is not overridable. Please check the number of points and update the points '
		SET @countryid = (
				SELECT TOP 1 CountryId
				FROM Country
				WHERE CountryISO2A = @pCountryCode
				)
		SET @panelid = (
				SELECT TOP 1 GUIDReference
				FROM Panel
				WHERE PanelCode = @pPanelCode
					AND Country_Id = @countryid
				)

		IF EXISTS (
				select 1 from IncentiveAccountTransaction iat
					join IncentiveAccount ia on ia.IncentiveAccountId=iat.Account_Id
					join Individual i on i.GUIDReference=ia.IncentiveAccountId
					AND i.IndividualId = @pBusinessId
				)
		BEGIN
			SET @pointsexist = (
					SELECT TOP 1 Balance
					from IncentiveAccountTransaction iat
					join IncentiveAccount ia on ia.IncentiveAccountId=iat.Account_Id
					join Individual i on i.GUIDReference=ia.IncentiveAccountId
					AND i.IndividualId = @pBusinessId
					)
		END

		IF EXISTS (
				SELECT 1
				FROM IncentivePoint ip
				INNER JOIN IncentivePointAccountEntryType iat ON iat.GUIDReference = ip.[Type_Id]
				INNER JOIN Country c ON c.CountryId = iat.Country_Id
				WHERE ip.[Type] = 'Reward'
					AND ip.RewardCode = @pRedemptionPointType
					AND c.CountryISO2A = @pCountryCode
					AND iat.Code = @pRedemptionTypeCode
				)
		BEGIN
			declare @tempincentivepoint table (
					Guidreference uniqueidentifier,
					GiftPrice float,
					Value int,
					HasUpdateableValue bit
					)

			insert into @tempincentivepoint
				SELECT TOP 1 ip.GUIDReference,ip.GiftPrice,ip.Value,ip.HasUpdateableValue
					FROM IncentivePoint ip
					INNER JOIN IncentivePointAccountEntryType iat ON iat.GUIDReference = ip.[Type_Id]
					INNER JOIN Country c ON c.CountryId = iat.Country_Id
					WHERE ip.[Type] = 'Reward'
						AND ip.RewardCode = @pRedemptionPointType
						AND c.CountryISO2A = @pCountryCode

			SET @pointId = (
					select top 1 Guidreference from @tempincentivepoint
					)
			SET @giftId = (
					select top 1 GiftPrice from @tempincentivepoint
					)
			SET @pointoverride = (
					SELECT TOP 1 Value from @tempincentivepoint
					)
			SET @pointupdate = (
					SELECT TOP 1 HasUpdateableValue from @tempincentivepoint
					
					)
		END
		ELSE
		BEGIN
			RAISERROR (
					@incentivepointnotexist
					,16
					,1
					);
		END

		IF (
				@pointupdate = 0
				AND @pointoverride <> @pPoints
				)
		BEGIN
			RAISERROR (
					@nooverride
					,16
					,1
					);
		END

		IF EXISTS (
				SELECT 1
				FROM OrderedContactMechanism ocm
				INNER JOIN Individual i ON i.GUIDReference = ocm.Candidate_Id
				INNER JOIN [Address] a ON a.GUIDReference = ocm.Address_Id
				INNER JOIN [AddressType] at ON a.Type_Id = at.Id
				INNER JOIN Translation t ON t.TranslationId = at.Description_Id
				WHERE i.IndividualId = @pBusinessId
					AND i.CountryId = @countryid
					AND t.KeyName = @pAddressType
				)
		BEGIN
			SET @addressid = (
					SELECT TOP 1 Address_Id
					FROM OrderedContactMechanism ocm
					INNER JOIN Individual i ON i.GUIDReference = ocm.Candidate_Id
					INNER JOIN [Address] a ON a.GUIDReference = ocm.Address_Id
					INNER JOIN [AddressType] at ON a.Type_Id = at.Id
					INNER JOIN Translation t ON t.TranslationId = at.Description_Id
					WHERE i.IndividualId = @pBusinessId
						AND i.CountryId = @countryid
						AND t.KeyName = @pAddressType
					ORDER BY ocm.[Order]
					)
		END
		ELSE
		BEGIN
			RAISERROR (
					@AddressnotExist
					,16
					,1
					);
		END

		IF EXISTS (
				SELECT 1
				FROM RewardDeliveryType
				)
		BEGIN
			SET @rewardDeliveryTypeId = (
					SELECT TOP 1 RewardDeliveryTypeId
					FROM RewardDeliveryType
					WHERE Code = @pDeliveryType
					)
		END

		INSERT INTO [dbo].[IncentiveAccountTransactionInfo] (
			[IncentiveAccountTransactionInfoId]
			,[Ammount]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[GiftPrice]
			,[Discriminator]
			,[Point_Id]
			,[RewardDeliveryType_Id]
			,[Country_Id]
			)
		VALUES (
			@incentiveaccountinfoid
			,@pPoints
			,@pUser
			,@currentDate
			,@currentDate
			,@giftId
			,'DebitTransactionInfo'
			,@pointId
			,@rewardDeliveryTypeId
			,@countryid
			)

		SET @individualid = (
				SELECT GUIDReference
				FROM Individual
				WHERE IndividualId = @pBusinessId
					AND CountryId = @countryid
				)

		IF (
				(
					SELECT TOP 1 Beneficiary_Id
					FROM IncentiveAccount
					WHERE IncentiveAccountId = @individualid
					) IS NULL
				)
			SET @accountid = (
					SELECT TOP 1 IncentiveAccountId
					FROM IncentiveAccount
					WHERE IncentiveAccountId = @individualid
					)
		ELSE
			SET @accountid = (
					SELECT TOP 1 Beneficiary_Id
					FROM IncentiveAccount
					WHERE IncentiveAccountId = @individualid
					)

		SET @transactionsourceid = (
				SELECT TOP 1 TransactionSourceId
				FROM TransactionSource
				WHERE Country_Id = @countryid
					AND IsDefault = 1
				)

		INSERT INTO [dbo].[IncentiveAccountTransaction] (
			[IncentiveAccountTransactionId]
			,[CreationDate]
			,[SynchronisationDate]
			,[TransactionDate]
			,[Comments]
			,[Balance]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[PackageId]
			,[TransactionInfo_Id]
			,[TransactionSource_Id]
			,[Depositor_Id]
			,[Panel_Id]
			,[DeliveryAddress_Id]
			,[Account_Id]
			,[Type]
			,[Country_Id]
			)
		VALUES (
			@incentiveaccounttransactionid
			,@currentDate
			,NULL
			,@currentDate
			,NULL
			,@pointsexist - @pPoints
			,@pUser
			,@currentDate
			,@currentDate
			,NULL
			,@incentiveaccountinfoid
			,@transactionsourceid
			,NULL
			,@panelid
			,@addressid
			,@accountid
			,'Debit'
			,@countryid
			)

		SET @statedefinitionid = (
				SELECT TOP 1 Id
				FROM StateDefinition
				WHERE Code = @pPackageStatus
					AND Country_Id = @countryid
				)

		INSERT INTO [dbo].[Package] (
			[GUIDReference]
			,[State_Id]
			,[Reward_Id]
			,[Debit_Id]
			,[Country_Id]
			,[DateSent]
			,[CreationTimeStamp]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			)
		VALUES (
			@packageid
			,@statedefinitionid
			,@pointId
			,@incentiveaccounttransactionid
			,@countryid
			,NULL
			,@currentDate
			,@pUser
			,@currentDate
			)

		UPDATE IncentiveAccountTransaction
		SET PackageId = @packageid,GPSUpdateTimestamp=@GetDate,GPSUser=@pUser
		WHERE IncentiveAccountTransactionId = @incentiveaccounttransactionid

		DECLARE @fromstateid UNIQUEIDENTIFIER = (
				SELECT TOP 1 Id
				FROM StateDefinition
				WHERE Code = 'PackagePreseted'
					AND Country_Id = @countryid
				)
		DECLARE @packagependingId UNIQUEIDENTIFIER = (
				SELECT TOP 1 Id
				FROM StateDefinition
				WHERE Code = 'PackagePending'
					AND Country_Id = @countryid
				)

		INSERT INTO [dbo].[StateDefinitionHistory] (
			[GUIDReference]
			,[GPSUser]
			,[CreationDate]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Comments]
			,[CollaborateInFuture]
			,[From_Id]
			,[To_Id]
			,[ReasonForchangeState_Id]
			,[Country_Id]
			,[Candidate_Id]
			,[GroupMembership_Id]
			,[Belonging_Id]
			,[Panelist_Id]
			,[Order_Id]
			,[Order_Country_Id]
			,[Package_Id]
			,[ImportFile_Id]
			,[ImportFilePendingRecord_Id]
			,[Action_Id]
			)
		VALUES (
			newid()
			,@pUser
			,@currentDate
			,@currentDate
			,@currentDate
			,NULL
			,0
			,@fromstateid
			,@packagependingId
			,NULL
			,@countryid
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,@packageid
			,NULL
			,NULL
			,NULL
			)

		INSERT INTO [dbo].[StateDefinitionHistory] (
			[GUIDReference]
			,[GPSUser]
			,[CreationDate]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Comments]
			,[CollaborateInFuture]
			,[From_Id]
			,[To_Id]
			,[ReasonForchangeState_Id]
			,[Country_Id]
			,[Candidate_Id]
			,[GroupMembership_Id]
			,[Belonging_Id]
			,[Panelist_Id]
			,[Order_Id]
			,[Order_Country_Id]
			,[Package_Id]
			,[ImportFile_Id]
			,[ImportFilePendingRecord_Id]
			,[Action_Id]
			)
		VALUES (
			newid()
			,@pUser
			,@currentDate
			,@currentDate
			,@currentDate
			,NULL
			,0
			,@packagependingId
			,@statedefinitionid
			,NULL
			,@countryid
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,@packageid
			,NULL
			,NULL
			,NULL
			)
	END TRY

	BEGIN CATCH
		DECLARE @ErrorNumber INT = ERROR_NUMBER();
		DECLARE @ErrorLine INT = ERROR_LINE();
		DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
		DECLARE @ErrorState INT = ERROR_STATE();

		RAISERROR (
				@ErrorMessage
				,@ErrorSeverity
				,@ErrorState
				);
	END CATCH


	COMMIT TRANSACTION

	SET XACT_ABORT OFF
	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessage1 NVARCHAR(4000);
		DECLARE @ErrorSeverity1 INT;
		DECLARE @ErrorState1 INT;

		SELECT @ErrorMessage1 = ERROR_MESSAGE(),
			   @ErrorSeverity1 = ERROR_SEVERITY(),
			   @ErrorState1 = ERROR_STATE();
	
		RAISERROR (@ErrorMessage1, -- Message text.
				   @ErrorSeverity1, -- Severity.
				   @ErrorState1 -- State.
				   );
END CATCH 
END
