CREATE PROCEDURE [dbo].LongRunningSqlQueries_AdminScreen (
	@pCountryISO2A VARCHAR(10) = ''
	,@psearchText VARCHAR(max) = ''
	,@pSortCol VARCHAR(20) = ''
	,@pPage INT = 1
	,@pRecsPerPage INT = 20
	,@pSortDirection VARCHAR(50) = ''
	,@pIsFilter INT = 0
	,@pQueryF VARCHAR(max) = ''
	,@pFromdateF VARCHAR(100) = ''
	,@pTodateF VARCHAR(100) = ''
	,@pTimeElapsedF VARCHAR(100) = ''
	,@pStatusF VARCHAR(100) = ''
	,@pDatabaseNameF VARCHAR(100) = ''
	,@pLogInNameF VARCHAR(100) = ''
	,@pHostNameF VARCHAR(100) = ''
	,@pProgramNameF VARCHAR(100) = ''
	,@pSessionIdF VARCHAR(100) = ''
	--,@pHistoryF varchar(100)=''
	,@pViewHistory INT = 0
	)
AS
BEGIN
	IF (@pTimeElapsedF = 0)
	BEGIN
		SET @pTimeElapsedF = ''
	END

	IF (@pSessionIdF = 0)
	BEGIN
		SET @pSessionIdF = ''
	END
	DECLARE @MaximumValue INT = (
		SELECT [ThresholdValue]
		FROM [master].[dbo].[SetThreshold]
		WHERE [ThresholdName] = 'Maximum'
		)
DECLARE @MinimumValue INT = (
		SELECT [ThresholdValue]
		FROM [master].[dbo].[SetThreshold]
		WHERE [ThresholdName] = 'Minimum'
		)
DECLARE @currentdate DATETIME = getdate()
DECLARE @Categorytable TABLE (
	[Query] VARCHAR(100)
	,[StartTime] [DateTime]
	,[TimeElapsed] BIGINT
	,[Status] VARCHAR(50)
	,DatabaseName NVARCHAR(50)
	,LogInName NVARCHAR(300)
	,HostName NVARCHAR(100)
	,[ProgramName] NVARCHAR(max)
	,CurrentTime [dateTime]
	,SessionId INT
	,History VARCHAR(100)
	)
	DECLARE @Final TABLE (
	ROWNUM BIGINT
	,[Query] VARCHAR(100)
	,[StartTime] [DateTime]
	,[TimeElapsed] BIGINT
	,[Status] VARCHAR(50)
	,DatabaseName NVARCHAR(50)
	,LogInName NVARCHAR(300)
	,HostName NVARCHAR(100)
	,[ProgramName] NVARCHAR(max)
	,CurrentTime [dateTime]
	,SessionId INT
	,History VARCHAR(100)
	)
DECLARE @LongRunningQueries AS TABLE (
	[id] [int] IDENTITY(1, 1) NOT NULL
	,[Query] [nvarchar](100) NULL
	,[StartTime] [datetime] NULL
	,[DB_Id] INT NULL
	,[TimeElapsed] INT NULL
	,[Status] [varchar](1000) NULL
	,[DB_Name] [varchar](1000) NULL
	,[Login_Name] [varchar](1000) NULL
	,[host_name] [varchar](100) NULL
	,[program_name] [varchar](max) NULL
	,[CurrentTimeStamp] [datetime] NULL
	,[Session_Id] INT NULL
	-- ,[History] [varchar](100) NuLL
	)
	INSERT INTO @LongRunningQueries
SELECT Left(TEXT, 100) AS Query
	,dr.start_time
	,dr.database_id
	,dr.total_elapsed_time / 1.0
	,dr.[status]
	,Db_name(dr.database_id) AS DatabaseName
	,se.login_name
	,se.host_name
	,se.program_name
	,@currentdate AS currenttime
	,dr.session_id
-- ,'History' as [History]
FROM sys.dm_exec_requests dr
INNER JOIN sys.dm_exec_sessions se ON dr.session_id = se.session_id
CROSS APPLY sys.Dm_exec_sql_text(sql_handle)
WHERE dr.database_id NOT IN (
		1
		,2
		,3
		,4
		)
	-- AND dr.total_elapsed_time/1.0  >@MaximumValue*1000
	AND dr.total_elapsed_time / 1.0 > @MinimumValue * 1000

INSERT INTO [master].[dbo].[MonitorLongRunningQueries]
SELECT [Query]
	,[StartTime]
	,[DB_Id]
	,[TimeElapsed]
	,[Status]
	,[DB_Name]
	,[Login_Name]
	,[host_name]
	,[program_name]
	,[CurrentTimeStamp]
	,[Session_Id]
	,'History'
