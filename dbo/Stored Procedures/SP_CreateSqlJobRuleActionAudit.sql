CREATE PROCEDURE [dbo].[SP_CreateSqlJobRuleActionAudit]
@jobAuditId as bigint,
@ruleActionName as nvarchar(50),
@businessId nvarchar(50),
@panelCode as int,
@countryCode as nvarchar(2),
@entityName as  nvarchar(50),
@correlationId as  nvarchar(50)

As 
BEGIN
	BEGIN TRY
		--BEGIN TRAN
		DECLARE @FetchaGPActionName NVARCHAR(50) = 'FetchaGPAction'
		DECLARE @returnValue INT = 0
		DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@countryCode))
		IF (@ruleActionName =  @FetchaGPActionName)
			BEGIN
				IF NOT EXISTS(SELECT 1 FROM SqlJobRuleActionAudit WHERE RuleActionName = @FetchaGPActionName AND JobAuditId = @jobAuditId)
					BEGIN
						INSERT INTO SqlJobRuleActionAudit (JobAuditId, RuleActionName, BusinessId, PanelCode, CountryCode, EntityName, CorrelationToken, GPSUser, GPSUpdateTimestamp, CreationTimeStamp)
						VALUES (@jobAuditId,@ruleActionName,@businessId,@panelCode,@countryCode,@entityName,@correlationId, SYSTEM_USER,@Getdate,@Getdate)
						
						SET @returnValue = 1
					END			
			END
		ELSE
			BEGIN 
				INSERT INTO SqlJobRuleActionAudit (JobAuditId, RuleActionName, BusinessId, PanelCode, CountryCode, EntityName, CorrelationToken, GPSUser, GPSUpdateTimestamp, CreationTimeStamp)
				VALUES (@jobAuditId,@ruleActionName,@businessId,@panelCode,@countryCode,@entityName,@correlationId, SYSTEM_USER,@Getdate,@Getdate)

				SET @returnValue = 1
			END

		SELECT @returnValue

		--COMMIT TRAN
	END TRY
	BEGIN CATCH
	--ROLLBACK TRAN
	SELECT 
			ERROR_NUMBER() AS ErrorNumber
			,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END
GO