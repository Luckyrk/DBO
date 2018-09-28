CREATE TABLE [dbo].[GeographicArea] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Code]               NVARCHAR (200)   NOT NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    CONSTRAINT [PK_dbo.GeographicArea] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.GeographicArea_dbo.Respondent_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[Respondent] ([GUIDReference]),
    CONSTRAINT [FK_dbo.GeographicArea_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[GeographicArea]([GUIDReference] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[GeographicArea]([Translation_Id] ASC);


GO
CREATE TRIGGER dbo.trgGeographicArea_U 
ON dbo.[GeographicArea] FOR update 
AS 
insert into audit.[GeographicArea](	 [GUIDReference]	 ,[Translation_Id]	 ,[Code]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Translation_Id]	 ,d.[Code]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[GeographicArea](	 [GUIDReference]	 ,[Translation_Id]	 ,[Code]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Translation_Id]	 ,i.[Code]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgGeographicArea_I
ON dbo.[GeographicArea] FOR insert 
AS 
insert into audit.[GeographicArea](	 [GUIDReference]	 ,[Translation_Id]	 ,[Code]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Translation_Id]	 ,i.[Code]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp],'I' from inserted i
GO
CREATE TRIGGER dbo.trgGeographicArea_D
ON dbo.[GeographicArea] FOR delete 
AS 
insert into audit.[GeographicArea](	 [GUIDReference]	 ,[Translation_Id]	 ,[Code]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Translation_Id]	 ,d.[Code]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp],'D' from deleted d