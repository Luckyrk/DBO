CREATE PROCEDURE [dbo].[UpdateShopFlags] (
@Flag_attribut int,
@Flag_detail VARCHAR(100),
@GPSUser VARCHAR(100),
@CountryId UNIQUEIDENTIFIER,
@CreationDate DATETIME = NULL,
@FlagsEntryRecords dbo.FlagsEntryRecords READONLY
)
AS
BEGIN

	BEGIN TRY

--BEGIN TRAN
--print '1'
	UPDATE FRS.[SHOPS_ATTRIBUTE] SET flag_detail=@Flag_detail,GPSUpdateTimestamp=@CreationDate,GPSUser=@GPSUser
	WHERE flag_attribut=@Flag_attribut
	AND flag_detail<>@Flag_detail
	--print '2'
	UPDATE T1 SET T1.flag_detail=T2.flag_detail,T1.GPSUser=@GPSUser,T1.GPSUpdateTimestamp=@CreationDate
	FROM [FRS].[FLAGS_DETAIL] T1
	INNER JOIN @FlagsEntryRecords T2 ON T2.flag_valeur=T1.flag_valeur AND T1.flag_attribut=@Flag_attribut
	WHERE EXISTS (
	SELECT 1 FROM [FRS].[FLAGS_DETAIL] T1
	INNER JOIN @FlagsEntryRecords T2 ON T2.flag_valeur=T1.flag_valeur
		AND T2.flag_detail<>T1.flag_detail
	WHERE T1.flag_attribut=@Flag_attribut
	) 
	--print '3'
	DELETE FROM T3
	FROM [FRS].[FLAGS_SHOP] T3 
	LEFT JOIN @FlagsEntryRecords T2 ON T2.flag_valeur=T3.flag_valeur AND T3.flag_attribut=@Flag_attribut
	WHERE T2.flag_valeur IS NULL
	AND  T3.flag_attribut=@Flag_attribut
	--print '4'
	DELETE FROM T1
	FROM [FRS].[FLAGS_DETAIL] T1
	LEFT JOIN @FlagsEntryRecords T2 ON T2.flag_valeur=T1.flag_valeur AND T1.flag_attribut=@Flag_attribut
	WHERE T2.flag_valeur IS NULL
	AND  T1.flag_attribut=@Flag_attribut
	--print '5'
	INSERT INTO [FRS].[FLAGS_DETAIL] (flag_attribut,flag_valeur,flag_detail,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
	SELECT @Flag_attribut,flag_valeur,flag_detail,@GPSUser,@CreationDate,@CreationDate 
	FROM 
	@FlagsEntryRecords T1
		WHERE NOT EXISTS (
	SELECT 1 FROM  [FRS].[FLAGS_DETAIL]  T2 WHERE T2.flag_valeur=T1.flag_valeur	ANd T2.flag_attribut=@Flag_attribut
	--WHERE T2.flag_attribut IS NULL
	) 

	--COMMIT TRAN

	END TRY

	BEGIN CATCH
	--print '6'
		--ROLLBACK TRANSACTION
		SELECT ERROR_MESSAGE()
		--ROLLBACK TRAN
	END CATCH
END