/*##########################################################################
-- Name             : GetGroupSequence
-- Date             : 2015-01-27
-- Author           : Venkata Ramana
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure used to get the devices based on type
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        :
-- PARAM Definitions
		 @pSequence			 -- Collective sequence number
      	 @pCountryID	     -- Country Guid

-- Sample Execution :

	SELECT dbo.[GetGroupSequence] (1,'17D348D8-A08D-CE7A-CB8C-08CF81794A86')

##########################################################################
-- ver  user               date        change 
-- 1.0  Venkata Ramana     2015-01-27  New

##########################################################################*/


CREATE FUNCTION [dbo].[GetGroupSequence] (
	@pSequence INT,
	@pCountryId UNIQUEIDENTIFIER
	)
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @FormattedSequence NVARCHAR(100),@countryDigits int

	SELECT @countryDigits=cc.GroupBusinessIdDigits
	FROM CountryConfiguration CC
	INNER JOIN Country C ON C.Configuration_Id = CC.Id
	WHERE C.CountryId = @pCountryId

	if( len(@pSequence)> @countryDigits)
		SET @FormattedSequence = @pSequence
	else
		SELECT @FormattedSequence = CAST(REPLICATE('0', GroupBusinessIdDigits - LEN(@pSequence)) AS NVARCHAR) + CAST(@pSequence AS NVARCHAR)
		FROM CountryConfiguration CC
		INNER JOIN Country C ON C.Configuration_Id = CC.Id
		WHERE C.CountryId = @pCountryId

	RETURN @FormattedSequence
END