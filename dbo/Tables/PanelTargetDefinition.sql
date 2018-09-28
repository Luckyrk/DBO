CREATE TABLE [dbo].[PanelTargetDefinition] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Name]               NVARCHAR (150)   NOT NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [Dimension_Id]       UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Panel_Id]           UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.PanelTargetDefinition] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.PanelTargetDefinition_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.PanelTargetDefinition_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.PanelTargetDefinition_dbo.PanelTargetValueDefinition_Dimension_Id] FOREIGN KEY ([Dimension_Id]) REFERENCES [dbo].[PanelTargetValueDefinition] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Dimension_Id]
    ON [dbo].[PanelTargetDefinition]([Dimension_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[PanelTargetDefinition]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[PanelTargetDefinition]([Panel_Id] ASC);


GO
CREATE TRIGGER dbo.trgPanelTargetDefinition_U 
ON dbo.[PanelTargetDefinition] FOR update 
AS 
insert into audit.[PanelTargetDefinition](	 [GUIDReference]	 ,[Name]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Dimension_Id]	 ,[Country_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Name]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[Dimension_Id]	 ,d.[Country_Id]	 ,d.[Panel_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[PanelTargetDefinition](	 [GUIDReference]	 ,[Name]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Dimension_Id]	 ,[Country_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Name]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[Dimension_Id]	 ,i.[Country_Id]	 ,i.[Panel_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgPanelTargetDefinition_I
ON dbo.[PanelTargetDefinition] FOR insert 
AS 
insert into audit.[PanelTargetDefinition](	 [GUIDReference]	 ,[Name]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Dimension_Id]	 ,[Country_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Name]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[Dimension_Id]	 ,i.[Country_Id]	 ,i.[Panel_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPanelTargetDefinition_D
ON dbo.[PanelTargetDefinition] FOR delete 
AS 
insert into audit.[PanelTargetDefinition](	 [GUIDReference]	 ,[Name]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Dimension_Id]	 ,[Country_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Name]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[Dimension_Id]	 ,d.[Country_Id]	 ,d.[Panel_Id],'D' from deleted d