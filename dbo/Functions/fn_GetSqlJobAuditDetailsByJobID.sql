CREATE FUNCTION [dbo].[fn_GetSqlJobAuditDetailsByJobID] (
	@jobID BIGINT
	,@jobRunDate NVARCHAR(10) = NULL
	,@jobStatusCode NVARCHAR(20) = NULL
	)
RETURNS @retTable TABLE (
	JobAuditId BIGINT NOT NULL
	,JobName NVARCHAR(200) NOT NULL
	,JobRunDate DATETIME NOT NULL
	,AuditCreationDate DATETIME NULL
	,ActionStatus NVARCHAR(100) NULL
	,RuleActionName NVARCHAR(50) NULL
	,BusinessId NVARCHAR(50) NULL
	,PanelName NVARCHAR(100) NULL
	,CountryCode VARCHAR(4) NULL
	,EntityName NVARCHAR(50) NULL
	,AuditStatus NVARCHAR(50) NULL
	,LoggedInUser NVARCHAR(50) NOT NULL
	,ElapsedTime TIME(7) NULL
	,ErrorInfo NVARCHAR(max) NULL
	,JobId BIGINT NOT NULL
	,RuleActionAuditId BIGINT NOT NULL
	)
AS
BEGIN
	--declare @jobID bigint,@jobRunDate nvarchar(10)      
	--set @jobID = 1      
	DECLARE @rundate AS DATETIME
	DECLARE @jobStatusCode2 NVARCHAR(20) = NULL

	IF (@jobStatusCode = 'R')
		SET @jobStatusCode2 = 'F'
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

	IF @jobStatusCode IS NOT NULL
	BEGIN
		INSERT INTO @retTable
		SELECT SJA.JobAuditId AS JobAuditId
			,SJ.[Description] AS JobName
			,SJA.JobRunDate AS JobRunDate
			,SJRA.CreationTimeStamp AS AuditCreationDate
			,CASE 
				WHEN CommQueue.correlation_id IS NULL
					THEN ISNULL((
								CASE 
									WHEN gpsQueue.subqueue = 'X'
										THEN 'Success'
									WHEN gpsQueue.subqueue = 'R'
										THEN 'WaitingInErrorAndRetryQ'
									WHEN gpsQueue.subqueue = 'F'
										THEN 'FailedQ'
									WHEN gpsQueue.subqueue = 'I'
										THEN 'WaitingInInputQ'
									END
								), 'NotApplicable')
				WHEN CommQueue.correlation_id IS NOT NULL
					THEN ISNULL((
								CASE 
									WHEN CommQueue.subqueue = 'X'
										THEN 'Success'
									WHEN CommQueue.subqueue = 'R'
										THEN 'WaitingInErrorAndRetryQ'
									WHEN CommQueue.subqueue = 'F'
										THEN 'FailedQ'
									WHEN CommQueue.subqueue = 'I'
										THEN 'WaitingInInputQ'
									END
								), 'NotApplicable')
				END AS ActionStatus
			,ISNULL(SJRA.RuleActionName, 'NoAction') AS RuleActionName
			,SJRA.BusinessId AS BusinessId
			,P.NAME AS PanelName
			,SJRA.CountryCode AS CountryCode
			,SJRA.EntityName AS EntityName
			,s.STATUS AS AuditStatus
			,SJ.GPSUser AS LoggedInUser
			,SJA.EllapsedTime AS ElapsedTime
			,(
				CASE 
					WHEN CommQueue.correlation_id IS NULL
						THEN gpsQueue.Error_Info
					WHEN CommQueue.correlation_id IS NOT NULL
						THEN CommQueue.Error_Info
					END
				) AS ErrorInfo
			,SJ.Id AS JobId
			,SJRA.RuleActionAuditId AS RuleActionAuditId
		FROM SqlJobAudit SJA
		LEFT JOIN SqlJobRuleActionAudit SJRA ON SJRA.JobAuditId = SJA.JobAuditId
		INNER JOIN StatusCode s ON s.Code = SJA.StatusCode
		INNER JOIN Country Ct ON Ct.CountryISO2A = SJRA.CountryCode
		LEFT JOIN Panel P ON P.PanelCode = SJRA.PanelCode
			AND P.Country_Id = ct.CountryId
		LEFT JOIN SqlJob SJ ON SJ.Id = SJA.JobId
		LEFT JOIN GPSRuleActionQueue gpsQueue WITH (NOLOCK) ON gpsQueue.correlation_id = SJRA.CorrelationToken
		LEFT JOIN CommunicationMessageQueue CommQueue WITH (NOLOCK) ON CommQueue.correlation_id = SJRA.CorrelationToken
		WHERE SJ.Id = @jobID
			AND gpsQueue.subqueue IN (
				@jobStatusCode
				,@jobStatusCode2
				)
			AND CONVERT(DATE, SJA.CreationTimeStamp) = CONVERT(DATE, @rundate)
		ORDER BY SJA.JobRunDate DESC
			--RETURN ;  
	END
	ELSE
	BEGIN
		INSERT INTO @retTable
		SELECT SJA.JobAuditId AS JobAuditId
			,SJ.[Description] AS JobName
			,SJA.JobRunDate AS JobRunDate
			,SJRA.CreationTimeStamp AS AuditCreationDate
			,CASE 
				WHEN CommQueue.correlation_id IS NULL
					THEN ISNULL((
								CASE 
									WHEN gpsQueue.subqueue = 'X'
										THEN 'Success'
									WHEN gpsQueue.subqueue = 'R'
										THEN 'WaitingInErrorAndRetryQ'
									WHEN gpsQueue.subqueue = 'F'
										THEN 'FailedQ'
									WHEN gpsQueue.subqueue = 'I'
										THEN 'WaitingInInputQ'
									END
								), 'NotApplicable')
				WHEN CommQueue.correlation_id IS NOT NULL
					THEN ISNULL((
								CASE 
									WHEN CommQueue.subqueue = 'X'
										THEN 'Success'
									WHEN CommQueue.subqueue = 'R'
										THEN 'WaitingInErrorAndRetryQ'
									WHEN CommQueue.subqueue = 'F'
										THEN 'FailedQ'
									WHEN CommQueue.subqueue = 'I'
										THEN 'WaitingInInputQ'
									END
								), 'NotApplicable')
				END AS ActionStatus
			,ISNULL(SJRA.RuleActionName, 'NoAction') AS RuleActionName
			,SJRA.BusinessId AS BusinessId
			,P.NAME AS PanelName
			,SJRA.CountryCode AS CountryCode
			,SJRA.EntityName AS EntityName
			,s.STATUS AS AuditStatus
			,SJ.GPSUser AS LoggedInUser
			,SJA.EllapsedTime AS ElapsedTime
			,(
				CASE 
					WHEN CommQueue.correlation_id IS NULL
						THEN gpsQueue.Error_Info
					WHEN CommQueue.correlation_id IS NOT NULL
						THEN CommQueue.Error_Info
					END
				) AS ErrorInfo
			,SJ.Id AS JobId
			,SJRA.RuleActionAuditId AS RuleActionAuditId
		FROM SqlJobAudit SJA
		LEFT JOIN SqlJobRuleActionAudit SJRA ON SJRA.JobAuditId = SJA.JobAuditId
		INNER JOIN StatusCode s ON s.Code = SJA.StatusCode
		INNER JOIN Country Ct ON Ct.CountryISO2A = SJRA.CountryCode
		LEFT JOIN Panel P ON P.PanelCode = SJRA.PanelCode
			AND P.Country_Id = ct.CountryId
		LEFT JOIN SqlJob SJ ON SJ.Id = SJA.JobId
		LEFT JOIN GPSRuleActionQueue gpsQueue WITH (NOLOCK) ON gpsQueue.correlation_id = SJRA.CorrelationToken
		LEFT JOIN CommunicationMessageQueue CommQueue WITH (NOLOCK) ON CommQueue.correlation_id = SJRA.CorrelationToken
		WHERE SJ.Id = @jobID
			AND CONVERT(DATE, SJA.CreationTimeStamp) = CONVERT(DATE, @rundate)
		ORDER BY SJA.JobRunDate DESC
			--RETURN;  
	END

	RETURN;
END