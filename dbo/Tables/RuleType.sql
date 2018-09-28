CREATE TABLE [dbo].[RuleType] (
    [GUIDReference]  UNIQUEIDENTIFIER NOT NULL,
    [RuleType]       NVARCHAR (500)   NOT NULL,
    [Country_Id]     UNIQUEIDENTIFIER NOT NULL,
    [RuleContext_Id] UNIQUEIDENTIFIER NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.RuleType] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.RuleType_dbo.BusinessRulesContext_RuleContext_Id] FOREIGN KEY ([RuleContext_Id]) REFERENCES [dbo].[BusinessRulesContext] ([GUIDReference]),
    CONSTRAINT [FK_dbo.RuleType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[RuleType]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RuleContext_Id]
    ON [dbo].[RuleType]([RuleContext_Id] ASC);


GO
CREATE TRIGGER dbo.trgRuleType_U 
ON dbo.[RuleType] FOR update 
AS 
insert into audit.[RuleType](	 [GUIDReference]	 ,[RuleType]	 ,[Country_Id]	 ,[RuleContext_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[RuleType]	 ,d.[Country_Id]	 ,d.[RuleContext_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[RuleType](	 [GUIDReference]	 ,[RuleType]	 ,[Country_Id]	 ,[RuleContext_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[RuleType]	 ,i.[Country_Id]	 ,i.[RuleContext_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgRuleType_I
ON dbo.[RuleType] FOR insert 
AS 
insert into audit.[RuleType](	 [GUIDReference]	 ,[RuleType]	 ,[Country_Id]	 ,[RuleContext_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[RuleType]	 ,i.[Country_Id]	 ,i.[RuleContext_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgRuleType_D
ON dbo.[RuleType] FOR delete 
AS 
insert into audit.[RuleType](	 [GUIDReference]	 ,[RuleType]	 ,[Country_Id]	 ,[RuleContext_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[RuleType]	 ,d.[Country_Id]	 ,d.[RuleContext_Id],'D' from deleted d