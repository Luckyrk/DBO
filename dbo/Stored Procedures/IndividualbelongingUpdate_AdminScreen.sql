CREATE PROCEDURE IndividualbelongingUpdate_AdminScreen (
	@pExistingIndividual UNIQUEIDENTIFIER
	,@pBelongingType NVARCHAR(max)
	,@pBelongingCode INT
	,@pNewIndividual UNIQUEIDENTIFIER
	,@pCountryIso2A NVARCHAR(max)
	)
AS
BEGIN
BEGIN TRY
	DECLARE @CountryId UNIQUEIDENTIFIER

	SET @CountryID = (
			SELECT TOP 1 countryID
			FROM country
			WHERE CountryISO2A = @pCountryIso2A
			)

	DECLARE @GetDate DATETIME

	SET @GetDate = (
			SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @CountryId)
			)
 IF (@pExistingIndividual = @pNewIndividual)
BEGIN
	UPDATE b
	SET CandidateId = @pNewIndividual
		,GPSUpdateTimestamp = @GetDate
	FROM Individual i
	INNER JOIN Belonging b ON i.GUIDReference = b.CandidateId
	INNER JOIN BelongingType bt ON bt.Id = b.TypeId
	INNER JOIN Country c ON c.CountryId = i.countryId
	WHERE CandidateId = @pExistingIndividual
		AND belongingcode = @pBelongingCode
		AND dbo.GetTranslationValue(bt.Translation_Id, 2057) = @pBelongingType
		AND i.countryid = @CountryID
END
ELSE
BEGIN
	IF EXISTS (
			SELECT *
			FROM Individual i
			INNER JOIN Belonging b ON i.GUIDReference = b.CandidateId
			INNER JOIN BelongingType bt ON bt.Id = b.TypeId
			INNER JOIN Country c ON c.CountryId = i.countryId
			WHERE CandidateId = @pNewIndividual
				AND dbo.GetTranslationValue(bt.Translation_Id, 2057) = @pBelongingType
				AND i.countryid = @CountryID
			) 

			BEGIN
			Declare  @MaxBelongingCodeCount int 
			set @MaxBelongingCodeCount =(select max(b.BelongingCode  ) as MaxBelongingCodeCount FROM Individual i INNER JOIN Belonging b ON i.GUIDReference = b.CandidateId
			INNER JOIN BelongingType bt ON bt.Id = b.TypeId
			INNER JOIN Country c ON c.CountryId = i.countryId
			WHERE CandidateId = @pNewIndividual
				AND dbo.GetTranslationValue(bt.Translation_Id, 2057) = @pBelongingType
				AND i.countryid = @CountryID)


			UPDATE b
	SET CandidateId = @pNewIndividual
		,GPSUpdateTimestamp = @GetDate
		,belongingcode =@MaxBelongingCodeCount+1
	FROM Individual i
	INNER JOIN Belonging b ON i.GUIDReference = b.CandidateId
	INNER JOIN BelongingType bt ON bt.Id = b.TypeId
	INNER JOIN Country c ON c.CountryId = i.countryId
	WHERE CandidateId = @pExistingIndividual
		AND belongingcode = @pBelongingCode
		AND dbo.GetTranslationValue(bt.Translation_Id, 2057) = @pBelongingType
		AND i.countryid = @CountryID
			END

			ELSE
			BEGIN
				UPDATE b
	SET CandidateId = @pNewIndividual
		,GPSUpdateTimestamp = @GetDate
		,belongingcode =1
	FROM Individual i
	INNER JOIN Belonging b ON i.GUIDReference = b.CandidateId
	INNER JOIN BelongingType bt ON bt.Id = b.TypeId
	INNER JOIN Country c ON c.CountryId = i.countryId
	WHERE CandidateId = @pExistingIndividual
		AND belongingcode = @pBelongingCode
		AND dbo.GetTranslationValue(bt.Translation_Id, 2057) = @pBelongingType
		AND i.countryid = @CountryID
			END


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

