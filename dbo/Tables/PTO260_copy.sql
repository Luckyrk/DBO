CREATE TABLE [dbo].[PTO260_copy] (
    [HOUSEHOLD_NUMBER]    NUMERIC (6)   NOT NULL,
    [COMMS_EVENT_CODE]    NUMERIC (3)   NOT NULL,
    [COMMS_DATE]          DATETIME      NOT NULL,
    [COMMS_EVENT_OUTCOME] NUMERIC (1)   NOT NULL,
    [INSERT_DATE]         DATETIME      NOT NULL,
    [COMMENTS]            VARCHAR (256) NULL,
    [CALL_NUMBER]         NUMERIC (8)   NULL,
    PRIMARY KEY CLUSTERED ([HOUSEHOLD_NUMBER] ASC, [COMMS_EVENT_CODE] ASC, [COMMS_DATE] ASC)
);




GO
CREATE TRIGGER dbo.trgPTO260_copy_U 
ON dbo.[PTO260_copy] FOR update 
AS 
insert into audit.[PTO260_copy](	 [HOUSEHOLD_NUMBER]	 ,[COMMS_EVENT_CODE]	 ,[COMMS_DATE]	 ,[COMMS_EVENT_OUTCOME]	 ,[INSERT_DATE]	 ,[COMMENTS]	 ,[CALL_NUMBER]	 ,AuditOperation) select 	 d.[HOUSEHOLD_NUMBER]	 ,d.[COMMS_EVENT_CODE]	 ,d.[COMMS_DATE]	 ,d.[COMMS_EVENT_OUTCOME]	 ,d.[INSERT_DATE]	 ,d.[COMMENTS]	 ,d.[CALL_NUMBER],'O'  from 	 deleted d join inserted i on d.COMMS_DATE = i.COMMS_DATE	 and d.COMMS_EVENT_CODE = i.COMMS_EVENT_CODE	 and d.HOUSEHOLD_NUMBER = i.HOUSEHOLD_NUMBER 
insert into audit.[PTO260_copy](	 [HOUSEHOLD_NUMBER]	 ,[COMMS_EVENT_CODE]	 ,[COMMS_DATE]	 ,[COMMS_EVENT_OUTCOME]	 ,[INSERT_DATE]	 ,[COMMENTS]	 ,[CALL_NUMBER]	 ,AuditOperation) select 	 i.[HOUSEHOLD_NUMBER]	 ,i.[COMMS_EVENT_CODE]	 ,i.[COMMS_DATE]	 ,i.[COMMS_EVENT_OUTCOME]	 ,i.[INSERT_DATE]	 ,i.[COMMENTS]	 ,i.[CALL_NUMBER],'N'  from 	 deleted d join inserted i on d.COMMS_DATE = i.COMMS_DATE	 and d.COMMS_EVENT_CODE = i.COMMS_EVENT_CODE	 and d.HOUSEHOLD_NUMBER = i.HOUSEHOLD_NUMBER
GO
CREATE TRIGGER dbo.trgPTO260_copy_I
ON dbo.[PTO260_copy] FOR insert 
AS 
insert into audit.[PTO260_copy](	 [HOUSEHOLD_NUMBER]	 ,[COMMS_EVENT_CODE]	 ,[COMMS_DATE]	 ,[COMMS_EVENT_OUTCOME]	 ,[INSERT_DATE]	 ,[COMMENTS]	 ,[CALL_NUMBER]	 ,AuditOperation) select 	 i.[HOUSEHOLD_NUMBER]	 ,i.[COMMS_EVENT_CODE]	 ,i.[COMMS_DATE]	 ,i.[COMMS_EVENT_OUTCOME]	 ,i.[INSERT_DATE]	 ,i.[COMMENTS]	 ,i.[CALL_NUMBER],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPTO260_copy_D
ON dbo.[PTO260_copy] FOR delete 
AS 
insert into audit.[PTO260_copy](	 [HOUSEHOLD_NUMBER]	 ,[COMMS_EVENT_CODE]	 ,[COMMS_DATE]	 ,[COMMS_EVENT_OUTCOME]	 ,[INSERT_DATE]	 ,[COMMENTS]	 ,[CALL_NUMBER]	 ,AuditOperation) select 	 d.[HOUSEHOLD_NUMBER]	 ,d.[COMMS_EVENT_CODE]	 ,d.[COMMS_DATE]	 ,d.[COMMS_EVENT_OUTCOME]	 ,d.[INSERT_DATE]	 ,d.[COMMENTS]	 ,d.[CALL_NUMBER],'D' from deleted d