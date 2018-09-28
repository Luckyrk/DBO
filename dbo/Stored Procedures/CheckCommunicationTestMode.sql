CREATE PROCEDURE [dbo].[CheckCommunicationTestMode]
	@pType VARCHAR(50),
	@pValue VARCHAR(50),
	@pCountryCode VARCHAR(5)
AS
BEGIN
	BEGIN TRY
		DECLARE @WhitelistKeyName VARCHAR(100)
		IF (@pType = 'Phone')
			SET @WhitelistKeyName = 'WhiteListPhoneNumbers'
		ELSE IF (@pType = 'Email')
			SET @WhitelistKeyName = 'WhiteListEmailAddresses'

		SELECT COUNT(*)
		FROM  
		(
			SELECT CAST ('<M>' + REPLACE(ISNULL(cast(KVAS.Value as varchar(max)), KAS.DefaultValue), ';', '</M><M>') + '</M>' AS XML) AS Data
			FROM KeyAppSetting KAS
			JOIN Country CN ON CN.CountryISO2A = @pCountryCode
			LEFT JOIN KeyValueAppSetting KVAS ON KVAS.KeyAppSetting_Id = KAS.GUIDReference AND KVAS.Country_Id = CN.CountryId
			WHERE KAS.KeyName = @WhitelistKeyName
		) AS A CROSS APPLY Data.nodes ('/M') AS Split(a)
		JOIN Country CN ON CN.CountryISO2A = @pCountryCode
		LEFT JOIN KeyAppSetting KAS ON KAS.KeyName = 'IsTestModeOn'
		LEFT JOIN KeyValueAppSetting KVAS ON KVAS.KeyAppSetting_Id = KAS.GUIDReference AND KVAS.Country_Id = CN.CountryId
		WHERE Split.a.value('.', 'VARCHAR(100)') = @pValue OR ISNULL(KVAS.Value, KAS.DefaultValue) IN ('0', 'false')
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
