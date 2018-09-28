CREATE PROCEDURE [dbo].[KitManagmentGridSave_AdminScreen]
(
@preasoncode INT,
--@pordercode INT,
@preasondescription NVARCHAR(100),
@pordertype NVARCHAR(100),
@pGPSUser nvarchar(max),
@pcountrycode VARCHAR(10),
@pIsUpdate INT 
)
AS
BEGIN
BEGIN TRY
DECLARE @OrderTypeId UNIQUEIDENTIFIER,@CountryId UNIQUEIDENTIFIER,@getdate DATETIME,@translationReasondescrptionID UNIQUEIDENTIFIER,@ReasonForOrderTypeID UNIQUEIDENTIFIER,@castReasonCode NVARCHAR(100)
,@CodeExistsError VARCHAR(2000)
	SET @CountryId = (SELECT CountryId FROM Country  WHERE CountryISO2A=@pcountrycode)
	SET @getdate = (select dbo.GetLocalDateTimeByCountryId(GETDATE(),@CountryId))
	SET @OrderTypeId = (SELECT TOP 1 ot.Id FROM OrderType ot
									JOIN TranslationTerm tt ON ot.Description_Id = tt.Translation_Id
									WHERE tt.Value = @pordertype AND tt.CultureCode = 2057 AND ot.Country_Id=@CountryId)

	SET @translationReasondescrptionID=(SELECT TOP 1 TranslationId  FROM Translation WHERE KeyName= 'kitmanagment_Reasondesc:'+ @preasondescription AND Discriminator='BusinessTranslation')
	IF(@translationReasondescrptionID IS NULL)
	BEGIN
		SET @translationReasondescrptionID = NEWID();
		INSERT INTO Translation VALUES (@translationReasondescrptionID,'kitmanagment_Reasondesc:'+ @preasondescription ,@getdate,@pGPSUser,@getdate,@getdate,'BusinessTranslation')	
		INSERT INTO TranslationTerm VALUES (NEWID(),2057,@preasondescription,@pGPSUser,@getdate,@getdate,@translationReasondescrptionID)			
	END
	IF @pIsUpdate = 0 
	BEGIN
		IF EXISTS(SELECT 1 FROM ReasonForOrderType WHERE Code=@preasoncode)
		BEGIN
		set @castReasonCode= CONVERT(nvarchar(100), @preasoncode)
		   set @CodeExistsError='Given Code '+@castReasonCode+' '+ 'Already Exists Please Give New Code'
		 RAISERROR (
			                   @CodeExistsError
				                 ,16
				                 ,1
				                );
								return;
		END
		INSERT INTO ReasonForOrderType  (Id,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Code,Description_Id,Country_Id,OrderType_Id) 
		VALUES (NEWID(),@pGPSUser,@getdate,@getdate,@preasoncode,@translationReasondescrptionID,@CountryId,@OrderTypeId)
	END
	ELSE IF @pIsUpdate = 1
	BEGIN
		 SET @ReasonForOrderTypeID=(SELECT TOP 1 Id FROM ReasonForOrderType WHERE Code=@preasoncode)
		 UPDATE ReasonForOrderType SET Description_Id=@translationReasondescrptionID,OrderType_Id=@OrderTypeId,GPSUser=@pGPSUser,GPSUpdateTimestamp=@getdate
		 WHERE Id=@ReasonForOrderTypeID
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


