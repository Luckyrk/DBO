CREATE PROCEDURE UpdateRoleAssignment_Adminscreen(
 @RoleId int,@countrycode varchar(10),@RoleAccess dbo.RoleAccess Readonly)
  AS
 Begin
 BEGIN TRY 
 Declare @AccessContext bigint
 set @AccessContext = (select AccessContextId from AccessContext where  [Description] LIKE '%' + @countrycode)

 Create  TABLE #TempTable(
 AccessContextId bigint,
 RestrictedAccessAreaId bigint,
 SystemRoleTypeId bigint,
 SystemOperationId bigint,
  IsPermissionGranted bit,
  ActiveFrom datetime,
  ActiveTo datetime
   )

Insert into #TempTable select * from @RoleAccess

MERGE AccessRights AS T
USING #TempTable AS S
ON T.AccessContextId = S.AccessContextId and
 T.RestrictedAccessAreaId = S.RestrictedAccessAreaId and
  T.SystemOperationId = S.SystemOperationId and
   T.SystemRoleTypeId = S.SystemRoleTypeId 
 WHEN MATCHED 
    THEN  	UPDATE SET IsPermissionGranted = S.IsPermissionGranted
WHEN NOT MATCHED BY TARGET 
    THEN INSERT(AccessContextId, RestrictedAccessAreaId, SystemOperationId, SystemRoleTypeId, IsPermissionGranted, ActiveFrom,ActiveTo,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
	VALUES(S.AccessContextId, S.RestrictedAccessAreaId,S.SystemOperationId,S.SystemRoleTypeId,S.IsPermissionGranted,S.ActiveFrom, S.ActiveTo,'AdminUser',GETDATE(),GETDATE())

OUTPUT $action, inserted.*;

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
 End






