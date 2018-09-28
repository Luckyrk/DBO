CREATE TABLE [dbo].[IncentiveLevel] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Code]               INT              NOT NULL,
    [Description]        NVARCHAR (50)    NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [IsDefault]          BIT              NOT NULL,
    [Panel_Id]           UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.IncentiveLevel] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.IncentiveLevel_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.IncentiveLevel_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [UniqueCode] UNIQUE NONCLUSTERED ([Panel_Id] ASC, [Code] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[IncentiveLevel]([Panel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[IncentiveLevel]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgIncentiveLevel_U 
ON dbo.[IncentiveLevel] FOR update 
AS 
insert into audit.[IncentiveLevel](	 [GUIDReference]	 ,[Code]	 ,[Description]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[IsDefault]	 ,[Panel_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Code]	 ,d.[Description]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[IsDefault]	 ,d.[Panel_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[IncentiveLevel](	 [GUIDReference]	 ,[Code]	 ,[Description]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[IsDefault]	 ,[Panel_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Code]	 ,i.[Description]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[IsDefault]	 ,i.[Panel_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgIncentiveLevel_I
ON dbo.[IncentiveLevel] FOR insert 
AS 
insert into audit.[IncentiveLevel](	 [GUIDReference]	 ,[Code]	 ,[Description]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[IsDefault]	 ,[Panel_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Code]	 ,i.[Description]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[IsDefault]	 ,i.[Panel_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgIncentiveLevel_D
ON dbo.[IncentiveLevel] FOR delete 
AS 
insert into audit.[IncentiveLevel](	 [GUIDReference]	 ,[Code]	 ,[Description]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[IsDefault]	 ,[Panel_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Code]	 ,d.[Description]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[IsDefault]	 ,d.[Panel_Id]	 ,d.[Country_Id],'D' from deleted d