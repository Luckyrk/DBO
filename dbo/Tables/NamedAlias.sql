CREATE TABLE [dbo].[NamedAlias] (
    [NamedAliasId]       UNIQUEIDENTIFIER NOT NULL,
    [Key]                NVARCHAR (50)    NOT NULL,
    [AliasContext_Id]    UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Guid]               UNIQUEIDENTIFIER NULL,
    [Incentive_Id]       UNIQUEIDENTIFIER NULL,
    [Candidate_Id]       UNIQUEIDENTIFIER NULL,
    [Type]               NVARCHAR (128)   NOT NULL,
    CONSTRAINT [PK_dbo.NamedAlias] PRIMARY KEY CLUSTERED ([NamedAliasId] ASC),
    CONSTRAINT [FK_dbo.NamedAlias_dbo.Candidate_Candidate_Id] FOREIGN KEY ([Candidate_Id]) REFERENCES [dbo].[Candidate] ([GUIDReference]),
    CONSTRAINT [FK_dbo.NamedAlias_dbo.IncentivePoint_Incentive_Id] FOREIGN KEY ([Incentive_Id]) REFERENCES [dbo].[IncentivePoint] ([GUIDReference]),
    CONSTRAINT [FK_dbo.NamedAlias_dbo.NamedAliasContext_AliasContext_Id] FOREIGN KEY ([AliasContext_Id]) REFERENCES [dbo].[NamedAliasContext] ([NamedAliasContextId]),
	CONSTRAINT [Un_KeyAliasContextIdType] UNIQUE NONCLUSTERED ([Key] ASC,[AliasContext_Id] ASC,[Type] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Candidate_Id]
    ON [dbo].[NamedAlias]([Candidate_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AliasContext_Id]
    ON [dbo].[NamedAlias]([AliasContext_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Incentive_Id]
    ON [dbo].[NamedAlias]([Incentive_Id] ASC);


GO
CREATE TRIGGER dbo.trgNamedAlias_U 
ON dbo.[NamedAlias] FOR update 
AS 
insert into audit.[NamedAlias](	 [NamedAliasId]	 ,[Key]	 ,[AliasContext_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Guid]	 ,[Incentive_Id]	 ,[Candidate_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[NamedAliasId]	 ,d.[Key]	 ,d.[AliasContext_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Guid]	 ,d.[Incentive_Id]	 ,d.[Candidate_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.NamedAliasId = i.NamedAliasId 
insert into audit.[NamedAlias](	 [NamedAliasId]	 ,[Key]	 ,[AliasContext_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Guid]	 ,[Incentive_Id]	 ,[Candidate_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[NamedAliasId]	 ,i.[Key]	 ,i.[AliasContext_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Guid]	 ,i.[Incentive_Id]	 ,i.[Candidate_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.NamedAliasId = i.NamedAliasId
GO
CREATE TRIGGER dbo.trgNamedAlias_I
ON dbo.[NamedAlias] FOR insert 
AS 
insert into audit.[NamedAlias](	 [NamedAliasId]	 ,[Key]	 ,[AliasContext_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Guid]	 ,[Incentive_Id]	 ,[Candidate_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[NamedAliasId]	 ,i.[Key]	 ,i.[AliasContext_Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Guid]	 ,i.[Incentive_Id]	 ,i.[Candidate_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgNamedAlias_D
ON dbo.[NamedAlias] FOR delete 
AS 
insert into audit.[NamedAlias](	 [NamedAliasId]	 ,[Key]	 ,[AliasContext_Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Guid]	 ,[Incentive_Id]	 ,[Candidate_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[NamedAliasId]	 ,d.[Key]	 ,d.[AliasContext_Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Guid]	 ,d.[Incentive_Id]	 ,d.[Candidate_Id]	 ,d.[Type],'D' from deleted d