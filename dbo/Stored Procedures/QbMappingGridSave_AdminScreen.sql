Go
create procedure [dbo].[QbMappingGridSave_AdminScreen] (
@pcountrycode NVARCHAR(10),
@pOldSourcefield NVARCHAR(100),
@pNewSourcefield NVARCHAR(100),
@pDescription NVARCHAR(100),
@plocaldescription NVARCHAR(100),
@pGPSEntity NVARCHAR(200),
@pAttributekey NVARCHAR(100),
@pDatatype NVARCHAR(100),
@pisdemographic int,
@pDemographicType NVARCHAR(100),
@pCalculation NVARCHAR(100),
@pPanel NVARCHAR(100),
@pperson INT,
@oldAttributekey Nvarchar(100),
@isNewRecord int,
@oldPerson int
)
AS
BEGIN 
BEGIN TRY 
/*---------------------------------------------------------------------------------------------------
Created By: Lakhil
Date      : 10/10/2016
Purpose: To show Demographics Mapping for Quest back fields.

Updates:
Saikiran [9-Nov-2016] -  Updated code for duplicate check.Added Validations.


Execute:
EXEC [DemoMappingGridSave_AdminScreen] 
---------------------------------------------------------------------------------------------------- */

IF ltrim(@pGPSEntity) = ''  SET @pGPSEntity = NULL
IF ltrim(@pDescription) = ''  SET @pDescription = NULL
IF ltrim(@pDatatype) = ''  SET @pDatatype = NULL
IF ltrim(@pDemographicType) = ''  SET @pDemographicType = NULL
IF ltrim(@pPanel)='' SET @pPanel=NULL
IF ltrim(@pisdemographic)='' SET @pPanel=NULL


 Declare @err bit
 Declare @err1 bit
 Declare @SourceFieldExistsError VARCHAR(max)='Given SourceField  ('+ (SELECT CONVERT(varchar(max), @pNewSourcefield)) +') Already Exists With Same Person Please Enter New SourceField OR New Person '
 Declare @AttributeExistsError VARCHAR(max)='Given Attributekey  ('+ (SELECT CONVERT(varchar(max), @pAttributekey)) +') Already Exists With Same Person Please Enter New Attributekey OR New Person '
 set @err  =0
 set @err1 =0
 

if((@pOldSourcefield=@pNewSourcefield) and (@oldAttributekey=@pAttributekey) and (@isNewRecord=0) and (@oldPerson=@pperson))
BEGIN
       set @err =1
	   Select 
@pDescription =   ISNULL(@pDescription, A.[Key] )
,@pDatatype = ISNULL(@pDatatype, A.[Type])
,@pGPSEntity  = ISNULL(@pGPSEntity, S.[Type] + ' Demographic')
,@pDemographicType  = ISNULL(@pDemographicType, S.[Type])
from Attribute A
join AttributeScope S ON S.GUIDReference = A.[Scope_Id]
join Country C ON C.CountryId = A.Country_Id
Where CountryISO2A = @pcountrycode
and  A.[Key] = @pAttributekey

	 
	 UPDATE [QBI].[demographicmappingtable] SET SourceField=@pNewSourcefield, [Description]=@pDescription,localdescription

       =@plocaldescription,GPSEntity=@pGPSEntity,AttributeKey=@pAttributekey,DataType=@pDatatype,IsDemographic=@pisdemographic,

	   DemographicType=@pDemographicType,Calculation=@pCalculation,Panel=@pPanel,person=@pperson

	   WHERE SourceField=@pOldSourcefield  and AttributeKey = @oldAttributekey and person = @oldPerson
