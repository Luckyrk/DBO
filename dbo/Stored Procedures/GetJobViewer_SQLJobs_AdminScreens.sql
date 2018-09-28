CREATE PROCEDURE [dbo].[GetJobViewer_SQLJobs_AdminScreens] (
	@pcountrycode VARCHAR(10)
	,@pSortCol VARCHAR(20) = ''
	,@pPage INT = 1
	,@pRecsPerPage INT = 10
	)
AS
begin
BEGIN TRY 
DECLARE @Jobs TABLE (
	JobName NVARCHAR(3000)
	,JobDescription NVARCHAR(3000)
	,StartDate DATETIME
	,EndDate DATETIME
	,JobStatus NVARCHAR(3000)
	,ExecutionTime INT
	,Origin NVARCHAR(3000)
	)
	--convert(nvarchar(MAX), StartDateTime, 121) 
	--convert(DATE, StartDateTime) 

INSERT INTO @Jobs
SELECT ProcessName AS JobName
	,StatusDescrip AS JobDescription
	,StartDateTime AS StartDate
	,StopDateTime AS EndDate
	,ProcessStatus AS JobStatus
	,ExecTime_Mins_Complete AS ExecutionTime
	,CountryISO2A AS Origin
FROM [Process]
WHERE ProcessType = 'SQL_Job'
--select ProcessName as JobName,StatusDescrip as JobDescription , convert(nvarchar(MAX), StartDateTime, 121)     as StartDate, convert(nvarchar(MAX), StopDateTime, 121)   as  EndDate ,ProcessStatus as JobStatus,StartDateTime from [Process] 
DECLARE @FirstRec INT
	,@LastRec INT

SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage
SELECT @LastRec = (@pPage * @pRecsPerPage + 1)
SELECT count(*) AS TotalRecords
FROM @Jobs 
; WITH CTE_Results
AS (
	SELECT ROW_NUMBER() OVER (

			ORDER BY  StartDate
				 DESC
			) AS ROWNUM
		,JobName
		,JobDescription
		,  StartDate
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