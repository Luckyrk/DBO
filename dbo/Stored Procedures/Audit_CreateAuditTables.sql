CREATE procedure [dbo].[Audit_CreateAuditTables] 
 @table varchar(100)
 
as
begin 
BEGIN TRY 
declare @schema varchar(10)
Select @schema= AuditSchema from dbo.AuditConfig where TableName=@table

declare @sql table(s varchar(4000), id int identity)

-- create statement
insert into  @sql(s) values ('create table ['+@schema+'].[' + @table + '] (')

-- column list
insert into @sql(s)
select 
    '  ['+COLUMN_NAME+'] ' + 
    DATA_TYPE + 
	coalesce('('+cast( CASE When DATA_TYPE='ntext' then null 
	                        When DATA_TYPE='image' then 'varbinary(max)' 
							When DATA_TYPE='xml' then null 
							When DATA_TYPE='varbinary' Then 'max'  
							When  DATA_TYPE='nvarchar' and CHARACTER_MAXIMUM_LENGTH=-1 then 'max'  
							else Convert(varchar,CHARACTER_MAXIMUM_LENGTH) end as varchar)+')','') + 
	' ' +
    ( case when IS_NULLABLE = 'No' then 'NOT ' else '' end ) + 
	'NULL ' + 
    ','
 
 from INFORMATION_SCHEMA.COLUMNS 
 where TABLE_NAME = @table and TABLE_SCHEMA='dbo'
 order by ORDINAL_POSITION

insert into @sql(s)
select 'AuditOperation nvarchar(1),'
insert into @sql(s)
select 'AuditDate datetime CONSTRAINT MD_'+@table+' DEFAULT GETDATE(),'
insert into @sql(s)
select 'AuditModifiedBy NVARCHAR(100) CONSTRAINT MB_'+@table+' DEFAULT SUSER_SNAME()'

-- closing bracket
insert into @sql(s) values( ')' )

DECLARE @combinedString VARCHAR(MAX)
SELECT @combinedString = COALESCE(@combinedString + '', '') + s
FROM @sql
 
Declare @ExistsStatement nvarchar(500) 
Select  @ExistsStatement='IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N''['+@schema+'].['+@table+']'') AND type in (N''U''))'
+CHAR(9)+CHAR(13) + 'DROP TABLE ['+@schema+'].['+@table+']'

Update AuditConfig set 
TableCreateStatement=@combinedString ,
TableCreateIfStatement=@ExistsStatement,
 ModificationTime=getdate() 
 where 
 TableName=@table and
 AuditSchema=@schema 
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