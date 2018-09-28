/*Using Table Type RolePermissionAccess to define the 
						UserRole
						Area - this is refered from RestrictedAccessAreaSubType table
						Name - Menu Name
						[Path] - URL Path of the Menu item
						SystemOperation - refered from Systemoperation table
						Grant Access - 0 (or) 1*/
--EXEC Usp_MenuInsert @Role='SuperAdministrator',@AreaTypeId=3,@Name='Query',@Path='queries',@SysOperation=1,@GrantAccess=1
CREATE Procedure Usp_MenuInsert
@Role VARCHAR(500),
@AreaTypeId INT,
@Name VARCHAR(100),
@Path VARCHAR(100),
@SysOperation INT,
@GrantAccess BIT
AS
BEGIN
BEGIN TRY 
DECLARE  @Permissions RolePermissionAccess
DECLARE @CountryId		   UNIQUEIDENTIFIER
DECLARE @CountryCode	   NVARCHAR(50) 
CREATE TABLE #TempCountryID
		(
			CountryId		   UNIQUEIDENTIFIER, 
			CountryISO2A	    NVARCHAR(50)  Collate Database_Default
		)

INSERT INTO #TempCountryID (CountryId,CountryISO2A) (SELECT CountryId,CountryISO2A FROM COUNTRY);

INSERT into @Permissions ([Role], [Area], [Name], [Path], [SystemOperation], [GrantAccess]) 
VALUES (@Role, @AreaTypeId, @Name,@Path, @SysOperation, @GrantAccess)

SELECT * FROM #TempCountryID

WHILE EXISTS (SELECT TOP 1 * FROM #TempCountryID) 
BEGIN
SELECT TOP 1 CountryId FROM #TempCountryID 
SET @CountryId = (SELECT TOP 1 CountryId FROM #TempCountryID)
SET @CountryCode = (SELECT TOP 1 CountryISO2A FROM #TempCountryID)

	IF NOT EXISTS (SELECT 1 FROM ACCESSCONTEXT AC WHERE  AC.Description LIKE '%' + @CountryCode)
	BEGIN
	INSERT INTO ACCESSCONTEXT VALUES ('Country'+@CountryCode ,'AdminUser',GETDATE(),GETDATE())
	END	

EXEC SetRolePermission  @Permissions, @CountryId

DELETE FROM #TempCountryID WHERE CountryId=@CountryId
SELECT * FROM #TempCountryID
END
Drop table #TempCountryID
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