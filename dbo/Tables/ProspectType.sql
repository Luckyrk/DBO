CREATE TABLE [dbo].[ProspectType] (
    [ProspectTypeId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Description]    NVARCHAR (200) NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ProspectType] PRIMARY KEY CLUSTERED ([ProspectTypeId] ASC)
);




GO
CREATE TRIGGER dbo.trgProspectType_U 
ON dbo.[ProspectType] FOR update 
AS 
insert into audit.[ProspectType](	 [ProspectTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[ProspectTypeId]	 ,d.[Description],'O'  from 	 deleted d join inserted i on d.ProspectTypeId = i.ProspectTypeId 
insert into audit.[ProspectType](	 [ProspectTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[ProspectTypeId]	 ,i.[Description],'N'  from 	 deleted d join inserted i on d.ProspectTypeId = i.ProspectTypeId
GO
CREATE TRIGGER dbo.trgProspectType_I
ON dbo.[ProspectType] FOR insert 
AS 
insert into audit.[ProspectType](	 [ProspectTypeId]	 ,[Description]	 ,AuditOperation) select 	 i.[ProspectTypeId]	 ,i.[Description],'I' from inserted i
GO
CREATE TRIGGER dbo.trgProspectType_D
ON dbo.[ProspectType] FOR delete 
AS 
insert into audit.[ProspectType](	 [ProspectTypeId]	 ,[Description]	 ,AuditOperation) select 	 d.[ProspectTypeId]	 ,d.[Description],'D' from deleted d