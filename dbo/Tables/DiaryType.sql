CREATE TABLE [dbo].[DiaryType] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Name]               NVARCHAR (100)   NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Panel_Id]           UNIQUEIDENTIFIER NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.DiaryType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.DiaryType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.DiaryType_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[DiaryType]([Panel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[DiaryType]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgDiaryType_U 
ON dbo.[DiaryType] FOR update 
AS 
insert into audit.[DiaryType](	 [Id]	 ,[Name]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panel_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Name]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Panel_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[DiaryType](	 [Id]	 ,[Name]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panel_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Name]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Panel_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgDiaryType_I
ON dbo.[DiaryType] FOR insert 
AS 
insert into audit.[DiaryType](	 [Id]	 ,[Name]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panel_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Name]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Panel_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDiaryType_D
ON dbo.[DiaryType] FOR delete 
AS 
insert into audit.[DiaryType](	 [Id]	 ,[Name]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panel_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Name]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Panel_Id]	 ,d.[Country_Id],'D' from deleted d