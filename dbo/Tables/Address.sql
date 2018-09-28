CREATE TABLE [dbo].[Address] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [AddressLine1]       NVARCHAR (100)   NULL,
    [GPSUser]            NVARCHAR (50)    NOT NULL,
    [GPSUpdateTimestamp] DATETIME         NOT NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [AddressLine2]       NVARCHAR (100)   NULL,
    [AddressLine3]       NVARCHAR (100)   NULL,
    [AddressLine4]       NVARCHAR (100)   NULL,
    [PostCode]           NVARCHAR (50)    NULL,
    [Type_Id]            UNIQUEIDENTIFIER NULL,
    [AddressType]        NVARCHAR (128)   DEFAULT ('None') NOT NULL,
	[Country_Id]		 UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.Address] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Address_dbo.AddressType_Type_Id] FOREIGN KEY ([Type_Id]) REFERENCES [dbo].[AddressType] ([Id])
);




GO
CREATE NONCLUSTERED INDEX [IX_Type_Id]
    ON [dbo].[Address]([Type_Id] ASC);

	
GO

CREATE NONCLUSTERED INDEX idx_AddressLine_AddressLine1
ON [dbo].[Address] ([AddressType])
INCLUDE ([GUIDReference],[AddressLine1])

GO
CREATE TRIGGER [dbo].[trgAddress_U] 
ON [dbo].[Address] FOR update 
AS 
insert into audit.[Address](	 [GUIDReference]	 ,[AddressLine1]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[AddressLine2]	 ,[AddressLine3]	 ,[AddressLine4]	 ,[PostCode]	 ,[Type_Id]	 ,[AddressType]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[AddressLine1]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[AddressLine2]	 ,d.[AddressLine3]	 ,d.[AddressLine4]	 ,d.[PostCode]	 ,d.[Type_Id]	 ,d.[AddressType],d.[Country_Id],'O'  from 	 deleted d join inserted i on d.[GUIDReference] = i.[GUIDReference] 
insert into audit.[Address](	 [GUIDReference]	 ,[AddressLine1]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[AddressLine2]	 ,[AddressLine3]	 ,[AddressLine4]	 ,[PostCode]	 ,[Type_Id]	 ,[AddressType]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[AddressLine1]	 ,i.[GPSUser]	 ,GETDATE()	 ,i.[CreationTimeStamp]	 ,i.[AddressLine2]	 ,i.[AddressLine3]	 ,i.[AddressLine4]	 ,i.[PostCode]	 ,i.[Type_Id]	 ,i.[AddressType],i.[Country_Id],'N'  from 	 deleted d join inserted i on d.[GUIDReference] = i.[GUIDReference]
GO
CREATE TRIGGER [dbo].[trgAddress_I]
ON [dbo].[Address] FOR insert 
AS 
insert into audit.[Address](	 [GUIDReference]	 ,[AddressLine1]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[AddressLine2]	 ,[AddressLine3]	 ,[AddressLine4]	 ,[PostCode]	 ,[Type_Id]	 ,[AddressType]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[AddressLine1]	 ,i.[GPSUser]	 ,GETDATE()	 ,i.[CreationTimeStamp]	 ,i.[AddressLine2]	 ,i.[AddressLine3]	 ,i.[AddressLine4]	 ,i.[PostCode]	 ,i.[Type_Id]	 ,i.[AddressType],i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgAddress_D
ON dbo.[Address] FOR delete 
AS 
insert into audit.[Address](	 [GUIDReference]	 ,[AddressLine1]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[AddressLine2]	 ,[AddressLine3]	 ,[AddressLine4]	 ,[PostCode]	 ,[Type_Id]	 ,[AddressType]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[AddressLine1]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[AddressLine2]	 ,d.[AddressLine3]	 ,d.[AddressLine4]	 ,d.[PostCode]	 ,d.[Type_Id]	 ,d.[AddressType],d.[Country_Id],'D' from deleted d
GO

