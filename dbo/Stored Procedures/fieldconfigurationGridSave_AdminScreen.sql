GO
CREATE PROCEDURE fieldconfigurationGridSave_AdminScreen
(
@pExistingKey VARCHAR(100),
@pKey VARCHAR(100),
@pExistingRequired BIT,
@pRequired BIT,
@pExistingVisible Bit,
@pVisible BIT,

@pCountrycode VARCHAR(500)
)
AS
BEGIN

BEGIN TRY

DECLARE @countryId UNIQUEIDENTIFIER
 SET @countryId=(SELECT Top 1 c.Configuration_id from FieldConfiguration Fc join country c ON c.Configuration_Id=Fc.CountryConfiguration_Id WHERE CountryISO2A=@pCountrycode )

IF  exists (SELECT 1  FROM FieldConfiguration WHERE [key]=@pExistingKey)

BEGIN

UPDATE FieldConfiguration SET [Key]=@pKey,[Required]=@pRequired,Visible=@pVisible WHERE [Key]=@pExistingKey and [Required]=@pExistingRequired and Visible=@pExistingVisible and CountryConfiguration_Id=@countryId
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
