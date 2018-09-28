CREATE TABLE [dbo].[AttributeValue] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [DemographicId]      UNIQUEIDENTIFIER NOT NULL,
    [CandidateId]        UNIQUEIDENTIFIER NULL,
    [RespondentId]       UNIQUEIDENTIFIER NULL,
    [GPSUser]            NVARCHAR (50)    NOT NULL,
    [GPSUpdateTimestamp] DATETIME         NOT NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Address_Id]         UNIQUEIDENTIFIER NULL,
    [Value]              NVARCHAR (400)   NULL,
    [ValueDesc]          NVARCHAR (400)   NULL,
    [FreeText]           NVARCHAR (150)   NULL,
    [EnumDefinition_Id]  UNIQUEIDENTIFIER NULL,
    [Country_Id]         UNIQUEIDENTIFIER NULL,
    [Discriminator]      NVARCHAR (300)   NULL,
    CONSTRAINT [PK_dbo.AttributeValue] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.AttributeValue_dbo.Address_Address_Id] FOREIGN KEY ([Address_Id]) REFERENCES [dbo].[Address] ([GUIDReference]),
    CONSTRAINT [FK_dbo.AttributeValue_dbo.Attribute_DemographicId] FOREIGN KEY ([DemographicId]) REFERENCES [dbo].[Attribute] ([GUIDReference]),
    CONSTRAINT [FK_dbo.AttributeValue_dbo.Candidate_CandidateId] FOREIGN KEY ([CandidateId]) REFERENCES [dbo].[Candidate] ([GUIDReference]),
    CONSTRAINT [FK_dbo.AttributeValue_dbo.Respondent_RespondentId] FOREIGN KEY ([RespondentId]) REFERENCES [dbo].[Respondent] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Address_Id]
   ON [dbo].[AttributeValue]([Address_Id] ASC);
GO
CREATE NONCLUSTERED INDEX [IX_RespondentId]
    ON [dbo].[AttributeValue]([RespondentId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_CandidateId]
    ON [dbo].[AttributeValue]([CandidateId] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_DemographicId]
    ON [dbo].[AttributeValue]([DemographicId] ASC);


GO
CREATE TRIGGER dbo.trgAttributeValue_U 
ON dbo.[AttributeValue] FOR update 
AS 
insert into audit.[AttributeValue](
	 [GUIDReference]
	 ,[DemographicId]
	 ,[RespondentId]
	 ,[CandidateId]
	 ,[GPSUser]
	 ,[GPSUpdateTimestamp]
	 ,[CreationTimeStamp]
	 ,[Address_Id]
	 ,[Value]
	 ,[ValueDesc]
     ,[EnumDefinition_Id]
	 ,AuditOperation) select 
	 d.[GUIDReference]
	 ,d.[DemographicId]
	 ,d.[RespondentId]
	 ,d.[CandidateId]
	 ,d.[GPSUser]
	 ,d.[GPSUpdateTimestamp]
	 ,d.[CreationTimeStamp]
	 ,d.[Address_Id]
	 ,d.[Value]
	 ,d.[ValueDesc]
     ,d.[EnumDefinition_Id],'O'  from 
	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[AttributeValue](
	 [GUIDReference]
	 ,[DemographicId]
	 ,[RespondentId]
	 ,[CandidateId]
	 ,[GPSUser]
	 ,[GPSUpdateTimestamp]
	 ,[CreationTimeStamp]
	 ,[Address_Id]
	 ,[Value]
	 ,[ValueDesc]
     ,[EnumDefinition_Id]
	 ,AuditOperation) select 
	 i.[GUIDReference]
	 ,i.[DemographicId]
	 ,i.[RespondentId]
	 ,i.[CandidateId]
	 ,i.[GPSUser]
	 ,i.[GPSUpdateTimestamp]
	 ,i.[CreationTimeStamp]
	 ,i.[Address_Id]
	 ,i.[Value]
	 ,i.[ValueDesc]
     ,i.[EnumDefinition_Id],'N'  from 
	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgAttributeValue_I
ON dbo.[AttributeValue] FOR insert 
AS 
insert into audit.[AttributeValue](
	 [GUIDReference]
	 ,[DemographicId]
	 ,[RespondentId]
	 ,[CandidateId]
	 ,[GPSUser]
	 ,[GPSUpdateTimestamp]
	 ,[CreationTimeStamp]
	 ,[Address_Id]
	 ,[Value]
	 ,[ValueDesc]
     ,[EnumDefinition_Id]
	 ,AuditOperation) select 
	 i.[GUIDReference]
	 ,i.[DemographicId]
	 ,i.[RespondentId]
	 ,i.[CandidateId]
	 ,i.[GPSUser]
	 ,i.[GPSUpdateTimestamp]
	 ,i.[CreationTimeStamp]
	 ,i.[Address_Id]
	 ,i.[Value]
	 ,i.[ValueDesc]
     ,i.[EnumDefinition_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgAttributeValue_D
ON dbo.[AttributeValue] FOR delete 
AS 
insert into audit.[AttributeValue](
	 [GUIDReference]
	 ,[DemographicId]
	 ,[RespondentId]
	 ,[CandidateId]
	 ,[GPSUser]
	 ,[GPSUpdateTimestamp]
	 ,[CreationTimeStamp]
	 ,[Address_Id]
	 ,[Value]
	 ,[ValueDesc]
     ,[EnumDefinition_Id]
	 ,AuditOperation) select 
	 d.[GUIDReference]
	 ,d.[DemographicId]
	 ,d.[RespondentId]
	 ,d.[CandidateId]
	 ,d.[GPSUser]
	 ,d.[GPSUpdateTimestamp]
	 ,d.[CreationTimeStamp]
	 ,d.[Address_Id]
	 ,d.[Value]
	 ,d.[ValueDesc]
     ,d.[EnumDefinition_Id],'D' from deleted d
GO
CREATE STATISTICS [_dta_stat_1925581898_2_1_8]
    ON [dbo].[AttributeValue]([DemographicId], [GUIDReference], [CandidateId]);


GO
CREATE STATISTICS [_dta_stat_1925581898_1_8]
    ON [dbo].[AttributeValue]([GUIDReference], [CandidateId]);

