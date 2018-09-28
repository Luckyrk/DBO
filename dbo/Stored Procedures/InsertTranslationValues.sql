GO
/*##########################################################################
-- Name				: InsertTranslationValues
-- Date             : 2016-02-10
-- Author           : Jagadesh Dasari
-- Purpose          : To insert Translation values
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
		@Keyname NVARCHAR(100)
		@Value NVARCHAR(100)
		@CultureCode INT
		@GPSUser NVARCHAR(200)			
		@Discriminator NVARCHAR(100)

-- Sample Execution :
		EXECUTE InsertTranslationValues 'ReturnAsset', 'Return', 2057, 'KT\DasariJ', 'SystemTranslation'

##########################################################################
-- version		user							date        change 
-- 1.0			Jagadesh Dasari				  2016-02-10   Initial
##########################################################################*/

CREATE PROCEDURE InsertTranslationValues (
			@Keyname NVARCHAR(100)
			,@Value NVARCHAR(100)
			,@CultureCode INT
			,@GPSUser NVARCHAR(200)			
			,@Discriminator NVARCHAR(100)
			)
	AS
BEGIN
BEGIN TRY
	IF @Keyname IS NOT NULL AND @Value IS NOT NULL AND @CultureCode IS NOT NULL AND @CultureCode > 0 AND @GPSUser IS NOT NULL AND @Discriminator IS NOT NULL 
		BEGIN
			DECLARE @TranslationId UNIQUEIDENTIFIER
					,@TranslationTermId UNIQUEIDENTIFIER
					,@GetDate DATETIME = GETDATE()

			SET @TranslationId = (SELECT TranslationId FROM [dbo].[Translation] WHERE [KeyName] = @Keyname AND  Discriminator=@Discriminator )
			IF @TranslationId IS NULL
				BEGIN
					SET @TranslationId = NEWID()
					INSERT INTO [Translation] (TranslationId, KeyName, LastUpdateDate, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, Discriminator)
					VALUES(@TranslationId, @Keyname, @GetDate, @GPSUser, @GetDate, @GetDate, @Discriminator)
				END

			SET @TranslationTermId = (SELECT GUIDReference FROM [dbo].[TranslationTerm] WHERE Translation_Id = @TranslationId AND [CultureCode] = @CultureCode)

			IF @TranslationTermId IS NULL
				BEGIN  
					INSERT INTO TranslationTerm (GUIDReference, CultureCode, Value, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, Translation_Id)
						VALUES(NEWID(), @CultureCode, @Value, @GPSUser, @GetDate, @GetDate, @TranslationId)
				END
			ELSE
				BEGIN
					UPDATE TranslationTerm SET Value = @Value, GPSUser = @GPSUser, GPSUpdateTimestamp = @GetDate WHERE GUIDReference = @TranslationTermId
				END
			SELECT @TranslationId AS TranslationId
		END
	ELSE
		BEGIN
			SELECT 'Required Proper Input Values.'
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
GO