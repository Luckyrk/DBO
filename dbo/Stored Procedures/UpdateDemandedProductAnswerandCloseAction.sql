/*##########################################################################  
-- Name    : UpdateDemandedProductAnswerandCloseAction.sql  
-- Date             : 2014-15-21  
-- Author           : Kattamuri Sunil Kumar  
-- Company          : Cognizant Technology Solution  
-- Purpose          : Updates the demandedproduct answer and closes the action based on condition
-- Usage   : From the UI while importing the DemandedProduct import contract
-- Impact   : Change on this procedure the DemandedProduct gets impacted.  
-- Required grants  :   
-- Called by        : 
-- Params Defintion :  
   @pDncAnswerCategory_id UNIQUEIDENTIFIER  -- AnswerCategoryId
	,@pDemandedProductAnswerid UNIQUEIDENTIFIER -- DemandedProductrAnswer Id
	,@pnewDncAnswerCategory_id UNIQUEIDENTIFIER -- New Answer provided by the user
	,@pActionTaskId UNIQUEIDENTIFIER  -- ActionTask Id 
-- Sample Execution :  
 
##########################################################################  
-- ver  user    date        change   
-- 1.0  Kattamuri     2014-10-15  initial  
##########################################################################*/

CREATE PROCEDURE UpdateDemandedProductAnswerandCloseAction (
	@pDncAnswerCategory_id UNIQUEIDENTIFIER
	,@pDemandedProductAnswerid UNIQUEIDENTIFIER
	,@pnewDncAnswerCategory_id UNIQUEIDENTIFIER
	,@pActionTaskId UNIQUEIDENTIFIER
	,@pCollaborationId UNIQUEIDENTIFIER
	)
AS
BEGIN
BEGIN TRY 
		DECLARE @GetDate DATETIME
		DECLARE @CountryId UNIQUEIDENTIFIER
		SET @CountryId=(select Country_Id from CollaborationMethodology  where GUIDReference=@pCollaborationId )
		SET @GetDate = (select dbo.GetLocalDateTimeByCountryId (getdate(),@CountryId))

	DECLARE @currentdate DATETIME = @GetDate	

	IF exists (select 1 from CollaborationMethodology where GUIDReference= @pCollaborationId)
	begin
	 	UPDATE DemandedProductAnswer
		SET DncAnswerCategory_Id = @pnewDncAnswerCategory_id , CollaborationMethodology_Id=@pCollaborationId
		WHERE Id = @pDemandedProductAnswerid
		AND DncAnswerCategory_Id = @pDncAnswerCategory_id
	end
	else 
		UPDATE DemandedProductAnswer
		SET DncAnswerCategory_Id = @pnewDncAnswerCategory_id
		WHERE Id = @pDemandedProductAnswerid
		AND DncAnswerCategory_Id = @pDncAnswerCategory_id
	  

	IF NOT EXISTS (
			SELECT 1
			FROM DemandedProductAnswer dp
			INNER JOIN ActionTask a ON a.GUIDReference = dp.ActionTask_Id
			INNER JOIN DemandedProductCategoryAnswer dpa ON dpa.Id = dp.DncAnswerCategory_Id
			WHERE dpa.AnswerCatCode = 99
				AND dp.ActionTask_Id = @pActionTaskId
				AND dpa.Country_Id = dp.Country_Id
			)
	BEGIN
		UPDATE ActionTask
		SET [CompletionDate] = @currentdate
			,[GPSUpdateTimestamp] = @currentdate
			,[CreationTimeStamp] = @currentdate
			,[State] = 4
		WHERE ([GUIDReference] = @pActionTaskId)
	END
	else
	  UPDATE ActionTask
		SET [CompletionDate] = @currentdate
			,[GPSUpdateTimestamp] = @currentdate
			,[CreationTimeStamp] = @currentdate
			,[State] = 1
		WHERE ([GUIDReference] = @pActionTaskId)
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