GO
--IF EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'EmailNotificationOnQBI_Failure')
--DROP PROCEDURE EmailNotificationOnQBI_Failure
--GO

CREATE PROCEDURE EmailNotificationOnQBI_Failure
@EmailSubject Varchar(200) =  'Quest Back Job  - Failed (Live)'
AS 
/**********************************************************************************************************************
CREATE BY : Suresh
Purpose: Email notification after QBImport job failure.

   PBI: 33475 applied.
-- EXECUTE GPS_PM.DBO.EmailNotificationOnQBI_Failure 'Quest Back Job  - Failed(Live)'
***********************************************************************************************************************************/
BEGIN
	DECLARE @EmailBody NVARCHAR(MAX)
	DECLARE @LastRunDate DATETIME
	DECLARE @Emails NVARCHAR(MAX)

	SET @LastRunDate=GETDATE()

	SET @EmailBody='<html xmlns=''_http://www.w3.org/1999/xhtml''><head><title></title></head><body> Quest Back Job has failed for date :'+convert(nvarchar(50),Getdate(),111)
	SET @EmailBody=@EmailBody+'</table></div></body></html>'
	SELECT TOP (1) @Emails=Emails FROM [QB_DataImport].[dbo].ftpConnectionInfo
	SET @EmailBody=@EmailBody+'</table></div></body></html>'
 
	EXEC msdb.dbo.sp_send_dbmail
	@profile_name = 'SQLMAIL',
	@recipients = @Emails,
	@subject = @EmailSubject ,
	@body = @EmailBody,
	@body_format= 'HTML'


END
 GO