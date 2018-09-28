CREATE TABLE [dbo].[PanelCalendarMapping] (
    [PanelID]            UNIQUEIDENTIFIER NOT NULL,
    [CalendarID]         UNIQUEIDENTIFIER NOT NULL,
    [OwnerCountryId]     UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    CONSTRAINT [PK_dbo.PanelCalendarMapping] PRIMARY KEY CLUSTERED ([PanelID] ASC, [CalendarID] ASC),
    CONSTRAINT [FK_dbo.PanelCalendarMapping_dbo.Calendar_CalendarID] FOREIGN KEY ([CalendarID]) REFERENCES [dbo].[Calendar] ([GUIDReference]),
    CONSTRAINT [FK_dbo.PanelCalendarMapping_dbo.Country_OwnerCountryId] FOREIGN KEY ([OwnerCountryId]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.PanelCalendarMapping_dbo.Panel_PanelID] FOREIGN KEY ([PanelID]) REFERENCES [dbo].[Panel] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_PanelID]
    ON [dbo].[PanelCalendarMapping]([PanelID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CalendarID]
    ON [dbo].[PanelCalendarMapping]([CalendarID] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OwnerCountryId]
    ON [dbo].[PanelCalendarMapping]([OwnerCountryId] ASC);


GO
CREATE TRIGGER dbo.trgPanelCalendarMapping_U 
ON dbo.[PanelCalendarMapping] FOR update 
AS 
insert into audit.[PanelCalendarMapping](	 [PanelID]	 ,[CalendarID]	 ,[OwnerCountryId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[PanelID]	 ,d.[CalendarID]	 ,d.[OwnerCountryId]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'O'  from 	 deleted d join inserted i on d.CalendarID = i.CalendarID	 and d.PanelID = i.PanelID 
insert into audit.[PanelCalendarMapping](	 [PanelID]	 ,[CalendarID]	 ,[OwnerCountryId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[PanelID]	 ,i.[CalendarID]	 ,i.[OwnerCountryId]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'N'  from 	 deleted d join inserted i on d.CalendarID = i.CalendarID	 and d.PanelID = i.PanelID
GO
CREATE TRIGGER dbo.trgPanelCalendarMapping_I
ON dbo.[PanelCalendarMapping] FOR insert 
AS 
insert into audit.[PanelCalendarMapping](	 [PanelID]	 ,[CalendarID]	 ,[OwnerCountryId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[PanelID]	 ,i.[CalendarID]	 ,i.[OwnerCountryId]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPanelCalendarMapping_D
ON dbo.[PanelCalendarMapping] FOR delete 
AS 
insert into audit.[PanelCalendarMapping](	 [PanelID]	 ,[CalendarID]	 ,[OwnerCountryId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[PanelID]	 ,d.[CalendarID]	 ,d.[OwnerCountryId]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'D' from deleted d