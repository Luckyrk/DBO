
-- =============================================
-- Author:		Fernandez, Matias
-- Create date: 2014/12/22
-- Description:	Create the Association between Role and Panel for a new panel
-- =============================================
/*

SAMPLE CALL:


DECLARE @PanelName NVARCHAR(50) = 'individual panel'
DECLARE @RoleName NVARCHAR(50) = 'main shopper'
DECLARE @CountryCode NVARCHAR(10) = 'es'

--TestMode: 1 - This will just show the panel and the role affected. Please execute only if one panel and role is shown
exec Sp_AddRoleToPanelAssociation @PanelName=@PanelName, @RoleName=@RoleName, @CountryCode= @CountryCode

--TestMode: 0
exec Sp_AddRoleToPanelAssociation @PanelName=@PanelName, @RoleName=@RoleName, @CountryCode= @CountryCode, @TestMode=0

NOTE: if the association already exists, the sp wont add a new one
*/

CREATE PROCEDURE SP_AddRoleToPanelAssociation
	@PanelName NVARCHAR(50),
	@RoleName NVARCHAR(50),
	@CountryCode NVARCHAR(10),
	@TestMode BIT = 1
AS
BEGIN

	SET NOCOUNT ON;	    
	BEGIN TRY 
	/* PLEASE CHECK THIS BEFORE RUNNING THE INSERT SCRIPT! */

	DECLARE @CountryId UNIQUEIDENTIFIER;
	SELECT @CountryId = CountryId FROM Country WHERE CountryISO2A LIKE @CountryCode

	DECLARE @PanelId UNIQUEIDENTIFIER;
	SELECT *							FROM Panel p WHERE p.Name like CONCAT('%',@PanelName,'%') AND Country_Id=@CountryId
	SELECT @PanelId = p.GUIDReference	FROM Panel p WHERE p.Name like CONCAT('%',@PanelName,'%') AND Country_Id=@CountryId

	DECLARE @RoleId UNIQUEIDENTIFIER;

	SELECT *
	FROM DynamicRole dr 
	JOIN TranslationTerm tt ON tt.Translation_Id=dr.Translation_Id
	WHERE tt.Value LIKE CONCAT('%',@RoleName,'%') AND CultureCode=2057 AND dr.Country_Id=@CountryId

	SELECT @RoleId = dr.DynamicRoleId
	FROM DynamicRole dr 
	JOIN TranslationTerm tt ON tt.Translation_Id=dr.Translation_Id
	WHERE tt.Value LIKE CONCAT('%',@RoleName,'%') AND CultureCode=2057 AND dr.Country_Id=@CountryId

	/*******************************************************/

	IF @TestMode=1
		SELECT 'TEST MODE is On, to insert the association between the panel and roles set it to Off (zero)';

	/* INSERT NEW ROLES */
	IF @TestMode = 0 AND NOT EXISTS(SELECT cs.ConfigurationSetId FROM ConfigurationSet cs
		JOIN DynamicRoleConfiguration drc ON drc.ConfigurationSetId=cs.ConfigurationSetId
		WHERE drc.DynamicRoleId=@RoleId AND cs.PanelId=@PanelId AND cs.CountryID=CountryID )
		BEGIN
			BEGIN TRAN T1;		
			DECLARE @CsId UNIQUEIDENTIFIER = NEWID();
			INSERT INTO ConfigurationSet(ConfigurationSetId, CountryID, PanelId, [Type],GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
			VALUES (@CsId, @CountryId, @PanelId, 'Panel','AdminUser',GETDATE(),GETDATE())
		
			INSERT INTO DynamicRoleConfiguration(DynamicRoleConfigurationId, ConfigurationSetId, DynamicRoleId, [Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
			VALUES (NEWID(), @CsId, @RoleId, 
				ISNULL((SELECT MAX([Order])+1 FROM ConfigurationSet cs
						JOIN DynamicRoleConfiguration drc ON drc.ConfigurationSetId=cs.ConfigurationSetId
						WHERE cs.PanelId=@PanelId)		,1),'AdminUser',GETDATE(),GETDATE())
			COMMIT TRAN T1;

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
GO
