CREATE PROCEDURE [dbo].[SP_UpdateSqlJobAudit]
@jobAuditId as bigint,
@jobStatus as nvarchar(50),
@ellapsedTime time


As 
BEGIN
BEGIN TRY
BEGIN TRAN

UPDATE SqlJobAudit SET StatusCode = (SELECT Code FROM StatusCode WHERE [Status] = @jobStatus), EllapsedTime = @ellapsedTime WHERE JobAuditId = @jobAuditId

COMMIT TRAN
END TRY
BEGIN CATCH
ROLLBACK TRAN
SELECT 
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_MESSAGE() AS ErrorMessage;
END CATCH
END