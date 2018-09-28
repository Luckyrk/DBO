CREATE PROCEDURE [dbo].[SP_UpdateRuleActionQueue]
@tableName as nvarchar(50)

As 
BEGIN
BEGIN TRY
BEGIN TRAN

DECLARE @SQLString as NVARCHAR(MAX)
SET @SQLString= 'UPDATE ' + @tableName + ' SET SUBQUEUE = ''R'', retry_count=6 WHERE SUBQUEUE = ''F'' '

print @SQLString
EXEC (@SQLString)

COMMIT TRAN
END TRY
BEGIN CATCH
ROLLBACK TRAN
SELECT 
        ERROR_NUMBER() AS ErrorNumber
        ,ERROR_MESSAGE() AS ErrorMessage;
END CATCH
END