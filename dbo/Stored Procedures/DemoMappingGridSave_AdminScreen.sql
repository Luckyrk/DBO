
Go
Create procedure [dbo].[DemoMappingGridSave_AdminScreen] (
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
@oldAttributekey Nvarchar(100),
@isNewRecord int
)
AS
BEGIN
/*---------------------------------------------------------------------------------------------------
Created By: Lakhil
Date      : 10/10/2016
Purpose: To show Demographics Mapping for Quest back fields.

Updates:
Saikiran [9-Nov-2016] -  Updated code for duplicate check.Added Validations.


Execute:
EXEC [DemoMappingGridSave_AdminScreen] 
---------------------------------------------------------------------------------------------------- */
BEGIN TRY
IF ltrim(@pGPSEntity) = ''  SET @pGPSEntity = NULL
IF ltrim(@pDescription) = ''  SET @pDescription = NULL
IF ltrim(@plocaldescription) = ''  SET @plocaldescription = NULL
IF ltrim(@pDatatype) = ''  SET @pDatatype = NULL
IF ltrim(@pDemographicType) = ''  SET @pDemographicType = NULL
IF ltrim(@pPanel)='' SET @pPanel=NULL
IF ltrim(@pisdemographic)='' SET @pPanel=NULL


 Declare @err bit
 Declare @err1 bit
 Declare @SourceFieldExistsError VARCHAR(max)='Given SourceField  ('+ (SELECT CONVERT(varchar(max), @pNewSourcefield)) +') Already Exists Please Give New SourceField'
 Declare @AttributeExistsError VARCHAR(max)='Given Attributekey  ('+ (SELECT CONVERT(varchar(max), @pAttributekey)) +') Already Exists Please Give New Attributekey'
 set @err  =0
 set @err1 =0
 

if((@pOldSourcefield=@pNewSourcefield) and (@oldAttributekey=@pAttributekey) and (@isNewRecord=0))
BEGIN
       set @err =1
	   Select 
@pDescription =   ISNULL(@pDescription, A.[Key] )
,@plocaldescription =  ISNULL(@plocaldescription, A.[Key] )
,@pDatatype = ISNULL(@pDatatype, A.[Type])
,@pGPSEntity  = ISNULL(@pGPSEntity, S.[Type] + ' Demographic')
,@pDemographicType  = ISNULL(@pDemographicType, S.[Type])
from Attribute A
join AttributeScope S ON S.GUIDReference = A.[Scope_Id]
join Country C ON C.CountryId = A.Country_Id
Where CountryISO2A = 'TW' -- @CountryISO2A
and  A.[Key] = @pAttributekey

	   update [QBI].[DemographicMappingTable] set SourceField=@pNewSourcefield,[Description]=@pDescription,localdescription
       =@plocaldescription,GPSEntity=@pGPSEntity,AttributeKey=@pAttributekey,DataType=@pDatatype,IsDemographic=@pisdemographic,
	   DemographicType=@pDemographicType,Calculation=@pCalculation,Panel=@pPanel
	   where SourceField=@pOldSourcefield  and AttributeKey =@oldAttributekey
END
ELSE
BEGIN
	IF ((@isNewRecord = 0))
	BEGIN
		IF ((@pOldSourcefield <> @pNewSourcefield))
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM [QBI].[DemographicMappingTable]
					WHERE SourceField = @pNewSourcefield
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
		IF ((@oldAttributekey <> @pAttributekey))
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM [QBI].[DemographicMappingTable]
					WHERE AttributeKey = @pAttributekey
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


IF (
		(@isNewRecord = 1)
		AND (@err = 0)
		)
BEGIN
	IF EXISTS (
			SELECT 1
			FROM [QBI].[DemographicMappingTable]
			WHERE SourceField = @pNewSourcefield
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
			WHERE AttributeKey = @pAttributekey
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
,@plocaldescription =  ISNULL(@plocaldescription, A.[Key] )
,@pDatatype = ISNULL(@pDatatype, A.[Type])
,@pGPSEntity  = ISNULL(@pGPSEntity, S.[Type] + ' Demographic')
,@pDemographicType  = ISNULL(@pDemographicType, S.[Type])
from Attribute A
join AttributeScope S ON S.GUIDReference = A.[Scope_Id]
join Country C ON C.CountryId = A.Country_Id
Where CountryISO2A = 'TW' -- @CountryISO2A
and  A.[Key] = @pAttributekey

		INSERT INTO [QBI].[DemographicMappingTable]
		VALUES (
			 @pNewSourcefield
			,@pDescription
			,@plocaldescription
			,@pGPSEntity
			,@pAttributekey
			,@pDatatype
			,ISNULL(@pisdemographic,1) 
			,@pDemographicType
			,@pCalculation
			,ISNULL(@pPanel,'ALL')
			)
	END
END

IF (
		(@err = 0)
		AND (@isNewRecord = 0)
		)
BEGIN

Select 
@pDescription =   ISNULL(@pDescription, A.[Key] )
,@plocaldescription =  ISNULL(@plocaldescription, A.[Key] )
,@pDatatype = ISNULL(@pDatatype, A.[Type])
,@pGPSEntity  = ISNULL(@pGPSEntity, S.[Type] + ' Demographic')
,@pDemographicType  = ISNULL(@pDemographicType, S.[Type])
from Attribute A
join AttributeScope S ON S.GUIDReference = A.[Scope_Id]
join Country C ON C.CountryId = A.Country_Id
Where CountryISO2A = 'TW' -- @CountryISO2A
and  A.[Key] = @pAttributekey

	UPDATE [QBI].[DemographicMappingTable]
	SET SourceField = @pNewSourcefield
		,[Description] = @pDescription
		,localdescription = @plocaldescription
		,GPSEntity = @pGPSEntity
		,AttributeKey = @pAttributekey
		,DataType = @pDatatype
		,IsDemographic = @pisdemographic
		,DemographicType = @pDemographicType
		,Calculation = @pCalculation
		,Panel = @pPanel
	WHERE SourceField = @pOldSourcefield
		AND AttributeKey = @oldAttributekey
END




--IF  EXISTS( SELECT 1 FROM [QBI].[DemographicMappingTable]  WHERE SourceField=@pOldSourcefield )
--    Begin
--	   update [QBI].[DemographicMappingTable] set SourceField=@pNewSourcefield,[Description]=@pDescription,localdescription
--       =@plocaldescription,GPSEntity=@pGPSEntity,AttributeKey=@pAttributekey,DataType=@pDatatype,IsDemographic=@pisdemographic,
--	   DemographicType=@pDemographicType,Calculation=@pCalculation,Panel=@pPanel
--	   where SourceField=@pOldSourcefield 
--	   	   END
--ELSE
--IF NOT EXISTS( SELECT 1 FROM [QBI].[DemographicMappingTable]  WHERE SourceField=@pNewSourcefield )
--       BEGIN
--	      Insert into [QBI].[DemographicMappingTable] values (@pOldSourcefield,@pDescription,@plocaldescription,@pGPSEntity,@pAttributekey,
--		                          @pDatatype,@pisdemographic,@pDemographicType,@pCalculation,@pPanel)

--		END
	
		
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