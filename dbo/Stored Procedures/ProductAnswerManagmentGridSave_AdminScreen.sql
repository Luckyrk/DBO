CREATE PROCEDURE [dbo].[ProductAnswerManagmentGridSave_AdminScreen] (
	@pproductCode NVARCHAR(20)
	,@pproductDescription NVARCHAR(400)
	,@pAnswerCode NVARCHAR(20)
	,@pAnswerDescription NVARCHAR(400)
	,@pCallAgain INT
	,@pAskAgain INT
	,@pGPSUser NVARCHAR(max)
	,@pcountrycode VARCHAR(10)
	,@pIsDelete INT
	,@pIsUpdate INT
	)
AS
BEGIN
	BEGIN TRY
		DECLARE @CountryId UNIQUEIDENTIFIER
			,@getdate DATETIME
			,@productCodeID UNIQUEIDENTIFIER
			,@answerCodeID UNIQUEIDENTIFIER
			,@CodeExistsError VARCHAR(2000)
			,@castProductCode NVARCHAR(100)
			,@castAnswerCode NVARCHAR(100)

		SET @CountryId = (
				SELECT CountryId
				FROM Country
				WHERE CountryISO2A = @pcountrycode
				)
		SET @getdate = (
				SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(), @CountryId)
				)
		SET @productCodeID = (
				SELECT TOP 1 ID
				FROM DemandedProductCategory
				WHERE ProductCode = @pproductCode AND Country_id = @CountryId
				)
		SET @answerCodeID = (
				SELECT ID
				FROM DemandedProductCategoryAnswer
				WHERE AnswerCatCode = @pAnswerCode AND Country_id = @CountryId
				)

		IF @pIsUpdate = 1
		BEGIN
			UPDATE DemandedproductCategoryAnswermapping
			SET DoNotCallAgain = @pCallAgain
				,AskAgainInterval = @pAskAgain
				,GPSUser = @pGPSUser
				,GPSUpdateTimestamp = @getdate
				,CreationTimeStamp = @getdate
			WHERE DemandedProductCategory_Id = @productCodeID
				AND DemandedProductCategoryAnswer_Id = @answerCodeID

		END

		IF (
				@pIsDelete = 0
				AND @pIsUpdate = 0
				)
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM DemandedproductCategoryAnswermapping
					WHERE DemandedProductCategory_Id = @productCodeID
						AND DemandedProductCategoryAnswer_Id = @answerCodeID
					)
			BEGIN
				SET @castProductCode = CONVERT(NVARCHAR(100), @pproductCode)
				SET @castAnswerCode = CONVERT(NVARCHAR(100), @pAnswerCode)
				SET @CodeExistsError = 'Given Product Code ' + @castProductCode + ' and Given Answer Code' + @castAnswerCode + ' ' + 'Already Exists Please Give New Code'

				RAISERROR (
						@CodeExistsError
						,16
						,1
						);

				RETURN;
			END

			INSERT INTO DemandedproductCategoryAnswermapping (
				Id
				,DemandedProductCategory_Id
				,DemandedProductCategoryAnswer_Id
				,DoNotCallAgain
				,AskAgainInterval
				,GPSUser
				,GPSUpdateTimeStamp
				,CreationTimeStamp
				)
			VALUES (
				NEWID()
				,@productCodeID
				,@answerCodeID
				,@pCallAgain
				,@pAskAgain
				,@pGPSUser
				,@getdate
				,@getdate
				)
		END
		ELSE IF @pIsDelete = 1
		BEGIN
			DELETE
			FROM DemandedproductCategoryAnswermapping
			WHERE DemandedProductCategory_Id = @productCodeID
				AND DemandedProductCategoryAnswer_Id = @answerCodeID
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
