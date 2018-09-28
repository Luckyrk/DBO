Create Procedure UpdateJobAuditStatus(@jobId BIGINT)
as
begin
BEGIN TRY 
	Declare @jobauditid int=(select top 1 JobAuditId from SqlJobAudit where JobId=@jobId and StatusCode=2 order by CreationTimeStamp desc)
	if exists (select 1 from SqlJobAudit sja
				 join SqlJobRuleActionAudit sra on sra.JobAuditId=sja.JobAuditId
				 join GPSRuleActionQueue(nolock) ga on ga.correlation_id=sra.CorrelationToken
				 where subqueue='I' and retry_count=0 and sja.JobAuditId=@jobauditid)
	  begin
		update SqlJobAudit set StatusCode=2 where JobAuditId=@jobauditid
	  end
	  else if exists (select 1 from SqlJobAudit sja
				 join SqlJobRuleActionAudit sra on sra.JobAuditId=sja.JobAuditId
				 join GPSRuleActionQueue(nolock) ga on ga.correlation_id=sra.CorrelationToken
				 where subqueue<>'I' and subqueue='R' and sja.JobAuditId=@jobauditid	)
	 begin
		update SqlJobAudit set StatusCode=0 where JobAuditId=@jobauditid
	 end
	 else 
	  begin
		update SqlJobAudit set StatusCode=1 where JobAuditId=@jobauditid
	  end
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
end