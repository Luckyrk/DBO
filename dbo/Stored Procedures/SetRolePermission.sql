CREATE PROCEDURE SetRolePermission @Permissions RolePermissionAccess READONLY, @CountryId UNIQUEIDENTIFIER
AS
BEGIN
BEGIN TRY 
	DECLARE @AreaId INT -- NEW ID
	DECLARE @ContextId INT -- Country Context
	DECLARE @Path NVARCHAR(255)
	DECLARE @Name NVARCHAR(255)
	DECLARE @AreaType INT
	DECLARE @CountryCode NVARCHAR(10)

	SET @CountryCode = (SELECT CountryISO2A FROM Country WHERE CountryId=@CountryId)

	IF NOT EXISTS (SELECT 1 FROM ACCESSCONTEXT AC WHERE  AC.Description LIKE '%' + @CountryCode)
	BEGIN
	INSERT INTO ACCESSCONTEXT VALUES ('Country' + @CountryCode ,'AdminUser',GETDATE(),GETDATE())
	END	

	SELECT @ContextId = AccessContextId FROM Country CN
	JOIN AccessContext AC ON AC.Description LIKE '%' + CN.CountryISO2A
	WHERE CN.CountryId = @CountryId

	DECLARE access_cursor CURSOR FOR 
	SELECT P.Name,P.[Path], P.Area
	FROM @Permissions P

	OPEN access_cursor
	FETCH NEXT FROM access_cursor INTO @Name,@Path, @AreaType

	WHILE @@FETCH_STATUS = 0  
    BEGIN  
		INSERT INTO RestrictedAccessArea(RestrictedAccessAreaTypeId, RestrictedAccessAreaSubTypeId, ActiveFrom,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
		SELECT DISTINCT 1, @AreaType, GETDATE(),'AdminUser',GETDATE(),GETDATE()
		WHERE NOT EXISTS(SELECT * FROM RestrictedAccessSystemArea WHERE [Path] = @Path)

		SELECT @AreaId = @@IDENTITY

		INSERT INTO RestrictedAccessSystemArea(RestrictedAccessAreaId, [Path], Name,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
		SELECT @AreaId, @Path, @Name,'AdminUser',GETDATE(),GETDATE()
		WHERE NOT EXISTS(SELECT * FROM RestrictedAccessSystemArea WHERE [Path] = @Path)

        FETCH NEXT FROM access_cursor INTO @Name,@Path, @AreaType
    END

    CLOSE access_cursor  
    DEALLOCATE access_cursor
	
	UPDATE AR SET AR.IsPermissionGranted = P.GrantAccess
	FROM @Permissions P
	JOIN SystemRoleType R ON R.[Description] = P.[Role]
	JOIN RestrictedAccessSystemArea RASA ON RASA.[Path] = P.[Path]
	JOIN AccessRights AR ON AR.AccessContextId = @ContextId AND AR.RestrictedAccessAreaId = RASA.RestrictedAccessAreaId AND AR.SystemRoleTypeId = R.SystemRoleTypeId
	
	INSERT INTO AccessRights(AccessContextId, RestrictedAccessAreaId, SystemOperationId, SystemRoleTypeId, IsPermissionGranted, ActiveFrom,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
	SELECT @ContextId, RASA.RestrictedAccessAreaId, P.SystemOperation, R.SystemRoleTypeId, P.GrantAccess, GETDATE(),'AdminUser',GETDATE(),GETDATE()
	FROM @Permissions P
	JOIN SystemRoleType R ON R.[Description] = P.[Role]
	JOIN RestrictedAccessSystemArea RASA ON RASA.[Path] = P.[Path]
	WHERE NOT EXISTS (SELECT * FROM AccessRights WHERE AccessContextId = @ContextId AND RestrictedAccessAreaId = RASA.RestrictedAccessAreaId AND SystemRoleTypeId = R.SystemRoleTypeId)

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