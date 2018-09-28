CREATE TABLE [dbo].[GPSRuleActionQueue] (
    [id]             BIGINT         IDENTITY (1, 1) NOT NULL,
    [from_endpoint]  VARCHAR (50)   NOT NULL,
    [to_endpoint]    VARCHAR (50)   NOT NULL,
    [subqueue]       CHAR (1)       NOT NULL,
    [insert_time]    DATETIME       NOT NULL,
    [last_processed] DATETIME       NULL,
    [retry_count]    INT            NOT NULL,
    [retry_time]     DATETIME       NOT NULL,
    [error_info]     NVARCHAR (MAX) NULL,
    [correlation_id] VARCHAR (100)  NULL,
    [label]          VARCHAR (100)  NULL,
    [msg_text]       NVARCHAR (MAX) NULL,
    [msg_headers]    NVARCHAR (MAX) NULL,
    [unique_id]      VARCHAR (40)   NULL,
    CONSTRAINT [PK_GPSRuleActionQueue] PRIMARY KEY CLUSTERED ([id] ASC)
);

GO
CREATE INDEX [IX_GPSRuleActionQueue_Subquee] ON [dbo].[GPSRuleActionQueue] ([subqueue])
GO
CREATE NONCLUSTERED INDEX [IXV_NON_Clustred_Subque_And_RetryTime] ON [dbo].[GPSRuleActionQueue]
(
       [subqueue] ASC,
       [retry_time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
CREATE TRIGGER dbo.trgGPSRuleActionQueue_U 
ON dbo.[GPSRuleActionQueue] FOR update 
AS 
insert into audit.[GPSRuleActionQueue](
	 [id]
	 ,[from_endpoint]
	 ,[to_endpoint]
	 ,[subqueue]
	 ,[insert_time]
	 ,[last_processed]
	 ,[retry_count]
	 ,[retry_time]
	 ,[error_info]
	 ,[correlation_id]
	 ,[label]
	 ,[msg_text]
	 ,[msg_headers]
	 ,[unique_id]
	 ,AuditOperation) select 
	 d.[id]
	 ,d.[from_endpoint]
	 ,d.[to_endpoint]
	 ,d.[subqueue]
	 ,d.[insert_time]
	 ,d.[last_processed]
	 ,d.[retry_count]
	 ,d.[retry_time]
	 ,d.[error_info]
	 ,d.[correlation_id]
	 ,d.[label]
	 ,d.[msg_text]
	 ,d.[msg_headers]
	 ,d.[unique_id],'O'  from 
	 deleted d join inserted i on d.id = i.id 
insert into audit.[GPSRuleActionQueue](
	 [id]
	 ,[from_endpoint]
	 ,[to_endpoint]
	 ,[subqueue]
	 ,[insert_time]
	 ,[last_processed]
	 ,[retry_count]
	 ,[retry_time]
	 ,[error_info]
	 ,[correlation_id]
	 ,[label]
	 ,[msg_text]
	 ,[msg_headers]
	 ,[unique_id]
	 ,AuditOperation) select 
	 i.[id]
	 ,i.[from_endpoint]
	 ,i.[to_endpoint]
	 ,i.[subqueue]
	 ,i.[insert_time]
	 ,i.[last_processed]
	 ,i.[retry_count]
	 ,i.[retry_time]
	 ,i.[error_info]
	 ,i.[correlation_id]
	 ,i.[label]
	 ,i.[msg_text]
	 ,i.[msg_headers]
	 ,i.[unique_id],'N'  from 
	 deleted d join inserted i on d.id = i.id
GO
CREATE TRIGGER dbo.trgGPSRuleActionQueue_I
ON dbo.[GPSRuleActionQueue] FOR insert 
AS 
insert into audit.[GPSRuleActionQueue](
	 [id]
	 ,[from_endpoint]
	 ,[to_endpoint]
	 ,[subqueue]
	 ,[insert_time]
	 ,[last_processed]
	 ,[retry_count]
	 ,[retry_time]
	 ,[error_info]
	 ,[correlation_id]
	 ,[label]
	 ,[msg_text]
	 ,[msg_headers]
	 ,[unique_id]
	 ,AuditOperation) select 
	 i.[id]
	 ,i.[from_endpoint]
	 ,i.[to_endpoint]
	 ,i.[subqueue]
	 ,i.[insert_time]
	 ,i.[last_processed]
	 ,i.[retry_count]
	 ,i.[retry_time]
	 ,i.[error_info]
	 ,i.[correlation_id]
	 ,i.[label]
	 ,i.[msg_text]
	 ,i.[msg_headers]
	 ,i.[unique_id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgGPSRuleActionQueue_D
ON dbo.[GPSRuleActionQueue] FOR delete 
AS 
insert into audit.[GPSRuleActionQueue](
	 [id]
	 ,[from_endpoint]
	 ,[to_endpoint]
	 ,[subqueue]
	 ,[insert_time]
	 ,[last_processed]
	 ,[retry_count]
	 ,[retry_time]
	 ,[error_info]
	 ,[correlation_id]
	 ,[label]
	 ,[msg_text]
	 ,[msg_headers]
	 ,[unique_id]
	 ,AuditOperation) select 
	 d.[id]
	 ,d.[from_endpoint]
	 ,d.[to_endpoint]
	 ,d.[subqueue]
	 ,d.[insert_time]
	 ,d.[last_processed]
	 ,d.[retry_count]
	 ,d.[retry_time]
	 ,d.[error_info]
	 ,d.[correlation_id]
	 ,d.[label]
	 ,d.[msg_text]
	 ,d.[msg_headers]
	 ,d.[unique_id],'D' from deleted d