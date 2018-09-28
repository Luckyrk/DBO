CREATE TABLE [dbo].[RuleParameters] (
    [GUIDReference]    UNIQUEIDENTIFIER NOT NULL,
    [Name]             NVARCHAR (50)    NULL,
    [IsInputParameter] BIT              NOT NULL,
    [TypeName]         NVARCHAR (500)   NULL,
    [RuleContext_Id]   UNIQUEIDENTIFIER NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.RuleParameters] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.RuleParameters_dbo.BusinessRulesContext_RuleContext_Id] FOREIGN KEY ([RuleContext_Id]) REFERENCES [dbo].[BusinessRulesContext] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_RuleContext_Id]
    ON [dbo].[RuleParameters]([RuleContext_Id] ASC);


GO
CREATE TRIGGER dbo.trgRuleParameters_U 
ON dbo.[RuleParameters] FOR update 
AS 
insert into audit.[RuleParameters](	 [GUIDReference]	 ,[Name]	 ,[IsInputParameter]	 ,[TypeName]	 ,[RuleContext_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Name]	 ,d.[IsInputParameter]	 ,d.[TypeName]	 ,d.[RuleContext_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[RuleParameters](	 [GUIDReference]	 ,[Name]	 ,[IsInputParameter]	 ,[TypeName]	 ,[RuleContext_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Name]	 ,i.[IsInputParameter]	 ,i.[TypeName]	 ,i.[RuleContext_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgRuleParameters_I
ON dbo.[RuleParameters] FOR insert 
AS 
insert into audit.[RuleParameters](	 [GUIDReference]	 ,[Name]	 ,[IsInputParameter]	 ,[TypeName]	 ,[RuleContext_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Name]	 ,i.[IsInputParameter]	 ,i.[TypeName]	 ,i.[RuleContext_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgRuleParameters_D
ON dbo.[RuleParameters] FOR delete 
AS 
insert into audit.[RuleParameters](	 [GUIDReference]	 ,[Name]	 ,[IsInputParameter]	 ,[TypeName]	 ,[RuleContext_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Name]	 ,d.[IsInputParameter]	 ,d.[TypeName]	 ,d.[RuleContext_Id],'D' from deleted d