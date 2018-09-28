Create Procedure [dbo].[Audit_CreateAuditTrigger_Update]
@tablename Nvarchar(100) ,
@audittable NVarchar (100) 
 
as 
begin 

set nocount on;
SET CONCAT_NULL_YIELDS_NULL  OFF;
BEGIN TRY
  
DECLARE @allsqlStatement VARCHAR(MAX)
DECLARE @sqlInsert VARCHAR(MAX) 
DECLARE @sqlColumns VARCHAR(MAX) 
DECLARE @sqlJoin VARCHAR(MAX) 
DECLARE @sqlWhere VARCHAR(MAX) 
DECLARE @sqlWhereFinal VARCHAR(MAX) 
DECLARE @sqlHeader VARCHAR(MAX) 
DECLARE @quote CHAR(1) 
SET @quote = CHAR(39) 

declare @dropStmt nvarchar (max)
set @dropStmt ='IF OBJECT_ID('+@quote+'trg'+@tablename+'_U'+@quote+') IS NOT NULL 
       DROP TRIGGER dbo.trg'+@tablename+'_U' 

--this is just the header info  for the trigger 
SET @sqlHeader ='CREATE TRIGGER dbo.trg'+@tablename+'_U 
ON dbo.['+@tablename+'] FOR update 
AS 
' 

set @allsqlStatement=@sqlHeader

--select insert into 
SELECT @sqlInsert = CASE colid When 1 Then COALESCE(@sqlInsert+' [' , '') + s.name +']'+ CHAR(13)+ CHAR(9)
								else  COALESCE(@sqlInsert+' ,[' , '') + s.name +']'+ CHAR(13)+ CHAR(9) end
 FROM sys.syscolumns  S JOIN sys.tables t on s.id=t.object_id join sys.schemas sc on t.schema_id=sc.schema_id
  WHERE OBJECT_NAME(id) = @tablename and sc.name='dbo' ORDER BY colid
SET @sqlInsert = 'insert into audit.['+@audittable+']('+CHAR(13) +CHAR(9)+@sqlInsert +' ,AuditOperation) ' 

set @allsqlStatement=@allsqlStatement+@sqlInsert

--select col list 
SELECT @sqlColumns = CASE colid When 1 Then COALESCE(@sqlColumns+' ' , '') +'d.[' + s.name +']'+ CHAR(13)+ CHAR(9)
								Else        COALESCE(@sqlColumns+' ,' , '') +'d.['+ s.name +']'+ CHAR(13) + CHAR(9) end
FROM sys.syscolumns  S JOIN sys.tables t on s.id=t.object_id join sys.schemas sc on t.schema_id=sc.schema_id
 WHERE OBJECT_NAME(id) = @tablename and sc.name='dbo' ORDER BY colid
SET @sqlColumns = 'select '+CHAR(13) +CHAR(9)+ @sqlColumns  

----strip the last linebreak 
SET @sqlColumns = LEFT(@sqlColumns, (LEN(@sqlColumns)-2)) 

set @allsqlStatement=@allsqlStatement+@sqlColumns + ',''O'' ' --add the operation of the trigger

--generate the join condition between Inserted and Deleted tables if the table has Primary key 
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE   WHERE TABLE_NAME  = @tablename and TABLE_SCHEMA='dbo'
 AND CONSTRAINT_NAME LIKE '%PK%')
BEGIN 
               SET @sqlJoin = '' 
               SELECT @sqlJoin = COALESCE(@sqlJoin , '') + 'd.'+ COLUMN_NAME + ' = i.'+ COLUMN_NAME + CHAR(13)+CHAR(9) +' and ' 
               FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME = @tablename and TABLE_SCHEMA='dbo' 
               AND CONSTRAINT_NAME LIKE '%PK%'
               SET @sqlJoin = ' from ' + CHAR(13) + CHAR(9) + ' deleted d join inserted i on ' + @sqlJoin 
               --strip off the last 'and' 
               SET @sqlJoin = LEFT(@sqlJoin, (LEN(@sqlJoin)-6)) 
END 
ELSE 
       SET @sqlJoin = 'from deleted d, inserted i' 

set @allsqlStatement=@allsqlStatement+@sqlJoin
 
set @allsqlStatement=@allsqlStatement+ ' 
'
set @allsqlStatement=@allsqlStatement+@sqlInsert

SET @sqlColumns=''
-- --select col list 
SELECT @sqlColumns = CASE colid When 1 Then COALESCE(@sqlColumns+' ' , '') +'i.[' + s.name +']'+ CHAR(13)+ CHAR(9)
								Else        COALESCE(@sqlColumns+' ,' , '') +'i.['+ s.name +']'+ CHAR(13) + CHAR(9) end
FROM sys.syscolumns  S JOIN sys.tables t on s.id=t.object_id join sys.schemas sc on t.schema_id=sc.schema_id
 WHERE OBJECT_NAME(id) = @tablename and sc.name='dbo' ORDER BY colid
SET @sqlColumns = 'select '+CHAR(13) +CHAR(9)+ @sqlColumns  

--strip the last linebreak 
SET @sqlColumns = LEFT(@sqlColumns, (LEN(@sqlColumns)-2)) 
--PRINT @sqlColumns 
set @allsqlStatement=@allsqlStatement+@sqlColumns + ',''N'' ' --add the operation of the trigger
 
--generate the join condition between Inserted and Deleted tables if the table has Primary key 
IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE   WHERE TABLE_NAME  = @tablename and TABLE_SCHEMA='dbo'
 AND CONSTRAINT_NAME LIKE '%PK%')
BEGIN 
               SET @sqlJoin = '' 
               SELECT @sqlJoin = COALESCE(@sqlJoin , '') + 'd.'+ COLUMN_NAME + ' = i.'+ COLUMN_NAME + CHAR(13)+CHAR(9) +' and ' 
               FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE WHERE TABLE_NAME = @tablename and TABLE_SCHEMA='dbo' 
               AND CONSTRAINT_NAME LIKE '%PK%'
               SET @sqlJoin = ' from ' + CHAR(13) + CHAR(9) + ' deleted d join inserted i on ' + @sqlJoin 
               --strip off the last 'and' 
               SET @sqlJoin = LEFT(@sqlJoin, (LEN(@sqlJoin)-6)) 
END 
ELSE 
       SET @sqlJoin = 'from deleted d, inserted i' 

set @allsqlStatement=@allsqlStatement+@sqlJoin

Declare @Enabled bit
Select @Enabled=TriggerEnabledUpdate from  AuditConfig Where TableName=@tablename
if @Enabled=1
Begin
	 exec (@dropStmt)
	 exec (@allsqlStatement)
	 
	Update AuditConfig set ModificationTime=GETDATE() Where TableName=@tablename
End 
Else	
	Print 'The Flag "TriggerEnabledUpdate" allocated in dbo.AuditConfig for the table ['+@tablename +'] is set to 0. No Action performed' 	
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
End