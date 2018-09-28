CREATE TABLE [dbo].[PublicIdToCandiateIdLookup] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [PublicId]           NVARCHAR (50)    NULL,
    [CandiateId]         UNIQUEIDENTIFIER NOT NULL,
    [PanelId]            UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.PublicIdToCandiateIdLookup] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.PublicIdToCandiateIdLookup_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[PublicIdToCandiateIdLookup]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgPublicIdToCandiateIdLookup_U 
ON dbo.[PublicIdToCandiateIdLookup] FOR update 
AS 
insert into audit.[PublicIdToCandiateIdLookup](	 [GUIDReference]	 ,[PublicId]	 ,[CandiateId]	 ,[PanelId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[PublicId]	 ,d.[CandiateId]	 ,d.[PanelId]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[PublicIdToCandiateIdLookup](	 [GUIDReference]	 ,[PublicId]	 ,[CandiateId]	 ,[PanelId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[PublicId]	 ,i.[CandiateId]	 ,i.[PanelId]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgPublicIdToCandiateIdLookup_I
ON dbo.[PublicIdToCandiateIdLookup] FOR insert 
AS 
insert into audit.[PublicIdToCandiateIdLookup](	 [GUIDReference]	 ,[PublicId]	 ,[CandiateId]	 ,[PanelId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[PublicId]	 ,i.[CandiateId]	 ,i.[PanelId]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPublicIdToCandiateIdLookup_D
ON dbo.[PublicIdToCandiateIdLookup] FOR delete 
AS 
insert into audit.[PublicIdToCandiateIdLookup](	 [GUIDReference]	 ,[PublicId]	 ,[CandiateId]	 ,[PanelId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[PublicId]	 ,d.[CandiateId]	 ,d.[PanelId]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Country_Id],'D' from deleted d