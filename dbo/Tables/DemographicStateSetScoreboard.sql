CREATE TABLE [dbo].[DemographicStateSetScoreboard] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Target]             BIGINT           NOT NULL,
    [Actual]             BIGINT           NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [StateSet_Id]        UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.DemographicStateSetScoreboard] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.DemographicStateSetScoreboard_dbo.StateGroupDefinition_StateSet_Id] FOREIGN KEY ([StateSet_Id]) REFERENCES [dbo].[StateGroupDefinition] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_StateSet_Id]
    ON [dbo].[DemographicStateSetScoreboard]([StateSet_Id] ASC);


GO
CREATE TRIGGER dbo.trgDemographicStateSetScoreboard_U 
ON dbo.[DemographicStateSetScoreboard] FOR update 
AS 
insert into audit.[DemographicStateSetScoreboard](	 [GUIDReference]	 ,[Target]	 ,[Actual]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[StateSet_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Target]	 ,d.[Actual]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[StateSet_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[DemographicStateSetScoreboard](	 [GUIDReference]	 ,[Target]	 ,[Actual]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[StateSet_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Target]	 ,i.[Actual]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[StateSet_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgDemographicStateSetScoreboard_I
ON dbo.[DemographicStateSetScoreboard] FOR insert 
AS 
insert into audit.[DemographicStateSetScoreboard](	 [GUIDReference]	 ,[Target]	 ,[Actual]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[StateSet_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Target]	 ,i.[Actual]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[StateSet_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDemographicStateSetScoreboard_D
ON dbo.[DemographicStateSetScoreboard] FOR delete 
AS 
insert into audit.[DemographicStateSetScoreboard](	 [GUIDReference]	 ,[Target]	 ,[Actual]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[StateSet_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Target]	 ,d.[Actual]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[StateSet_Id],'D' from deleted d