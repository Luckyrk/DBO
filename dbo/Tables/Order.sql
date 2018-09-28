CREATE TABLE [dbo].[Order] (
    [OrderId]            BIGINT           IDENTITY (1, 1) NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [OrderedDate]        DATETIME         NOT NULL,
    [DispatchedDate]     DATETIME         NULL,
    [Comments]           NVARCHAR (200)   NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [State_Id]           UNIQUEIDENTIFIER NOT NULL,
    [Region_Id]          UNIQUEIDENTIFIER NULL,
    [Location_Id]        UNIQUEIDENTIFIER NOT NULL,
    [Type_Id]            UNIQUEIDENTIFIER NOT NULL,
    [SentBy_Id]          UNIQUEIDENTIFIER NULL,
    [ActionTask_Id]      UNIQUEIDENTIFIER NOT NULL,
    [Reason_Id]          UNIQUEIDENTIFIER NULL,
    [CountryOrderId]     BIGINT           NULL,
    [PostalAddress_Id]   UNIQUEIDENTIFIER NULL,
    [PickUpdate]         DATETIME         NULL,
    [FromHours]          INT              NULL,
    [ToHours]            INT              NULL,
    CONSTRAINT [PK_dbo.Order] PRIMARY KEY CLUSTERED ([OrderId] ASC, [Country_Id] ASC) WITH (FILLFACTOR = 90),
    CONSTRAINT [FK_dbo.Order_dbo.ActionTask_ActionTask_Id] FOREIGN KEY ([ActionTask_Id]) REFERENCES [dbo].[ActionTask] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Order_dbo.Address_PostalAddress_Id] FOREIGN KEY ([PostalAddress_Id]) REFERENCES [dbo].[Address] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Order_dbo.AttributeValue_Region_Id] FOREIGN KEY ([Region_Id]) REFERENCES [dbo].[AttributeValue] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Order_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.Order_dbo.IdentityUser_SentBy_Id] FOREIGN KEY ([SentBy_Id]) REFERENCES [dbo].[IdentityUser] ([Id]),
    CONSTRAINT [FK_dbo.Order_dbo.OrderType_Type_Id] FOREIGN KEY ([Type_Id]) REFERENCES [dbo].[OrderType] ([Id]),
    CONSTRAINT [FK_dbo.Order_dbo.ReasonForOrderType_Reason_Id] FOREIGN KEY ([Reason_Id]) REFERENCES [dbo].[ReasonForOrderType] ([Id]),
    CONSTRAINT [FK_dbo.Order_dbo.StateDefinition_State_Id] FOREIGN KEY ([State_Id]) REFERENCES [dbo].[StateDefinition] ([Id]),
    CONSTRAINT [FK_dbo.Order_dbo.StockPanelistLocation_Location_Id] FOREIGN KEY ([Location_Id]) REFERENCES [dbo].[StockPanelistLocation] ([GUIDReference])
);














