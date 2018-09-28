CREATE TABLE [dbo].[DemandedProductAnswer] (
    [Id]                        UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]                   NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]        DATETIME         NULL,
    [CreationTimeStamp]         DATETIME         NULL,
    [Panelist_Id]               UNIQUEIDENTIFIER NULL,
    [DncProduct_Id]             UNIQUEIDENTIFIER NULL,
    [DncAnswerCategory_Id]      UNIQUEIDENTIFIER NULL,
    [CalendarPeriod_CalendarId] UNIQUEIDENTIFIER NULL,
    [CalendarPeriod_PeriodId]   UNIQUEIDENTIFIER NULL,
    [ActionTask_Id]             UNIQUEIDENTIFIER NULL,
    [Country_Id]                UNIQUEIDENTIFIER NOT NULL,
    [CollaborationMethodology_Id] UNIQUEIDENTIFIER NULL, 
    [FreeText]                      NVARCHAR(400) NULL, 
    CONSTRAINT [PK_dbo.DemandedProductAnswer] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.DemandedProductAnswer_dbo.ActionTask_ActionTask_Id] FOREIGN KEY ([ActionTask_Id]) REFERENCES [dbo].[ActionTask] ([GUIDReference]),
    CONSTRAINT [FK_dbo.DemandedProductAnswer_dbo.CalendarPeriod_CalendarPeriod_CalendarId_CalendarPeriod_PeriodId] FOREIGN KEY ([CalendarPeriod_CalendarId], [CalendarPeriod_PeriodId]) REFERENCES [dbo].[CalendarPeriod] ([CalendarId], [PeriodId]),
    CONSTRAINT [FK_dbo.DemandedProductAnswer_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.DemandedProductAnswer_dbo.DemandedProductCategory_DncProduct_Id] FOREIGN KEY ([DncProduct_Id]) REFERENCES [dbo].[DemandedProductCategory] ([Id]),
    CONSTRAINT [FK_dbo.DemandedProductAnswer_dbo.DemandedProductCategoryAnswer_DncAnswerCategory_Id] FOREIGN KEY ([DncAnswerCategory_Id]) REFERENCES [dbo].[DemandedProductCategoryAnswer] ([Id]),
    CONSTRAINT [FK_dbo.DemandedProductAnswer_dbo.Panelist_Panelist_Id] FOREIGN KEY ([Panelist_Id]) REFERENCES [dbo].[Panelist] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Panelist_Id]
    ON [dbo].[DemandedProductAnswer]([Panelist_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DncProduct_Id]
    ON [dbo].[DemandedProductAnswer]([DncProduct_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DncAnswerCategory_Id]
    ON [dbo].[DemandedProductAnswer]([DncAnswerCategory_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CalendarPeriod_CalendarId_CalendarPeriod_PeriodId]
    ON [dbo].[DemandedProductAnswer]([CalendarPeriod_CalendarId] ASC, [CalendarPeriod_PeriodId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ActionTask_Id]
    ON [dbo].[DemandedProductAnswer]([ActionTask_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[DemandedProductAnswer]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgDemandedProductAnswer_U 
ON dbo.[DemandedProductAnswer] FOR update 
AS 
insert into audit.[DemandedProductAnswer](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panelist_Id]	 ,[DncProduct_Id]	 ,[DncAnswerCategory_Id]	 ,[CalendarPeriod_CalendarId]	 ,[CalendarPeriod_PeriodId]	 ,[ActionTask_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Panelist_Id]	 ,d.[DncProduct_Id]	 ,d.[DncAnswerCategory_Id]	 ,d.[CalendarPeriod_CalendarId]	 ,d.[CalendarPeriod_PeriodId]	 ,d.[ActionTask_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[DemandedProductAnswer](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panelist_Id]	 ,[DncProduct_Id]	 ,[DncAnswerCategory_Id]	 ,[CalendarPeriod_CalendarId]	 ,[CalendarPeriod_PeriodId]	 ,[ActionTask_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Panelist_Id]	 ,i.[DncProduct_Id]	 ,i.[DncAnswerCategory_Id]	 ,i.[CalendarPeriod_CalendarId]	 ,i.[CalendarPeriod_PeriodId]	 ,i.[ActionTask_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgDemandedProductAnswer_I
ON dbo.[DemandedProductAnswer] FOR insert 
AS 
insert into audit.[DemandedProductAnswer](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panelist_Id]	 ,[DncProduct_Id]	 ,[DncAnswerCategory_Id]	 ,[CalendarPeriod_CalendarId]	 ,[CalendarPeriod_PeriodId]	 ,[ActionTask_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Panelist_Id]	 ,i.[DncProduct_Id]	 ,i.[DncAnswerCategory_Id]	 ,i.[CalendarPeriod_CalendarId]	 ,i.[CalendarPeriod_PeriodId]	 ,i.[ActionTask_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDemandedProductAnswer_D
ON dbo.[DemandedProductAnswer] FOR delete 
AS 
insert into audit.[DemandedProductAnswer](	 [Id]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Panelist_Id]	 ,[DncProduct_Id]	 ,[DncAnswerCategory_Id]	 ,[CalendarPeriod_CalendarId]	 ,[CalendarPeriod_PeriodId]	 ,[ActionTask_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Panelist_Id]	 ,d.[DncProduct_Id]	 ,d.[DncAnswerCategory_Id]	 ,d.[CalendarPeriod_CalendarId]	 ,d.[CalendarPeriod_PeriodId]	 ,d.[ActionTask_Id]	 ,d.[Country_Id],'D' from deleted d