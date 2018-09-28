/*##########################################################################
-- Name				: IsFieldRequiredOrFieldVisible
-- Date             : 2014-11-05
-- Author           : Teena Areti
-- Purpose          : To identify supplied field is required or can be visible
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : SP
-- PARAM Definitions
			@pCountryId UNIQUEIDENTIFIER  -- guid of country
			,@pKey NVARCHAR(100)		-- Key that needs to be validated
			,@pRequiredOrVisible BIT    -- Bit to identify whether key si required or not and can be visible or not
											1  is to check the functionality for required
											0 is to check for visibility
##########################################################################
-- version  user                  date        change 
-- 1.0  Teena Areti				2014-11-05   Initial
-- 1.1 Teena Areti			    2014-12-09	 Handled null data condition

##########################################################################*/
CREATE FUNCTION [dbo].[IsFieldRequiredOrFieldVisible] (
	@pCountryId UNIQUEIDENTIFIER
	,@pKey NVARCHAR(100)
	,@pRequiredOrVisible BIT
	)
RETURNS BIT
AS
BEGIN
	DECLARE @IsFieldRequired BIT=0

	IF @pCountryId IS NOT NULL
	BEGIN
		IF @pRequiredOrVisible = 1
			SET @IsFieldRequired = (
					SELECT FldConfig.[Required]
					FROM FieldConfiguration FldConfig
					INNER JOIN CountryConfiguration CountCounfig ON FldConfig.CountryConfiguration_Id = CountCounfig.Id
					INNER JOIN Country C ON C.Configuration_Id = CountCounfig.Id
					WHERE C.CountryId = @pCountryId
						AND FldConfig.[Key] = @pKey
					)
		ELSE IF @pRequiredOrVisible = 0
			SET @IsFieldRequired = (
					SELECT FldConfig.Visible
					FROM FieldConfiguration FldConfig
					INNER JOIN CountryConfiguration CountCounfig ON FldConfig.CountryConfiguration_Id = CountCounfig.Id
					INNER JOIN Country C ON C.Configuration_Id = CountCounfig.Id
					WHERE C.CountryId = @pCountryId
						AND FldConfig.[Key] = @pKey
					)
	END
	ELSE
		SET @IsFieldRequired = 0

	RETURN ISNULL(@IsFieldRequired, 0);   
END