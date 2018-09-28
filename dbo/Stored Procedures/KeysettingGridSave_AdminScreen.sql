
GO

CREATE PROCEDURE [dbo].[KeysettingGridSave_AdminScreen]
(
 @pKeyname VARCHAR(200),

 @pvalue VARCHAR(500),
 
 @pCountryCode VARCHAR(500)
)
AS
BEGIN
BEGIN TRY 
	DECLARE @countryid UNIQUEIDENTIFIER 
	SET @countryid = (SELECT TOP 1 countryid FROM Country WHERE CountryISO2A=@pCountryCode)
    IF EXISTS (SELECT GUIDReference FROM KeyAppSetting WHERE KeyName= @pKeyname)
  BEGIN
 
    DECLARE @id UNIQUEIDENTIFIER
    SET @id=(SELECT  GUIDReference FROM KeyAppSetting WHERE KeyName=@pKeyname)
 
    UPDATE KeyValueAppSetting SET  Value =@pvalue WHERE KeyAppSetting_Id=@id  
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
 
 Go