FROM @LongRunningQueries L
WHERE [TimeElapsed] / 1.0 > @MaximumValue * 1000
	AND NOT EXISTS (
		SELECT 1
		FROM [master].[dbo].[MonitorLongRunningQueries] M
		WHERE L.[StartTime] = M.[StartTime]
			AND L.session_id = M.[Session_Id]
		)
UPDATE M
SET M.[TimeElapsed] = L.[TimeElapsed] / 1.0
	,M.[Status] = L.[Status]
	,M.[CurrentTimeStamp] = @currentdate
FROM [master].[dbo].[MonitorLongRunningQueries] AS M
INNER JOIN @LongRunningQueries L ON L.[StartTime] = M.[StartTime]
	AND L.session_id = M.[Session_Id]
			INSERT INTO @Categorytable



	 SELECT 
	[Query],[StartTime], [TimeElapsed],
	[Status],[DB_Name], [Login_Name], [host_name], 
	[program_name], [CurrentTimeStamp], [Session_Id],   'Running' 
	 FROM @LongRunningQueries where  ([Query] like '%'+@pQueryF+'%'or isnull (@pQueryF,'') ='')
	 -- and  ([TimeElapsed] like '%'+@pTimeElapsedF+'%'or isnull (@pTimeElapsedF,'') ='')
 and  ([TimeElapsed]/1000.0 >= convert(BigINT, @pTimeElapsedF) or isnull (@pTimeElapsedF,'') ='') 
	  and ([Status] like '%'+@pStatusF+'%' or isnull (@pStatusF,'') ='')
	and ([DB_Name] like  '%'+@pDatabaseNameF+'%'or isnull (@pDatabaseNameF,'') ='' )
	and ([Login_Name] like  '%'+@pLogInNameF+'%'or isnull (@pLogInNameF,'') ='')
	and ([host_name]  like  '%'+@pHostNameF+'%'or isnull (@pHostNameF,'') ='')
	and ([program_name]like  '%'+@pProgramNameF+'%'or isnull (@pProgramNameF,'') ='')
	and ([Session_Id] like  '%'+@pSessionIdF+'%'or isnull (@pSessionIdF,'') ='')
	and  ( (isnull(@pFromdateF,'')='') or ([StartTime] between @pFromdateF and @pTodateF) ) 


	
	 if (@pViewHistory=1)
	 BEGIN
	INSERT INTO @Categorytable 
	 SELECT 
	[Query],[StartTime], [TimeElapsed],
	[Status],[DB_Name], [Login_Name], [host_name], 
	[program_name], [CurrentTimeStamp], [Session_Id],  History 	 
	from [master].[dbo].[MonitorLongRunningQueries] M
	Where  NOT EXISTS (
			select 1 from 
			@LongRunningQueries L
			WHERE L.[StartTime] = M.[StartTime]
			AND L.session_id = M.[Session_Id]
		) and ( ([Query] like '%'+@pQueryF+'%'or isnull (@pQueryF,'') ='')
	 and  ([TimeElapsed]/1000.0 >= convert(BigINT, @pTimeElapsedF) or isnull (@pTimeElapsedF,'') ='')
	  and ([Status] like '%'+@pStatusF+'%' or isnull (@pStatusF,'') ='')
	and ([DB_Name] like  '%'+@pDatabaseNameF+'%'or isnull (@pDatabaseNameF,'') ='' )
	and ([Login_Name] like  '%'+@pLogInNameF+'%'or isnull (@pLogInNameF,'') ='')
	and ([host_name]  like  '%'+@pHostNameF+'%'or isnull (@pHostNameF,'') ='')
	and ([program_name]like  '%'+@pProgramNameF+'%'or isnull (@pProgramNameF,'') ='')
	and ([Session_Id] like  '%'+@pSessionIdF+'%'or isnull (@pSessionIdF,'') ='')
	 and ( (isnull(@pFromdateF,'')='') or ([StartTime] between @pFromdateF and @pTodateF) ) 

		) 
		END
		DECLARE @total INT

SET @total = (
		SELECT count(*) AS TotalRecords
		FROM @Categorytable
		)

DECLARE @FirstRec1 INT
	,@LastRec1 INT

SELECT @FirstRec1 = (@pPage - 1) * @total

SELECT @LastRec1 = (@pPage * @total + 1)

DECLARE @FirstRec INT
	,@LastRec INT

SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage

SELECT @LastRec = (@pPage * @pRecsPerPage + 1)

