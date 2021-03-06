 CREATE PROCEDURE [dbo].[ExecuteGPSImportsPackage2] 
		 @PackageName NVARCHAR(200)  
        ,@PackageServer NVARCHAR(200)  
        ,@FolderPath NVARCHAR(500) 
        ,@DTexePath NVARCHAR (500) = N'c: & cd\ & cd "C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\"'
        ,@LogFilePath NVARCHAR(500) = N'\\KWSLOAPP002\Imports\Log\DTEXECLogging.txt'
 AS
 --  This shold be run on all Regions (DBs)
/*---------------------------------------------------------------------------------------------------------------------
Created By  :	Suresh
Version		:	2
 --  This shold be run on all Regions 
DATE				Name						Change
16-JUN-2016		Suresh Policharla		Change in SSIS Package deployment model to Catalog type, and so command has been changed.
20-JUL-2016		Suresh					Created Job script to run package

SP Calls:
 File was placed in the wrong folder : \\kwsloapp011\Imports\PurchaseSummaryCounts\Iberia\ES\Beauty
--	exec  [ExecuteGPSImportsPackage2] 'PurchaseSummaryCountsImport', 'KWSLOSQL001\KWSLOSQL2012', '\\kwsloapp011\Imports\PurchaseSummaryCounts\TW\MP\'
	exec  [ExecuteGPSImportsPackage2] '\SSISDB\GPS_IMPORTS\GPSImports_ASIA\PanelistEligibilityImport.dtsx', 'KWSLOSQL001\KWSLOSQL2012',
	 '\\kwsloapp011\Imports\EligibilityImport\TW\BP\Insert'
----------------------------------------------------------------------------------------------------------------------*/
BEGIN
BEGIN TRY 
        DECLARE @command NVARCHAR(MAX);
        DECLARE @Msg NVARCHAR(1000);
        DECLARE @TB AS TABLE (Result NVARCHAR(MAX));

		Declare @CountryCode VARCHAR(20) 

	--	select  @FolderPath
