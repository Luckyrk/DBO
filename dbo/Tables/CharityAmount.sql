CREATE TABLE [dbo].[CharityAmount] (
    [GUIDReference] UNIQUEIDENTIFIER NOT NULL,
    [Value]         INT              NOT NULL,
    [Country_Id]    UNIQUEIDENTIFIER NOT NULL,
    [Subscription]  NVARCHAR (100)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CharityAmount] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.CharityAmount_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[CharityAmount]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgCharityAmount_U 
ON dbo.[CharityAmount] FOR update 
AS 
insert into audit.[CharityAmount](	 [GUIDReference]	 ,[Value]	 ,[Country_Id]	 ,[Subscription]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Value]	 ,d.[Country_Id]	 ,d.[Subscription],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[CharityAmount](	 [GUIDReference]	 ,[Value]	 ,[Country_Id]	 ,[Subscription]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Value]	 ,i.[Country_Id]	 ,i.[Subscription],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgCharityAmount_I
ON dbo.[CharityAmount] FOR insert 
AS 
insert into audit.[CharityAmount](	 [GUIDReference]	 ,[Value]	 ,[Country_Id]	 ,[Subscription]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Value]	 ,i.[Country_Id]	 ,i.[Subscription],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCharityAmount_D
ON dbo.[CharityAmount] FOR delete 
AS 
insert into audit.[CharityAmount](	 [GUIDReference]	 ,[Value]	 ,[Country_Id]	 ,[Subscription]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Value]	 ,d.[Country_Id]	 ,d.[Subscription],'D' from deleted d