INSERT INTO @Final
SELECT *
FROM (
	SELECT ROW_NUMBER() OVER (
			ORDER BY CASE 
					WHEN @pSortCol = 'Query'
						AND @pSortDirection = 'Asc'
						THEN Query
					END ASC
				,CASE 
					WHEN @pSortCol = 'Query'
						AND @pSortDirection = 'DESC'
						THEN Query
					END DESC
				,CASE 
					WHEN @pSortCol = 'StartTime'
						AND @pSortDirection = 'Asc'
						THEN StartTime
					END ASC
				,CASE 
					WHEN @pSortCol = 'StartTime'
						AND @pSortDirection = 'DESC'
						THEN StartTime
					END DESC
				,CASE 
					WHEN @pSortCol = 'TimeElapsed'
						AND @pSortDirection = 'Asc'
						THEN TimeElapsed
					END ASC
				,CASE 
					WHEN @pSortCol = 'TimeElapsed'
						AND @pSortDirection = 'DESC'
						THEN TimeElapsed
					END DESC
				,CASE 
					WHEN @pSortCol = 'Status'
						AND @pSortDirection = 'Asc'
						THEN STATUS
					END ASC
				,CASE 
					WHEN @pSortCol = 'Status'
						AND @pSortDirection = 'DESC'
						THEN STATUS
					END DESC
				,CASE 
					WHEN @pSortCol = 'DatabaseName'
						AND @pSortDirection = 'Asc'
						THEN DatabaseName
					END ASC
				,CASE 
					WHEN @pSortCol = 'DatabaseName'
						AND @pSortDirection = 'DESC'
						THEN DatabaseName
					END DESC
				,CASE 
					WHEN @pSortCol = 'LogInName'
						AND @pSortDirection = 'Asc'
						THEN LogInName
					END ASC
				,CASE 
					WHEN @pSortCol = 'LogInName'
						AND @pSortDirection = 'DESC'
						THEN LogInName
					END DESC
				,CASE 
					WHEN @pSortCol = 'HostName'
						AND @pSortDirection = 'Asc'
						THEN HostName
					END ASC
				,CASE 
					WHEN @pSortCol = 'HostName'
						AND @pSortDirection = 'DESC'
						THEN HostName
					END DESC
				,CASE 
					WHEN @pSortCol = 'ProgramName'
						AND @pSortDirection = 'Asc'
						THEN ProgramName
					END ASC
				,CASE 
					WHEN @pSortCol = 'ProgramName'
						AND @pSortDirection = 'DESC'
						THEN ProgramName
					END DESC
				,CASE 
					WHEN @pSortCol = 'CurrentTime'
						AND @pSortDirection = 'Asc'
						THEN CurrentTime
					END ASC
				,CASE 
					WHEN @pSortCol = 'CurrentTime'
						AND @pSortDirection = 'DESC'
						THEN CurrentTime
					END DESC
				,CASE 
					WHEN @pSortCol = 'SessionId'
						AND @pSortDirection = 'Asc'
						THEN SessionId
					END ASC
				,CASE 
					WHEN @pSortCol = 'SessionId'
						AND @pSortDirection = 'DESC'
						THEN SessionId
					END DESC
				,CASE 
					WHEN @pSortCol = 'History'
						AND @pSortDirection = 'Asc'
						THEN History
					END ASC
				,CASE 
					WHEN @pSortCol = 'History'
						AND @pSortDirection = 'DESC'
						THEN History
					END DESC
				,CASE 
					WHEN @pSortCol = ''
						AND @pSortDirection = ''
						THEN TimeElapsed
					END DESC
			) AS ROWNUM
		,[Query]
		,[StartTime]
		,([TimeElapsed] / 1000.0) AS [TimeElapsed]
		,[Status]
		,DatabaseName
		,LogInName
		,HostName
		,[ProgramName]
		,CurrentTime
		,SessionId
		,History
	FROM @Categorytable
	) TT
	SELECT count(*) AS TotalRecords
FROM @Final;

WITH CTE_Results1
AS (
	SELECT ROW_NUMBER() OVER (
			ORDER BY @pSortCol ASC
			) AS ROWNUM1
		,[Query]
		,[StartTime]
		,[TimeElapsed]
		,[Status]
		,DatabaseName
		,LogInName
		,HostName
		,[ProgramName]
		,CurrentTime
		,SessionId
		,History
	FROM @Final
	)
	SELECT ROWNUM
	,[Query]
	,[StartTime]
	,([TimeElapsed]) AS [TimeElapsed]
	,[Status]
	,DatabaseName
	,LogInName
	,HostName
	,[ProgramName]
	,CurrentTime
	,SessionId
	,History
FROM @final
WHERE ROWNUM > @FirstRec
	AND ROWNUM < @LastRec
	--ORDER BY ROWNUM
	END


