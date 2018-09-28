CREATE PROCEDURE [dbo].[EmailNotificationOnQBI_Success]
 @CountryCode varchar(100)='TW'
 ,@EmailSubject NVARCHAR(500)=' Quest Back New Recruit Job SUCCEEDED (Live)'
,@ErrorLogfolderPath varchar(1000)='\\kwslosql001\DataShare\QB_Error_Logs\'
AS
/**********************************************************************************************************************
CREATE BY : Suresh
Purpose: Email notification after QBImport job success.

   PBI: 33475 applied.
-- EXECUTE GPS_PM.DBO.EmailNotificationOnQBI_Success 'TW', 'Quest Back New Recruit Job SUCCEEDED (Live)', '\\kwslosql210\DataShare\QB_Error_Logs\'
***********************************************************************************************************************************/
BEGIN
BEGIN TRY 
	SET @EmailSubject= @CountryCode + ' ' + @EmailSubject
	DECLARE @EmailBody NVARCHAR(MAX)=''
	DECLARE @LastRunDate DATETIME
	DECLARE @Emails NVARCHAR(MAX)
	DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@CountryCode))

	SET @LastRunDate=@Getdate
	DECLARE @ErrorLogfile varchar(100)='QB_Errorlog_'+Convert(nvarchar(max),@LastRunDate,112)+'.txt'
	DECLARE @PanelistMappingfile varchar(100)='Id_Mapping_'+Convert(nvarchar(max),@LastRunDate,112)+'.txt'

	DECLARE @ErrorLogfileName varchar(100)=@ErrorLogfolderPath+@ErrorLogfile
	DECLARE @PanelistMappingfileName varchar(100)=@ErrorLogfolderPath+@PanelistMappingfile
	DECLARE @ProcessedFileName varchar(100)
	DECLARE @ProcessId UNIQUEIDENTIFIER
	DECLARE @ProcessIdString NVARCHAR(MAX)
 
	SET @ProcessId=(SELECT TOP (1) AuditGUID from  [GPS_PM].[QBI].[ImportAuditSummary] 
	WHERE CountryCode= @CountryCode AND DAY(@LastRunDate)=DAY(FileImportDate) AND MONTH(@LastRunDate)=MONTH(FileImportDate)AND YEAR(@LastRunDate)=YEAR(FileImportDate) 
	Order by FileImportDate Desc)
	SET @ProcessIdString=cast(@ProcessId as nvarchar(500))


	IF (@ProcessId IS NOT NULL AND EXISTS (SELECT 1 from  [GPS_PM].[QBI].[ImportAuditSummary] WHERE AuditGUID=@ProcessId))
	BEGIN
		SET @EmailBody='<html xmlns=''_http://www.w3.org/1999/xhtml''><head><title></title></head><body>
						Quest Back New Recruit Job. 
					<br/> <b>Results: </b><br/> <div><table style=''border:1px solid black;border-collapse:collapse;''><tr><th style=''border:1px solid black;border-collapse:collapse;''>File Name</th><th style=''border:1px solid black;border-collapse:collapse;''>Panel Name</th><th style=''border:1px solid black;border-collapse:collapse;''>Total Records (Pstatus=1)</th><th style=''border:1px solid black;border-collapse:collapse;''>Non Duplicate Records</th><th style=''border:1px solid black;border-collapse:collapse;''>Passed Records</th><th style=''border:1px solid black;border-collapse:collapse;''>Failed Records</th></tr>'
					

                SELECT @EmailBody=@EmailBody+'<tr><td style=''border:1px solid black;border-collapse:collapse;''>'+[Filename]+'</td>
				<td style=''border:1px solid black;border-collapse:collapse;''>'+PanelName+'</td>
				<td style=''border:1px solid black;border-collapse:collapse;text-align:center''>'+Convert(varchar,(TotalRows))+'</td>
				<td style=''border:1px solid black;border-collapse:collapse;text-align:center''>'+Convert(varchar,(NewPanelistCount))+'</td>
				<td style=''border:1px solid black;border-collapse:collapse;text-align:center''>'+Convert(varchar,(PassedRows))++'</td>
				<td style=''border:1px solid black;border-collapse:collapse;text-align:center''>'+Convert(varchar,FailedRows)+'</td></tr>'
                FROM
                (
                                SELECT [Filename],PanelName,Convert(varchar,[TotalRows]) as TotalRows,Convert(varchar,NewPanelistCount) as NewPanelistCount,Convert(varchar,PassedRows) as PassedRows,Convert(varchar,[NewPanelistCount]-PassedRows) as FailedRows ,FileImportDate as rundate 
                                FROM  [GPS_PM].[QBI].[ImportAuditSummary]
                                WHERE CountryCode=@CountryCode AND AuditGUID=@ProcessId

                ) t

                SET @EmailBody=@EmailBody+'</table></div>'

                IF EXISTS (select 1 from QB_DataImport.dbo.MappedKeyALias where BusinessArea='INDIVIDUAL' AND ProcessId=@ProcessIdString)
                BEGIN

					SET @EmailBody=@EmailBody+'<div style=''margin-top: 10px''>'
					SET @EmailBody=@EmailBody+'Please find the attached '+@PanelistMappingfile+' file for panelists mappings.</div>'
					DECLARE @Str VARCHAR(2000)
					/*  33475  updates */
					-- SET @Str=''+'bcp "SELECT ''SourceKey''+ char(9) +''TargetKey'' UNION ALL select SourceKey+ char(9) +TargetKey from QB_DataImport.dbo.MappedKeyALias where BusinessArea=''INDIVIDUAL'' AND ProcessId='''+@ProcessIdString+'''" queryout "'+@PanelistMappingfileName+'" -c -t, -T'+''
					SET @Str=''+'bcp "SELECT ''SourceKey''+ char(9) +''TargetKey'' + char(9) +''EmailID'' UNION ALL select SourceKey+ char(9) +TargetKey + char(9) + EmailId from QB_DataImport.dbo.MappedKeyAliasWithEmail where ProcessId='''+@ProcessIdString+'''" queryout "'+@PanelistMappingfileName+'" -c -t, -T'+''
					EXEC master.dbo.xp_cmdshell @Str

                    IF EXISTS (SELECT 1 FROM QB_DataImport.dbo.ERROR_LOG ERR WHERE ProcessId=@ProcessIdString)
                    BEGIN

						SET @EmailBody=@EmailBody+'<div style=''margin-top: 5px''>'
						SET @EmailBody=@EmailBody+'<b>Errors occurred during the Import</b> '
						SET @EmailBody=@EmailBody+' Please check the attached '+@ErrorLogfile+' file for error logs.</div>'

						DECLARE @ErrorStr VARCHAR(2000)
						SET @ErrorStr=''+'bcp "SELECT ''Id''+ char(9) +''BusinessArea''+ char(9) +''SourceKey''+ char(9) +''ErrorDescription'' UNION ALL SELECT cast(ERR.ERROR_ID as nvarchar(1000)) + char(9) +ERR.BusinessArea + char(9) +ERR.SourceKey + char(9) +ERR.Error_Description  FROM QB_DataImport.dbo.ERROR_LOG ERR WHERE ERR.ProcessId='''+@ProcessIdString+'''" queryout "'+@ErrorLogfileName+'" -c -t, -T'+''
						EXEC master.dbo.xp_cmdshell @ErrorStr
						SET @EmailSubject=@EmailSubject+'– Errors occurred'

                    END
                    ELSE 
                    BEGIN
                        SET @EmailBody=@EmailBody+'<div style=''margin-top: 5px''>'
                        SET @EmailBody=@EmailBody+'<i>Note: No error occured during the QB import processes.</i></div>'
                    END
                END
	END
	ELSE
	BEGIN
					SET @EmailBody=@EmailBody+'<tr><td style=''border:1px solid black;border-collapse:collapse;''>
					</td><td style=''border:1px solid black;border-collapse:collapse;''></td><td style=''border:1px solid black;border-collapse:collapse;text-align:center''>
					</td><td style=''border:1px solid black;border-collapse:collapse;text-align:center''>
					</td><td style=''border:1px solid black;border-collapse:collapse;text-align:center''></td></tr>'
	END
 
	SELECT TOP (1) @Emails=Emails FROM QB_DataImport.dbo.ftpConnectionInfo Where CountryISO2A = @CountryCode 
	SET @EmailBody=@EmailBody+'</body></html>'
	SET @EmailSubject=   @EmailSubject+'.'
 

--	USE msdb
	DECLARE @isAttachmentExists INT
	exec master.dbo.xp_fileexist @PanelistMappingfileName, @isAttachmentExists OUTPUT

	IF EXISTS (SELECT 1 FROM QB_DataImport.dbo.ERROR_LOG ERR WHERE ProcessId=@ProcessIdString)
	BEGIN
	DECLARE @attachments varchar(200)=@ErrorLogfileName+';'+@PanelistMappingfileName
	
	IF @isAttachmentExists <> 1
		BEGIN
			SET @attachments = NULL	

			EXEC msdb.dbo.sp_send_dbmail
			@profile_name = 'SQLMAIL',
			@recipients = @Emails,
			@subject = @EmailSubject,
			@body =  @EmailBody
			,@body_format= 'HTML'			
		END
		ELSE 
		BEGIN
			EXEC msdb.dbo.sp_send_dbmail
			@profile_name = 'SQLMAIL',
			@recipients = @Emails,
			@subject = @EmailSubject,
			@body =  @EmailBody
			,@body_format= 'HTML',
			@file_attachments=@attachments
	END

	END
	ELSE IF EXISTS (select 1 from QB_DataImport.dbo.MappedKeyALias where BusinessArea='INDIVIDUAL' AND ProcessId=@ProcessIdString)
	BEGIN
			IF @isAttachmentExists <> 1
				BEGIN
					SET @attachments = NULL	

					EXEC msdb.dbo.sp_send_dbmail
					@profile_name = 'SQLMAIL',
					@recipients = @Emails,
					@subject = @EmailSubject,
					@body =  @EmailBody
					,@body_format= 'HTML'			
				END
				ELSE 
				BEGIN
					EXEC msdb.dbo.sp_send_dbmail
					@profile_name = 'SQLMAIL',
					@recipients = @Emails,
					@subject = @EmailSubject,
					@body =  @EmailBody
					,@body_format= 'HTML',
					@file_attachments=@PanelistMappingfileName
				END
	END
	ELSE
	BEGIN
		EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'SQLMAIL',
		@recipients = @Emails,
		@subject = @EmailSubject,
		@body =  @EmailBody
		,@body_format= 'HTML'

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