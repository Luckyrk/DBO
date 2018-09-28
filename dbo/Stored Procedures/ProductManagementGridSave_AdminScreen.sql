CREATE PROCEDURE [dbo].[ProductManagmentGridSave_AdminScreen] (
	@pproductCode NVARCHAR(20)
	,@pproductDescription NVARCHAR(400)
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
			,@castProductCode NVARCHAR(100)
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
					FROM DemandedProductCategory
					WHERE ProductCode = @pproductCode AND Country_id = @CountryId
					)
			BEGIN
				PRINT 'Insert'

				SELECT @pproductCode

				SET @castProductCode = CONVERT(NVARCHAR(100), @pproductCode)

				SELECT @castProductCode

				SET @CodeExistsError = 'Given Code ' + @castProductCode + ' ' + 'Already Exists Please Give New Code'

				RAISERROR (
						@CodeExistsError
						,16
						,1
						);

				RETURN;
			END

			INSERT INTO DemandedProductCategory (
				Id
				,ProductCode
				,ProductDescription
				,GPSUser
				,GPSUpdateTimeStamp
				,CreationTimeStamp
				,Country_Id
				)
			VALUES (
				NEWID()
				,@pproductCode
				,@pproductDescription
				,@pGPSUser
				,@getdate
				,@getdate
				,@CountryId
				)
		END
		ELSE IF @pIsUpdate = 1
		BEGIN
			SET @existProductCodeId = (
					SELECT TOP 1 Id
					FROM DemandedProductCategory
					WHERE ProductCode = @pproductCode AND Country_id = @CountryId
					)

			UPDATE DemandedProductCategory
			SET ProductDescription = @pproductDescription
				,GPSUser = @pGPSUser
				,GPSUpdateTimestamp = @getdate
				,CreationTimeStamp = @getdate
			WHERE Id = (
					SELECT TOP 1 Id
					FROM DemandedProductCategory
					WHERE ProductCode = @pproductCode AND Country_id = @CountryId
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