CREATE PROCEDURE LogMailMergeError (
	@pBusinessId VARCHAR(10)
	,@pCountryCode VARCHAR(5)
	,@pCommunicationType VARCHAR(10)
	,@pTemplateId BIGINT
	,@pUserName VARCHAR(50)
	,@pErrorMessage NVARCHAR(max)
	,@pTimestamp DATETIME
	)
AS
BEGIN
	INSERT INTO MailMergeError (
		BusinessId
		,CountryCode
		,TemplateId
		,GPSUser
		,CommunicationType
		,CreationTimeStamp
		,ErrorMessage
		)
	VALUES (
		@pBusinessId
		,@pCountryCode
		,@pTemplateId
		,@pUserName
		,@pCommunicationType
		,@pTimestamp
		,@pErrorMessage
		)
END