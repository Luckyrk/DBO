CREATE TABLE [dbo].[CollectiveGroupContactHistory] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [DateFrom]           DATETIME         NOT NULL,
    [DateTo]             DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [GPSUser]            NVARCHAR (100)   NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [Group_Id]           UNIQUEIDENTIFIER NULL,
    [Individual_Id]      UNIQUEIDENTIFIER NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.CollectiveGroupContactHistory] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.CollectiveGroupContactHistory_dbo.Collective_Group_Id] FOREIGN KEY ([Group_Id]) REFERENCES [dbo].[Collective] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CollectiveGroupContactHistory_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.CollectiveGroupContactHistory_dbo.Individual_Individual_Id] FOREIGN KEY ([Individual_Id]) REFERENCES [dbo].[Individual] ([GUIDReference])
);




GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[CollectiveGroupContactHistory]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Individual_Id]
    ON [dbo].[CollectiveGroupContactHistory]([Individual_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Group_Id]
    ON [dbo].[CollectiveGroupContactHistory]([Group_Id] ASC);


GO
CREATE TRIGGER dbo.trgCollectiveGroupContactHistory_U 
ON dbo.[CollectiveGroupContactHistory] FOR update 
AS 
insert into audit.[CollectiveGroupContactHistory](	 [Id]	 ,[DateFrom]	 ,[DateTo]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Group_Id]	 ,[Individual_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[DateFrom]	 ,d.[DateTo]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[Group_Id]	 ,d.[Individual_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[CollectiveGroupContactHistory](	 [Id]	 ,[DateFrom]	 ,[DateTo]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Group_Id]	 ,[Individual_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[DateFrom]	 ,i.[DateTo]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[Group_Id]	 ,i.[Individual_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgCollectiveGroupContactHistory_I
ON dbo.[CollectiveGroupContactHistory] FOR insert 
AS 
insert into audit.[CollectiveGroupContactHistory](	 [Id]	 ,[DateFrom]	 ,[DateTo]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Group_Id]	 ,[Individual_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[DateFrom]	 ,i.[DateTo]	 ,i.[CreationTimeStamp]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[Group_Id]	 ,i.[Individual_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCollectiveGroupContactHistory_D
ON dbo.[CollectiveGroupContactHistory] FOR delete 
AS 
insert into audit.[CollectiveGroupContactHistory](	 [Id]	 ,[DateFrom]	 ,[DateTo]	 ,[CreationTimeStamp]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[Group_Id]	 ,[Individual_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[DateFrom]	 ,d.[DateTo]	 ,d.[CreationTimeStamp]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[Group_Id]	 ,d.[Individual_Id]	 ,d.[Country_Id],'D' from deleted d