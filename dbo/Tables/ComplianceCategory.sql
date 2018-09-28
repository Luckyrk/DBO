CREATE TABLE [dbo].[ComplianceCategory] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [KeyName]            NVARCHAR (1000)  NOT NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NOT NULL,
    [CreationTimeStamp]  DATETIME         NOT NULL,
    [GPSUpdateTimestamp] DATETIME         NOT NULL,
    CONSTRAINT [PK_dbo.ComplianceCategory] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ComplianceCategory_Country] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ComplianceCategory_Translation] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);


GO
CREATE TRIGGER dbo.trgComplianceCategory_U 
ON dbo.[ComplianceCategory] FOR update 
AS 
insert into audit.[ComplianceCategory](	 [GUIDReference]	 ,[KeyName]	 ,[Translation_Id]	 ,[Country_Id]	 ,[GPSUser]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[KeyName]	 ,d.[Translation_Id]	 ,d.[Country_Id]	 ,d.[GPSUser]	 ,d.[CreationTimeStamp]	 ,d.[GPSUpdateTimestamp],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[ComplianceCategory](	 [GUIDReference]	 ,[KeyName]	 ,[Translation_Id]	 ,[Country_Id]	 ,[GPSUser]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[KeyName]	 ,i.[Translation_Id]	 ,i.[Country_Id]	 ,i.[GPSUser]	 ,i.[CreationTimeStamp]	 ,i.[GPSUpdateTimestamp],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgComplianceCategory_D
ON dbo.[ComplianceCategory] FOR delete 
AS 
insert into audit.[ComplianceCategory](	 [GUIDReference]	 ,[KeyName]	 ,[Translation_Id]	 ,[Country_Id]	 ,[GPSUser]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[KeyName]	 ,d.[Translation_Id]	 ,d.[Country_Id]	 ,d.[GPSUser]	 ,d.[CreationTimeStamp]	 ,d.[GPSUpdateTimestamp],'D' from deleted d
GO
CREATE TRIGGER dbo.trgComplianceCategory_I
ON dbo.[ComplianceCategory] FOR insert 
AS 
insert into audit.[ComplianceCategory](	 [GUIDReference]	 ,[KeyName]	 ,[Translation_Id]	 ,[Country_Id]	 ,[GPSUser]	 ,[CreationTimeStamp]	 ,[GPSUpdateTimestamp]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[KeyName]	 ,i.[Translation_Id]	 ,i.[Country_Id]	 ,i.[GPSUser]	 ,i.[CreationTimeStamp]	 ,i.[GPSUpdateTimestamp],'I' from inserted i