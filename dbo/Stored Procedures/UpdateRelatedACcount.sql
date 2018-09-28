
CREATE PROCEDURE [dbo].[UpdateRelatedACcount] @pBusinessId UNIQUEIDENTIFIER
       ,@pBeneficiaryId UNIQUEIDENTIFIER
       ,@LinkorUnlink NVARCHAR(256)
       ,@countryId UNIQUEIDENTIFIER
AS
BEGIN
BEGIN TRY 
DECLARE @TranGetDate DATETIME

	SET @TranGetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@countryId))
       DECLARE @AccountType VARCHAR(100)
	   declare @ownTranaction nvarchar(400)
       SET @AccountType = (
                     SELECT [Type]
                     FROM IncentiveAccount
                     WHERE IncentiveAccountId = @pBeneficiaryId
                     )

       --IF (@AccountType = 'OwnAccount')
       --BEGIN
              IF (@LinkorUnlink = 'Link')
              BEGIN
              if(@AccountType='OwnAccount')
              begin
                     DECLARE @balance INT
                     DECLARE @beneficiaryBalance INT
                     DECLARE @IncentivePointId UNIQUEIDENTIFIER

                     BEGIN TRANSACTION trans1

                     UPDATE Incentiveaccount
                     SET [Type] = 'RelatedAccount'
                           ,Beneficiary_Id = @pBeneficiaryId
                     WHERE IncentiveAccountId = @pBusinessId

                     SET @IncentivePointId = (
                                                     select IncentivePoint.GUIDReference from IncentivePoint inner join Translation t1 on  IncentivePoint.Description_Id = t1.TranslationId
                         WHERE t1.KeyName = 'LinkAccountTransfer'

                                  )

                           SET @balance = (
                                  SELECT ISNULL(SUM(CASE IAT.[Type]
                                                WHEN 'Debit'
                                                       THEN (- 1 * ((ISNULL(Ammount,0))))
                                                ELSE ISNULL(info.Ammount,0)
                                                END), 0) AS Balance

                     FROM IncentiveAccount IA
                     LEFT JOIN IncentiveAccountTransaction IAT ON IA.IncentiveAccountId = IAT.Account_Id AND IA.IncentiveAccountId =@pBusinessId
                     LEFT JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = Info.IncentiveAccountTransactionInfoId
                     WHERE IA.IncentiveAccountId =@pBusinessId
                     GROUP BY IA.IncentiveAccountId
                                  )

                                  
                                  
       if(@balance>0)          

	   begin
                     DECLARE @IncentiveAccountTransactionInfoId UNIQUEIDENTIFIER = NEWID()


                     INSERT INTO IncentiveAccountTransactionInfo (
                           IncentiveAccountTransactionInfoId
                           ,Ammount
                           ,GPSUser
                           ,GPSUpdateTimestamp
                           ,CreationTimeStamp
                           ,GiftPrice
                           ,Discriminator
                           ,Point_Id
                           ,RewardDeliveryType_Id
                           ,Country_Id
                           )
                     VALUES (
                           @IncentiveAccountTransactionInfoId
                           ,@balance
                           ,'GpsApp'
                           ,@TranGetDate
                           ,@TranGetDate
                           ,0
                           ,'TransactionInfo'
                           ,@IncentivePointId
                           ,NULL
                           ,@countryId
                           )

              

                     SET @beneficiaryBalance = (
                                  SELECT ISNULL(SUM(CASE IAT.[Type]

                                                WHEN 'Debit'

                                                       THEN (- 1 * ((ISNULL(Ammount,0))))

                                                ELSE ISNULL(info.Ammount,0)

                                                END), 0) AS Balance

                     FROM IncentiveAccount IA

                     LEFT JOIN IncentiveAccountTransaction IAT ON IA.IncentiveAccountId = IAT.Account_Id AND IA.IncentiveAccountId =@pBeneficiaryId

                     LEFT JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = Info.IncentiveAccountTransactionInfoId

                     WHERE IA.IncentiveAccountId =@pBeneficiaryId

                     GROUP BY IA.IncentiveAccountId
                                  )

                     IF @beneficiaryBalance IS NULL
                     BEGIN
                           SET @beneficiaryBalance = 0
                     END

                     SET @beneficiaryBalance = @balance + @beneficiaryBalance

                     DECLARE @transactionSourceKey UNIQUEIDENTIFIER = (
                                  SELECT TransactionSource.TransactionSourceId
                                  FROM Translation
                                  INNER JOIN TransactionSource ON Translation.TranslationId = TransactionSource.Description_Id
                                  WHERE Translation.KeyName = 'DefaultTransactionSourceKey'
                                         AND Country_Id = @countryId
                                  )
								  declare @AccountBusinessId nvarchar(50)
