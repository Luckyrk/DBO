CREATE TABLE [dbo].[QueryFilter] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Index]              INT              NOT NULL,
    [Name]               NVARCHAR (150)   NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Type]               NVARCHAR (200)   NULL,
    [Model]              NVARCHAR (500)   NULL,
    [Discriminator]      NVARCHAR (128)   NOT NULL,
    [Enum_Id]            UNIQUEIDENTIFIER NULL,
    [BaseQuery_Id]       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.QueryFilter] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.QueryFilter_dbo.Attribute_Enum_Id] FOREIGN KEY ([Enum_Id]) REFERENCES [dbo].[Attribute] ([GUIDReference]),
    CONSTRAINT [FK_dbo.QueryFilter_dbo.PreDefinedQuery_BaseQuery_Id] FOREIGN KEY ([BaseQuery_Id]) REFERENCES [dbo].[PreDefinedQuery] ([PreDefinedQueryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Enum_Id]
    ON [dbo].[QueryFilter]([Enum_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_BaseQuery_Id]
    ON [dbo].[QueryFilter]([BaseQuery_Id] ASC);


GO
CREATE TRIGGER dbo.trgQueryFilter_U 
ON dbo.[QueryFilter] FOR update 
AS 
insert into audit.[QueryFilter](	 [Id]	 ,[Index]	 ,[Name]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Type]	 ,[Model]	 ,[Discriminator]	 ,[Enum_Id]	 ,[BaseQuery_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Index]	 ,d.[Name]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Type]	 ,d.[Model]	 ,d.[Discriminator]	 ,d.[Enum_Id]	 ,d.[BaseQuery_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[QueryFilter](	 [Id]	 ,[Index]	 ,[Name]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Type]	 ,[Model]	 ,[Discriminator]	 ,[Enum_Id]	 ,[BaseQuery_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Index]	 ,i.[Name]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Type]	 ,i.[Model]	 ,i.[Discriminator]	 ,i.[Enum_Id]	 ,i.[BaseQuery_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgQueryFilter_I
ON dbo.[QueryFilter] FOR insert 
AS 
insert into audit.[QueryFilter](	 [Id]	 ,[Index]	 ,[Name]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Type]	 ,[Model]	 ,[Discriminator]	 ,[Enum_Id]	 ,[BaseQuery_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Index]	 ,i.[Name]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Type]	 ,i.[Model]	 ,i.[Discriminator]	 ,i.[Enum_Id]	 ,i.[BaseQuery_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgQueryFilter_D
ON dbo.[QueryFilter] FOR delete 
AS 
insert into audit.[QueryFilter](	 [Id]	 ,[Index]	 ,[Name]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Type]	 ,[Model]	 ,[Discriminator]	 ,[Enum_Id]	 ,[BaseQuery_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Index]	 ,d.[Name]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Type]	 ,d.[Model]	 ,d.[Discriminator]	 ,d.[Enum_Id]	 ,d.[BaseQuery_Id],'D' from deleted d