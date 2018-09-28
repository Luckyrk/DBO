CREATE PROCEDURE [dbo].[MessageCategoryGridSave_AdminScreen] (
	@pId INT
	,@pDescription VARCHAR(40)
	,@pcountrycode VARCHAR(10)
	,@pUserName VARCHAR(100)
	)
AS
BEGIN 
BEGIN TRY 


IF EXISTS( SELECT 1 FROM TemplateMessageCategories TMC JOIN COUNTRY C ON C.CountryId = TMC.CountryId
			WHERE C.CountryISO2A=@pcountrycode AND TemplateMessageCategoryId=@pId )
	BEGIN
		IF  EXISTS (SELECT 1 FROM TemplateMessageCategories TMC
							JOIN COUNTRY C ON C.CountryId = TMC.CountryId
							WHERE C.CountryISO2A=@pcountrycode AND [Description]= @pDescription AND  TemplateMessageCategoryID<>@pId )
		BEGIN
		SELECT 3	
		END
		ELSE
		BEGIN
		UPDATE TMC SET TMC.[Description]= @pDescription, TMC.GPSUser = @pUserName, GPSUpdateTimestamp = getdate()
			FROM TemplateMessageCategories TMC
			JOIN COUNTRY C ON C.CountryId = TMC.CountryId
			WHERE C.CountryISO2A=@pcountrycode
			AND  TMC.TemplateMessageCategoryId = @pId
			select 1
		END
		
	END
ELSE
	BEGIN
		DECLARE @CountryId UNIQUEIDENTIFIER
		SET @CountryId = (SELECT C.CountryId FROM COUNTRY C WHERE C.CountryISO2A=@pcountrycode)
		if not exists (SELECT 1 FROM TemplateMessageCategories TMC JOIN COUNTRY C ON C.CountryId = TMC.CountryId
							WHERE C.CountryISO2A=@pcountrycode AND  [Description]= @pDescription)
			BEGIN
			INSERT INTO TemplateMessageCategories VALUES (@pDescription,@CountryId,1,@pUserName,getdate(),getdate())
			select 2
			END
		else
		select 3
	END
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

