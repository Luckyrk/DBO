CREATE VIEW [dbo].[CommunicationQueueView]
	AS SELECT
	RAQ.id
	,JA.JobId
	,JRA.BusinessId
	,JRA.CountryCode
	,JRA.PanelCode
	,RAQ.msg_text
	,SUBSTRING(REPLACE(SUBSTRING(RAQ.msg_text, CHARINDEX('"To","Value":"', RAQ.msg_text, 0), 1000), '"To","Value":"', ''), 0, CHARINDEX('"', REPLACE(SUBSTRING(RAQ.msg_text, CHARINDEX('"To","Value":"', RAQ.msg_text, 0), 1000), '"To","Value":"', ''), 0)) AS [To]
	,(CASE WHEN JRA.RuleActionName LIKE 'SendSms%' THEN 'SMS' WHEN JRA.RuleActionName LIKE 'SendEmail%' THEN 'Email' WHEN JRA.RuleActionName LIKE 'AutomatedCall%' THEN 'AutomatedCall' END) AS [Type]
	,RAQ.insert_time AS [Date]
	,(CASE WHEN ISNULL(CQ.subqueue, RAQ.subqueue) = 'F' THEN 'Fail' WHEN ISNULL(CQ.subqueue, RAQ.subqueue) = 'X' THEN 'Success' END) AS [Status]
	,(CASE WHEN ISNULL(CQ.subqueue, RAQ.subqueue) = 'F' THEN ISNULL(CQ.error_info, RAQ.error_info) END) AS [Error]
	FROM GPSRuleActionQueue RAQ WITH(NOLOCK)
	JOIN SqlJobRuleActionAudit JRA ON RAQ.correlation_id = JRA.CorrelationToken
	JOIN SqlJobAudit JA ON JA.JobAuditId = JRA.JobAuditId
	LEFT JOIN CommunicationMessageQueue CQ WITH(NOLOCK) ON RAQ.correlation_id = CQ.correlation_id
	WHERE ISNULL(CQ.subqueue, RAQ.subqueue) IN ('F', 'X') AND (JRA.RuleActionName LIKE 'SendSms%' OR JRA.RuleActionName LIKE 'SendEmail%' OR JRA.RuleActionName LIKE 'AutomatedCall%')

