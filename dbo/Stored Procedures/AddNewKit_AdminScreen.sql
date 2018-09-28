Create PROCEDURE [dbo].[AddNewKit_AdminScreen] (
	@kitName NVARCHAR(100)
	,@countryCode NVARCHAR(2)
	)
AS

BEGIN
	DECLARE @guid UNIQUEIDENTIFIER
	DECLARE @existedkitname VARCHAR(max)

	SET @guid = NEWID()

	DECLARE @countryId UNIQUEIDENTIFIER

	SET @countryId = (
			SELECT CountryId
			FROM [dbo].[Country]
			WHERE CountryISO2A = @countryCode
			)

	DECLARE @GetDate DATETIME

	SET @GetDate = (
			SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @countryId)
			)

	DECLARE @pKitname NVARCHAR(100)

	SET @pKitname = LTRIM(@kitName)
	SET @pKitname = RTRIM(@pKitname)

	DECLARE @code INT

	 SET @code = (SELECT (MAX(Code) + 1) FROM [dbo].[StockKit]
                         WHERE Country_Id = @countryId)

		 set @code =  ISNULL(@code , 1)

	INSERT INTO [dbo].[StockKit] (
		GUIDReference
		,Code
		,NAME
		,Country_Id
		,CreationTimeStamp
		)
	VALUES (
		@guid
		,@code
		,@pKitname
		,@countryId
		,@GetDate
		);
END




