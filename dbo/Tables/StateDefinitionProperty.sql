CREATE TABLE [dbo].[StateDefinitionProperty] (
    [StatedefinitionPropertyId] UNIQUEIDENTIFIER NOT NULL,
    [LocationId]                UNIQUEIDENTIFIER NULL,
    [StateDefinitionId]         UNIQUEIDENTIFIER NULL,
    [Type]                      NVARCHAR (128)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StateDefinitionProperty] PRIMARY KEY CLUSTERED ([StatedefinitionPropertyId] ASC),
    CONSTRAINT [FK_dbo.StateDefinitionProperty_dbo.GenericStockLocation_Location_Id] FOREIGN KEY ([LocationId]) REFERENCES [dbo].[GenericStockLocation] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StateDefinitionProperty_dbo.StateDefinition_Id] FOREIGN KEY ([StateDefinitionId]) REFERENCES [dbo].[StateDefinition] ([Id])
);



GO
CREATE NONCLUSTERED INDEX [IX_StatedefinitionPropertyId]
    ON [dbo].[StateDefinitionProperty]([StatedefinitionPropertyId] ASC);
	
GO
CREATE NONCLUSTERED INDEX [IX_Location_Id]
    ON [dbo].[StateDefinitionProperty]([LocationId] ASC);
	
GO
CREATE NONCLUSTERED INDEX [IX_StateDefinition_Id]
    ON [dbo].[StateDefinitionProperty]([StateDefinitionId] ASC);
GO
CREATE TRIGGER dbo.trgStateDefinitionProperty_U 
ON dbo.[StateDefinitionProperty] FOR update 
AS 
insert into audit.[StateDefinitionProperty](	 [StatedefinitionPropertyId]	 ,[LocationId]	 ,[StateDefinitionId]	 ,[Type]	 ,AuditOperation) select 	 d.[StatedefinitionPropertyId]	 ,d.[LocationId]	 ,d.[StateDefinitionId]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.StatedefinitionPropertyId = i.StatedefinitionPropertyId 
insert into audit.[StateDefinitionProperty](	 [StatedefinitionPropertyId]	 ,[LocationId]	 ,[StateDefinitionId]	 ,[Type]	 ,AuditOperation) select 	 i.[StatedefinitionPropertyId]	 ,i.[LocationId]	 ,i.[StateDefinitionId]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.StatedefinitionPropertyId = i.StatedefinitionPropertyId
GO
CREATE TRIGGER dbo.trgStateDefinitionProperty_I
ON dbo.[StateDefinitionProperty] FOR insert 
AS 
insert into audit.[StateDefinitionProperty](	 [StatedefinitionPropertyId]	 ,[LocationId]	 ,[StateDefinitionId]	 ,[Type]	 ,AuditOperation) select 	 i.[StatedefinitionPropertyId]	 ,i.[LocationId]	 ,i.[StateDefinitionId]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgStateDefinitionProperty_D
ON dbo.[StateDefinitionProperty] FOR delete 
AS 
insert into audit.[StateDefinitionProperty](	 [StatedefinitionPropertyId]	 ,[LocationId]	 ,[StateDefinitionId]	 ,[Type]	 ,AuditOperation) select 	 d.[StatedefinitionPropertyId]	 ,d.[LocationId]	 ,d.[StateDefinitionId]	 ,d.[Type],'D' from deleted d