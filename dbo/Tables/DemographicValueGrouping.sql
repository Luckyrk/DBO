CREATE TABLE [dbo].[DemographicValueGrouping] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Label_Id]           UNIQUEIDENTIFIER NULL,
    [Demographic_Id]     UNIQUEIDENTIFIER NULL,
    [Type]               NVARCHAR (100)   NOT NULL,
    CONSTRAINT [PK_dbo.DemographicValueGrouping] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.DemographicValueGrouping_dbo.Attribute_Demographic_Id] FOREIGN KEY ([Demographic_Id]) REFERENCES [dbo].[Attribute] ([GUIDReference]),
    CONSTRAINT [FK_dbo.DemographicValueGrouping_dbo.Translation_Label_Id] FOREIGN KEY ([Label_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Label_Id]
    ON [dbo].[DemographicValueGrouping]([Label_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Demographic_Id]
    ON [dbo].[DemographicValueGrouping]([Demographic_Id] ASC);


GO
CREATE TRIGGER dbo.trgDemographicValueGrouping_U 
ON dbo.[DemographicValueGrouping] FOR update 
AS 
insert into audit.[DemographicValueGrouping](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Label_Id]	 ,[Demographic_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Label_Id]	 ,d.[Demographic_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[DemographicValueGrouping](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Label_Id]	 ,[Demographic_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Label_Id]	 ,i.[Demographic_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgDemographicValueGrouping_I
ON dbo.[DemographicValueGrouping] FOR insert 
AS 
insert into audit.[DemographicValueGrouping](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Label_Id]	 ,[Demographic_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Label_Id]	 ,i.[Demographic_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDemographicValueGrouping_D
ON dbo.[DemographicValueGrouping] FOR delete 
AS 
insert into audit.[DemographicValueGrouping](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Label_Id]	 ,[Demographic_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Label_Id]	 ,d.[Demographic_Id]	 ,d.[Type],'D' from deleted d