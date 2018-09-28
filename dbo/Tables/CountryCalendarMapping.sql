CREATE TABLE [dbo].[CountryCalendarMapping] (
    [CountryId]          UNIQUEIDENTIFIER NOT NULL,
    [CalendarId]         UNIQUEIDENTIFIER NOT NULL,
    [OwnerCountryId]     UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    CONSTRAINT [PK_dbo.CountryCalendarMapping] PRIMARY KEY CLUSTERED ([CountryId] ASC, [CalendarId] ASC),
    CONSTRAINT [FK_dbo.CountryCalendarMapping_dbo.Calendar_CalendarId] FOREIGN KEY ([CalendarId]) REFERENCES [dbo].[Calendar] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CountryCalendarMapping_dbo.Country_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.CountryCalendarMapping_dbo.Country_OwnerCountryId] FOREIGN KEY ([OwnerCountryId]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_CountryId]
    ON [dbo].[CountryCalendarMapping]([CountryId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CalendarId]
    ON [dbo].[CountryCalendarMapping]([CalendarId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_OwnerCountryId]
    ON [dbo].[CountryCalendarMapping]([OwnerCountryId] ASC);


GO
CREATE TRIGGER dbo.trgCountryCalendarMapping_U 
ON dbo.[CountryCalendarMapping] FOR update 
AS 
insert into audit.[CountryCalendarMapping](	 [CountryId]	 ,[CalendarId]	 ,[OwnerCountryId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[CountryId]	 ,d.[CalendarId]	 ,d.[OwnerCountryId]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'O'  from 	 deleted d join inserted i on d.CalendarId = i.CalendarId	 and d.CountryId = i.CountryId 
insert into audit.[CountryCalendarMapping](	 [CountryId]	 ,[CalendarId]	 ,[OwnerCountryId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[CountryId]	 ,i.[CalendarId]	 ,i.[OwnerCountryId]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'N'  from 	 deleted d join inserted i on d.CalendarId = i.CalendarId	 and d.CountryId = i.CountryId
GO
CREATE TRIGGER dbo.trgCountryCalendarMapping_I
ON dbo.[CountryCalendarMapping] FOR insert 
AS 
insert into audit.[CountryCalendarMapping](	 [CountryId]	 ,[CalendarId]	 ,[OwnerCountryId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[CountryId]	 ,i.[CalendarId]	 ,i.[OwnerCountryId]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCountryCalendarMapping_D
ON dbo.[CountryCalendarMapping] FOR delete 
AS 
insert into audit.[CountryCalendarMapping](	 [CountryId]	 ,[CalendarId]	 ,[OwnerCountryId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[CountryId]	 ,d.[CalendarId]	 ,d.[OwnerCountryId]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'D' from deleted d