END
ELSE
BEGIN
	IF ((@isNewRecord = 0))
	BEGIN
		IF ((@pOldSourcefield <> @pNewSourcefield) or (@pperson <> @oldPerson) )
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM [QBI].[DemographicMappingTable]
					WHERE SourceField = @pNewSourcefield and person = @pperson
					)
			BEGIN
				SET @err = 1

				RAISERROR (
						@SourceFieldExistsError
						,16
						,1
						);
			END
			ELSE
			BEGIN
				IF (@err = 0)
					SET @err = 0
			END
		END
	END

	IF ((@isNewRecord = 0))
	BEGIN
		IF ((@oldAttributekey <> @pAttributekey) or (@pperson <> @oldPerson))
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM [QBI].[DemographicMappingTable]
					WHERE AttributeKey = @pAttributekey and person = @pperson
					)
			BEGIN
				SET @err = 1

				RAISERROR (
						@AttributeExistsError
						,16
						,1
						);
			END
			ELSE
			BEGIN
				IF (@err = 0)
					SET @err = 0
			END
		END
	END
END


IF ((@isNewRecord = 1)AND (@err = 0))
BEGIN
	IF EXISTS (
			SELECT 1
			FROM [QBI].[DemographicMappingTable]
			WHERE SourceField = @pNewSourcefield and person = @pperson
			)
	BEGIN
		SET @err1 = 1

		RAISERROR (
				@SourceFieldExistsError
				,16
				,1
				);
	END
	ELSE
	BEGIN
		IF (@err1 = 0)
			SET @err1 = 0
	END

	IF EXISTS (
			SELECT 1
			FROM [QBI].[DemographicMappingTable]
			WHERE AttributeKey = @pAttributekey  and person = @pperson
			)
	BEGIN
		SET @err1 = 1

		RAISERROR (
				@AttributeExistsError
				,16
				,1
				);
	END
	ELSE
	BEGIN
		IF (@err1 = 0)
			SET @err1 = 0
	END

	IF (@err1 = 0)
	BEGIN
Select 
@pDescription =   ISNULL(@pDescription, A.[Key] )
,@pDatatype = ISNULL(@pDatatype, A.[Type])
,@pGPSEntity  = ISNULL(@pGPSEntity, S.[Type] + ' Demographic')
,@pDemographicType  = ISNULL(@pDemographicType, S.[Type])
from Attribute A
join AttributeScope S ON S.GUIDReference = A.[Scope_Id]
join Country C ON C.CountryId = A.Country_Id
Where CountryISO2A = @pcountrycode
and  A.[Key] = @pAttributekey

				INSERT INTO [QBI].[demographicmappingtable] VALUES (@pNewSourcefield,@pDescription,@pGPSEntity,@pAttributekey,

		                          @pDatatype,ISNULL(@pisdemographic,1),@pDemographicType,@pCalculation,ISNULL(@pPanel,'ALL'),@plocaldescription,@pperson , @pcountrycode)
	END
END

IF (
		(@err = 0)
		AND (@isNewRecord = 0)
		)
BEGIN

Select 
@pDescription =   ISNULL(@pDescription, A.[Key] )
,@pDatatype = ISNULL(@pDatatype, A.[Type])
,@pGPSEntity  = ISNULL(@pGPSEntity, S.[Type] + ' Demographic')
,@pDemographicType  = ISNULL(@pDemographicType, S.[Type])
from Attribute A
join AttributeScope S ON S.GUIDReference = A.[Scope_Id]
join Country C ON C.CountryId = A.Country_Id
Where CountryISO2A = @pcountrycode
and  A.[Key] = @pAttributekey

	 UPDATE [QBI].[demographicmappingtable] SET SourceField=@pNewSourcefield, [Description]=@pDescription,localdescription

       =@plocaldescription,GPSEntity=@pGPSEntity,AttributeKey=@pAttributekey,DataType=@pDatatype,IsDemographic=@pisdemographic,

	   DemographicType=@pDemographicType,Calculation=@pCalculation,Panel=@pPanel,person=@pperson

	   WHERE SourceField=@pOldSourcefield  and AttributeKey = @oldAttributekey and person = @oldPerson
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