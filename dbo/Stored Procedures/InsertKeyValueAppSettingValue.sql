
--EXEC InsertKeyValueAppSettingValue 'TW','QuestbackImportPath','D:\PBI\','D:\PBI\','KT\ChamchalaV','Questback Incentive Import'
CREATE Procedure InsertKeyValueAppSettingValue
@CountryCode VARCHAR(100),
@KeyName VARCHAR(1000),
@DefaultValue VARCHAR(1000),
@Value VARCHAR(1000),
@GpsUser VARCHAR(1000),
@Commnet VARCHAR(1000)
AS
BEGIN
BEGIN TRY
DECLARE @Getdate DATETIME=GETDATE(),@KeyAppSettingID UniqueIdentiFier=NEWID(),@CountryId UniqueIdentiFier
 IF NOT EXISTS(SELECT 1 FROM KeyAppSetting WHERE KeyName=@KeyName)
BEGIN
INSERT INTO KeyAppSetting
	SELECT @KeyAppSettingID,@KeyName,@Commnet,@DefaultValue,@GpsUser,@Getdate,@Getdate
END
ELSE
BEGIN 
 SET @KeyAppSettingID=(SELECT TOP 1 GUIDReference FROM KeyAppSetting WHERE KeyName=@KeyName)
END
SET @CountryId=(Select CountryId FROM Country WHERE CountryISO2A=@CountryCode)
IF(@CountryId IS NOT NULL)
BEGIN
	INSERT INTO KeyValueAppSetting
	SELECT NEWID(),@Value,@GpsUser,@Getdate,@Getdate,K.GUIDReference,@CountryId FROM 
	KeyAppSetting K 
	WHERE K.GUIDReference=@KeyAppSettingID AND
	NOT EXISTS(
	SELECT 1 FROM KeyValueAppSetting KV
	WHERE KV.Country_Id=@CountryId AND KV.KeyAppSetting_Id=@KeyAppSettingID
	)

	UPDATE K2 SET K2.Value=@Value
	FROM
	KeyAppSetting K1
	JOIN KeyValueAppSetting K2 ON K2.KeyAppSetting_Id=K1.GUIDReference
	WHERE K1.GUIDReference=@KeyAppSettingID AND K2.Country_Id=@CountryId

	SELECT K1.GUIDReference As  KeyAppSettingId,K2.GUIDReference AS KeyValueID,K1.KeyName,K1.DefaultValue,K2.Value,K1.Comment FROM 
	KeyAppSetting K1
	JOIN KeyValueAppSetting K2 ON K2.KeyAppSetting_Id=K1.GUIDReference
	WHERE K1.GUIDReference=@KeyAppSettingID AND K2.Country_Id=@CountryId
END
ELSE
BEGIN 
 SELECT 'Country not available'
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