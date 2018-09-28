CREATE TABLE [dbo].[ExportColumn] (
    [Id]               UNIQUEIDENTIFIER NOT NULL,
    [Name]             NVARCHAR (200)   NOT NULL,
    [Length]           INT              NOT NULL,
    [Order]            INT              NOT NULL,
    [PaddingCharacter] NVARCHAR (5)     NULL,
    [QueryExport_Id]   UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ExportColumn] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.ExportColumn_dbo.QueryExport_QueryExport_Id] FOREIGN KEY ([QueryExport_Id]) REFERENCES [dbo].[QueryExport] ([Id]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_QueryExport_Id]
    ON [dbo].[ExportColumn]([QueryExport_Id] ASC);


GO
CREATE TRIGGER dbo.trgExportColumn_U 
ON dbo.[ExportColumn] FOR update 
AS 
insert into audit.[ExportColumn](	 [Id]	 ,[Name]	 ,[Length]	 ,[Order]	 ,[PaddingCharacter]	 ,[QueryExport_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Name]	 ,d.[Length]	 ,d.[Order]	 ,d.[PaddingCharacter]	 ,d.[QueryExport_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[ExportColumn](	 [Id]	 ,[Name]	 ,[Length]	 ,[Order]	 ,[PaddingCharacter]	 ,[QueryExport_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Name]	 ,i.[Length]	 ,i.[Order]	 ,i.[PaddingCharacter]	 ,i.[QueryExport_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgExportColumn_I
ON dbo.[ExportColumn] FOR insert 
AS 
insert into audit.[ExportColumn](	 [Id]	 ,[Name]	 ,[Length]	 ,[Order]	 ,[PaddingCharacter]	 ,[QueryExport_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Name]	 ,i.[Length]	 ,i.[Order]	 ,i.[PaddingCharacter]	 ,i.[QueryExport_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgExportColumn_D
ON dbo.[ExportColumn] FOR delete 
AS 
insert into audit.[ExportColumn](	 [Id]	 ,[Name]	 ,[Length]	 ,[Order]	 ,[PaddingCharacter]	 ,[QueryExport_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Name]	 ,d.[Length]	 ,d.[Order]	 ,d.[PaddingCharacter]	 ,d.[QueryExport_Id],'D' from deleted d