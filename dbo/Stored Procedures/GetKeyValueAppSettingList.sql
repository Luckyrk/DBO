/*
************************************
-- Name				: GetKeyValueAppSettingList
-- Date             : 2014-12-22
-- Author           : Ramana
-- Purpose          : Gets Key,Value for the supplied CountryId
param definitions
	 PARAM Definitions
	@pCountryId UNIQUEIDENTIFIER

EXEC GetKeyValueAppSettingList '3558A18E-CCEB-CADC-CB8C-08CF81794A86' 
##########################################################################
-- ver  user        date			change 
-- 1.0  Ramana     2014-12-22		initial
########################################################################## 
*/

CREATE PROCEDURE GetKeyValueAppSettingList 
	@pCountryId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT KS.KeyName,CASE 
			WHEN KV.Value IS NULL
				THEN KS.DefaultValue
			ELSE KV.Value
			END AS Value
	FROM KeyAppSetting KS
	LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id = KS.GUIDReference
	AND KV.Country_Id = @pCountryId
	
END