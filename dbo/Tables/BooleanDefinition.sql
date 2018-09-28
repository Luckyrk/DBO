CREATE TABLE [dbo].[BooleanDefinition] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Value]              BIT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.BooleanDefinition] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.BooleanDefinition_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[BooleanDefinition]([Translation_Id] ASC);


GO
CREATE TRIGGER dbo.trgBooleanDefinition_U 
ON dbo.[BooleanDefinition] FOR update 
AS 
insert into audit.[BooleanDefinition](	 [Id]	 ,[Value]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Value]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[BooleanDefinition](	 [Id]	 ,[Value]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Value]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgBooleanDefinition_I
ON dbo.[BooleanDefinition] FOR insert 
AS 
insert into audit.[BooleanDefinition](	 [Id]	 ,[Value]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Value]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgBooleanDefinition_D
ON dbo.[BooleanDefinition] FOR delete 
AS 
insert into audit.[BooleanDefinition](	 [Id]	 ,[Value]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Value]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id],'D' from deleted d