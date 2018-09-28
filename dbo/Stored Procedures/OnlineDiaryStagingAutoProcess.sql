/*##########################################################################
-- Name				: OnlineDiaryStagingAutoProcess
-- Date             : 2015-02-03
-- Author           : Jagadeesh B
-- Company          : Cognizant Technology Solution
-- Purpose          : Online Dairy Job from source to staging table move
-- Usage			:
-- Impact			: 
-- Required grants  : 
-- Called by        : Online Dairy Job
-- PARAM Definitions
	@pJobId bigint -- Job Id
-- Sample Execution :
    DECLARE @TotalRows BIGINT
	Exec OnlineDiaryStagingAutoProcess 'TW','panel_export_20141214180000.csv','F:\fromftp\MalePanel\panel_export_20141214180000.csv',@TotalRows OUT
##########################################################################
user			 date        change 
Jagadeesh B      2015-02-03  Initial
##########################################################################*/
CREATE PROCEDURE OnlineDiaryStagingAutoProcess
(
  @CountryCode NVARCHAR(20)
 ,@FileName NVARCHAR(200)
 ,@LocalPath NVARCHAR(200)
 ,@TotalRows BIGINT OUTPUT
)
AS
BEGIN 
BEGIN TRY 
DECLARE @ERROR_NUMBER BIGINT
DECLARE @ERROR_MESSAGE NVARCHAR(MAX)
DECLARE @FailedRows BIGINT
DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(getdate(),@CountryCode))

SELECT @TotalRows=COUNT(*) from TWN_OnLineDiaryProcessing.dbo.ftpFileImport where processid is null
BEGIN TRY


SET @ERROR_NUMBER=0
SET @ERROR_MESSAGE='NPAN or date_last_checkout is not valid '

   
INSERT INTO Staging.DiaryEntryStage
( NPAN, DiarySourceValue, ReceivedDate, 
Points, PanelId, CountryCode,[FileName], 
GPSUser, GPSUpdateTimestamp, CreationTimeStamp )
SELECT 
  [uid] AS NPAN
 , 1 AS DiarySourceValue
   , MAX(date_last_checkout) AS ReceivedDate
  , pcredit_points as Points   
   , PanelID  
   ,@CountryCode as CountryCode
   , [FileName]
   ,SYSTEM_USER as GPSUser
   , @Getdate as GPSUpdateTimeStamp
   , @Getdate as CreateTimeStamp
 
   FROM TWN_OnLineDiaryProcessing.dbo.ftpFileImport
   WHERE processid is null and (
    ISNULL([uid],'0')<>'0' AND LTRIM([uid])<> ''
    AND date_last_checkout is not null 
    AND date_last_checkout <> ' ')

   GROUP BY PanelID, [uid], FileName,pcredit_points
   ORDER BY NPAN
-------------------------   
INSERT INTO dbo.FailedDiaryEntryStage
( NPAN, DiarySourceValue, ReceivedDate, 
Points, PanelId, CountryCode,[FileName], 
GPSUser, GPSUpdateTimestamp, CreationTimeStamp,[UId])
SELECT 
  u_other_id AS NPAN
 , 1 AS DiarySourceValue
   , date_last_checkout AS ReceivedDate
  , pcredit_points as Points   
   , PanelID  
   ,@CountryCode as CountryCode
   , [FileName]
   ,SYSTEM_USER as GPSUser
   , @Getdate as GPSUpdateTimeStamp
   , @Getdate as CreateTimeStamp
   ,[uid] as [Uid]
   FROM TWN_OnLineDiaryProcessing.dbo.ftpFileImport
   WHERE processid is null and (
    ISNULL([uid],'0')='0' AND LTRIM([uid])=''
    or date_last_checkout is  null 
    or date_last_checkout = ' ')

 --------------------------------------------------------------


INSERT INTO TWN_OnLineDiaryProcessing.dbo.ImportAudit
(
AuditGUID, PanelID, [Filename], FileImportDate, 
GPSUser, ImportTypeID, OutcomeID, ErrorCode,ErrorDescription,FileRowCount
 )
SELECT	NewID() as AuditGUID,PanelID,[FileName],@Getdate as FileImportDate,
        SYSTEM_USER as GPSUser,1 as ImportTypeID,2 as OutcomeID,@ERROR_NUMBER as ErrorCode,
	(@ERROR_MESSAGE+'for uid: '+[uid]+'.( NPAN: '+u_other_id+'  Recived date: '+date_last_checkout+' )') as ErrorDescription,@TotalRows
FROM TWN_OnLineDiaryProcessing.dbo.ftpFileImport
   WHERE processid is null and (
    ISNULL([uid],'0')='0' AND LTRIM([uid])=''
    or date_last_checkout is  null 
    or date_last_checkout = ' ')

-----------------------------------------------------------------
    

 END TRY
 BEGIN CATCH
-- log here
print 'error'

INSERT INTO TWN_OnLineDiaryProcessing.dbo.ImportAudit
(
AuditGUID, PanelID, [Filename], FileImportDate, 
GPSUser, ImportTypeID, OutcomeID, ErrorCode,ErrorDescription,FileRowCount
 )
SELECT	NewID() as AuditGUID,PanelID,[FileName],@Getdate as FileImportDate,
        SYSTEM_USER as GPSUser,1 as ImportTypeID,2 as OutcomeID,@ERROR_NUMBER as ErrorCode,
		'Exception occuerd - File not processed.' as ErrorDescription,@TotalRows
FROM TWN_OnLineDiaryProcessing.dbo.ftpFileImport where processid is null 
 END CATCH
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