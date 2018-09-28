CREATE PROCEDURE [dbo].[ProductReasonsManagmentGridSave_AdminScreen] (
	@pAnswerCode NVARCHAR(20)
	,@pAnswerDescription NVARCHAR(400)
	,@pCallAgain BIT
	,@pGPSUser NVARCHAR(max)
	,@pcountrycode VARCHAR(10)
	,@pIsUpdate INT
	)
AS
BEGIN
	BEGIN TRY
		DECLARE @CountryId UNIQUEIDENTIFIER
			,@getdate DATETIME
			,@CodeExistsError VARCHAR(2000)
			,@castAnswerCode NVARCHAR(100)
			,@existProductCodeId UNIQUEIDENTIFIER

		SET @CountryId = (
				SELECT CountryId
				FROM Country
				WHERE CountryISO2A = @pcountrycode
				)
		SET @getdate = (
				SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(), @CountryId)
				)

		IF @pIsUpdate = 0
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM DemandedProductCategoryAnswer
					WHERE AnswerCatCode = @pAnswerCode and country_id = @CountryId
					)
			BEGIN
				PRINT 'Insert'

				SELECT @pAnswerCode

				SET @castAnswerCode = CONVERT(NVARCHAR(100), @pAnswerCode)

				SELECT @castAnswerCode

				SET @CodeExistsError = 'Given Code ' + @castAnswerCode + ' ' + 'Already Exists Please Give New Code'

				RAISERROR (
						@CodeExistsError
						,16
						,1
						);

				RETURN;
			END

			INSERT INTO DemandedProductCategoryAnswer (
				Id
				,AnswerCatCode
				,AnswerCatDescription
				,CallAgain
				,GPSUser
				,GPSUpdateTimeStamp
				,CreationTimeStamp
				,Country_Id
				,IsFreeTextRequired
				)
			VALUES (
				NEWID()
				,@pAnswerCode
				,@pAnswerDescription
				,@pCallAgain
				,@pGPSUser
				,@getdate
				,@getdate
				,@CountryId
				,0
				)
		END
		ELSE IF @pIsUpdate = 1
		BEGIN
			SET @existProductCodeId = (
					SELECT TOP 1 Id
					FROM DemandedProductCategoryAnswer
					WHERE AnswercatCode = @pAnswerCode and country_id = @CountryId
					)

			UPDATE DemandedProductCategoryAnswer
			SET AnswerCatDescription = @pAnswerDescription
				,callAgain = @pCallAgain
				,GPSUser = @pGPSUser
				,GPSUpdateTimestamp = @getdate
				,CreationTimeStamp = @getdate
				,IsFreeTextRequired = 0
			WHERE Id = (
					SELECT TOP 1 Id
					FROM DemandedProductCategoryAnswer
					WHERE AnswerCatCode = @pAnswerCode and country_id = @CountryId
					)
		END
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
