CREATE PROCEDURE [dbo].[Audit_CreateAllTables]
	 
AS
BEGIN
	 
	SET NOCOUNT ON;

     Declare @AuditTable nvarchar(100)
Declare CursorCreateTables Cursor for
SELECT  AuditTable FROM dbo.AuditConfig where   TableCreateFlag=1 
OPEN CursorCreateTables
fetch next from CursorCreateTables
  into @AuditTable
    while @@fetch_status = 0
    begin   
	   exec Audit_CreateAuditTables @AuditTable
    fetch next from CursorCreateTables
    into @AuditTable
    end
    close CursorCreateTables
	deallocate CursorCreateTables
 
 
--To drop and recreate the Audit tables
 Declare @AuditTable_C nvarchar(100)
Declare CursorCreateTables Cursor for
SELECT  AuditTable FROM dbo.AuditConfig where  TableCreateFlag=1    
OPEN CursorCreateTables
fetch next from CursorCreateTables
  into @AuditTable_C
    while @@fetch_status = 0
    begin   
	   
	   declare @sqlstm nvarchar(4000) 
		 select @sqlstm =TableCreateIfStatement from AuditConfig where AuditTable=@AuditTable_C
		 exec sp_executesql @sqlstm
	 select @sqlstm= TableCreateStatement from AuditConfig where AuditTable=@AuditTable_C
      exec sp_executesql @sqlstm 
    
 
    fetch next from CursorCreateTables
    into @AuditTable_C
    end
    close CursorCreateTables
	deallocate CursorCreateTables
END