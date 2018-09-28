CREATE PROCEDURE sp_GetSqlJobReRunDeatilsbyJobId
              @JobId INT
   AS
BEGIN
   
    SET NOCOUNT ON;
    IF EXISTS (select 1 from  SqlJobAudit SJA
       
              INNER JOIN StatusCode s ON s.Code = SJA.StatusCode where SJA.JobId = @JobId and SJA.StatusCode = 2)
        SELECT  0 
    ELSE
        SELECT 1
END
GO