set @AccountBusinessId=(select IndividualId from Individual where GUIDReference =@pBusinessId)
set @ownTranaction='Points transfered from the '+@AccountBusinessId+' '+'Account'
                     INSERT INTO IncentiveAccountTransaction (
                           IncentiveAccountTransactionId
                           ,CreationDate
                           ,SynchronisationDate
                           ,TransactionDate
                           ,Comments
                           ,Balance
                           ,GPSUser
                           ,GPSUpdateTimestamp
                           ,CreationTimeStamp
                           ,PackageId
                           ,TransactionInfo_Id
                           ,TransactionSource_Id
                           ,Depositor_Id
                           ,Panel_Id
                           ,DeliveryAddress_Id
                           ,Account_Id
                           ,[Type]
                           ,Country_Id
                           ,GiftPrice
                           ,CostPrice
                           ,ProviderExtractionDate
                           )
                     VALUES (
                           NEWID()
                           ,@TranGetDate
                           ,@TranGetDate
                           ,@TranGetDate
                           ,@ownTranaction
                           ,@beneficiaryBalance
                           ,'GPSApp'
                           ,@TranGetDate
                           ,@TranGetDate
                           ,NULL
                           ,@IncentiveAccountTransactionInfoId
                           ,@transactionSourceKey
                           ,@pBusinessId
                           ,NULL
                           ,NULL
                           ,@pBeneficiaryId
                           ,'Credit'
                           ,@countryId
                           ,0
                           ,0
                           ,NULL
                           )


						  --Insert record for negative transfererd balance
declare @beneficiaryBusinessId nvarchar(50)
set @beneficiaryBusinessId=(select IndividualId from Individual where GUIDReference =@pBeneficiaryId)

   set    @IncentiveAccountTransactionInfoId  = NEWID()
                     INSERT INTO IncentiveAccountTransactionInfo (
                           IncentiveAccountTransactionInfoId
                           ,Ammount
                           ,GPSUser
                           ,GPSUpdateTimestamp
                           ,CreationTimeStamp
                           ,GiftPrice
                           ,Discriminator
                           ,Point_Id
                           ,RewardDeliveryType_Id
                           ,Country_Id
                           )
                     VALUES (
                          @IncentiveAccountTransactionInfoId
                           ,-@balance
                           ,'GpsApp'
                           ,@TranGetDate
                           ,@TranGetDate
                           ,0
                           ,'TransactionInfo'
                           ,@IncentivePointId
                           ,NULL
                           ,@countryId
                           )

set @ownTranaction='Points transfered to the '+@beneficiaryBusinessId+' '+'Account'
                     INSERT INTO IncentiveAccountTransaction (
                           IncentiveAccountTransactionId
                           ,CreationDate
                           ,SynchronisationDate
                           ,TransactionDate
                           ,Comments
                           ,Balance
                           ,GPSUser
                           ,GPSUpdateTimestamp
                           ,CreationTimeStamp
                           ,PackageId
                           ,TransactionInfo_Id
                           ,TransactionSource_Id
                           ,Depositor_Id
                           ,Panel_Id
                           ,DeliveryAddress_Id
                           ,Account_Id
                           ,[Type]
                           ,Country_Id
                           ,GiftPrice
                           ,CostPrice
                           ,ProviderExtractionDate
                           )
                     VALUES (
                           NEWID()
                           ,@TranGetDate
                           ,@TranGetDate
                           ,@TranGetDate
                           ,@ownTranaction
                           ,0
                           ,'GPSApp'
                           ,@TranGetDate
                           ,@TranGetDate
                           ,NULL
                           ,@IncentiveAccountTransactionInfoId
                           ,@transactionSourceKey
                           ,@pBusinessId
                           ,NULL
                           ,NULL
                           ,@pBusinessId
                           ,'Credit'
                           ,@countryId
                           ,0
                           ,0
                           ,NULL
                           )




                     --      UPDATE Info SET Ammount=0
                     --               FROM IncentiveAccount IA
                     --LEFT JOIN IncentiveAccountTransaction IAT ON IA.IncentiveAccountId = IAT.Account_Id AND IA.IncentiveAccountId =@pBusinessId
                     --LEFT JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = Info.IncentiveAccountTransactionInfoId
                     --WHERE IA.IncentiveAccountId =@pBusinessId

                     --      UPDATE IncentiveAccountTransaction SET Balance=0 WHERE Account_Id =@pBusinessId
end
                     COMMIT TRANSACTION tran1
                     --update IncentiveAccountTransactionInfo set Ammount=@balance where IncentiveAccountTransactionInfoId=@IncentiveAccountTransactionInfoId
                     select 1
              END
       
              else
              begin
              select 3
			  print 3
       end
       end
              ELSE
              BEGIN
                     UPDATE Incentiveaccount
                     SET [Type] = 'OwnAccount'
                           ,Beneficiary_Id = NULL
                     WHERE IncentiveAccountId = @pBusinessId

                     select 1
              END
       
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH
END

