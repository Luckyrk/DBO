CREATE TABLE [dbo].[IncentivePointAccountEntryType] (
    [GUIDReference]              UNIQUEIDENTIFIER NOT NULL,
    [Code]                       INT              IDENTITY (1, 1) NOT NULL,
    [GPSUser]                    NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]         DATETIME         NULL,
    [CreationTimeStamp]          DATETIME         NULL,
    [TypeName_Id]                UNIQUEIDENTIFIER NOT NULL,
    [Description_Id]             UNIQUEIDENTIFIER NULL,
    [Country_Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Type]                       NVARCHAR (100)   NOT NULL,
    [IsDealtByCommunicationTeam] BIT              DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dbo.IncentivePointAccountEntryType] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.IncentivePointAccountEntryType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.IncentivePointAccountEntryType_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [FK_dbo.IncentivePointAccountEntryType_dbo.Translation_TypeName_Id] FOREIGN KEY ([TypeName_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniquePointTypeTranslation] UNIQUE NONCLUSTERED ([TypeName_Id] ASC, [Country_Id] ASC)
);








GO
CREATE NONCLUSTERED INDEX [IX_TypeName_Id]
    ON [dbo].[IncentivePointAccountEntryType]([TypeName_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[IncentivePointAccountEntryType]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[IncentivePointAccountEntryType]([Country_Id] ASC);



GO
CREATE TRIGGER dbo.trgIncentivePointAccountEntryType_U 
ON dbo.[IncentivePointAccountEntryType] FOR update 
AS 
insert into audit.[IncentivePointAccountEntryType](	 [GUIDReference]	 ,[Code]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[TypeName_Id]	 ,[Description_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Code]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[TypeName_Id]	 ,d.[Description_Id]	 ,d.[Country_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[IncentivePointAccountEntryType](	 [GUIDReference]	 ,[Code]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[TypeName_Id]	 ,[Description_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Code]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[TypeName_Id]	 ,i.[Description_Id]	 ,i.[Country_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgIncentivePointAccountEntryType_I
ON dbo.[IncentivePointAccountEntryType] FOR insert 
AS 
insert into audit.[IncentivePointAccountEntryType](	 [GUIDReference]	 ,[Code]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[TypeName_Id]	 ,[Description_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Code]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[TypeName_Id]	 ,i.[Description_Id]	 ,i.[Country_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgIncentivePointAccountEntryType_D
ON dbo.[IncentivePointAccountEntryType] FOR delete 
AS 
insert into audit.[IncentivePointAccountEntryType](	 [GUIDReference]	 ,[Code]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[TypeName_Id]	 ,[Description_Id]	 ,[Country_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Code]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[TypeName_Id]	 ,d.[Description_Id]	 ,d.[Country_Id]	 ,d.[Type],'D' from deleted d