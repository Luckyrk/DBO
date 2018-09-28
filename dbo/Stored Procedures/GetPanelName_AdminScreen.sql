Create procedure GetPanelName_AdminScreen
(
@IndividualId NVARCHAR(30)
,@CountryISO2A NVARCHAR(30)

)
AS
BEGIN
BEGIN TRY 
Declare @err bit
set @err=0

DECLARE @Configuration_Id uniqueidentifier
SET @Configuration_Id=(select Configuration_Id from Country where CountryISO2A=@CountryISO2A)

DECLARE @GroupBusinessIdDigits INT
SET @GroupBusinessIdDigits=(select top 1 GroupBusinessIdDigits from CountryConfiguration where Id=@Configuration_Id)


Declare @GroupBusinessIdDigitsError VARCHAR(max)='Your Sequence is not correct Please enter your ('+ (SELECT CONVERT(varchar(10), @GroupBusinessIdDigits)) +') digit SequenceID followed by hypen(-) and then 2 digits' 

Declare @individualIdError varchar(max) ='Given IndividualId does not exists'

if exists (select top 1 *  from  individual where individualid = @IndividualId)
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
End

if(@err=0)
begin try

     declare @IndividualIdincomingGroupBusinessIdDigits INT
	 Declare @UpdateRightPart int
     set @IndividualIdincomingGroupBusinessIdDigits=LEN(left (@IndividualId, CHARINDEX('-',@IndividualId)-1))
	 set @UpdateRightPart=( LEN(RIGHT(@IndividualId,LEN (@IndividualId) - CHARINDEX('-',@IndividualId))))

END TRY

begin catch
set @err=1

RAISERROR (

				@GroupBusinessIdDigitsError

				,16

				,1

				);
END CATCH


If(@err=0)
IF((@GroupBusinessIdDigits=@IndividualIdincomingGroupBusinessIdDigits) and   (@UpdateRightPart=2)  )
BEGIN

print 1
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



if(@err=0)
BEGIN
	select  t.PanelCode,t.PanelName from (
	SELECT p.PanelCode,p.Name as PanelName
			FROM Panelist pl
			INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id
			INNER JOIN Panel p ON p.GUIDReference = pl.Panel_Id
			INNER JOIN Country c ON c.CountryId = p.Country_Id
			WHERE i.IndividualId = @IndividualId
				AND c.CountryISO2A = @CountryISO2A 
		union
	SELECT p.PanelCode,p.Name as PanelName
			FROM Panelist pl
			INNER JOIN collective ct ON ct.GUIDReference = pl.PanelMember_Id
			INNER JOIN Panel p ON p.GUIDReference = pl.Panel_Id
			INNER JOIN Country c ON c.CountryId = p.Country_Id
			join collectivemembership cm on cm.Group_Id=ct.guidreference
			join individual i on i.guidreference=cm.Individual_Id
			WHERE i.IndividualId = @IndividualId
				AND c.CountryISO2A = @CountryISO2A ) as t  order by t.PanelName
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
				
				
	