/*##########################################################################
-- Name				: GetDiaryEntryById
-- Date             : 2014-11-17
-- Author           : 
-- Purpose          : 
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
      	 @pId	-- Guid of DiaryEntry	
-- Sample Execution :
exec GetDiaryEntryById '0C9E374B-F655-CEC9-5C06-08D11B00910B'
##########################################################################
-- version  user                  date        change 
-- 1.0  Pradeep					  2014-11-17  Initial
-- 1.1  Ramana				      2014-11-18   Refactor
##########################################################################*/
CREATE PROCEDURE GetDiaryEntryById (@pId UNIQUEIDENTIFIER)
AS
BEGIN
BEGIN TRY 
	SELECT  Id
		,DiaryDateYear
		,DiaryDatePeriod
		,DiaryDateWeek
		,BusinessId
		,CONVERT(varchar(10), ReceivedDate, 120) AS ReceivedDate
		,Points
		,NumberOfDaysLate
		,NumberOfDaysEarly
		,PanelId
	FROM DiaryEntry
	WHERE Id = @pId
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