CREATE PROCEDURE [dbo].[SP_UpdateSqlJobAuditErrorInfo]
@jobAuditId as bigint,
@errorMessage as nvarchar(max)

As 
BEGIN
BEGIN TRY
BEGIN TRAN

UPDATE SqlJobAudit SET [Error_Info] = @errorMessage,StatusCode=0  WHERE JobAuditId = @jobAuditId

COMMIT TRAN
END TRY
BEGIN CATCH
ROLLBACK TRAN
SELECT 
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_MESSAGE() AS ErrorMessage;
END CATCH
END