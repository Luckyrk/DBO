CREATE TABLE [dbo].[AddressType] (
    [Id]                UNIQUEIDENTIFIER NOT NULL,
    [IsDefault]         BIT              NOT NULL,
    [Description_Id]    UNIQUEIDENTIFIER NOT NULL,
    [DiscriminatorType] NVARCHAR (128)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.AddressType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.AddressType_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[AddressType]([Description_Id] ASC);


GO
CREATE TRIGGER dbo.trgAddressType_U 
ON dbo.[AddressType] FOR update 
AS 
insert into audit.[AddressType](	 [Id]	 ,[IsDefault]	 ,[Description_Id]	 ,[DiscriminatorType]	 ,AuditOperation) select 	 d.[Id]	 ,d.[IsDefault]	 ,d.[Description_Id]	 ,d.[DiscriminatorType],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[AddressType](	 [Id]	 ,[IsDefault]	 ,[Description_Id]	 ,[DiscriminatorType]	 ,AuditOperation) select 	 i.[Id]	 ,i.[IsDefault]	 ,i.[Description_Id]	 ,i.[DiscriminatorType],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgAddressType_I
ON dbo.[AddressType] FOR insert 
AS 
insert into audit.[AddressType](	 [Id]	 ,[IsDefault]	 ,[Description_Id]	 ,[DiscriminatorType]	 ,AuditOperation) select 	 i.[Id]	 ,i.[IsDefault]	 ,i.[Description_Id]	 ,i.[DiscriminatorType],'I' from inserted i
GO
CREATE TRIGGER dbo.trgAddressType_D
ON dbo.[AddressType] FOR delete 
AS 
insert into audit.[AddressType](	 [Id]	 ,[IsDefault]	 ,[Description_Id]	 ,[DiscriminatorType]	 ,AuditOperation) select 	 d.[Id]	 ,d.[IsDefault]	 ,d.[Description_Id]	 ,d.[DiscriminatorType],'D' from deleted d