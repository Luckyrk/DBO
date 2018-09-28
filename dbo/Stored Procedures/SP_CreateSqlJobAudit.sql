
CREATE PROCEDURE [dbo].[SP_CreateSqlJobAudit]
@jobId as bigint,
@statusName as nvarchar(10),
@jobRundate datetime,
@loggedInUser nvarchar(50),
@jobAuditId as bigint OUTPUT


As 
BEGIN
BEGIN TRY
BEGIN TRAN
DECLARE @statusCode as int
SELECT @statusCode = (SELECT Code from StatusCode WHERE [Status] = @statusName)
Declare @GetDate DATETIME
SET @GetDate=(Select dbo.GetLocalDateTimeByCountryId(GETDATE(),CountryId) from SqlJob  WHERE Id=@jobId)

INSERT INTO SqlJobAudit (JobId, JobRunDate, StatusCode, GPSUser, GPSUpdateTimestamp, CreationTimeStamp)
VALUES (@jobId,@GetDate,@statusCode,@loggedInUser,@GetDate,@GetDate)

SELECT @jobAuditId = scope_Identity()

SELECT @jobAuditId 

COMMIT TRAN
END TRY
BEGIN CATCH
ROLLBACK TRAN
SELECT 
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_MESSAGE() AS ErrorMessage;
END CATCH
END