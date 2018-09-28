CREATE TABLE [dbo].[Action] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [CreationDate]       DATETIME         NOT NULL,
    [FromDate]           DATETIME         NOT NULL,
    [DueDate]            DATETIME         NOT NULL,
    [Comments]           NVARCHAR (2000)  NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Type_Id]            UNIQUEIDENTIFIER NOT NULL,
    [State_Id]           UNIQUEIDENTIFIER NOT NULL,
    [AssignedTo_Id]      UNIQUEIDENTIFIER NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [BusinessGroup_Id]   UNIQUEIDENTIFIER NULL,
    [HouseHoldGroup_Id]  UNIQUEIDENTIFIER NULL,
    [Individual_Id]      UNIQUEIDENTIFIER NULL,
    [Panelist_Id]        UNIQUEIDENTIFIER NULL,
    [Type]               NVARCHAR (128)   NOT NULL,
    CONSTRAINT [PK_dbo.Action] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Action_dbo.ActionType_Type_Id] FOREIGN KEY ([Type_Id]) REFERENCES [dbo].[ActionType] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Action_dbo.Collective_BusinessGroup_Id] FOREIGN KEY ([BusinessGroup_Id]) REFERENCES [dbo].[Collective] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Action_dbo.Collective_HouseHoldGroup_Id] FOREIGN KEY ([HouseHoldGroup_Id]) REFERENCES [dbo].[Collective] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Action_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.Action_dbo.Individual_Individual_Id] FOREIGN KEY ([Individual_Id]) REFERENCES [dbo].[Individual] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Action_dbo.Panelist_Panelist_Id] FOREIGN KEY ([Panelist_Id]) REFERENCES [dbo].[Panelist] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Action_dbo.StateDefinition_State_Id] FOREIGN KEY ([State_Id]) REFERENCES [dbo].[StateDefinition] ([Id]),
    CONSTRAINT [FK_dbo.Action_dbo.Users_AssignedTo_Id] FOREIGN KEY ([AssignedTo_Id]) REFERENCES [dbo].[Users] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Type_Id]
    ON [dbo].[Action]([Type_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_State_Id]
    ON [dbo].[Action]([State_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AssignedTo_Id]
    ON [dbo].[Action]([AssignedTo_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[Action]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_BusinessGroup_Id]
    ON [dbo].[Action]([BusinessGroup_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_HouseHoldGroup_Id]
    ON [dbo].[Action]([HouseHoldGroup_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Individual_Id]
    ON [dbo].[Action]([Individual_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panelist_Id]
    ON [dbo].[Action]([Panelist_Id] ASC);


GO
CREATE TRIGGER dbo.trgAction_U 
ON dbo.[Action] FOR update 
AS 
insert into audit.[Action](	 [GUIDReference]	 ,[CreationDate]	 ,[FromDate]	 ,[DueDate]	 ,[Comments]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Type_Id]	 ,[State_Id]	 ,[AssignedTo_Id]	 ,[Country_Id]	 ,[BusinessGroup_Id]	 ,[HouseHoldGroup_Id]	 ,[Individual_Id]	 ,[Panelist_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[CreationDate]	 ,d.[FromDate]	 ,d.[DueDate]	 ,d.[Comments]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Type_Id]	 ,d.[State_Id]	 ,d.[AssignedTo_Id]	 ,d.[Country_Id]	 ,d.[BusinessGroup_Id]	 ,d.[HouseHoldGroup_Id]	 ,d.[Individual_Id]	 ,d.[Panelist_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[Action](	 [GUIDReference]	 ,[CreationDate]	 ,[FromDate]	 ,[DueDate]	 ,[Comments]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Type_Id]	 ,[State_Id]	 ,[AssignedTo_Id]	 ,[Country_Id]	 ,[BusinessGroup_Id]	 ,[HouseHoldGroup_Id]	 ,[Individual_Id]	 ,[Panelist_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[CreationDate]	 ,i.[FromDate]	 ,i.[DueDate]	 ,i.[Comments]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Type_Id]	 ,i.[State_Id]	 ,i.[AssignedTo_Id]	 ,i.[Country_Id]	 ,i.[BusinessGroup_Id]	 ,i.[HouseHoldGroup_Id]	 ,i.[Individual_Id]	 ,i.[Panelist_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgAction_I
ON dbo.[Action] FOR insert 
AS 
insert into audit.[Action](	 [GUIDReference]	 ,[CreationDate]	 ,[FromDate]	 ,[DueDate]	 ,[Comments]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Type_Id]	 ,[State_Id]	 ,[AssignedTo_Id]	 ,[Country_Id]	 ,[BusinessGroup_Id]	 ,[HouseHoldGroup_Id]	 ,[Individual_Id]	 ,[Panelist_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[CreationDate]	 ,i.[FromDate]	 ,i.[DueDate]	 ,i.[Comments]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Type_Id]	 ,i.[State_Id]	 ,i.[AssignedTo_Id]	 ,i.[Country_Id]	 ,i.[BusinessGroup_Id]	 ,i.[HouseHoldGroup_Id]	 ,i.[Individual_Id]	 ,i.[Panelist_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgAction_D
ON dbo.[Action] FOR delete 
AS 
insert into audit.[Action](	 [GUIDReference]	 ,[CreationDate]	 ,[FromDate]	 ,[DueDate]	 ,[Comments]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Type_Id]	 ,[State_Id]	 ,[AssignedTo_Id]	 ,[Country_Id]	 ,[BusinessGroup_Id]	 ,[HouseHoldGroup_Id]	 ,[Individual_Id]	 ,[Panelist_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[CreationDate]	 ,d.[FromDate]	 ,d.[DueDate]	 ,d.[Comments]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Type_Id]	 ,d.[State_Id]	 ,d.[AssignedTo_Id]	 ,d.[Country_Id]	 ,d.[BusinessGroup_Id]	 ,d.[HouseHoldGroup_Id]	 ,d.[Individual_Id]	 ,d.[Panelist_Id]	 ,d.[Type],'D' from deleted d