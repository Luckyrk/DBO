	CREATE PROCEDURE [dbo].[JobViewerGridFilter_AdminScreen] (

@psearchText VARCHAR(10) 

	,@pcountrycode VARCHAR(10)

	,@pSortCol VARCHAR(20) = ''

	,@pPage INT = 1

	,@pRecsPerPage INT = 10


	)

AS
begin

BEGIN TRY 

--convert(nvarchar(10), StartDate, 120) 
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

	)



INSERT INTO @Jobs

select ProcessName as JobName,StatusDescrip as JobDescription ,StartDateTime AS StartDate ,StopDateTime AS   EndDate ,ProcessStatus as JobStatus from [Process] 

where 
 	Process.ProcessName LIKE '%'+@psearchText+'%'

		OR Process.StatusDescrip LIKE '%'+@psearchText+'%'
		OR Process.StartDateTime   LIKE '%'+@psearchText+'%'
		OR Process.StopDateTime  LIKE '%'+@psearchText+'%'
		OR Process.ProcessStatus LIKE '%'+@psearchText+'%'
		or   convert(nvarchar(10), Process.StartDateTime, 120)   LIKE '%'+@psearchText+'%'
		or  convert(nvarchar(10), Process.StopDateTime, 120)    LIKE '%'+@psearchText+'%'

DECLARE @FirstRec INT

	,@LastRec INT



SELECT @FirstRec = (@pPage - 1) * @pRecsPerPage



SELECT @LastRec = (@pPage * @pRecsPerPage + 1)



SELECT count(*) AS TotalRecords

FROM @Jobs

; WITH CTE_Results

AS (

	SELECT ROW_NUMBER() OVER (

			ORDER BY StartDate DESC

				

			) AS ROWNUM

		,JobName

		,JobDescription

		,StartDate

		,EndDate

		,JobStatus



	FROM @Jobs

	)

SELECT JobName

	,JobDescription 

	,convert(nvarchar(100), StartDate , 121)  as StartDate ,convert(nvarchar(100), EndDate , 121)  as EndDate,JobStatus 

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
end
