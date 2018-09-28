CREATE procedure GetIndividualIds_AdminScreen
(
@psequence NVARCHAR(30)
,@pcountryISO2A NVARCHAR(30)

)
AS
BEGIN
BEGIN TRY 
Declare @err bit
set @err=0

DECLARE @Configuration_Id uniqueidentifier
SET @Configuration_Id=(select Configuration_Id from Country where CountryISO2A=@pcountryISO2A)

Declare @CountryId uniqueidentifier
Set @CountryId=(select CountryId from country where countryiso2a=@pcountryISO2A)

DECLARE @GroupBusinessIdDigits INT
SET @GroupBusinessIdDigits=(select top 1 GroupBusinessIdDigits from CountryConfiguration where Id=@Configuration_Id)

	Declare @GroupBusinessIdDigitsError VARCHAR(max)='Please enter your ('+ (SELECT CONVERT(varchar(10), @GroupBusinessIdDigits)) +') digit GroupId' 
	
if(@err=0)
IF(@GroupBusinessIdDigits=LEN(@psequence)) 
BEGIN
SET @err =0
END
else 
BEGIN
set @err=1
RAISERROR (
 
				@GroupBusinessIdDigitsError

				,16

				,1

				);
				END


Declare @individualIdError varchar(max) ='Given GroupId does not exists'
if(@err=0)
if exists (select top 1 individualid  from  individual  where individualid like + @psequence + '%' and CountryId=@CountryId)
begin
set @err=0
End
Else
Begin
set @err=1
RAISERROR (

				@individualIdError

				,16

				,1

				);
END





if(@err=0)
BEGIN
	select GuidReference,IndividualId from individual where individualid like + @psequence + '%' and CountryId=@CountryId
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
				GO
				

		
