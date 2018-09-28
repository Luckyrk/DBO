CREATE PROCEDURE [dbo].[UpdateAccountTransactions] (@pIndividualId UNIQUEIDENTIFIER)
AS
BEGIN
BEGIN TRY 
       DECLARE @groupContactId UNIQUEIDENTIFIER
              ,@benificiaryId UNIQUEIDENTIFIER
			  ,@Balance INT


		DECLARE @GetDate DATETIME
		DECLARE @CountryId UNIQUEIDENTIFIER
		SET @CountryId=(select CountryId from individual where GUIDReference=@pIndividualId )
		SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryId))

	   

       SELECT @groupContactId = c.GroupContact_Id
       FROM CollectiveMembership cm
       INNER JOIN collective c ON cm.Group_Id = c.GUIDReference
       WHERE Individual_Id = @pIndividualId

       IF (@groupContactId = @pIndividualId)
       BEGIN
              SELECT @benificiaryId = Beneficiary_Id
              FROM IncentiveAccount
              WHERE IncentiveAccountId = @pIndividualId

              UPDATE IncentiveAccount
              SET Beneficiary_Id = NULL
                     ,[Type] = 'OwnAccount'
					 ,GPSUpdateTimestamp=@GetDate
              WHERE IncentiveAccountId = @pIndividualId

              IF (@benificiaryId IS NOT NULL)
              BEGIN
                     UPDATE IncentiveAccount
                     SET Beneficiary_Id = @pIndividualId
                           ,[Type] = 'RelatedAccount'
						   ,GPSUpdateTimestamp=@GetDate
                     WHERE IncentiveAccountId = @benificiaryId;;

                     WITH T (IncentiveAccTranId)
                     AS (
                           SELECT IncentiveAccountTransactionId
                           FROM IncentiveAccountTransaction
                           WHERE Account_Id = @benificiaryId
                           )
                     UPDATE IncentiveAccountTransaction
                     SET Account_Id = @pIndividualId,GPSUpdateTimestamp=@GetDate
                     WHERE IncentiveAccountTransactionId IN (
                                  SELECT IncentiveAccTranId
                                  FROM T
                                  )
								  SET @Balance=(SELECT
																		ISNULL(
																		SUM(CASE IAT.[Type]
																			WHEN 'Debit' THEN (- 1 * ((ISNULL(Ammount,0))))
																			ELSE ISNULL(info.Ammount,0)
																			END), 0)
																	FROM dbo.IncentiveAccount AS ia
																	INNER JOIN dbo.IncentiveAccountTransaction AS iat ON iat.Account_Id = ia.IncentiveAccountId
																		AND iat.Country_Id = ia.Country_Id
																	INNER JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = Info.IncentiveAccountTransactionInfoId
																	WHERE ia.IncentiveAccountId=@pIndividualId
																	)
                     ;WITH TEMP AS (
                           SELECT IATI.Ammount,IATI.IncentiveAccountTransactionInfoId,IncentiveAccountTransactionId
                           ,ROW_NUMBER() OVER(Partition BY Account_Id ORDER BY IAT.TransactionDate ASC,IAT.GPSUpdateTimestamp ASC,IAT.Balance ASC) AS Rno
                           ,Balance
                           --,* 
                           FROM
                                  IncentiveAccountTransaction IAT
                                  JOIN IncentiveAccountTransactionInfo IATI ON IAT.TransactionInfo_Id=IATI.IncentiveAccountTransactionInfoId
                           WHERE Account_Id = @pIndividualId
                           )
              
                     UPDATE IAT SET IAT.Balance=Tee.Cum,GPSUpdateTimestamp=@GetDate
                     FROM 
                      (
                           SELECT 
                           (SELECT  ISNULL(@Balance,0)+SUM(T2.Ammount) FROM Temp T2 WHERE T2.Rno<=T.Rno)   AS Cum
                           ,*     FROM TEMP T) AS Tee
                     JOIN IncentiveAccountTransaction IAT ON IAT.IncentiveAccountTransactionId=Tee.IncentiveAccountTransactionId

              END
       END
       ELSE
       BEGIN
              UPDATE IncentiveAccount
              SET Beneficiary_Id = @groupContactId
                     ,[Type] = 'RelatedAccount'
					 ,GPSUpdateTimestamp=@GetDate
              WHERE IncentiveAccountId = @pIndividualId;

              UPDATE IncentiveAccount
              SET Beneficiary_Id = NULL
                     ,[Type] = 'OwnAccount'
					 ,GPSUpdateTimestamp=@GetDate
              WHERE IncentiveAccountId = @groupContactId;

              WITH T (IncentiveAccTranId)
              AS (
                     SELECT IncentiveAccountTransactionId
                     FROM IncentiveAccountTransaction
                     WHERE Account_Id = @pIndividualId
                     )
              UPDATE IncentiveAccountTransaction
              SET Account_Id = @groupContactId
					,GPSUpdateTimestamp=@GetDate
              WHERE IncentiveAccountTransactionId IN (
                           SELECT IncentiveAccTranId
                           FROM T
                           )
				  SET @Balance=(SELECT
																		ISNULL(
																		SUM(CASE IAT.[Type]
																			WHEN 'Debit' THEN (- 1 * ((ISNULL(Ammount,0))))
																			ELSE ISNULL(info.Ammount,0)
																			END), 0)
																	FROM dbo.IncentiveAccount AS ia
																	INNER JOIN dbo.IncentiveAccountTransaction AS iat ON iat.Account_Id = ia.IncentiveAccountId
																		AND iat.Country_Id = ia.Country_Id
																	INNER JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = Info.IncentiveAccountTransactionInfoId
																	WHERE ia.IncentiveAccountId=@groupContactId
																	)


              ;WITH TEMP AS (
                           SELECT IATI.Ammount,IATI.IncentiveAccountTransactionInfoId,IncentiveAccountTransactionId
                           ,ROW_NUMBER() OVER(Partition BY Account_Id ORDER BY IAT.TransactionDate ASC,IAT.GPSUpdateTimestamp ASC,IAT.Balance ASC) AS Rno
                           ,Balance
                           --,* 
                           FROM
                                  IncentiveAccountTransaction IAT
                                  JOIN IncentiveAccountTransactionInfo IATI ON IAT.TransactionInfo_Id=IATI.IncentiveAccountTransactionInfoId
                           WHERE Account_Id = @groupContactId
                           )
              
                     UPDATE IAT SET IAT.Balance=Tee.Cum,GPSUpdateTimestamp=@GetDate
                     FROM 
                      (
                           SELECT 
                           (SELECT  ISNULL(@Balance,0)+SUM(T2.Ammount) FROM Temp T2 WHERE T2.Rno<=T.Rno)   AS Cum
                           ,*     FROM TEMP T) AS Tee
                     JOIN IncentiveAccountTransaction IAT ON IAT.IncentiveAccountTransactionId=Tee.IncentiveAccountTransactionId

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

