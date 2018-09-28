CREATE PROCEDURE [dbo].[GenericEmailNotificationOnQBI]
  @CountryCode varchar(100)='FR'
  ,@ConnectionID VARCHAR(100) = '1'
  ,@ProcessId VARCHAR(100) 
 
AS
BEGIN
BEGIN TRY 
	DECLARE @EmailSubject NVARCHAR(500)='';
	DECLARE @ErrorLogfolderPath varchar(1000);
	SELECT @EmailSubject = EmailSubject,@ErrorLogfolderPath = ErrorLogfolderPath FROM QB_DataImport.[dbo].[QB_TableMapping] WHERE [ConnectionId]= @ConnectionID AND [CountryISO2A] = @CountryCode;
	---'France Quest Back New Recruit Job SUCCEEDED (Pre Live)'
		--,@ErrorLogfolderPath varchar(1000)='\\KWSLOAPP011\Imports\Questionaire\'

	DECLARE @bcpPath varchar(100) = '@"C:\Program Files\Microsoft SQL Server\110\Tools\Binn\bcp.exe"'
	DECLARE @EmailBody NVARCHAR(MAX)=''
	DECLARE @LastRunDate DATETIME
	DECLARE @Emails NVARCHAR(MAX)
		DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@CountryCode))

	SET @LastRunDate=@Getdate
	DECLARE @ErrorLogfile varchar(100)='QB_Errorlog_FR_'+Convert(nvarchar(max),@LastRunDate,112)+'.txt'	

	DECLARE @ErrorLogfileName varchar(100)=@ErrorLogfolderPath+@ErrorLogfile
	
	DECLARE @ProcessedFileName varchar(100)
	
 
	IF (@ProcessId IS NOT NULL AND EXISTS (SELECT 1 from  [QBI].[ImportAuditSummary] WHERE AuditGUID=@ProcessId))
	BEGIN

			IF @ConnectionID = '2'
			BEGIN

				DECLARE @TOTAL INT = 0;

				SELECT @TOTAL = [TotalRows] FROM  [QBI].[ImportAuditSummary]
									WHERE CountryCode=@CountryCode AND AuditGUID=@ProcessId
				
				SET @EmailBody='<html xmlns=''_http://www.w3.org/1999/xhtml''><head><title></title></head><body>
						Quest Back New Recruit Job. 
					<br/> <b>Results: </b><br/> 
					<b>Total Number of Source Rows: </b> ' +Convert(varchar,(@TOTAL))+ '<br/><br/> 

					<div><table style=''border:1px solid black;border-collapse:collapse;''>
					<tr><th style=''border:1px solid black;border-collapse:collapse;''>File Name</th>
					<th style=''border:1px solid black;border-collapse:collapse;''>Type</th>
					<th style=''border:1px solid black;border-collapse:collapse;''>Total processed records</th>
					<th style=''border:1px solid black;border-collapse:collapse;''>No of inserted records</th>
					<th style=''border:1px solid black;border-collapse:collapse;''>No of updated records</th>
					<th style=''border:1px solid black;border-collapse:collapse;''>Failed/Ignored Records</th></tr>'

					SELECT @EmailBody = @EmailBody +'<tr><td style=''border:1px solid black;border-collapse:collapse;''>'+[Filename]+'</td>
									
					<td style=''border:1px solid black;border-collapse:collapse;''>QB Import</td>
					<td style=''border:1px solid black;border-collapse:collapse;text-align:center''>'+Convert(varchar,(TotalRows))+'</td>				
					<td style=''border:1px solid black;border-collapse:collapse;text-align:center''>'+Convert(varchar,(PassedRows))++'</td>
					<td style=''border:1px solid black;border-collapse:collapse;text-align:center''>'+Convert(varchar,(UpdatedRows))++'</td>
					<td style=''border:1px solid black;border-collapse:collapse;text-align:center''>'+Convert(varchar,([FailedOrIgnoredRows]))+'</td></tr>'
					FROM
					(
									SELECT [Filename],PanelName,Convert(varchar,[TotalRows]) as TotalRows,								
									Convert(varchar,PassedRows) as PassedRows,
									Convert(varchar,NewPanelistCount) as UpdatedRows,
									Convert(varchar,[TotalRows]-(PassedRows + NewPanelistCount)) as [FailedOrIgnoredRows],
									FileImportDate as rundate 
									FROM  [QBI].[ImportAuditSummary]
									WHERE CountryCode=@CountryCode AND AuditGUID=@ProcessId

					) t
			END
			ELSE
			BEGIN

				SET @EmailBody='<html xmlns=''_http://www.w3.org/1999/xhtml''><head><title></title></head><body>
						Quest Back New Recruit Job. 
					<br/> <b>Results: </b><br/> <div><table style=''border:1px solid black;border-collapse:collapse;''>
					<tr><th style=''border:1px solid black;border-collapse:collapse;''>File Name</th>
					<th style=''border:1px solid black;border-collapse:collapse;''>Type</th>
					<th style=''border:1px solid black;border-collapse:collapse;''>Total Records</th>
					<th style=''border:1px solid black;border-collapse:collapse;''>Passed Records</th>
					<th style=''border:1px solid black;border-collapse:collapse;''>Failed Records</th></tr>'

				SELECT @EmailBody = @EmailBody +'<tr><td style=''border:1px solid black;border-collapse:collapse;''>'+[Filename]+'</td>				
				<td style=''border:1px solid black;border-collapse:collapse;''>QB Import</td>
				<td style=''border:1px solid black;border-collapse:collapse;text-align:center''>'+Convert(varchar,(TotalRows))+'</td>				
				<td style=''border:1px solid black;border-collapse:collapse;text-align:center''>'+Convert(varchar,(PassedRows))++'</td>
				<td style=''border:1px solid black;border-collapse:collapse;text-align:center''>'+Convert(varchar,FailedRows)+'</td></tr>'
				FROM
				(
								SELECT [Filename],PanelName,Convert(varchar,[TotalRows]) as TotalRows,								
								Convert(varchar,PassedRows) as PassedRows,
								Convert(varchar,[TotalRows]-PassedRows) as FailedRows ,FileImportDate as rundate 
								FROM  [QBI].[ImportAuditSummary]
								WHERE CountryCode=@CountryCode AND AuditGUID=@ProcessId

				) t
		END

                SET @EmailBody=@EmailBody+'</table></div>'

				   IF EXISTS (SELECT 1 FROM QB_DataImport.dbo.ERROR_LOG ERR WHERE ProcessId=@ProcessId)
                    BEGIN

						SET @EmailBody=@EmailBody+'<div style=''margin-top: 5px''>'
						SET @EmailBody=@EmailBody+'<b>Errors occurred during the Import</b> '
						SET @EmailBody=@EmailBody+' Please check the attached '+@ErrorLogfile+' file for error logs.</div>'

						DECLARE @ErrorStr VARCHAR(2000)
						SET @ErrorStr=''+ @bcpPath + ' "SELECT ''Id''+ char(9) +''BusinessArea''+ char(9) +''SourceKey''+ char(9) +''ErrorDescription'' UNION ALL SELECT cast(ERR.ERROR_ID as nvarchar(1000))  + char(9) + ERR.BusinessArea + char(9) +ERR.SourceKey + char(9) + ERR.Error_Description  FROM QB_DataImport.dbo.ERROR_LOG ERR WHERE ERR.ProcessId='''+@ProcessId+'''" queryout "'+@ErrorLogfileName+'" -c -t, -T -S'+ @@SERVERNAME 

						select @ErrorStr 

						select @ErrorStr as test

						EXEC master.dbo.xp_cmdshell @ErrorStr
						SET @EmailSubject=@EmailSubject+'– Errors occurred'

                    END
                    ELSE 
                    BEGIN
                        SET @EmailBody=@EmailBody+'<div style=''margin-top: 5px''>'
                        SET @EmailBody=@EmailBody+'<i>Note: No error occured during the QB import processes.</i></div>'
                    END
             
	END
	ELSE
	BEGIN
	
					SET @EmailBody=@EmailBody+'<tr><td style=''border:1px solid black;border-collapse:collapse;''>
					</td><td style=''border:1px solid black;border-collapse:collapse;''></td><td style=''border:1px solid black;border-collapse:collapse;text-align:center''>
					</td><td style=''border:1px solid black;border-collapse:collapse;text-align:center''>
					</td><td style=''border:1px solid black;border-collapse:collapse;text-align:center''></td></tr>'
	END
 
	SELECT TOP (1) @Emails=Emails FROM QB_DataImport.dbo.ftpConnectionInfo  WHERE CountryISO2a = @CountryCode and ConnectionID = @ConnectionID
	SET @EmailBody=@EmailBody+'</body></html>'
	SET @EmailSubject=@EmailSubject+'.'
 
 print @EmailBody

--	USE msdb


	IF EXISTS (SELECT 1 FROM QB_DataImport.dbo.ERROR_LOG ERR WHERE ProcessId=@ProcessId)
	BEGIN
	DECLARE @attachments varchar(200)= @ErrorLogfileName 

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'SQLMAIL',
		@recipients = @Emails,
		@subject = @EmailSubject,
		@body =  @EmailBody
		,@body_format= 'HTML',
		@file_attachments=@attachments
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