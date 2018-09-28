CREATE PROCEDURE [dbo].[GetJobViewerGrid_VisualCron_AdminScreens] (
     @pischkhistory bit
	,@pcountrycode VARCHAR(10)
	,@pSortCol VARCHAR(20) = ''
	,@pPage INT = 1
	,@pRecsPerPage INT = 10
	)
AS
BEGIN
BEGIN TRY 
DECLARE @EmptyGuid UNIQUEIDENTIFIER
SET @EmptyGuid = '00000000-0000-0000-0000-000000000000'

DECLARE @Jobs TABLE (
	JobName NVARCHAR(3000)
	,JobDescription NVARCHAR(3000)
	,StartDate DATETIME
	,EndDate DATETIME
	,JobStatus NVARCHAR(3000)
	,ExecutionTime Float(53)
	,Origin NVARCHAR(3000)
	,ProcessId UNIQUEIDENTIFIER
	,JobProcessType nvarchar(3000)
	)

IF @pischkhistory = 'true'

BEGIN
INSERT INTO @Jobs
select ProcessName as JobName,StatusDescrip as JobDescription ,StartDateTime     as StartDate,  StopDateTime  as  EndDate ,ProcessStatus as JobStatus,ExecTime_Mins_Complete as ExecutionTime , CountryISO2A as Origin ,ProcessGUID as ProcessId, ProcessType as JobProcessType  from [Process]  where ProcessType = 'VisualCron_Job'   order by ProcessGUId desc
--select ProcessName as JobName,StatusDescrip as JobDescription , convert(nvarchar(MAX), StartDateTime, 121)     as StartDate, convert(nvarchar(MAX), StopDateTime, 121)   as  EndDate ,ProcessStatus as JobStatus,StartDateTime from [Process] 
END
ELSE
BEGIN
INSERT INTO @Jobs
select ProcessName as JobName,StatusDescrip as JobDescription ,StartDateTime     as StartDate,  StopDateTime  as  EndDate ,ProcessStatus as JobStatus,ExecTime_Mins_Complete as ExecutionTime , CountryISO2A as Origin ,ProcessGUID as ProcessId, ProcessType as JobProcessType  from [Process]  where ProcessType = 'VisualCron_Job' and ParentId = @EmptyGuid   order by ProcessGUId desc
END
DECLARE @FirstRec INT
	,@LastRec INT
SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage
SELECT @LastRec = (@pPage * @pRecsPerPage + 1)
SELECT count(*) AS TotalRecords
FROM @Jobs 
;WITH CTE_Results
AS (
		SELECT ROW_NUMBER() OVER (
				ORDER BY ProcessId DESC
				) AS ROWNUM
			,JobName
			,JobDescription
			,StartDate
			,EndDate
			,JobStatus
			,ExecutionTime
			,Origin
		FROM @Jobs
		)

SELECT JobName
	,JobDescription
	,convert(NVARCHAR(100), StartDate, 121) AS StartDate
	,convert(NVARCHAR(100), EndDate, 121) AS EndDate
	,JobStatus
	,ExecutionTime
	,Origin
FROM CTE_Results

WHERE ROWNUM > @FirstRec
	AND ROWNUM < @LastRec
ORDER BY ROWNUM ASC
--WHERE ROWNUM > @FirstRec
	--AND ROWNUM < @LastRec 
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