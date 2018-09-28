CREATE PROC [dbo].[InsertUpdateFormRule]
(  
	@pFormID				UNIQUEIDENTIFIER,
	@pRuleId				UNIQUEIDENTIFIER,
	@pGPSUser               NVARCHAR(50)
)
AS 
BEGIN
BEGIN TRY
	SET NOCOUNT ON; 
	SET XACT_ABORT ON;  
	DECLARE @GUIDReference UNIQUEIDENTIFIER = NEWID();
	DECLARE @formID UNIQUEIDENTIFIER , @formruleID UNIQUEIDENTIFIER;
	SELECT @formID = FormID ,@formruleID = GUIDReference from [dbo].[FormRule] WHERE RuleId = @pRuleId 
	IF(@formID <> @pFormID)
	DELETE FROM dbo.FormRuleParameters WHERE FormRule_Id = @formruleID

IF  EXISTS ( SELECT 1 FROM [dbo].[FormRule] WHERE FormID = @pFormID AND RuleId = @pRuleId )
BEGIN
UPDATE [dbo].[FormRule] SET [FormID] = @pFormID,
	[GPSUser] = @pGPSUser,           
	[GPSUpdateTimestamp] = GETDATE()
	WHERE  RuleId = @pRuleId

	SELECT  GUIDReference FROM [dbo].[FormRule] WHERE FormID = @pFormID AND RuleId = @pRuleId 
END

ELSE
BEGIN
INSERT INTO [dbo].[FormRule]
( 
    [GUIDReference],     
	[FormID],	
	[RuleId],			
	[CreationTimeStamp], 
	[GPSUser],           
	[GPSUpdateTimestamp]
) 
      
VALUES
(
    @GUIDReference,
	@pFormID ,
	@pRuleId ,
	GETDATE(),
	@pGPSUser,
	NULL
)

	-- Begin Return Select - do not remove
SELECT GUIDReference
		FROM [dbo].[FormRule] fr (NOLOCK) WHERE fr.GUIDReference = @GUIDReference

	-- End Return Select - do not remove
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