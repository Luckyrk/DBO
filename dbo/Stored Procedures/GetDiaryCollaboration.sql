CREATE PROCEDURE [dbo].[GetDiaryCollaboration]
(
	@pPanelId UniqueIdentifier,	
	@pCountryId UniqueIdentifier,
	@pCultureCode INT
 )
AS

BEGIN
BEGIN TRY 
SELECT Code AS CollaborationCode, dbo.GetTranslationValue(TranslationId,@pCultureCode) AS CollaborationValue
FROM CollaborationMethodology CM
INNER JOIN (
	SELECT DISTINCT CollaborationMethodology_Id 
	FROM Panelist 
	WHERE Country_Id = @pCountryId AND Panel_Id = @pPanelId
	AND CollaborationMethodology_Id IS NOT NULL
	) C ON C.CollaborationMethodology_Id = CM.GUIDReference
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