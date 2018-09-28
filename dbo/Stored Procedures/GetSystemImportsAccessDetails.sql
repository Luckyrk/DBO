CREATE PROCEDURE GetSystemImportsAccessDetails (
	@pUserName NVARCHAR(200)
	,@pCountryId UNIQUEIDENTIFIER
	)
AS
BEGIN
	BEGIN TRY
		DECLARE @COUNTRYCONTEXTNAME VARCHAR(100)

		SELECT @COUNTRYCONTEXTNAME = 'Country' + CountryISO2A
		FROM COUNTRY
		WHERE CountryId = @pCountryId

		SELECT DISTINCT T.KEYNAME AS NAME
		FROM IDENTITYUSER IU
		JOIN SYSTEMUSERROLE SUR ON IU.Id = SUR.IDENTITYUSERID
			AND SUR.CountryId = @pCountryId
		JOIN AccessRights AR ON SUR.SystemRoleTypeId = AR.SystemRoleTypeId
		INNER JOIN AccessContext AC ON AC.AccessContextId = AR.AccessContextId
		INNER JOIN RestrictedAccessArea RA ON RA.RestrictedAccessAreaId = AR.RestrictedAccessAreaId
		INNER JOIN RestrictedAccessAreaSubType RST ON RA.RestrictedAccessAreaTypeId = RST.RestrictedAccessAreaTypeId
		INNER JOIN RestrictedAccessSystemArea RASA ON RASA.RestrictedAccessAreaId = RA.RestrictedAccessAreaId
			AND RA.RestrictedAccessAreaSubTypeId = RST.RestrictedAccessAreaSubTypeId
		JOIN TRANSLATIONTERM TT ON RASA.NAME = TT.VALUE
			AND TT.CULTURECODE = 2057
		JOIN TRANSLATION T ON TT.TRANSLATION_ID = T.TRANSLATIONID
		WHERE IU.USERNAME = @pUserName
			AND RST.Description = 'System - Import'
			AND AR.IsPermissionGranted = 1
			AND AC.[Description] = @COUNTRYCONTEXTNAME
	END TRY

	BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE()
			,@ErrorSeverity = ERROR_SEVERITY()
			,@ErrorState = ERROR_STATE();

		RAISERROR (
				@ErrorMessage
				,-- Message text.
				@ErrorSeverity
				,-- Severity.
				@ErrorState -- State.
				);
	END CATCH
END