GO
CREATE NONCLUSTERED INDEX [IX_State_Id]
    ON [dbo].[Order]([State_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Region_Id]
    ON [dbo].[Order]([Region_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Location_Id]
    ON [dbo].[Order]([Location_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Type_Id]
    ON [dbo].[Order]([Type_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_SentBy_Id]
    ON [dbo].[Order]([SentBy_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ActionTask_Id]
    ON [dbo].[Order]([ActionTask_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Reason_Id]
    ON [dbo].[Order]([Reason_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[Order]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgOrder_U 
ON dbo.[Order] FOR update 
AS 
insert into audit.[Order](
[OrderId]
,[Country_Id]
,[OrderedDate]
,[DispatchedDate]
,[Comments]
,[GPSUser]
,[GPSUpdateTimestamp]
,[CreationTimeStamp]
,[State_Id]
,[Region_Id]
,[Location_Id]
,[Type_Id]
,[SentBy_Id]
,[ActionTask_Id]
,[Reason_Id]
,[CountryOrderId]
,[PostalAddress_Id]
,AuditOperation) select 
d.[OrderId]
,d.[Country_Id]
,d.[OrderedDate]
,d.[DispatchedDate]
,d.[Comments]
,d.[GPSUser]
,d.[GPSUpdateTimestamp]
,d.[CreationTimeStamp]
,d.[State_Id]
,d.[Region_Id]
,d.[Location_Id]
,d.[Type_Id]
,d.[SentBy_Id]
,d.[ActionTask_Id]
,d.[Reason_Id]
,d.[CountryOrderId]
,d.[PostalAddress_Id],'O'  from 
deleted d join inserted i on d.Country_Id = i.Country_Id
and d.OrderId = i.OrderId 
insert into audit.[Order](
[OrderId]
,[Country_Id]
,[OrderedDate]
,[DispatchedDate]
,[Comments]
,[GPSUser]
,[GPSUpdateTimestamp]
,[CreationTimeStamp]
,[State_Id]
,[Region_Id]
,[Location_Id]
,[Type_Id]
,[SentBy_Id]
,[ActionTask_Id]
,[Reason_Id]
,[CountryOrderId]
,[PostalAddress_Id]
,AuditOperation) select 
i.[OrderId]
,i.[Country_Id]
,i.[OrderedDate]
,i.[DispatchedDate]
,i.[Comments]
,i.[GPSUser]
,i.[GPSUpdateTimestamp]
,i.[CreationTimeStamp]
,i.[State_Id]
,i.[Region_Id]
,i.[Location_Id]
,i.[Type_Id]
,i.[SentBy_Id]
,i.[ActionTask_Id]
,i.[Reason_Id]
,i.[CountryOrderId]
,i.[PostalAddress_Id],'N'  from 
deleted d join inserted i on d.Country_Id = i.Country_Id
and d.OrderId = i.OrderId
GO
DISABLE TRIGGER [dbo].[trgOrder_U]
    ON [dbo].[Order];


GO
CREATE TRIGGER dbo.trgOrder_I
ON dbo.[Order] FOR insert 
AS 
insert into audit.[Order](
[OrderId]
,[Country_Id]
,[OrderedDate]
,[DispatchedDate]
,[Comments]
,[GPSUser]
,[GPSUpdateTimestamp]
,[CreationTimeStamp]
,[State_Id]
,[Region_Id]
,[Location_Id]
,[Type_Id]
,[SentBy_Id]
,[ActionTask_Id]
,[Reason_Id]
,[CountryOrderId]
,[PostalAddress_Id]
,AuditOperation) select 
i.[OrderId]
,i.[Country_Id]
,i.[OrderedDate]
,i.[DispatchedDate]
,i.[Comments]
,i.[GPSUser]
,i.[GPSUpdateTimestamp]
,i.[CreationTimeStamp]
,i.[State_Id]
,i.[Region_Id]
,i.[Location_Id]
,i.[Type_Id]
,i.[SentBy_Id]
,i.[ActionTask_Id]
,i.[Reason_Id]
,i.[CountryOrderId]
,i.[PostalAddress_Id],'I' from inserted i
GO
DISABLE TRIGGER [dbo].[trgOrder_I]
    ON [dbo].[Order];


GO
CREATE TRIGGER dbo.trgOrder_D
ON dbo.[Order] FOR delete 
AS 
insert into [GPS_PM_Iberia_Audit].[Audit].[Order](
[OrderId]
,[Country_Id]
,[OrderedDate]
,[DispatchedDate]
,[Comments]
,[GPSUser]
,[GPSUpdateTimestamp]
,[CreationTimeStamp]
,[State_Id]
,[Region_Id]
,[Location_Id]
,[Type_Id]
,[SentBy_Id]
,[ActionTask_Id]
,[Reason_Id]
,[CountryOrderId]
,[PostalAddress_Id]
,[AuditOperation],[AuditModifiedBy],[__$operation],[AuditDate]) select 
d.[OrderId]
,d.[Country_Id]
,d.[OrderedDate]
,d.[DispatchedDate]
,d.[Comments]
,SYSTEM_USER
,d.[GPSUpdateTimestamp]
,d.[CreationTimeStamp]
,d.[State_Id]
,d.[Region_Id]
,d.[Location_Id]
,d.[Type_Id]
,d.[SentBy_Id]
,d.[ActionTask_Id]
,d.[Reason_Id]
,d.[CountryOrderId]
,d.[PostalAddress_Id],'D',SYSTEM_USER,1,dbo.GetLocalDateTime(GETDATE(),'ES') from deleted d