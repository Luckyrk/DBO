Create procedure UpdateIndividualId_AdminScreen(
@UpdatedIndividualId NVARCHAR(30),
@ExistingIndividualId NVARCHAR(30),
@CountryCode NVARCHAR(30)
)
As
Begin
BEGIN TRY 
Declare @err bit
set @err =0

 


DECLARE @Configuration_Id uniqueidentifier
SET @Configuration_Id=(select Configuration_Id from Country where CountryISO2A=@CountryCode)

DECLARE @GroupBusinessIdDigits INT
SET @GroupBusinessIdDigits=(select top 1 GroupBusinessIdDigits from CountryConfiguration where Id=@Configuration_Id)


	Declare @GroupBusinessIdDigitsError VARCHAR(max)='Your Sequence is not correct Please enter your ('+ (SELECT CONVERT(varchar(10), @GroupBusinessIdDigits)) +') digit SequenceID followed by hypen(-) and then 2 digits' 
	Declare @NoGroupBusinessIdDigitsError BIT

if(@err=0)
begin try
     declare @IndividualIdincomingGroupBusinessIdDigits INT
	 Declare @UpdateRightPart int
     set @IndividualIdincomingGroupBusinessIdDigits=len(left (@UpdatedIndividualId, CHARINDEX('-',@UpdatedIndividualId)-1))
	 set @UpdateRightPart=( LEN(RIGHT(@UpdatedIndividualId,LEN (@UpdatedIndividualId) - CHARINDEX('-',@UpdatedIndividualId))))
	 
	 declare @left varchar(max)
	 declare @right varchar(max)
	 set @left=(left (@UpdatedIndividualId, CHARINDEX('-',@UpdatedIndividualId)-1))
	


	 Declare @GroupIdincomingGroupBusinessIdDigits int
	 Declare @ExistingRightPart int
	 SET @GroupIdincomingGroupBusinessIdDigits=len(left (@ExistingIndividualId, CHARINDEX('-',@ExistingIndividualId)-1))
	 set @ExistingRightPart=(LEN(RIGHT(@ExistingIndividualId,LEN (@ExistingIndividualId) - CHARINDEX('-',@ExistingIndividualId))))

	  SET @right=(left (@ExistingIndividualId, CHARINDEX('-',@ExistingIndividualId)-1))
	 


END try

begin catch
set @err=1
RAISERROR (

				@GroupBusinessIdDigitsError

				,16

				,1

				);
end catch
	
	Declare @LeftRightNoMatchError varchar(max) ='Your sequence id should match'

	if(@right=@left)
	begin
	set @err=0
	End
	Else
	Begin
	set @err=1
	RAISERROR (

				@LeftRightNoMatchError

				,16

				,1

				);
				
	END


If(@err=0)
IF((@GroupBusinessIdDigits=@IndividualIdincomingGroupBusinessIdDigits) and (@GroupBusinessIdDigits=@GroupIdincomingGroupBusinessIdDigits) and (@UpdateRightPart=2) and (@ExistingRightPart=2))
BEGIN
SET @NoGroupBusinessIdDigitsError =1
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


Declare @CountryID uniqueidentifier
Declare @NoExistingIdError BIT
Declare @NoUpdateIdError  BIT
Declare @NOBusinessIdError BIT
SET @CountryID =
(select Top 1 C.CountryId from country C
inner join Individual I on I.CountryId=C.CountryId
where C.CountryISO2A=@CountryCode)

DECLARE @GetDate DATETIME
 SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryID))


	DECLARE @IndividualIdNotExistingError VARCHAR(max) = 'This '+@ExistingIndividualId+' individualId Does not Exists Please Give Correct IndividualID'  

IF(@err=0)
IF  EXISTS (select * from Individual I where I.IndividualId=@ExistingIndividualId and I.CountryId=@CountryID )

	BEGIN
	SET @NoExistingIdError=1
	END

ELSE
BEGIN
set @err=1
	RAISERROR (

				@IndividualIdNotExistingError

				,16

				,1

				);
END

	DECLARE @IndividualIdError VARCHAR(max) = 'This '+@UpdatedIndividualId+' IndivdiualId Already Exists Please Give Unique IndivdiualId '  

IF(@err=0)
IF EXISTS (select * from Individual I where I.IndividualId=@UpdatedIndividualId and I.CountryId=@CountryID )

	BEGIN
	SET @err=1
		RAISERROR (

				@IndividualIdError

				,16

				,1

				);

	END

ELSE
BEGIN
SET @NoUpdateIdError=1
END

	DECLARE @BussinessId VARCHAR(max) = 'This '+@UpdatedIndividualId+' BussinessId Already Exists Please Give Unique BussinessId '  
IF(@err=0)
IF EXISTS (select * from DiaryEntry where BusinessId=@UpdatedIndividualId and Country_Id=@CountryID)
BEGIN
SET @err=1
RAISERROR (

				@BussinessId

				,16

				,1

				);
END
ELSE
BEGIN 
SET @NOBusinessIdError=1
END

BEGIN TRANSACTION
	BEGIN TRY
	if(@err=0)
if((@NoExistingIdError=1) and (@NoGroupBusinessIdDigitsError =1) and(@NoUpdateIdError=1) and (@NOBusinessIdError=1))
BEGIN

Update Individual 
SET    IndividualId=@UpdatedIndividualId ,GPSUpdateTimestamp=@GetDate
where  IndividualId=@ExistingIndividualId and CountryId=@CountryID


Update DiaryEntry
SET  BusinessId=@UpdatedIndividualId,GPSUpdateTimestamp=@GetDate
WHERE  BusinessId=@ExistingIndividualId and Country_Id=@CountryID


END

	COMMIT TRANSACTION

	END TRY
		BEGIN CATCH

		DECLARE @error NVARCHAR(max) = (

				SELECT ERROR_MESSAGE()

				)



		RAISERROR (

				@error

				,16

				,1

				)



		ROLLBACK TRANSACTION

	END CATCH
	


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








