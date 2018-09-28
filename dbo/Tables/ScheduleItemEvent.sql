CREATE TABLE [dbo].[ScheduleItemEvent] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Query_Id]           UNIQUEIDENTIFIER NULL,
    [Action_Id]          UNIQUEIDENTIFIER NULL,
    [Type]               NVARCHAR (128)   NOT NULL,
    [Country_Id] UNIQUEIDENTIFIER NOT NULL, 
    CONSTRAINT [PK_dbo.ScheduleItemEvent] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ScheduleItemEvent_dbo.PreDefinedQuery_Query_Id] FOREIGN KEY ([Query_Id]) REFERENCES [dbo].[PreDefinedQuery] ([PreDefinedQueryId]),
    CONSTRAINT [FK_dbo.ScheduleItemEvent_dbo.QueryAction_Action_Id] FOREIGN KEY ([Action_Id]) REFERENCES [dbo].[QueryAction] ([GUIDReference]) ,
	CONSTRAINT [FK_dbo.ScheduleItemEvent_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Query_Id]
    ON [dbo].[ScheduleItemEvent]([Query_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Action_Id]
    ON [dbo].[ScheduleItemEvent]([Action_Id] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ScheduleItemEvent]([Country_Id] ASC);

GO
CREATE TRIGGER dbo.trgScheduleItemEvent_U 
ON dbo.[ScheduleItemEvent] FOR update 
AS 
insert into audit.[ScheduleItemEvent](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Query_Id]	 ,[Action_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Query_Id]	 ,d.[Action_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ScheduleItemEvent](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Query_Id]	 ,[Action_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Query_Id]	 ,i.[Action_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgScheduleItemEvent_I
ON dbo.[ScheduleItemEvent] FOR insert 
AS 
insert into audit.[ScheduleItemEvent](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Query_Id]	 ,[Action_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Query_Id]	 ,i.[Action_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgScheduleItemEvent_D
ON dbo.[ScheduleItemEvent] FOR delete 
AS 
insert into audit.[ScheduleItemEvent](	 [GUIDReference]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Query_Id]	 ,[Action_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Query_Id]	 ,d.[Action_Id]	 ,d.[Type],'D' from deleted d