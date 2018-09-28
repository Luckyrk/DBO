
Create PROCEDURE IsUserAuthorizeAdminScreen_AdminScreen (
	@pusername NVARCHAR(Max)
	,@pcountryCode NVARCHAR(MAX)
	)
AS
BEGIN
BEGIN TRY 
if exists(select 1 from identityuser where username =@pusername)
BEGIN
declare @pcountryid uniqueidentifier=(select top 1 CountryId from Country where CountryISO2A=@pcountrycode)
Declare @id  uniqueidentifier =( select ID from identityuser where username =@pusername )
IF EXISTS (
		SELECT 1
		FROM IdentityUser id
		INNER JOIN SystemUserRole sr ON sr.IdentityUserId = id.Id
		INNER JOIN SystemRoleType st ON st.SystemRoleTypeId = sr.SystemRoleTypeId
		INNER JOIN Country c ON c.CountryId = sr.CountryId
		WHERE id.id = @id
			AND st.[Description] = 'AdminScreenUser'
			AND c.CountryISO2A = @pcountryCode
			AND @pcountryCode IS NOT NULL
		)
	SELECT 1
	ELSE IF (@pcountryCode IS NULL)
BEGIN
	IF EXISTS (
			SELECT 1
			FROM IdentityUser id
			INNER JOIN SystemUserRole sr ON sr.IdentityUserId = id.Id
			INNER JOIN SystemRoleType st ON st.SystemRoleTypeId = sr.SystemRoleTypeId
			INNER JOIN Country c ON c.CountryId = sr.CountryId
			WHERE id.id = @id
				AND st.[Description] = 'AdminScreenUser'
			)
		SELECT 1
	ELSE
		SELECT 0
END
else
select 0
END
ELSE 
BEGIN
select 0
END
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