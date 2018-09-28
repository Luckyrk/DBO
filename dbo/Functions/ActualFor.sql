CREATE FUNCTION [dbo].[ActualFor] 
( @Tuple_Id UNIQUEIDENTIFIER, @StateSet_Id UNIQUEIDENTIFIER, @Panel_Id UNIQUEIDENTIFIER ) RETURNS INT AS 
BEGIN 

DECLARE @Actual INT 
DECLARE @CountOfNonGADemographics INT 

SET @CountOfNonGADemographics =  dbo.CountNonGADemographicsForTuple( @Tuple_Id)

IF @CountOfNonGADemographics > 0
	SET @Actual = dbo.ActualForNonGADemographic(@Tuple_Id,@StateSet_Id,@Panel_Id)
ELSE

	SET @Actual = dbo.ActualForGADemographic(@Tuple_Id,@StateSet_Id,@Panel_Id)

RETURN @Actual
END