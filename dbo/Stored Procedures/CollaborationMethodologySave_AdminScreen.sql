
CREATE PROCEDURE [dbo].[CollaborationMethodologySave_AdminScreen]

(

@pcode VARCHAR(10),

@pValue VARCHAR(100),

@pGpsUser nvarchar(max),

@pcountrycode VARCHAR(10)

)
AS
 BEGIN
 BEGIN TRY 
 Declare @err bit
DECLARE @TranslationId UNIQUEIDENTIFIER
DECLARE @GetDate DATETIME
declare @pCountryId UNIQUEIDENTIFIER
Declare @CodeExistsError nvarchar(max) = 'Code ('+ (SELECT CONVERT(varchar(max), @pcode)) +') already exists please enter unique code'
Declare @CollaborationNameExistsError nvarchar(max) = 'Collaboration Name ('+ @pValue +') already exists please enter unique Name'
set @pCountryId = (select CountryId from Country where CountryISO2A=@pcountrycode)
SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryId))
set @err=0
 
 if exists (SELECT 1 FROM CollaborationMethodology WHERE code=@pcode and Country_Id =@pCountryId)
 BEGIN
 set @err=1
 RAISERROR (

				@CodeExistsError

				,16

				,1

				);
				END
 

 if exists (select 1 from translationterm where value = @pValue and CultureCode= 2057 )
 begin
	SET @TranslationId = (SELECT TOP 1 TranslationId FROM Translation t
				JOIN TranslationTerm tt ON t.TranslationId = tt.Translation_Id
				WHERE Discriminator='BusinessTranslation' and t.KeyName=@pValue 
					AND tt.CultureCode = 2057)   
 END
 
 

 IF(@err=0)
 BEGIN
	IF(@TranslationId = '00000000-0000-0000-0000-000000000000')
	BEGIN 
	   INSERT INTO Translation VALUES (NEWID(),@pValue,@GetDate,@pGpsUser,@GetDate,@GetDate,'BusinessTranslation')
	   SET @TranslationId = (SELECT TranslationId FROM Translation WHERE Discriminator='BusinessTranslation' and KeyName=@pValue )
	   INSERT INTO TranslationTerm VALUES (NEWID(),2057,@pValue,@pGpsUser,@GetDate,@GetDate,@TranslationId)
   END
   INSERT INTO CollaborationMethodology VALUES (NEWID(),@pcode,@pGpsUser,@GetDate,@GetDate,@TranslationId,@pCountryId)   
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

