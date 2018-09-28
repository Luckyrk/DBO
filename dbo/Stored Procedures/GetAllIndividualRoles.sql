CREATE PROCEDURE [dbo].[GetAllIndividualRoles](
@pBusinessId UNIQUEIDENTIFIER
)
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON;
		SET XACT_ABORT ON;

        DECLARE @GROUPID AS UNIQUEIDENTIFIER

        SET @GROUPID=(SELECT Group_Id  FROM CollectiveMembership  WHERE Individual_Id = @pBusinessId )

        SELECT DISTINCT D.Code AS Code FROM DynamicRoleAssignment DR
        JOIN DynamicRole d ON DR.DynamicRole_Id = D.DynamicRoleId
        JOIN Collective C ON C.GUIDReference = DR.Group_Id
        JOIN CollectiveMembership CM ON CM.Group_Id = c.GUIDReference
        WHERE CM.Group_Id = @GROUPID AND DR.Candidate_Id IS NOT NULL
   END TRY

   BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			@ErrorSeverity = ERROR_SEVERITY(),
			@ErrorState = ERROR_STATE();

		RAISERROR (
				@ErrorMessage,-- Message text.
				@ErrorSeverity,-- Severity.				
				@ErrorState -- State.
				);
	END CATCH

 END

