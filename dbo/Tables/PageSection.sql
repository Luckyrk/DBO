CREATE TABLE [dbo].[PageSection] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Order]              INT              NOT NULL,
    [Orientation]		 INT DEFAULT 0,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Column_Id]          UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.PageSection] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.PageSection_dbo.PageColumn_Column_Id] FOREIGN KEY ([Column_Id]) REFERENCES [dbo].[PageColumn] ([PageColumnId]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.PageSection_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[PageSection]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Column_Id]
    ON [dbo].[PageSection]([Column_Id] ASC);


GO
CREATE TRIGGER dbo.trgPageSection_U 
ON dbo.[PageSection] FOR update 
AS 
insert into audit.[PageSection](	 [Id]	 ,[Order]	 ,[Orientation]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Column_Id]	 	 ,AuditOperation) select 	 d.[Id]	 ,d.[Order]	 ,d.[Orientation]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Column_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[PageSection](	 [Id]	 ,[Order]	 ,[Orientation]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Column_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Order]	 ,i.[Orientation]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Column_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgPageSection_I
ON dbo.[PageSection] FOR insert 
AS 
insert into audit.[PageSection](	 [Id]	 ,[Order]	 ,[Orientation]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Column_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Order]	 ,i.[Orientation]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Translation_Id]	 ,i.[Column_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPageSection_D
ON dbo.[PageSection] FOR delete 
AS 
insert into audit.[PageSection](	 [Id]	 ,[Order]	 ,[Orientation]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Translation_Id]	 ,[Column_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Order]	 ,d.[Orientation]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Translation_Id]	 ,d.[Column_Id],'D' from deleted d