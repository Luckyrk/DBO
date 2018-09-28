Create Procedure UpdateGroupId_AdminScreen(

@UpdatedIndividualId nvarchar(30),
@ExistingIndividualId nvarchar(30),
@CountryCode Nvarchar(30)
)
As
Begin
BEGIN TRY 
Declare @NoError BIT
Declare @Err BIT
     SET @Err=0


DECLARE @Configuration_Id uniqueidentifier

SET @Configuration_Id=(select Configuration_Id from Country where CountryISO2A=@CountryCode)




DECLARE @GroupBusinessIdDigits INT
SET @GroupBusinessIdDigits=(select top 1 GroupBusinessIdDigits from CountryConfiguration where Id=@Configuration_Id)



	

	Declare @GroupBusinessIdDigitsError VARCHAR(max)='Your Sequence is not correct Please enter your ('+ (SELECT CONVERT(varchar(10), @GroupBusinessIdDigits)) +') digit SequenceID' 
	Declare @NoGroupBusinessIdDigitsError BIT
if(@Err=0)
IF((@GroupBusinessIdDigits=LEN(@UpdatedIndividualId)) and (@GroupBusinessIdDigits=LEN(@ExistingIndividualId)) )
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



DECLARE @GroupIdLength INT
DECLARE @CountryID uniqueidentifier

     SET @CountryID=(select Top 1 CountryId from Country where CountryISO2A=@CountryCode)
			
			DECLARE @GetDate DATETIME
 SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryID))

			

	SET @GroupIdLength = (select CC.GroupBusinessIdDigits from CountryConfiguration CC
			inner join COUNTRY C ON C.Configuration_Id=CC.Id
			WHERE C.CountryId=@CountryID)
		

			

   DECLARE @IdExistsError VARCHAR(max) = 'This '+@ExistingIndividualId+' Sequence Does Not Exists Please Give New Sequence ' 
   if(@Err=0)
   IF EXISTS (Select * from Collective C  where C.Sequence=@ExistingIndividualId and CountryId=@CountryID)		
   BEGIN
   SET @NoError=1
   End

   Else 
   Begin
             SET @Err=1
   RAISERROR (
				@IdExistsError
				,16
				,1
				);
     
   End


   DECLARE @Sequence VARCHAR(max) = 'This '+@UpdatedIndividualId+' Sequence Already Exists Please Give Unique Sequence ' 
   if(@Err=0)
   IF EXISTS (Select * from Collective C  where C.Sequence=@UpdatedIndividualId and CountryId=@CountryID)		
   BEGIN
      SET @Err=1
   RAISERROR (
				@Sequence
				,16
				,1
				);
   End

   Else 
   Begin
  
    SET @NoError=1
   End






   

    BEGIN TRANSACTION
	BEGIN TRY
    IF((@Err=0) and (@NoGroupBusinessIdDigitsError=1))
    BEGIN

     -------
   
-----------------

update i set i.IndividualId= REPLACE((i.IndividualId),LEFT(i.IndividualId,@GroupIdLength),(RIGHT(1000000000000 +@UpdatedIndividualId,@GroupIdLength))),GPSUpdateTimestamp=@GetDate from CollectiveMembership cm
join Collective c on c.GUIDReference=cm.Group_Id
join Individual i on i.GUIDReference=cm.Individual_Id
join Country Cn on Cn.CountryId= i.CountryId
where c.Sequence=@ExistingIndividualId and Cn.CountryId=@CountryID

	
----------
   update d set d.BusinessId= REPLACE((d.BusinessId),LEFT(d.BusinessId,@GroupIdLength),(RIGHT(1000000000000 +@UpdatedIndividualId,@GroupIdLength))),GPSUpdateTimestamp=@GetDate
   from CollectiveMembership cm
join Collective c on c.GUIDReference=cm.Group_Id
join Individual i on i.GUIDReference=cm.Individual_Id
join DiaryEntry d on i.IndividualId=d.BusinessId
join Country Cn on Cn.CountryId= i.CountryId
where c.Sequence =@ExistingIndividualId and Cn.CountryId=@CountryID
-----
 Update Collective Set Sequence= @UpdatedIndividualId,GPSUpdateTimestamp=@GetDate where Sequence=@ExistingIndividualId and CountryId=@CountryID


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

   
   GO





