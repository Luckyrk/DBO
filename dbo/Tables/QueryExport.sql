CREATE TABLE [dbo].[QueryExport] (
    [Id]               UNIQUEIDENTIFIER NOT NULL,
    [PaddingCharacter] NVARCHAR (1)     NULL,
    [Type]             NVARCHAR (128)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.QueryExport] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE TRIGGER dbo.trgQueryExport_U 
ON dbo.[QueryExport] FOR update 
AS 
insert into audit.[QueryExport](	 [Id]	 ,[PaddingCharacter]	 ,[Type]	 ,AuditOperation) select 	 d.[Id]	 ,d.[PaddingCharacter]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[QueryExport](	 [Id]	 ,[PaddingCharacter]	 ,[Type]	 ,AuditOperation) select 	 i.[Id]	 ,i.[PaddingCharacter]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgQueryExport_I
ON dbo.[QueryExport] FOR insert 
AS 
insert into audit.[QueryExport](	 [Id]	 ,[PaddingCharacter]	 ,[Type]	 ,AuditOperation) select 	 i.[Id]	 ,i.[PaddingCharacter]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgQueryExport_D
ON dbo.[QueryExport] FOR delete 
AS 
insert into audit.[QueryExport](	 [Id]	 ,[PaddingCharacter]	 ,[Type]	 ,AuditOperation) select 	 d.[Id]	 ,d.[PaddingCharacter]	 ,d.[Type],'D' from deleted d