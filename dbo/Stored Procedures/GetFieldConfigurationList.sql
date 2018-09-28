/*
************************************
-- Name				: GetFieldConfigurationList
-- Date             : 2014-12-22
-- Author           : Ramana
-- Purpose          : Gets Value for the supplied CountryId from FieldConfiguration
  --param definitions
	-- Usage            : 
	-- Impact           : 
	-- Required grants  : 
	-- Called by        : Called from UI
	-- PARAM Definitions
	--,@pCountryId UNIQUEIDENTIFIER

EXEC GetFieldConfigurationList '17D348D8-A08D-CE7A-CB8C-08CF81794A86' 
##########################################################################
-- ver  user        date			change 
-- 1.0  Ramana    2014-12-22		initial
########################################################################## 
*/
CREATE PROCEDURE GetFieldConfigurationList 
	@pCountryId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT FC.[Key] AS KeyName,FC.[Required],FC.Visible FROM 
	Country C
	JOIN FieldConfiguration FC ON C.Configuration_Id=FC.CountryConfiguration_Id
	WHERE C.CountryId=@pCountryId
END