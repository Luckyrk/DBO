CREATE TABLE [dbo].[CommunicationEventReason] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Comment]            NVARCHAR (500)   NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [ReasonType_Id]      UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Communication_Id]   UNIQUEIDENTIFIER NOT NULL,
    [panel_id] UNIQUEIDENTIFIER NULL, 
    CONSTRAINT [PK_dbo.CommunicationEventReason] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.CommunicationEventReason_dbo.CommunicationEvent_Communication_Id] FOREIGN KEY ([Communication_Id]) REFERENCES [dbo].[CommunicationEvent] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CommunicationEventReason_dbo.CommunicationEventReasonType_ReasonType_Id] FOREIGN KEY ([ReasonType_Id]) REFERENCES [dbo].[CommunicationEventReasonType] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CommunicationEventReason_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_ReasonType_Id]
    ON [dbo].[CommunicationEventReason]([ReasonType_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[CommunicationEventReason]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Communication_Id]
    ON [dbo].[CommunicationEventReason]([Communication_Id] ASC) INCLUDE ([CreationTimeStamp]);


GO
CREATE TRIGGER dbo.trgCommunicationEventReason_U 
ON dbo.[CommunicationEventReason] FOR update 
AS 
insert into audit.[CommunicationEventReason](	 [GUIDReference]	 ,[Comment]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ReasonType_Id]	 ,[Country_Id]	 ,[Communication_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Comment]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[ReasonType_Id]	 ,d.[Country_Id]	 ,d.[Communication_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[CommunicationEventReason](	 [GUIDReference]	 ,[Comment]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ReasonType_Id]	 ,[Country_Id]	 ,[Communication_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Comment]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[ReasonType_Id]	 ,i.[Country_Id]	 ,i.[Communication_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgCommunicationEventReason_I
ON dbo.[CommunicationEventReason] FOR insert 
AS 
insert into audit.[CommunicationEventReason](	 [GUIDReference]	 ,[Comment]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ReasonType_Id]	 ,[Country_Id]	 ,[Communication_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Comment]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[ReasonType_Id]	 ,i.[Country_Id]	 ,i.[Communication_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCommunicationEventReason_D
ON dbo.[CommunicationEventReason] FOR delete 
AS 
insert into audit.[CommunicationEventReason](	 [GUIDReference]	 ,[Comment]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[ReasonType_Id]	 ,[Country_Id]	 ,[Communication_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Comment]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[ReasonType_Id]	 ,d.[Country_Id]	 ,d.[Communication_Id],'D' from deleted d