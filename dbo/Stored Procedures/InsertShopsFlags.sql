
CREATE PROCEDURE [dbo].[InsertShopsFlags] (
@Flag_attribut int,
@Flag_detail VARCHAR(100),
	@GPSUser VARCHAR(100)
	,@CountryId UNIQUEIDENTIFIER
	,@CreationDate DATETIME = NULL
	,@FlagsEntryRecords dbo.FlagsEntryRecords READONLY
	)
AS
BEGIN
	BEGIN TRY

	insert into FRS.[SHOPS_ATTRIBUTE](flag_attribut,flag_detail,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) 
	values (@Flag_attribut,@Flag_detail,@GPSUser,@CreationDate,@CreationDate)

	INSERT INTO [FRS].[FLAGS_DETAIL] (flag_attribut,flag_valeur,flag_detail,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
	SELECT @Flag_attribut,flag_detail,flag_valeur,@GPSUser,@CreationDate,@CreationDate FROM @FlagsEntryRecords

	END TRY

	BEGIN CATCH
		--ROLLBACK TRANSACTION

		SELECT ERROR_MESSAGE()
	END CATCH

	
END

