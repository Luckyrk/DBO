CREATE TABLE [dbo].[RestrictedAccessArea] (
    [RestrictedAccessAreaId]        BIGINT   IDENTITY (1, 1) NOT NULL,
    [RestrictedAccessAreaTypeId]    BIGINT   NOT NULL,
    [RestrictedAccessAreaSubTypeId] BIGINT   NOT NULL,
    [ActiveFrom]                    DATETIME NOT NULL,
    [ActiveTo]                      DATETIME NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.RestrictedAccessArea] PRIMARY KEY CLUSTERED ([RestrictedAccessAreaId] ASC),
    CONSTRAINT [FK_dbo.RestrictedAccessArea_dbo.RestrictedAccessAreaSubType_RestrictedAccessAreaSubTypeId] FOREIGN KEY ([RestrictedAccessAreaSubTypeId]) REFERENCES [dbo].[RestrictedAccessAreaSubType] ([RestrictedAccessAreaSubTypeId]),
    CONSTRAINT [FK_dbo.RestrictedAccessArea_dbo.RestrictedAccessAreaType_RestrictedAccessAreaTypeId] FOREIGN KEY ([RestrictedAccessAreaTypeId]) REFERENCES [dbo].[RestrictedAccessAreaType] ([RestrictedAccessAreaTypeId])
);






GO
CREATE NONCLUSTERED INDEX [IX_RestrictedAccessAreaSubTypeId]
    ON [dbo].[RestrictedAccessArea]([RestrictedAccessAreaSubTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_RestrictedAccessAreaTypeId]
    ON [dbo].[RestrictedAccessArea]([RestrictedAccessAreaTypeId] ASC);


GO
CREATE TRIGGER dbo.trgRestrictedAccessArea_U 
ON dbo.[RestrictedAccessArea] FOR update 
AS 
insert into audit.[RestrictedAccessArea](	 [RestrictedAccessAreaId]	 ,[RestrictedAccessAreaTypeId]	 ,[RestrictedAccessAreaSubTypeId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[RestrictedAccessAreaId]	 ,d.[RestrictedAccessAreaTypeId]	 ,d.[RestrictedAccessAreaSubTypeId]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'O'  from 	 deleted d join inserted i on d.RestrictedAccessAreaId = i.RestrictedAccessAreaId 
insert into audit.[RestrictedAccessArea](	 [RestrictedAccessAreaId]	 ,[RestrictedAccessAreaTypeId]	 ,[RestrictedAccessAreaSubTypeId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[RestrictedAccessAreaId]	 ,i.[RestrictedAccessAreaTypeId]	 ,i.[RestrictedAccessAreaSubTypeId]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'N'  from 	 deleted d join inserted i on d.RestrictedAccessAreaId = i.RestrictedAccessAreaId
GO
CREATE TRIGGER dbo.trgRestrictedAccessArea_I
ON dbo.[RestrictedAccessArea] FOR insert 
AS 
insert into audit.[RestrictedAccessArea](	 [RestrictedAccessAreaId]	 ,[RestrictedAccessAreaTypeId]	 ,[RestrictedAccessAreaSubTypeId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[RestrictedAccessAreaId]	 ,i.[RestrictedAccessAreaTypeId]	 ,i.[RestrictedAccessAreaSubTypeId]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'I' from inserted i
GO
CREATE TRIGGER dbo.trgRestrictedAccessArea_D
ON dbo.[RestrictedAccessArea] FOR delete 
AS 
insert into audit.[RestrictedAccessArea](	 [RestrictedAccessAreaId]	 ,[RestrictedAccessAreaTypeId]	 ,[RestrictedAccessAreaSubTypeId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[RestrictedAccessAreaId]	 ,d.[RestrictedAccessAreaTypeId]	 ,d.[RestrictedAccessAreaSubTypeId]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'D' from deleted d