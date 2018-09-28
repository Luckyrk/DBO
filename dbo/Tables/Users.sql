CREATE TABLE [dbo].[Users] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Lastname]           NVARCHAR (100)   NOT NULL,
    [Name]               NVARCHAR (200)   NOT NULL,
    [Username]           NVARCHAR (50)    NOT NULL,
    [Email]              NVARCHAR (100)   NOT NULL,
    [Birthdate]          DATETIME         NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.Users] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Users_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[Users]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgUsers_U 
ON dbo.[Users] FOR update 
AS 
insert into audit.[Users](	 [GUIDReference]	 ,[Lastname]	 ,[Name]	 ,[Username]	 ,[Email]	 ,[Birthdate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Lastname]	 ,d.[Name]	 ,d.[Username]	 ,d.[Email]	 ,d.[Birthdate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[Users](	 [GUIDReference]	 ,[Lastname]	 ,[Name]	 ,[Username]	 ,[Email]	 ,[Birthdate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Lastname]	 ,i.[Name]	 ,i.[Username]	 ,i.[Email]	 ,i.[Birthdate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgUsers_I
ON dbo.[Users] FOR insert 
AS 
insert into audit.[Users](	 [GUIDReference]	 ,[Lastname]	 ,[Name]	 ,[Username]	 ,[Email]	 ,[Birthdate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Lastname]	 ,i.[Name]	 ,i.[Username]	 ,i.[Email]	 ,i.[Birthdate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgUsers_D
ON dbo.[Users] FOR delete 
AS 
insert into audit.[Users](	 [GUIDReference]	 ,[Lastname]	 ,[Name]	 ,[Username]	 ,[Email]	 ,[Birthdate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Lastname]	 ,d.[Name]	 ,d.[Username]	 ,d.[Email]	 ,d.[Birthdate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Country_Id],'D' from deleted d