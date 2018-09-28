CREATE TABLE [dbo].[ScheduleItem] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Name]               NVARCHAR (200)   NOT NULL,
    [StartDate]          DATETIME         NOT NULL,
    [DueDate]            DATETIME         NOT NULL,
    [Enabled]            BIT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Frequency_Id]       UNIQUEIDENTIFIER NOT NULL,
    [Event_Id]           UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.ScheduleItem] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ScheduleItem_dbo.ScheduleItemEvent_Event_Id] FOREIGN KEY ([Event_Id]) REFERENCES [dbo].[ScheduleItemEvent] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.ScheduleItem_dbo.ScheduleItemFrequency_Frequency_Id] FOREIGN KEY ([Frequency_Id]) REFERENCES [dbo].[ScheduleItemFrequency] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_ScheduleItem_dbo.ScheduleItem_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [UniqueScheduleItemName] UNIQUE NONCLUSTERED ([Name] ASC, [Country_Id] ASC)
);












GO
CREATE NONCLUSTERED INDEX [IX_Frequency_Id]
    ON [dbo].[ScheduleItem]([Frequency_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Event_Id]
    ON [dbo].[ScheduleItem]([Event_Id] ASC);


GO
CREATE TRIGGER dbo.trgScheduleItem_U 
ON dbo.[ScheduleItem] FOR update 
AS 
insert into audit.[ScheduleItem](	 [GUIDReference]	 ,[Name]	 ,[StartDate]	 ,[DueDate]	 ,[Enabled]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Frequency_Id]	 ,[Event_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Name]	 ,d.[StartDate]	 ,d.[DueDate]	 ,d.[Enabled]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Frequency_Id]	 ,d.[Event_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ScheduleItem](	 [GUIDReference]	 ,[Name]	 ,[StartDate]	 ,[DueDate]	 ,[Enabled]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Frequency_Id]	 ,[Event_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Name]	 ,i.[StartDate]	 ,i.[DueDate]	 ,i.[Enabled]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Frequency_Id]	 ,i.[Event_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgScheduleItem_I
ON dbo.[ScheduleItem] FOR insert 
AS 
insert into audit.[ScheduleItem](	 [GUIDReference]	 ,[Name]	 ,[StartDate]	 ,[DueDate]	 ,[Enabled]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Frequency_Id]	 ,[Event_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Name]	 ,i.[StartDate]	 ,i.[DueDate]	 ,i.[Enabled]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Frequency_Id]	 ,i.[Event_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgScheduleItem_D
ON dbo.[ScheduleItem] FOR delete 
AS 
insert into audit.[ScheduleItem](	 [GUIDReference]	 ,[Name]	 ,[StartDate]	 ,[DueDate]	 ,[Enabled]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Frequency_Id]	 ,[Event_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Name]	 ,d.[StartDate]	 ,d.[DueDate]	 ,d.[Enabled]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Frequency_Id]	 ,d.[Event_Id]	 ,d.[Country_Id],'D' from deleted d