CREATE TABLE [dbo].[ComplianceCategoryStatus] (
    [GUIDReference]         UNIQUEIDENTIFIER NOT NULL,
    [ComplianceCategory_Id] UNIQUEIDENTIFIER NOT NULL,
    [Panelist_Id]           UNIQUEIDENTIFIER NOT NULL,
    [SignalColor]           NVARCHAR (1000)  NOT NULL,
    [GPSUser]               NVARCHAR (50)    NOT NULL,
    [CreationTimeStamp]     DATETIME         NOT NULL,
    [GPSUpdateTimestamp]    DATETIME         NOT NULL,
    CONSTRAINT [PK_dbo.ComplianceCategoryStatus] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ComplianceCategoryStatus_ComplianceCategory] FOREIGN KEY ([ComplianceCategory_Id]) REFERENCES [dbo].[ComplianceCategory] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ComplianceCategoryStatus_Panelist] FOREIGN KEY ([Panelist_Id]) REFERENCES [dbo].[Panelist] ([GUIDReference])
);


GO
CREATE TRIGGER dbo.trgComplianceCategoryStatus_U 
ON dbo.[ComplianceCategoryStatus] FOR update 
AS 
insert into audit.[ComplianceCategoryStatus](	 [GUIDReference]	 ,[ComplianceCategory_Id]	 ,[Panelist_Id]	 ,[SignalColor]	 ,[GPSUser]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[ComplianceCategory_Id]	 ,d.[Panelist_Id]	 ,d.[SignalColor]	 ,d.[GPSUser]	 ,d.[CreationTimeStamp]	 ,d.[GPSUpdateTimestamp],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ComplianceCategoryStatus](	 [GUIDReference]	 ,[ComplianceCategory_Id]	 ,[Panelist_Id]	 ,[SignalColor]	 ,[GPSUser]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[ComplianceCategory_Id]	 ,i.[Panelist_Id]	 ,i.[SignalColor]	 ,i.[GPSUser]	 ,i.[CreationTimeStamp]	 ,i.[GPSUpdateTimestamp],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgComplianceCategoryStatus_D
ON dbo.[ComplianceCategoryStatus] FOR delete 
AS 
insert into audit.[ComplianceCategoryStatus](	 [GUIDReference]	 ,[ComplianceCategory_Id]	 ,[Panelist_Id]	 ,[SignalColor]	 ,[GPSUser]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[ComplianceCategory_Id]	 ,d.[Panelist_Id]	 ,d.[SignalColor]	 ,d.[GPSUser]	 ,d.[CreationTimeStamp]	 ,d.[GPSUpdateTimestamp],'D' from deleted d
GO
CREATE TRIGGER dbo.trgComplianceCategoryStatus_I
ON dbo.[ComplianceCategoryStatus] FOR insert 
AS 
insert into audit.[ComplianceCategoryStatus](	 [GUIDReference]	 ,[ComplianceCategory_Id]	 ,[Panelist_Id]	 ,[SignalColor]	 ,[GPSUser]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[ComplianceCategory_Id]	 ,i.[Panelist_Id]	 ,i.[SignalColor]	 ,i.[GPSUser]	 ,i.[CreationTimeStamp]	 ,i.[GPSUpdateTimestamp],'I' from inserted i