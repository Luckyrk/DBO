Create PROCEDURE [dbo].[JobViewerGridFilter_VisualCron_AdminScreens](
@pProcesstype varchar(max)
,@pishistoryChecked bit
,@pJobName VARCHAR(max) 
,@pDescription VARCHAR(max) 
,@pStatus VARCHAR(max) 
,@pOrigin VARCHAR(max) 
,@pfromStartDateTime DATETIME
,@ptoStartDateTime DATETIME
,@pSortCol VARCHAR(20) = ''
,@pPage INT = 1
,@pRecsPerPage INT = 10
)
/*
Job History Log:
*/
AS

BEGIN
BEGIN TRY
       BEGIN TRY
              BEGIN
                     IF ISDATE(@pfromStartDateTime) != 1
                           SET @pfromStartDateTime = '1900-01-01 00:00:00.000'

                     IF ISDATE(@ptoStartDateTime) != 1
                           SET @ptoStartDateTime = GETDATE()
                     SET @pfromStartDateTime = ISNULL(@pfromStartDateTime, '1900-01-01 00:00:00.000')
                     SET @ptoStartDateTime = ISNULL(@ptoStartDateTime, GETDATE())
              END
       END TRY

       BEGIN CATCH
       END CATCH

       IF @pfromStartDateTime < '1900-01-01'
              SET @pfromStartDateTime = '1900-01-01'

       IF @ptoStartDateTime < '1900-01-01'
              SET @ptoStartDateTime = GETDATE()

			  
 DECLARE @pEmptyGuid UNIQUEIDENTIFIER
	DECLARE @pprocessdate DATETIME;
	SET @pEmptyGuid = '00000000-0000-0000-0000-000000000000'

DECLARE @Jobs TABLE (
       JobName NVARCHAR(3000)
       ,JobDescription NVARCHAR(3000)
       ,StartDate DATETIME
       ,EndDate DATETIME
       ,JobStatus NVARCHAR(3000)
       ,ExecutionTime FLOAT(53)
       ,Origin NVARCHAR(3000)
       ,ProcessId UNIQUEIDENTIFIER
       ,JobProcessType NVARCHAR(3000)
       )
	   IF(@pishistoryChecked =  'false' AND @pProcesstype = 'VisualCron_Job')
	   BEGIN
INSERT INTO @Jobs
SELECT ProcessName AS JobName
       ,StatusDescrip AS JobDescription
       ,StartDateTime AS StartDate
       ,StopDateTime AS EndDate
       ,ProcessStatus AS JobStatus
       ,ExecTime_Mins_Complete AS ExecutionTime
       ,CountryISO2A AS Origin
       ,ProcessGUID AS ProcessId
       ,ProcessType AS JobProcessType
FROM [Process]
WHERE ProcessType = @pProcesstype and ParentId = @pEmptyGuid
       AND (
              Process.ProcessName LIKE '%' + @pJobName + '%'
              OR @pJobName IS NULL
              )
       AND (
              Process.StatusDescrip LIKE '%' + @pDescription + '%'
              OR @pDescription IS NULL
              )
       AND (
              Process.ProcessStatus LIKE '%' + @pStatus + '%'
              OR @pStatus IS NULL
              )
       AND (
              Process.CountryISO2A LIKE '%' + @pOrigin + '%'
              OR @pOrigin IS NULL
              )
       AND (
              (
                     StartDateTime BETWEEN @pfromStartDateTime
                           AND @ptoStartDateTime
                     )
              OR (
                     @pfromStartDateTime = '1900-01-01 00:00:00.000'
                     AND @ptoStartDateTime = '1900-01-01 00:00:00.000'
                     )
              )
ORDER BY ProcessGUId DESC
END
ELSE 
BEGIN
INSERT INTO @Jobs
SELECT ProcessName AS JobName
       ,StatusDescrip AS JobDescription
       ,StartDateTime AS StartDate
       ,StopDateTime AS EndDate
       ,ProcessStatus AS JobStatus
       ,ExecTime_Mins_Complete AS ExecutionTime
       ,CountryISO2A AS Origin
       ,ProcessGUID AS ProcessId
       ,ProcessType AS JobProcessType
FROM [Process]
WHERE ProcessType = @pProcesstype 
       AND (
              Process.ProcessName LIKE '%' + @pJobName + '%'
              OR @pJobName IS NULL
              )
       AND (
              Process.StatusDescrip LIKE '%' + @pDescription + '%'
              OR @pDescription IS NULL
              )
       AND (
              Process.ProcessStatus LIKE '%' + @pStatus + '%'
              OR @pStatus IS NULL
              )
       AND (
              Process.CountryISO2A LIKE '%' + @pOrigin + '%'
              OR @pOrigin IS NULL
              )
       AND (
              (
                     StartDateTime BETWEEN @pfromStartDateTime
                           AND @ptoStartDateTime
                     )
              OR (
                     @pfromStartDateTime = '1900-01-01 00:00:00.000'
                     AND @ptoStartDateTime = '1900-01-01 00:00:00.000'
                     )
              )
ORDER BY ProcessGUId DESC
END
DECLARE @FirstRec INT
       ,@LastRec INT

SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage

SELECT @LastRec = (@pPage * @pRecsPerPage + 1)

--SELECT count(*) AS TotalRecords
--FROM @Jobs where JobProcessType = 'VisualCron_Job';
SELECT count(*) AS TotalRecords
FROM @Jobs;

WITH CTE_Results
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