CREATE FUNCTION [dbo].[fn_GetSqlJobAuditByJobID] (
	@jobID BIGINT
	,@jobRunDate NVARCHAR(10) = NULL
      )
RETURNS @retTable TABLE (
      JobAuditId BIGINT NOT NULL
      ,JobName NVARCHAR(200) NOT NULL
      ,JobRunDate DATETIME NOT NULL
      ,AuditStatus NVARCHAR(50) NULL
      ,LoggedInUser NVARCHAR(50) NOT NULL
      ,ElapsedTime TIME(7) NULL
      ,ErrorInfo NVARCHAR(max) NULL
	  ,JobId BIGINT NOT NULL
      )
AS
BEGIN
      --declare @jobID bigint,@jobRunDate nvarchar(10)
      --set @jobID = 1
      DECLARE @rundate AS DATETIME

      SET @rundate = (
                  SELECT TOP 1 SJA.JobRunDate AS JobRunDate
                  FROM SqlJobAudit SJA
                  LEFT JOIN SqlJobRuleActionAudit SJRA ON SJRA.JobAuditId = SJA.JobAuditId
                  LEFT JOIN SqlJob SJ ON SJ.Id = SJA.JobId
                  WHERE SJ.Id = @jobID
                  ORDER BY SJA.JobRunDate DESC
                  )

      IF (@jobRunDate IS NOT NULL)
      BEGIN
            SET @rundate = @jobRunDate
      END

      INSERT INTO @retTable
	SELECT SJA.JobAuditId AS JobAuditId
		,SJ.[Description] AS JobName
		,SJA.JobRunDate AS JobRunDate
		,s.Status AS AuditStatus
		,SJA.GPSUser AS LoggedInUser
		,SJA.EllapsedTime AS ElapsedTime
		,SJA.Error_Info AS ErrorInfo
		,SJ.Id AS JobId
	FROM SqlJobAudit SJA
	left JOIN StatusCode s ON s.Code = SJA.StatusCode
      LEFT JOIN SqlJob SJ ON SJ.Id = SJA.JobId
     
      WHERE SJ.Id = @jobID
            AND CONVERT(DATE, SJA.CreationTimeStamp) = CONVERT(DATE, @rundate)
      ORDER BY SJA.JobRunDate DESC

      RETURN;
END