--	select  *	from SSISFileImportsConfig Where FilePath = @FolderPath
--	Where FilePath = '\\kwsloapp011\Imports\PurchaseSummaryCounts\TW\LP\Insert'  --  @FolderPath

	If exists ( select 1 from SSISFileImportsConfig
	Where ltrim(rtrim(FilePath)) = ltrim(rtrim(@FolderPath)) 
	 )
	begin		 

		
		declare @ProjectName as varchar(100)
		declare @referenceID as varchar(100)

		declare @T table
		(
		  PackageName varchar(250)
		)

		insert into @T values
		( @PackageName )
 
		 --DECLARE  @PackageName varchar(200) = 'SSISDB\GPS_IMPORTS\GPSImports_ASIA\PanelistEligibilityImport.dtsx'

		 select @ProjectName = substring(PackageName, P3.Pos + 1, P4.Pos - P3.Pos - 1)
		 from @T
		  cross apply (select (charindex('\', PackageName))) as P1(Pos)
		  cross apply (select (charindex('\', PackageName, P1.Pos+1))) as P2(Pos)
		  cross apply (select (charindex('\', PackageName, P2.Pos+1))) as P3(Pos)
		  cross apply (select (charindex('\', PackageName, P3.Pos+1))) as P4(Pos)

		SELECT @referenceID=  reference_id
		FROM SSISDB.internal.environment_references R
		Join  SSISDB.catalog.projects P
		ON P.project_id = R.project_id
		where [name] = @ProjectName 
	  
		SET @command=N'/ISSERVER "\"' + @PackageName  +'\"" /SERVER  "\"' + @PackageServer + '\""  /ENVREFERENCE  "\"' + @referenceID + '\""  /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING N';
		SET @command = @command + ' /SET \Package.Variables[User::ImportFilePath].Properties[Value];' + @FolderPath; 
		        SET @Msg = @DTexePath + ' & DTexec.exe ' + @command;
				--use master
						INSERT INTO @TB
        EXEC xp_cmdshell @Msg;

        SELECT RESULT  FROM @TB;

/*		
DECLARE @sp varchar(max)	 
SET @sp = N'/ISSERVER "\"' + @PackageName  +'\"" /SERVER  "\"' + @PackageServer + '\""  /ENVREFERENCE  "\"' + @referenceID + '\""  /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING N';
-- N'/ISSERVER "\"\SSISDB\GPS_IMPORTS\GPSImports_ASIA\PurchaseSummaryCountsImport.dtsx\"" /SERVER "\"KWSLOSQL001\KWSLOSQL2012\"" /ENVREFERENCE 21 /Par "\"$ServerOption::LOGGING_LEVEL(Int16)\"";1 /Par "\"$ServerOption::SYNCHRONIZED(Boolean)\"";True /CALLERINFO SQLAGENT /REPORTING E';
SET @sp = @sp + ' /SET \Package.Variables[User::ImportFilePath].Properties[Value];' +  @FolderPath;

print @sp

-----------------------------
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

DECLARE @DBName Varchar(20) = DB_NAME()
 -- select @DBName
DECLARE @jobId BINARY(16)

EXEC @ReturnCode = msdb.dbo.sp_add_job @job_name=N'DUMMY_JOB', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
-- IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

Select @jobid = Job_Id FROM msdb.dbo.sysjobs where [name] = 'DUMMY_JOB'

    EXEC msdb.dbo.sp_add_jobstep @job_id= @jobid, @step_name=N'Step1', 
            @step_id=1, 
            @cmdexec_success_code=0, 
            @on_success_action=1, 
            @on_fail_action=2, 
            @retry_attempts=0, 
            @retry_interval=0, 
        	@os_run_priority=0, @subsystem=N'SSIS', 
            @command=@sp, 
            @database_name= @DBName  , 
            @flags=0
						
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'

EXEC msdb.dbo.sp_start_job N'DUMMY_JOB'
WAITFOR DELAY '000:00:20'

EXEC msdb.dbo.sp_delete_jobstep   @job_name ='DUMMY_JOB' , @step_id = 1
EXEC msdb.dbo.sp_delete_job @job_name ='DUMMY_JOB' 
*/
----------------------------
	Print 'PackageServer: ' + @PackageServer + ', PackageName: ' +  @PackageName + ', FolderPath: ' + @FolderPath

	end
	else
	begin
	
		print 'file path issue:'
		--select Convert(varchar(100), GETDATE()) + ': File was placed in the wrong folder : ' + @FolderPath

		DECLARE @FindFile TABLE 
			(FileNames nvarchar(500)
			,depth int
			,isFile int)

		INSERT INTO @FindFile 
		EXEC xp_DirTree @FolderPath,1,1

		DECLARE @FileName as NVARCHAR(400)
		DECLARE @JobGUID as varchar(200) =  convert(Varchar(200), NEWID())


		SELECT top 1 @FileName = FileNames from @FindFile 
		where isFile=1
		
		DECLARE @ErrorDesc Varchar(300) = ISNULL(@FileName,'') + ' File was placed in the wrong folder : ' + @FolderPath
		 -- select * from FileImportErrorLog order by 1 desc
		INSERT INTO FileImportErrorLog
		([FileName],	CountryCode,	PanelCode,	ImportType,	ErrorSource,	ErrorCode,	ErrorDescription,	ErrorDate,	JobId)
		VALUES(ISNULL(@FileName,''), '', 0,'Unknown', 'Unknown Source',  '0', @ErrorDesc , GETDATE(), @JobGUID)

			---
					declare @emailTable as TABLE (
					emailIds varchar(4000)
					)

					declare @emailConcat varchar(4000)  = ''

					select   @emailConcat= @emailConcat + ';' + EmailIds
					from  SSISFileImportsConfig
					Where  FilePath like  @FolderPath + '%'

					DECLARE @XML xml = N'<r><![CDATA[' + REPLACE(@emailConcat, ';', ']]></r><r><![CDATA[') + ']]></r>'

					INSERT INTO @emailTable (emailIds)
					SELECT distinct RTRIM(LTRIM(T.c.value('.', 'NVARCHAR(4000)')))
					FROM @xml.nodes('//r') T(c)


					SET @emailConcat = ''

					SELECT  @emailConcat= @emailConcat + ';' +EmailIds
					FROM @emailTable
					where emailIds<>''

					select 'Folderpath: ' + @FolderPath + ', FileName : ' + ISNULL(@FileName,'Unknown') + ', DB:' + DB_NAME() + ', Server: ' + HOST_NAME() + ',' +  @emailConcat
		
		--	if LEN(@emailConcat) >0
				EXEC msdb.dbo.sp_send_dbmail @profile_name = 'SQLMAIL'
				,@recipients = @emailConcat
				,@subject = 'SSIS File Imports Notification' 
				,@body =  @ErrorDesc
				,@body_format = 'HTML'
	end
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