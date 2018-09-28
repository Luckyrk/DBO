CREATE PROCEDURE [dbo].[JobViewerGrid_AdminScreen] (
	@pcountrycode VARCHAR(10)
	,@pSortCol VARCHAR(20) = ''
	,@pPage INT = 1
	,@pRecsPerPage INT = 10
	)
AS
begin

  --public string JobName { get; set; }
  --      public string JobDescription { get; set; }
  --      public DateTime StartDate { get; set; }
  --      public DateTime EndDate { get; set; }
  --      public string JobStatus { get; set; }
DECLARE @Jobs TABLE (
	JobName nvarchar(3000)
	,JobDescription nvarchar(3000)
	,StartDate Datetime
	,EndDate Datetime
	,JobStatus nvarchar(3000)
	,StartDateTime Datetime
	)
	--convert(nvarchar(MAX), StartDateTime, 121) 
	--convert(DATE, StartDateTime) 
INSERT INTO @Jobs

	select ProcessName as JobName,StatusDescrip as JobDescription ,StartDateTime     as StartDate,  StopDateTime  as  EndDate ,ProcessStatus as JobStatus,StartDateTime from [Process] 

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
		,StartDateTime

	FROM @Jobs
	)
SELECT JobName
	,JobDescription 
	,convert(nvarchar(100), StartDate, 121)  as StartDate,convert(nvarchar(100), EndDate, 121)  as EndDate
		,JobStatus,JobStatus 
FROM CTE_Results
WHERE ROWNUM > @FirstRec
	AND ROWNUM < @LastRec


end