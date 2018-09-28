CREATE PROCEDURE [dbo].[GetEmailReports] (@pMarkAsSent BIT = 0)
AS
BEGIN
BEGIN TRY 
	SELECT CN.CountryISO2A AS CountryCode, KV.Value AS DistributionAddresses
	FROM Country CN
	JOIN KeyAppSetting KA ON KA.KeyName = 'EmailReportAddresses'
	JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id = KA.GUIDReference AND KV.Country_Id = CN.CountryId

	SELECT CN.CountryISO2A AS CountryCode, [Timestamp], [From], [To], [Subject], [Message] 
	FROM EmailLog EL
	JOIN Country CN ON EL.Country_Id = CN.CountryId
	WHERE [Sent] = 0

	UPDATE EmailLog SET [Sent] = 1
	WHERE [Sent] = 0 AND @pMarkAsSent = 1
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