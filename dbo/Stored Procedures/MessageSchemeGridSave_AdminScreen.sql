CREATE PROCEDURE [dbo].[MessageSchemeGridSave_AdminScreen_New] (
	 @pId INT
	,@pDescription VARCHAR(50)
	,@pPanelCode INT
	,@pcountrycode VARCHAR(10)
	,@pPanelTemplateMessageSchemeId INT
	)
AS
begin
BEGIN TRY
		DECLARE @CountryId UNIQUEIDENTIFIER,@DescTemplateMessageSchemeId INT
		DECLARE @TempMsgSchmId INT
		DECLARE @PanelId UNIQUEIDENTIFIER
		SET @CountryId = (SELECT C.CountryId FROM COUNTRY C WHERE C.CountryISO2A=@pcountrycode)
		SET @DescTemplateMessageSchemeId=(SELECT TOP 1 TemplateMessageSchemeId FROm TemplateMessageScheme WHERE [Description]=@pDescription AND CountryId=@CountryId)
		SET @PanelId = (SELECT P.GUIDReference FROM PANEL P WHERE P.PanelCode = @pPanelCode and p.Country_Id=@CountryId)

		IF(ISNULL(@pPanelTemplateMessageSchemeId,0)=0)
		BEGIN 
		   IF(ISNULL(@pId,0)=0)
			BEGIN 
				 IF(@DescTemplateMessageSchemeId IS NULL)
				 BEGIN
					  INSERT INTO TemplateMessageScheme([Description],CountryId,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
						 SELECT @pDescription,@CountryId,'AdminUser',GETDATE(),GETDATE()
					 SET @DescTemplateMessageSchemeId=@@IDENTITY
					IF(@PanelId IS NOT NULL)
					BEGIN
					 INSERT INTO PanelTemplateMessageScheme(TemplateMessageSchemeId,GUIDReference,panel_Id,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
					 SELECT @DescTemplateMessageSchemeId,@PanelId,@PanelId,'AdminUser',GETDATE(),GETDATE()
					END
						 SELECT 1 --INSERT  TemplateMessageScheme SUCESS
						 RETURN
 				 END
				 ELSE
					 BEGIN
						  SELECT 2  --DESC Already EXISTS in TemplateMessageScheme INSERT
						  RETURN
					 END
			END
			ELSE
			 BEGIN
					IF EXISTS(SELECT 1 FROM TemplateMessageScheme WHERE [Description]=@pDescription AND TemplateMessageSchemeId<>@pId AND CountryId=@CountryId)
					BEGIN 
						 SELECT 3  --DESC Already EXISTS in TemplateMessageScheme UPDATE
						RETURN
					END
					ELSE
					BEGIN
					IF(@PanelId IS NULL)
						BEGIN
							UPDATE TemplateMessageScheme SET [Description]=@pDescription WHERE TemplateMessageSchemeId=@pId
							SELECT 4 --UPDATE  TemplateMessageScheme SUCESS
							RETURN
						END
					ELSE
						BEGIN
							IF EXISTS(SELECT 1 FROM PanelTemplateMessageScheme WHERE TemplateMessageSchemeId=@pID AND panel_Id=@PanelId)
							BEGIN
								 SELECT 5 --PANELID exists
								 RETURN
							END
							ELSE
							 BEGIN
								UPDATE TemplateMessageScheme SET [Description]=@pDescription WHERE TemplateMessageSchemeId=@pId
								INSERT INTO PanelTemplateMessageScheme (TemplateMessageSchemeId,GUIDReference,panel_Id,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
								SELECT @pID,@PanelId,@PanelId,'AdminUser',GETDATE(),GETDATE()
								SELECT 6
								RETURN
							END
						 
						END
					END
			 END
		END
		ELSE
			BEGIN 
			 IF EXISTS(SELECT TOP 1 PanelTemplateMessageSchemeId FROm PanelTemplateMessageScheme WHERE PanelTemplateMessageSchemeId<>@pPanelTemplateMessageSchemeId AND TemplateMessageSchemeId=@pId AND panel_Id=@PanelId) 
					 BEGIN 
						SELECT 7  --Panel already assigned
						RETURN
					END
				ELSE
					BEGIN						 
						 IF EXISTS(SELECT 1 FROm TemplateMessageScheme WHERE TemplateMessageSchemeId<>@pId AND [Description]=@pDescription AND CountryId=@CountryId)
						BEGIN
							SELECT 8   --Description already assigned in TemplateMessageScheme While PanelTemplateMessageScheme UPDATE
							RETURN
						END
						 UPDATE TemplateMessageScheme SET [Description]=@pDescription WHERE TemplateMessageSchemeId=@pId AND CountryId=@CountryId
						 IF(@PanelId IS NOT NULL)
						 BEGIN
							UPDATE PanelTemplateMessageScheme SET panel_Id=@PanelId WHERE  PanelTemplateMessageSchemeId=@pPanelTemplateMessageSchemeId
						 END
						 ELSE
							BEGIN 
								DELETE FROM PanelTemplateMessageScheme WHERE  PanelTemplateMessageSchemeId=@pPanelTemplateMessageSchemeId
							END
					 
						 SELECT 9 -- PanelTemplateMessageScheme UPDATE SUCESS
				 END
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


