create  PROCEDURE [dbo].[GetFindindividualTermKeyValues]
@pKeyName NVARCHAR(100),
@pCountryId uniqueidentifier
AS
BEGIN
BEGIN TRY 
declare @pKeyName1 NVARCHAR(100)
set @pKeyName1='CapturePlusURL'

	
	SELECT 
	CASE
	WHEN KV.Value IS NULL THEN KS.DefaultValue
	ELSE KV.Value
	END AS Value
	from KeyAppSetting KS
	LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id=@pCountryID
	WHERE KS.KeyName=@pKeyName
	
	
		SELECT 
	CASE
	WHEN KV.Value IS NULL THEN KS.DefaultValue
	ELSE KV.Value
	END AS Value
	from KeyAppSetting KS
	LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id=@pCountryID
	WHERE KS.KeyName=@pKeyName1
	
	DECLARE @isGroupListBehaviour BIT
	SELECT @isGroupListBehaviour = dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'IsGroupListBehaviour', 0)
	SELECT @isGroupListBehaviour

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