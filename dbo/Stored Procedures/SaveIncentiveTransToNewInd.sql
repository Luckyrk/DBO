CREATE PROCEDURE [dbo].[SaveIncentiveTransToNewInd] (
	@pMainContactCode INT
	,@pIndividualId UNIQUEIDENTIFIER
	,@pPanelistId UNIQUEIDENTIFIER
	)
AS
BEGIN
BEGIN TRY
	DECLARE @pCandidateId UNIQUEIDENTIFIER
		DECLARE @GetDate DATETIME
		DECLARE @CountryId UNIQUEIDENTIFIER
		SET @CountryId=(select CountryId from individual where GUIDReference=@pIndividualId )
		SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryId))


	SELECT @pCandidateId = DA.Candidate_Id
	FROM DynamicRole D
	INNER JOIN DynamicRoleAssignment DA ON D.DynamicRoleId = DA.DynamicRole_id
	INNER JOIN Panelist P ON p.GUIDReference = DA.Panelist_Id
	WHERE p.GUIDReference = @pPanelistId
		AND D.Code = @pMainContactCode

	

	IF (@pCandidateId IS NOT NULL)
	BEGIN
		
		UPDATE IncentiveAccount
		SET Beneficiary_Id = NULL
			,[Type] = 'OwnAccount'
			,GPSUpdateTimestamp=@GetDate
		WHERE IncentiveAccountId = @pIndividualId

		UPDATE IncentiveAccount
		SET Beneficiary_Id = @pIndividualId
			,[Type] = 'RelatedAccount'
			,GPSUpdateTimestamp=@GetDate
		WHERE IncentiveAccountId = @pCandidateId;

		;WITH T (IncentiveAccTranId)
		AS (
			SELECT IncentiveAccountTransactionId
			FROM IncentiveAccountTransaction
			WHERE Account_Id = @pCandidateId
			)
		UPDATE IncentiveAccountTransaction
		SET Account_Id = @pIndividualId, GPSUpdateTimestamp = @GetDate
		WHERE IncentiveAccountTransactionId IN (
				SELECT IncentiveAccTranId
				FROM T
				)

		SELECT 1
	END

	SELECT 0
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