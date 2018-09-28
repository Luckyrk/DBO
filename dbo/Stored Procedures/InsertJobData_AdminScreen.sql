CREATE PROCEDURE [dbo].[InsertJobData_AdminScreen]
AS
BEGIN
BEGIN TRY 
SELECT 
jh.instance_id,
 [jobs].Job_Id ,
CASE WHEN jh.run_status=0 THEN 'Failed'
                     WHEN jh.run_status=1 THEN 'Succeeded'
                     WHEN jh.run_status=2 THEN 'Retry'
                     WHEN jh.run_status=3 THEN 'Cancelled'
					  WHEN jh.run_status=4 THEN 'In progress'
               ELSE 'Unknown'  
			   end as JobStatus
		,[Description] = [jobs].[description]
		------As dicussed with mega at present we are keeping dummy country ,it should come from JobCountryMapper table based on [ProcessName] column
		,'DummyCountry' as Country
		,'SQL_Job'  as ProcessType
		, [JobName] = [jobs].[name]
		,(SELECT DB_NAME()) as DBName
		,(select SUSER_SNAME([jobs].[owner_sid])) as [User]
		,(select SUSER_SNAME([jobs].[owner_sid])) as [Host]
		,(select (CONVERT(DATETIME, RTRIM(jh.run_date)) + ((jh.run_time/10000 * 3600) + ((jh.run_time%10000)/100*60) +
       (jh.run_time%10000)%100 /*run_time_elapsed_seconds*/) / (23.999999*3600 /* seconds in a day*/))) as StartDate
      ,CASE WHEN jh.run_status NOT IN (4,1) 
		THEN 
       ( select CONVERT(DATETIME, RTRIM(jh.run_date)) + ((jh.run_time/10000 * 3600) + ((jh.run_time%10000)/100*60) +
(jh.run_time%10000)%100) / (86399.9964 /* Start Date Time */)
+ ((jh.run_duration/10000 * 3600) + ((jh.run_duration%10000)/100*60) + (jh.run_duration%10000)%100
/*run_duration_elapsed_seconds*/) / (86399.9964 /* seconds in a day*/))
ELSE
NULL
END
as EndDate
,jh.run_duration

into #JobTempTable
FROM	 [msdb].[dbo].[sysjobs] AS [jobs] WITh(NOLOCK) 
		 
		 INNER JOIN
    (
        SELECT job_id, instance_id = MAX(instance_id)
            FROM msdb.dbo.sysjobhistory
            GROUP BY job_id
    ) AS l
    ON [jobs].job_id = l.job_id
INNER JOIN

		 msdb.dbo.sysjobhistory AS jh
    ON jh.job_id = l.job_id
    AND jh.instance_id = l.instance_id
				 and   jh.run_date is not null

				 --where [jobs].job_id not in (select job_id from  [msdb].[dbo].[sysjobs] ) 
				 and   jh.run_date is not null

				 order by jh.run_date desc

			

				 --where [jobs].job_id not in (select job_id from  [msdb].[dbo].[sysjobs] ) 
	

			
			
				
				
				INSERT INTO [dbo].[Process]
           ([Instance_Id]
           ,[ProcessGUID]
           ,[ProcessStatus]
           ,[StatusDescrip]
           ,[CountryISO2A]
           ,[ProcessType]
           ,[ProcessName]
           ,[DatabaseName]
           ,[SYSTEM_USER]
           ,[HOST_NAME]
           ,[StartDateTime]
           ,[StopDateTime]
           ,[ExecTime_Mins_Complete])
          
			select * from #JobTempTable [jobs] where [jobs].job_id not in (select ProcessGUID from  Process )

				 order by [jobs].EndDate desc

				 update  P set P.ProcessStatus =T.JobStatus,
				 P.ExecTime_Mins_Complete =T.run_duration
				from Process P inner join #JobTempTable T
				 on P.ProcessGUID=T.Job_Id
				 and P.Instance_Id=T.Instance_Id
				 WHERE p.ProcessGUID  in (select job_id from  [msdb].[dbo].[sysjobs])
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