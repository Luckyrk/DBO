CREATE PROCEDURE [dbo].[InsertGAMappings_AdminScreen] (
	@CountryCode VARCHAR(5)
	,@IdentityUser NVARCHAR(200)
	,@DiscriminatorType VARCHAR(50)
	,@Value UNIQUEIDENTIFIER
	,@FromDate DATETIME
	,@ToDate DATETIME
	,@User NVARCHAR(200)
	)
AS
BEGIN
	DECLARE @IDENTITYUSERGUID UNIQUEIDENTIFIER
	DECLARE @COUNTRYGUID UNIQUEIDENTIFIER
	DECLARE @GetDate DATETIME

	SELECT @COUNTRYGUID = CountryId
	FROM COUNTRY
	WHERE CountryISO2A = @CountryCode

	SET @GetDate = (
			SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @COUNTRYGUID)
			)

	SELECT @IDENTITYUSERGUID = IU.ID
	FROM IDENTITYUSER IU
	JOIN SYSTEMUSERROLE SUR ON IU.ID = SUR.IdentityUserId
	JOIN COUNTRY C ON SUR.CountryId = C.CountryId
	WHERE IU.UserName = @IdentityUser
		AND C.CountryISO2A = @CountryCode

	IF EXISTS (
			SELECT 1
			FROM SamplePointMapping
			WHERE IdentityUserID = @IDENTITYUSERGUID
				AND DiscriminatorType = @DiscriminatorType
				AND Value = @Value
			)
	BEGIN
		SELECT 'User Mapping Already Exist.' AS [RESULT]
	END
	ELSE IF (@IDENTITYUSERGUID IS NOT NULL)
	BEGIN
		INSERT INTO SamplePointMapping (
			GuidReference
			,IdentityUserID
			,DiscriminatorType
			,Value
			,FromDate
			,ToDate
			,CreatedBy
			,CreatedDate
			,ModifiedBy
			,ModifiedDate
			)
		SELECT NEWID()
			,@IDENTITYUSERGUID
			,@DiscriminatorType
			,@Value
			,@FromDate
			,@ToDate
			,@User
			,@GetDate
			,@User
			,@GetDate

		SELECT 'User Mapping Added Successfully.' AS [RESULT]
	END
	ELSE
		SELECT 'User Doesnot exist for this region.' AS [RESULT]
END
