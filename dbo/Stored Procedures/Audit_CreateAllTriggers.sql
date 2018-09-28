CREATE Procedure [dbo].[Audit_CreateAllTriggers] @TriggerKind nvarchar(1)
 AS
 begin
 BEGIN TRY 
 if @TriggerKind = 'U'
 begin
--To drop and Update Triggers
 Declare @TableName_U nvarchar(100)
 Declare @AuditTable_U nvarchar(100)
Declare CursorCreateTables Cursor for
SELECT  TableName,AuditTable FROM dbo.AuditConfig Where TriggerEnabledUpdate=1 and TableCreateFlag=1      
OPEN CursorCreateTables
fetch next from CursorCreateTables
  into @TableName_U , @AuditTable_U
    while @@fetch_status = 0
    begin   
	  exec Audit_CreateAuditTrigger_Update @TableName_U,@AuditTable_U
    fetch next from CursorCreateTables
    into  @TableName_U ,@AuditTable_U
    end
    close CursorCreateTables
	deallocate CursorCreateTables
  end
 
  if @TriggerKind = 'I'
  Begin 
 --To drop and Insert Triggers
 Declare @TableName_I nvarchar(100)
 Declare @AuditTable_I nvarchar(100)
Declare CursorCreateTables Cursor for
SELECT  TableName,AuditTable FROM dbo.AuditConfig Where TriggerEnabledInsert=1 and TableCreateFlag=1     
OPEN CursorCreateTables
fetch next from CursorCreateTables
  into @TableName_I , @AuditTable_I
    while @@fetch_status = 0
    begin   
	  exec Audit_CreateAuditTrigger_Insert @TableName_I,@AuditTable_I
    fetch next from CursorCreateTables
    into  @TableName_I ,@AuditTable_I
    end
    close CursorCreateTables
	deallocate CursorCreateTables
 End 
   
  if @TriggerKind = 'D' -- delete Triggers
  Begin 
 Declare @TableName_D nvarchar(100)
 Declare @AuditTable_D nvarchar(100)
Declare CursorCreateTables Cursor for
SELECT  TableName,AuditTable FROM dbo.AuditConfig Where TriggerEnabledDelete=1 and TableCreateFlag=1     
OPEN CursorCreateTables
fetch next from CursorCreateTables
  into @TableName_D , @AuditTable_D
    while @@fetch_status = 0
    begin   
	  exec Audit_CreateAuditTrigger_Delete @TableName_D,@AuditTable_D
    fetch next from CursorCreateTables
    into  @TableName_D ,@AuditTable_D
    end
    close CursorCreateTables
	deallocate CursorCreateTables
 End
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