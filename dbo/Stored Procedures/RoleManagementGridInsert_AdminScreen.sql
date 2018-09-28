CREATE PROCEDURE RoleManagementGridInsert_AdminScreen(
	@pDescription NVARCHAR(max),
	@pCountry NVARCHAR(max)
	)
AS
BEGIN
BEGIN TRY 

		IF  EXISTS (SELECT 1 FROM systemroletype
							WHERE  [Description]= @pDescription )
		BEGIN
		SELECT 2	
		END
		ELSE
		BEGIN

		DECLARE @SystemOperation INT 
		DECLARE @ContextId INT

		
		set @SystemOperation = (select SystemOperationId from SystemOperation where [Description]='create')

		Insert into SYSTEMROLETYPE values (@pDescription,'AdminUser',GETDATE(),GETDATE())

		IF EXISTS (SELECT  1 FROM Country CN
		JOIN AccessContext AC ON AC.Description LIKE '%' + CN.CountryISO2A
		WHERE CN.CountryISO2A = @pCountry)
		BEGIN
		set @ContextId = (SELECT  AccessContextId FROM Country CN
		JOIN AccessContext AC ON AC.Description LIKE '%' + CN.CountryISO2A
		WHERE CN.CountryISO2A = @pCountry)

			INSERT INTO AccessRights(AccessContextId, RestrictedAccessAreaId, SystemOperationId, SystemRoleTypeId, IsPermissionGranted, ActiveFrom,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
			SELECT @ContextId, RASA.RestrictedAccessAreaId, @SystemOperation, R.SystemRoleTypeId, 1, GETDATE(),'AdminUser',GETDATE(),GETDATE()
			FROM  RestrictedAccessSystemArea RASA
			JOIN SystemRoleType R ON R.[Description] = @pDescription
			WHERE NOT EXISTS (SELECT * FROM AccessRights WHERE AccessContextId = @ContextId AND RestrictedAccessAreaId = RASA.RestrictedAccessAreaId AND SystemRoleTypeId = R.SystemRoleTypeId)

		END
	
		select 1
		END
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
