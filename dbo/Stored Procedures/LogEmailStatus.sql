CREATE PROCEDURE [dbo].[LogEmailStatus] (
	 @pCountryCode VARCHAR(10), 
	 @pTimestamp DATETIME,
	 @pFrom VARCHAR(100), 
	 @pTo VARCHAR(100), 
	 @pSubject VARCHAR(400), 
	 @pMessage VARCHAR(400)
	)
AS
BEGIN

	INSERT INTO [EmailLog] ([Country_Id], [Timestamp], [From], [To], [Subject], [Message])
		SELECT CN.CountryId, @pTimestamp, @pFrom, @pTo, @pSubject, @pMessage
		FROM Country CN
		WHERE CN.CountryISO2A = @pCountryCode

END