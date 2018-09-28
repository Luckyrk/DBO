CREATE TABLE [dbo].[CommunicationEventReasonType] (
    [GUIDReference]             UNIQUEIDENTIFIER NOT NULL,
    [CommEventReasonCode]       INT              IDENTITY (1, 1) NOT NULL,
    [GPSUser]                   NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]        DATETIME         NULL,
    [CreationTimeStamp]         DATETIME         NULL,
    [RelatedActionType_Id]      UNIQUEIDENTIFIER NULL,
    [TagTranslation_Id]         UNIQUEIDENTIFIER NOT NULL,
    [PanelRestriction_Id]       UNIQUEIDENTIFIER NULL,
    [DescriptionTranslation_Id] UNIQUEIDENTIFIER NOT NULL,
    [TypeTranslation_Id]        UNIQUEIDENTIFIER NULL,
    [Country_Id]                UNIQUEIDENTIFIER NOT NULL,
    [IsClosed] BIT NULL, 
    [IsDealtByCommunicationTeam] BIT NULL, 
    [IsForFqs] BIT NULL, 
	[FqsUrl]					NVARCHAR(100)	NULL,
    CONSTRAINT [PK_dbo.CommunicationEventReasonType] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.CommunicationEventReasonType_dbo.ActionTaskType_RelatedActionType_Id] FOREIGN KEY ([RelatedActionType_Id]) REFERENCES [dbo].[ActionTaskType] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CommunicationEventReasonType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.CommunicationEventReasonType_dbo.Panel_PanelRestriction_Id] FOREIGN KEY ([PanelRestriction_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CommunicationEventReasonType_dbo.Translation_DescriptionTranslation_Id] FOREIGN KEY ([DescriptionTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [FK_dbo.CommunicationEventReasonType_dbo.Translation_TagTranslation_Id] FOREIGN KEY ([TagTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [FK_dbo.CommunicationEventReasonType_dbo.Translation_TypeTranslation_Id] FOREIGN KEY ([TypeTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueCommunicationEventReasonTypeTranslation] UNIQUE NONCLUSTERED ([TagTranslation_Id] ASC, [Country_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_RelatedActionType_Id]
    ON [dbo].[CommunicationEventReasonType]([RelatedActionType_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TagTranslation_Id]
    ON [dbo].[CommunicationEventReasonType]([TagTranslation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PanelRestriction_Id]
    ON [dbo].[CommunicationEventReasonType]([PanelRestriction_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DescriptionTranslation_Id]
    ON [dbo].[CommunicationEventReasonType]([DescriptionTranslation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TypeTranslation_Id]
    ON [dbo].[CommunicationEventReasonType]([TypeTranslation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[CommunicationEventReasonType]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgCommunicationEventReasonType_U 
ON dbo.[CommunicationEventReasonType] FOR update 
AS 
insert into audit.[CommunicationEventReasonType](	 [GUIDReference]	 ,[CommEventReasonCode]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[RelatedActionType_Id]	 ,[TagTranslation_Id]	 ,[PanelRestriction_Id]	 ,[DescriptionTranslation_Id]	 ,[TypeTranslation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[CommEventReasonCode]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[RelatedActionType_Id]	 ,d.[TagTranslation_Id]	 ,d.[PanelRestriction_Id]	 ,d.[DescriptionTranslation_Id]	 ,d.[TypeTranslation_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[CommunicationEventReasonType](	 [GUIDReference]	 ,[CommEventReasonCode]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[RelatedActionType_Id]	 ,[TagTranslation_Id]	 ,[PanelRestriction_Id]	 ,[DescriptionTranslation_Id]	 ,[TypeTranslation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[CommEventReasonCode]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[RelatedActionType_Id]	 ,i.[TagTranslation_Id]	 ,i.[PanelRestriction_Id]	 ,i.[DescriptionTranslation_Id]	 ,i.[TypeTranslation_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgCommunicationEventReasonType_I
ON dbo.[CommunicationEventReasonType] FOR insert 
AS 
insert into audit.[CommunicationEventReasonType](	 [GUIDReference]	 ,[CommEventReasonCode]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[RelatedActionType_Id]	 ,[TagTranslation_Id]	 ,[PanelRestriction_Id]	 ,[DescriptionTranslation_Id]	 ,[TypeTranslation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[CommEventReasonCode]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[RelatedActionType_Id]	 ,i.[TagTranslation_Id]	 ,i.[PanelRestriction_Id]	 ,i.[DescriptionTranslation_Id]	 ,i.[TypeTranslation_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCommunicationEventReasonType_D
ON dbo.[CommunicationEventReasonType] FOR delete 
AS 
insert into audit.[CommunicationEventReasonType](	 [GUIDReference]	 ,[CommEventReasonCode]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[RelatedActionType_Id]	 ,[TagTranslation_Id]	 ,[PanelRestriction_Id]	 ,[DescriptionTranslation_Id]	 ,[TypeTranslation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[CommEventReasonCode]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[RelatedActionType_Id]	 ,d.[TagTranslation_Id]	 ,d.[PanelRestriction_Id]	 ,d.[DescriptionTranslation_Id]	 ,d.[TypeTranslation_Id]	 ,d.[Country_Id],'D' from deleted d