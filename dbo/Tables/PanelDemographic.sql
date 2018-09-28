CREATE TABLE [dbo].[PanelDemographic] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [IsCalculated]       BIT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [BaseDemographic_Id] UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Panel_Id]           UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.PanelDemographic] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.PanelDemographic_dbo.Attribute_BaseDemographic_Id] FOREIGN KEY ([BaseDemographic_Id]) REFERENCES [dbo].[Attribute] ([GUIDReference]),
    CONSTRAINT [FK_dbo.PanelDemographic_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.PanelDemographic_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [UniquePanelDemographic] UNIQUE NONCLUSTERED ([BaseDemographic_Id] ASC, [Panel_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_BaseDemographic_Id]
    ON [dbo].[PanelDemographic]([BaseDemographic_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[PanelDemographic]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[PanelDemographic]([Panel_Id] ASC);


GO
CREATE TRIGGER dbo.trgPanelDemographic_U 
ON dbo.[PanelDemographic] FOR update 
AS 
insert into audit.[PanelDemographic](	 [GUIDReference]	 ,[IsCalculated]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[BaseDemographic_Id]	 ,[Country_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[IsCalculated]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[BaseDemographic_Id]	 ,d.[Country_Id]	 ,d.[Panel_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[PanelDemographic](	 [GUIDReference]	 ,[IsCalculated]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[BaseDemographic_Id]	 ,[Country_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[IsCalculated]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[BaseDemographic_Id]	 ,i.[Country_Id]	 ,i.[Panel_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgPanelDemographic_I
ON dbo.[PanelDemographic] FOR insert 
AS 
insert into audit.[PanelDemographic](	 [GUIDReference]	 ,[IsCalculated]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[BaseDemographic_Id]	 ,[Country_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[IsCalculated]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[BaseDemographic_Id]	 ,i.[Country_Id]	 ,i.[Panel_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPanelDemographic_D
ON dbo.[PanelDemographic] FOR delete 
AS 
insert into audit.[PanelDemographic](	 [GUIDReference]	 ,[IsCalculated]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[BaseDemographic_Id]	 ,[Country_Id]	 ,[Panel_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[IsCalculated]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[BaseDemographic_Id]	 ,d.[Country_Id]	 ,d.[Panel_Id],'D' from deleted d