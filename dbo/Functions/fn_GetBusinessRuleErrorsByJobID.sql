
CREATE FUNCTION [dbo].[fn_GetBusinessRuleErrorsByJobID] (
	@jobID BIGINT
	,@jobRunDate NVARCHAR(10) = NULL
	)
RETURNS @retTable TABLE (
	BusinessRuleExceptionLogId UNIQUEIDENTIFIER NOT NULL
	,JobAuditId BIGINT NOT NULL
	,JobRunDate DATETIME NOT NULL
	,RuleActionName NVARCHAR(50) NULL
	,BusinessId NVARCHAR(50) NULL
	,PanelName NVARCHAR(100) NULL
	,CountryCode VARCHAR(4) NULL
	,ApplicationName NVARCHAR(200) NULL
	,Version INT NULL
	,LoggedInUser NVARCHAR(50) NOT NULL
	,ElapsedTime TIME(7) NULL
	,ErrorInfo NVARCHAR(max) NULL
	)
AS
BEGIN
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
	SELECT BRE.Id AS BusinessRuleExceptionLogId
		,SJA.JobAuditId AS JobAuditId
		,SJA.JobRunDate AS JobRunDate
		,BRE.BusinessRule AS RuleActionName
		,BRE.BusinessId AS BusinessId
		,BRE.PanelCode AS PanelCode
		,BRE.CountryCode AS CountryCode
		,BRE.ApplicationName AS ApplicationName
		,BRE.Version AS Version
		,SJA.GPSUser AS LoggedInUser
		,SJA.EllapsedTime AS ElapsedTime
		,BRE.ExceptionDetail AS ErrorInfo
	FROM BusinessRuleExceptionLog BRE
	LEFT JOIN SqlJobAudit SJA ON BRE.JobAuditId = SJA.JobAuditId
	LEFT JOIN StatusCode s ON s.Code = 0 --Only errors related for Failed jobs
	LEFT JOIN SqlJob SJ ON SJ.Id = SJA.JobId
	WHERE SJ.Id = @jobID
		AND CONVERT(DATE, SJA.CreationTimeStamp) = CONVERT(DATE, @rundate)
	ORDER BY SJA.JobRunDate DESC

	RETURN;
END