
 CREATE PROCEDURE [dbo].[ImportsEmailNotification] (
	 @JobId AS VARCHAR(200) 
	,@ImportType VARCHAR(1000) 
	,@CountryCode VARCHAR(500) 
	)
AS

--This should be run on all regions (DB's)
/*************************************************
CREATED BY : Jagadeesh B (Initial Version)
UPDATES:
3-JAN-2015 : PBI-37504 Log file update
8-JUN-2017 : Removed unwanted code. SSISLog tables etc.

SP Calls Examples:
EXEC [ImportsEmailNotification] '9393C4BA-F95F-480A-B911-2B14A1E1CA35', 'ActionTasks', 'GB'
EXEC [ImportsEmailNotification] 'C559D076-2B0F-4D57-A2AC-0187C7614800', 'CommunicationEvents', 'TW'
************************************************/
BEGIN
BEGIN TRY
	DECLARE @bcpPath varchar(100) = '@"C:\Program Files\Microsoft SQL Server\110\Tools\Binn\bcp.exe"'
	DECLARE @ErrorLogPath NVARCHAR(500) = ''
	DECLARE @EmailContent NVARCHAR(MAX) = ''
	DECLARE @EmailSubject NVARCHAR(500) = ''
	DECLARE @Emails NVARCHAR(MAX) = ''
	DECLARE @DBName VARCHAR(50) = ''
	DECLARE @FileName  NVARCHAR(500)

	-- DECLARE @DeleteFileString NVARCHAR(1000) = ''

	DECLARE @FilePath NVARCHAR(500) = ''
	DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@CountryCode))

	SELECT TOP (1) @ErrorLogPath = LogFilePath 
		,@Emails = EmailIds
		,@EmailSubject = EmailSubject
		,@DBName = DBName
		,@FilePath = FilePath
	FROM [SSIS_Dataimport].DBO.SSISFileImportsConfig
	WHERE ImportType = @ImportType
		AND CountryCode = @CountryCode

	SELECT top(1) @FileName = CASE
	WHEN @ImportType='SodexoImport' THEN REPLACE([Filename],@FilePath+'\','')
	ELSE	 REPLACE(REPLACE(REPLACE([Filename],@FilePath,''),' ', ''),'\','_')  
	END
	FROM [FileImportAuditSummary]
	WHERE importType = @ImportType
	AND CountryCode = @CountryCode
	AND JobId = @JobId

	
	if @FileName is null
	begin 
		select top 1 @FileName = [FileName] from [FileImportErrorLog]	where JobId = @JobId
	end


	DECLARE @LastRunDate DATETIME
	DECLARE @ErrorLogfolderPath VARCHAR(1000) = @ErrorLogPath 
	DECLARE @ErrorLogfile VARCHAR(1000) = @FileName + '_'+  @ImportType + '_' + REPLACE(REPLACE(REPLACE(CONVERT(VARCHAR(19), CONVERT(DATETIME, @Getdate, 112), 126), '-', ''), 'T', ''), ':', '') + '.txt'
	DECLARE @ErrorLogfileName VARCHAR(1000) =@ErrorLogfolderPath  + @ErrorLogfile -- complete file path
	DECLARE @SSIS_ErrorLogfolderPath VARCHAR(1000) = @ErrorLogPath  
	DECLARE @SSIS_ErrorLogfile VARCHAR(1000) =   @FileName  + '_'+  @ImportType + '_SSIS_Errorlog_' + Convert(NVARCHAR(max), @Getdate, 112) + '.txt'
	--	DECLARE @SSIS_ErrorLogfileName VARCHAR(1000) = @SSIS_ErrorLogfolderPath + @SSIS_ErrorLogfile -- complete file path
	
	SET @LastRunDate = @Getdate
	SET @EmailContent = @EmailContent + '<!DOCTYPE html><html xmlns=''http://www.w3.org/1999/xhtml''><head><title></title></head><body><b>' + @EmailSubject + ' Summary:</b><br /><br />'
	SET @EmailContent = @EmailContent + '<div><table style=''border:1px solid black;border-collapse:collapse;''><tr><th style=''border:1px solid black;border-collapse:collapse;''>Country Code</th><th style=''border:1px solid black;border-collapse:collapse;''>Panel Name</th><th style=''border:1px solid black;border-collapse:collapse;''>File Name</th><th style=''border:1px solid black;border-collapse:collapse;''>File Import Date</th><th style=''border:1px solid black;border-collapse:collapse;''>Passed Rows</th><th style=''border:1px solid black;border-collapse:collapse;''>Status</th><th style=''border:1px solid black;border-collapse:collapse;''>Comments</th></tr>'

	IF EXISTS (
			SELECT 1
			FROM [FileImportAuditSummary]
			WHERE importType = @ImportType
				AND CountryCode = @CountryCode
				AND JobId = @JobId
			)
	BEGIN
		SELECT TOP 1000 @EmailContent = @EmailContent + '<tr><td style=''border:1px solid black;border-collapse:collapse;''>' + CountryCode + '</td>
       <td style=''border:1px solid black;border-collapse:collapse;''>' + ISNULL(PanelName, '') + '</td>
       <td style=''border:1px solid black;border-collapse:collapse;''>' + ISNULL([Filename], '') + '</td>
       <td style=''border:1px solid black;border-collapse:collapse;''>' + convert(NVARCHAR(100), FileImportDate, 105) + '</td>     
       <td style=''border:1px solid black;border-collapse:collapse;''>' + Convert(VARCHAR, PassedRows) + '</td>
       <td style=''border:1px solid black;border-collapse:collapse;''>' + [Status] + '</td>
       <td style=''border:1px solid black;border-collapse:collapse;''>' + ISNULL([Comments], '') + '</td></tr>'
		FROM [FileImportAuditSummary]
		WHERE importType = @ImportType
			AND CountryCode = @CountryCode
			AND JobId = @JobId
	END
	ELSE
	BEGIN
			SET @EmailContent = @EmailContent + '<tr><td style=''border:1px solid black;border-collapse:collapse;''>' + @CountryCode + '</td>
			   <td style=''border:1px solid black;border-collapse:collapse;''> </td>
			   <td style=''border:1px solid black;border-collapse:collapse;''>' + ISNULL(@FileName,'') + '</td>
			   <td style=''border:1px solid black;border-collapse:collapse;''>' + convert(NVARCHAR(100), @LastRunDate, 105)   + '</td>     
			   <td style=''border:1px solid black;border-collapse:collapse;''> 0 </td>
			   <td style=''border:1px solid black;border-collapse:collapse;''>Failed</td>
			   <td style=''border:1px solid black;border-collapse:collapse;''> Errors occured. </td></tr>'

	END

	SET @EmailContent = @EmailContent + '</table></div>'
	---------------------
	IF EXISTS (	SELECT 1
			FROM [FileImportErrorLog]
			WHERE JobId = @JobId)
	BEGIN
		SET @EmailContent = @EmailContent + '<br /><br /><div> Some errors occured during the process, please check the attached file: ' + @ErrorLogfile + ' for errors.</div>'

		DECLARE @ErrorDate VARCHAR(2000) = convert(NVARCHAR(100), @LastRunDate, 111)
		DECLARE @Str VARCHAR(2000)

		SET @Str = '' + @bcpPath + ' "SELECT ''FileName''+ char(9) +''CountryCode''+ char(9) +''PanelCode''+ char(9) +''ImportType''+ char(9) +''ErrorCode''+ char(9) +''ErrorDescription'' UNION ALL select isnull([FileName],'''')+ char(9) +isnull(CountryCode,'''')+ char(9) +isnull(cast(PanelCode as nvarchar),'''')+ char(9) +isnull(cast(ImportType as nvarchar),'''')+ char(9) +isnull(cast(ErrorCode as nvarchar),'''')+ char(9) +ErrorDescription from ' + @DBName + '.dbo.[FileImportErrorLog] where importType=''' + @ImportType + ''' and CountryCode=''' + @CountryCode + '''and JobId=''' + @JobId + '''" queryout "' + @ErrorLogfileName + '" -c -t, -T -S' + @@SERVERNAME + ''

		print '2'
		print @Str

		EXEC master.dbo.xp_cmdshell @Str
	END
	--------------------
		
SET @EmailContent = @EmailContent + '</body></html>'
 
	IF EXISTS (	SELECT 1
			FROM [FileImportAuditSummary]
			WHERE importType = @ImportType
				AND CountryCode = @CountryCode
				AND JobId = @JobId	)
	BEGIN
		IF EXISTS (	SELECT 1
				FROM [FileImportErrorLog]
				WHERE importType = @ImportType
				AND JobId = @JobId)
		BEGIN
			print '1: ' + @ErrorLogfileName

			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'SQLMAIL'
				,@recipients = @Emails
				,@subject = @EmailSubject
				,@body = @EmailContent
				,@body_format = 'HTML'
				,@file_attachments = @ErrorLogfileName

			-- SET @DeleteFileString = '' + 'del ' + @ErrorLogfileName + ''
			-- EXEC master.dbo.xp_cmdshell @DeleteFileString
		END
		ELSE
		BEGIN
			print '2'

			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'SQLMAIL'
				,@recipients = @Emails
				,@subject = @EmailSubject
				,@body = @EmailContent
				,@body_format = 'HTML'
		END
	END
	ELSE IF EXISTS (SELECT 1
				FROM [FileImportErrorLog]
				WHERE JobId = @JobId)
		BEGIN
			print '3: ' + @ErrorLogfileName
			EXEC msdb.dbo.sp_send_dbmail @profile_name = 'SQLMAIL'
			,@recipients = @Emails
			,@subject = @EmailSubject 
			,@body = @EmailContent
			,@body_format = 'HTML'
			,@file_attachments = @ErrorLogfileName
		END
		
		-- SET @DeleteFileString = '' + 'del ' + @SSIS_ErrorLogfileName + ''
		-- EXEC master.dbo.xp_cmdshell @DeleteFileString
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
GO