CREATE TABLE [dbo].[EnumSet] (
    [Id]             UNIQUEIDENTIFIER NOT NULL,
    [Translation_Id] UNIQUEIDENTIFIER NULL,
    [Country_Id]     UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.EnumSet] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.EnumSet_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.EnumSet_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[EnumSet]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[EnumSet]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgEnumSet_U 
ON dbo.[EnumSet] FOR update 
AS 
insert into audit.[EnumSet](	 [Id]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Translation_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[EnumSet](	 [Id]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Translation_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgEnumSet_I
ON dbo.[EnumSet] FOR insert 
AS 
insert into audit.[EnumSet](	 [Id]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Translation_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgEnumSet_D
ON dbo.[EnumSet] FOR delete 
AS 
insert into audit.[EnumSet](	 [Id]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Translation_Id]	 ,d.[Country_Id],'D' from deleted d