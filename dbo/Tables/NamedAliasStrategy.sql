CREATE TABLE [dbo].[NamedAliasStrategy] (
    [NamedAliasStrategyId] UNIQUEIDENTIFIER NOT NULL,
    [Max]                  INT              NOT NULL,
    [Min]                  INT              NOT NULL,
    [GPSUser]              NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]   DATETIME         NULL,
    [CreationTimeStamp]    DATETIME         NULL,
    [Prefix]               NVARCHAR (20)    NULL,
    [Postfix]              NVARCHAR (20)    NULL,
    [Next]                 INT              NULL,
    [Nullable]             BIT              NULL,
    [TypeTranslation_Id]   UNIQUEIDENTIFIER NULL,
    [Type]                 NVARCHAR (100)   NOT NULL,
    CONSTRAINT [PK_dbo.NamedAliasStrategy] PRIMARY KEY CLUSTERED ([NamedAliasStrategyId] ASC),
    CONSTRAINT [FK_dbo.NamedAliasStrategy_dbo.Translation_TypeTranslation_Id] FOREIGN KEY ([TypeTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_TypeTranslation_Id]
    ON [dbo].[NamedAliasStrategy]([TypeTranslation_Id] ASC);


GO
CREATE TRIGGER dbo.trgNamedAliasStrategy_U 
ON dbo.[NamedAliasStrategy] FOR update 
AS 
insert into audit.[NamedAliasStrategy](	 [NamedAliasStrategyId]	 ,[Max]	 ,[Min]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Prefix]	 ,[Postfix]	 ,[Next]	 ,[Nullable]	 ,[TypeTranslation_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[NamedAliasStrategyId]	 ,d.[Max]	 ,d.[Min]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Prefix]	 ,d.[Postfix]	 ,d.[Next]	 ,d.[Nullable]	 ,d.[TypeTranslation_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.NamedAliasStrategyId = i.NamedAliasStrategyId 
insert into audit.[NamedAliasStrategy](	 [NamedAliasStrategyId]	 ,[Max]	 ,[Min]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Prefix]	 ,[Postfix]	 ,[Next]	 ,[Nullable]	 ,[TypeTranslation_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[NamedAliasStrategyId]	 ,i.[Max]	 ,i.[Min]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Prefix]	 ,i.[Postfix]	 ,i.[Next]	 ,i.[Nullable]	 ,i.[TypeTranslation_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.NamedAliasStrategyId = i.NamedAliasStrategyId
GO
CREATE TRIGGER dbo.trgNamedAliasStrategy_I
ON dbo.[NamedAliasStrategy] FOR insert 
AS 
insert into audit.[NamedAliasStrategy](	 [NamedAliasStrategyId]	 ,[Max]	 ,[Min]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Prefix]	 ,[Postfix]	 ,[Next]	 ,[Nullable]	 ,[TypeTranslation_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[NamedAliasStrategyId]	 ,i.[Max]	 ,i.[Min]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Prefix]	 ,i.[Postfix]	 ,i.[Next]	 ,i.[Nullable]	 ,i.[TypeTranslation_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgNamedAliasStrategy_D
ON dbo.[NamedAliasStrategy] FOR delete 
AS 
insert into audit.[NamedAliasStrategy](	 [NamedAliasStrategyId]	 ,[Max]	 ,[Min]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Prefix]	 ,[Postfix]	 ,[Next]	 ,[Nullable]	 ,[TypeTranslation_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[NamedAliasStrategyId]	 ,d.[Max]	 ,d.[Min]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Prefix]	 ,d.[Postfix]	 ,d.[Next]	 ,d.[Nullable]	 ,d.[TypeTranslation_Id]	 ,d.[Type],'D' from deleted d