CREATE PROCEDURE DeleteCollaborationMethodologyHistory_AdminScreen (@pid UNIQUEIDENTIFIER)
AS
BEGIN
BEGIN TRY 
	DECLARE @Panelist_Id UNIQUEIDENTIFIER
	DECLARE @OldCollaboration_Id UNIQUEIDENTIFIER
	DECLARE @NewCollaboration_Id UNIQUEIDENTIFIER

	SET @Panelist_Id = (
			SELECT TOP 1 Panelist_Id
			FROM CollaborationMethodologyHistory
			WHERE GUIDReference = @pid
			)
	SET @OldCollaboration_Id = (
			SELECT TOP 1 OldCollaborationMethodology_Id
			FROM CollaborationMethodologyHistory
			WHERE Panelist_Id = @Panelist_Id
			ORDER BY [Date] DESC, CreationTimeStamp DESC
			)
	SET @NewCollaboration_Id = (
			SELECT TOP 1 NewCollaborationMethodology_Id
			FROM CollaborationMethodologyHistory
			WHERE Panelist_Id = @Panelist_Id
			ORDER BY [Date] DESC, CreationTimeStamp DESC
			)

	DELETE
	FROM CollaborationMethodologyHistory
	WHERE GUIDReference = @pid

	UPDATE Panelist
	SET CollaborationMethodology_Id = @OldCollaboration_Id
	WHERE CollaborationMethodology_Id = @NewCollaboration_Id AND GUIDReference = @Panelist_Id
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