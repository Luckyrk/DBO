CREATE PROCEDURE ValidateUserName_AdminScreen @pcountrycode VARCHAR(200)
	,@pusername NVARCHAR(max)
AS
BEGIN
	DECLARE @pCountryId UNIQUEIDENTIFIER
		,@perrormessage NVARCHAR(max)
		,@perrormessagenow NVARCHAR(max)
SET @pCountryId = (
		SELECT CountryId
		FROM Country
		WHERE CountryISO2A = @pcountrycode
		)

BEGIN
	IF (@pusername IN (
				SELECT UserName
				FROM identityuser a
				JOIN SystemUserRole b ON a.Id = b.IdentityUserId
				WHERE b.CountryId = @pCountryId
				)
			)
	BEGIN
		SELECT 1
	END
	ELSE
		SELECT 0
END END