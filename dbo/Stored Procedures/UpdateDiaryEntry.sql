/*##########################################################################
-- Name				: UpdateDiaryEntry
-- Date             : 2014-11-12
-- Author           : 
-- Purpose          : 
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
      	 @pId	-- Guid of DiaryEntry
		 @pReceivedDate		-- ReceivedDate of DiaryEntry
		 @pBusinessId       --  BusinessId of DiaryEntry
		 @pNumberOfDaysEarly  -- NumberOfDaysEarly of DiaryEntry
		 @pNumberOfDaysLate   -- NumberOfDaysLate of DiaryEntry
		 @pPanelId            -- PanelId of DiaryEntry
-- Sample Execution :
		   
##########################################################################
-- version  user                  date        change 
-- 1.0   Pradeep &  Ramana		  2014-11-12   Initial
-- 1.1  Ramana				      2014-11-18   Refactor
-- 1.2  Sandhya					  2018-05-09   Type Casted Recieved Date
##########################################################################*/
CREATE PROCEDURE UpdateDiaryEntry (
	@pId UNIQUEIDENTIFIER
	,@pReceivedDate VARCHAR(50)
	,@pBusinessId VARCHAR(50)
	,@pNumberOfDaysEarly INT
	,@pNumberOfDaysLate INT
	,@pPanelId UNIQUEIDENTIFIER
	)
AS
BEGIN
BEGIN TRY 
	DECLARE @together INT
		,@dbtogether INT
		,@dbReceivedDate DATETIME
		,@pCountryId UniqueIdentifier
		,@Getdate DATETIME

	SELECT @pCountryId=Country_Id FROM Panel WHERE GUIDReference=@pPanelId
	SET @Getdate=(SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(),@pCountryId))

	SELECT @dbReceivedDate = CAST(ReceivedDate AS DATE)
	FROM DiaryEntry
	WHERE Id = @pId

	UPDATE DiaryEntry
	SET BusinessId = @pBusinessId
		,ReceivedDate = CAST(@pReceivedDate AS DATETIME)
		,NumberOfDaysEarly = @pNumberOfDaysEarly
		,NumberOfDaysLate = @pNumberOfDaysLate
		,GPSUpdateTimestamp=@Getdate
	WHERE Id = @pId

	IF (CAST(@dbReceivedDate AS DATE) <> CAST(@pReceivedDate AS DATE))
	BEGIN
		SELECT @dbtogether = COUNT(0)
		FROM DiaryEntry
		WHERE BusinessId = @pBusinessId
			AND CAST(ReceivedDate AS DATE) = CAST(@dbReceivedDate AS DATE)
			AND PanelId = @pPanelId
		GROUP BY BusinessId
			,CAST(ReceivedDate AS DATE)
			,PanelId

		IF (@dbtogether < 3)
			UPDATE DiaryEntry
			SET Together = 0
			WHERE BusinessId = @pBusinessId
				AND CAST(ReceivedDate AS DATE) = CAST(@dbReceivedDate AS DATE)
				AND PanelId = @pPanelId
	END

	SELECT @together = COUNT(0)
	FROM DiaryEntry
	WHERE BusinessId = @pBusinessId
		AND CAST(ReceivedDate AS DATE) = CAST(@pReceivedDate AS DATE)
		AND PanelId = @pPanelId
	GROUP BY BusinessId
		,CAST(ReceivedDate AS DATE)
		,PanelId

	IF (@together >= 3)
	BEGIN
		UPDATE DiaryEntry
		SET Together = 1
		WHERE BusinessId = @pBusinessId
			AND CAST(ReceivedDate AS DATE) = CAST(@pReceivedDate AS DATE)
			AND PanelId = @pPanelId
	END
	ELSE
	BEGIN
		UPDATE DiaryEntry
		SET Together = 0
		WHERE BusinessId = @pBusinessId
			AND CAST(ReceivedDate AS DATE) = CAST(@pReceivedDate AS DATE)
			AND PanelId = @pPanelId
	END

	SELECT 'Success'
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