/*##########################################################################
-- Name				: GetBusinessRuleErrorsByJobId.sql
-- Date             : 2014-10-27
-- Author           : GopiChand
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure gets all the business rule exception logs by job id
-- Usage			:
-- Impact			: 
-- Required grants  : 
-- Called by        : Rule Composer
-- PARAM Definitions
	@pJobId bigint -- Job Id
-- Sample Execution :
	Exec GetBusinessRuleErrorsByJobId 1
##########################################################################
-- ver  user			 date        change 
-- 1.0  GopiChand       2014-10-27	 Initial
##########################################################################*/
CREATE PROCEDURE [dbo].[GetBusinessRuleErrorsByJobId] @pJobId bigint
AS
BEGIN
BEGIN TRY 
	SELECT *
	FROM BusinessRuleExceptionLog E
	INNER JOIN SqlJobAudit JA ON E.JobAuditId = JA.JobAuditId
	WHERE JA.JobId = @pJobId
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