CREATE Procedure [dbo].[Audit_CreateAuditTrigger_Delete]
@tablename Nvarchar(100) ,
@audittable NVarchar (100) 
 
as 
begin 
BEGIN TRY 
set nocount on
SET CONCAT_NULL_YIELDS_NULL  OFF  
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
set @dropStmt ='IF OBJECT_ID('+@quote+'trg'+@tablename+'_D'+@quote+') IS NOT NULL 
       DROP TRIGGER dbo.trg'+@tablename+'_D' 

--this is just the header info  for the trigger 
SET @sqlHeader ='CREATE TRIGGER dbo.trg'+@tablename+'_D
ON dbo.['+@tablename+'] FOR delete 
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
FROM sys.syscolumns  S JOIN sys.tables t on s.id=t.object_id join sys.schemas sc on t.[schema_id]=sc.[schema_id]
 WHERE OBJECT_NAME(id) = @tablename and sc.name='dbo' ORDER BY colid
SET @sqlColumns = 'select '+CHAR(13) +CHAR(9)+ @sqlColumns  

--strip the last linebreak 
SET @sqlColumns = LEFT(@sqlColumns, (LEN(@sqlColumns)-2)) 

set @allsqlStatement=@allsqlStatement+@sqlColumns + ',''D'' ' --add the operation of the trigger
 
set @sqlJoin = 'from deleted d' 

set @allsqlStatement=@allsqlStatement+@sqlJoin

Declare @Enabled bit
Select @Enabled=TriggerEnabledDelete from  AuditConfig Where TableName=@tablename
if @Enabled=1
Begin
	 exec (@dropStmt)
	 exec (@allsqlStatement)
	 
	Update AuditConfig set ModificationTime=GETDATE() Where TableName=@tablename
End 
Else	
	Print 'The Flag "TriggerEnabledDelete" allocated in dbo.AuditConfig for the table ['+@tablename +'] is set to 0. No Action performed' 	
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
End