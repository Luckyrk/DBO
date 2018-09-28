CREATE TABLE [dbo].[StateGroupMapping] (
    [DemographicStateSet_Id] UNIQUEIDENTIFIER NOT NULL,
    [StateDefinition_Id]     UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StateGroupMapping] PRIMARY KEY CLUSTERED ([DemographicStateSet_Id] ASC, [StateDefinition_Id] ASC),
    CONSTRAINT [FK_dbo.StateGroupMapping_dbo.StateDefinition_StateDefinition_Id] FOREIGN KEY ([StateDefinition_Id]) REFERENCES [dbo].[StateDefinition] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.StateGroupMapping_dbo.StateGroupDefinition_DemographicStateSet_Id] FOREIGN KEY ([DemographicStateSet_Id]) REFERENCES [dbo].[StateGroupDefinition] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_DemographicStateSet_Id]
    ON [dbo].[StateGroupMapping]([DemographicStateSet_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_StateDefinition_Id]
    ON [dbo].[StateGroupMapping]([StateDefinition_Id] ASC);


GO
CREATE TRIGGER dbo.trgStateGroupMapping_U 
ON dbo.[StateGroupMapping] FOR update 
AS 
insert into audit.[StateGroupMapping](	 [DemographicStateSet_Id]	 ,[StateDefinition_Id]	 ,AuditOperation) select 	 d.[DemographicStateSet_Id]	 ,d.[StateDefinition_Id],'O'  from 	 deleted d join inserted i on d.DemographicStateSet_Id = i.DemographicStateSet_Id	 and d.StateDefinition_Id = i.StateDefinition_Id 
insert into audit.[StateGroupMapping](	 [DemographicStateSet_Id]	 ,[StateDefinition_Id]	 ,AuditOperation) select 	 i.[DemographicStateSet_Id]	 ,i.[StateDefinition_Id],'N'  from 	 deleted d join inserted i on d.DemographicStateSet_Id = i.DemographicStateSet_Id	 and d.StateDefinition_Id = i.StateDefinition_Id
GO
CREATE TRIGGER dbo.trgStateGroupMapping_I
ON dbo.[StateGroupMapping] FOR insert 
AS 
insert into audit.[StateGroupMapping](	 [DemographicStateSet_Id]	 ,[StateDefinition_Id]	 ,AuditOperation) select 	 i.[DemographicStateSet_Id]	 ,i.[StateDefinition_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgStateGroupMapping_D
ON dbo.[StateGroupMapping] FOR delete 
AS 
insert into audit.[StateGroupMapping](	 [DemographicStateSet_Id]	 ,[StateDefinition_Id]	 ,AuditOperation) select 	 d.[DemographicStateSet_Id]	 ,d.[StateDefinition_Id],'D' from deleted d