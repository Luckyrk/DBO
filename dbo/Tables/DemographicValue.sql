CREATE TABLE [dbo].[DemographicValue] (
    [GUIDReference]               UNIQUEIDENTIFIER NOT NULL,
    [Grouping_Id]                 UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]                     NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]          DATETIME         NULL,
    [Label_Id]                    UNIQUEIDENTIFIER NULL,
    [DemographicValueGrouping_Id] UNIQUEIDENTIFIER NULL,
	[CreationTimeStamp]			  DATETIME         NULL,
    CONSTRAINT [PK_dbo.DemographicValue] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.DemographicValue_dbo.DemographicValueGrouping_DemographicValueGrouping_Id] FOREIGN KEY ([DemographicValueGrouping_Id]) REFERENCES [dbo].[DemographicValueGrouping] ([GUIDReference]),
    CONSTRAINT [FK_dbo.DemographicValue_dbo.DemographicValueGrouping_Grouping_Id] FOREIGN KEY ([Grouping_Id]) REFERENCES [dbo].[DemographicValueGrouping] ([GUIDReference]),
    CONSTRAINT [FK_dbo.DemographicValue_dbo.Translation_Label_Id] FOREIGN KEY ([Label_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Label_Id]
    ON [dbo].[DemographicValue]([Label_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DemographicValueGrouping_Id]
    ON [dbo].[DemographicValue]([DemographicValueGrouping_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Grouping_Id]
    ON [dbo].[DemographicValue]([Grouping_Id] ASC);


GO
CREATE TRIGGER dbo.trgDemographicValue_U 
ON dbo.[DemographicValue] FOR update 
AS 
insert into audit.[DemographicValue](	 [GUIDReference]	 ,[Grouping_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Label_Id]	 ,[DemographicValueGrouping_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Grouping_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[Label_Id]	 ,d.[DemographicValueGrouping_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[DemographicValue](	 [GUIDReference]	 ,[Grouping_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Label_Id]	 ,[DemographicValueGrouping_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Grouping_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[Label_Id]	 ,i.[DemographicValueGrouping_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgDemographicValue_I
ON dbo.[DemographicValue] FOR insert 
AS 
insert into audit.[DemographicValue](	 [GUIDReference]	 ,[Grouping_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Label_Id]	 ,[DemographicValueGrouping_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Grouping_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[Label_Id]	 ,i.[DemographicValueGrouping_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDemographicValue_D
ON dbo.[DemographicValue] FOR delete 
AS 
insert into audit.[DemographicValue](	 [GUIDReference]	 ,[Grouping_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Label_Id]	 ,[DemographicValueGrouping_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Grouping_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[Label_Id]	 ,d.[DemographicValueGrouping_Id],'D' from deleted d