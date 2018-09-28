CREATE TABLE [dbo].[RestrictedAccessSystemArea] (
    [RestrictedAccessAreaId] BIGINT         NOT NULL,
    [Path]                   NVARCHAR (MAX) NULL,
    [Name]                   NVARCHAR (MAX) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.RestrictedAccessSystemArea] PRIMARY KEY CLUSTERED ([RestrictedAccessAreaId] ASC),
    CONSTRAINT [FK_dbo.RestrictedAccessSystemArea_dbo.RestrictedAccessArea_RestrictedAccessAreaId] FOREIGN KEY ([RestrictedAccessAreaId]) REFERENCES [dbo].[RestrictedAccessArea] ([RestrictedAccessAreaId])
);






GO
CREATE NONCLUSTERED INDEX [IX_RestrictedAccessAreaId]
    ON [dbo].[RestrictedAccessSystemArea]([RestrictedAccessAreaId] ASC);


GO
CREATE TRIGGER dbo.trgRestrictedAccessSystemArea_U 
ON dbo.[RestrictedAccessSystemArea] FOR update 
AS 
insert into audit.[RestrictedAccessSystemArea](	 [RestrictedAccessAreaId]	 ,[Path]	 ,[Name]	 ,AuditOperation) select 	 d.[RestrictedAccessAreaId]	 ,d.[Path]	 ,d.[Name],'O'  from 	 deleted d join inserted i on d.RestrictedAccessAreaId = i.RestrictedAccessAreaId 
insert into audit.[RestrictedAccessSystemArea](	 [RestrictedAccessAreaId]	 ,[Path]	 ,[Name]	 ,AuditOperation) select 	 i.[RestrictedAccessAreaId]	 ,i.[Path]	 ,i.[Name],'N'  from 	 deleted d join inserted i on d.RestrictedAccessAreaId = i.RestrictedAccessAreaId
GO
CREATE TRIGGER dbo.trgRestrictedAccessSystemArea_I
ON dbo.[RestrictedAccessSystemArea] FOR insert 
AS 
insert into audit.[RestrictedAccessSystemArea](	 [RestrictedAccessAreaId]	 ,[Path]	 ,[Name]	 ,AuditOperation) select 	 i.[RestrictedAccessAreaId]	 ,i.[Path]	 ,i.[Name],'I' from inserted i
GO
CREATE TRIGGER dbo.trgRestrictedAccessSystemArea_D
ON dbo.[RestrictedAccessSystemArea] FOR delete 
AS 
insert into audit.[RestrictedAccessSystemArea](	 [RestrictedAccessAreaId]	 ,[Path]	 ,[Name]	 ,AuditOperation) select 	 d.[RestrictedAccessAreaId]	 ,d.[Path]	 ,d.[Name],'D' from deleted d