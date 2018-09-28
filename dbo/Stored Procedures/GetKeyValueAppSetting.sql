/*************************************/
/*
-- Name				: GetKeyValueAppSetting
-- Date             : 2014-11-26
-- Author           : Ramana
-- Purpose          : Gets Value for the supplied Keyname
					  param definitions
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : Called from UI
-- PARAM Definitions
	@pKeyName NVARCHAR(100),
	@pCountryId uniqueidentifier
	
 EXEC GetKeyValueAppSetting 'OpenComBeforeAddingReason','17D348D8-A08D-CE7A-CB8C-08CF81794A86'

 ##########################################################################
-- ver  user        date			change 
-- 1.0  Ramana     2014-11-26		initial
##########################################################################*/
CREATE PROCEDURE [GetKeyValueAppSetting]
@pKeyName NVARCHAR(100),
@pCountryId uniqueidentifier
AS
BEGIN
BEGIN TRY 
IF @pCountryId = CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
BEGIN

	SELECT Distinct 
	CASE
	WHEN KV.Value IS NULL THEN KS.DefaultValue
	ELSE KV.Value
	END AS Value
	from KeyAppSetting KS
	LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference 
	WHERE KS.KeyName=@pKeyName
	
END
ELSE
BEGIN

	SELECT 
	CASE
	WHEN KV.Value IS NULL THEN KS.DefaultValue
	ELSE KV.Value
	END AS Value
	from KeyAppSetting KS
	LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id=@pCountryID
	WHERE KS.KeyName=@pKeyName

END
END TRY 
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH
END
