CREATE TABLE [dbo].[ProspectAttribute] (
    [CountryId]   UNIQUEIDENTIFIER NOT NULL,
    [AttributeId] UNIQUEIDENTIFIER NOT NULL,
    [ProspectId]  BIGINT           NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_ProspectAttribute] PRIMARY KEY CLUSTERED ([CountryId] ASC, [AttributeId] ASC, [ProspectId] ASC),
    CONSTRAINT [FK_ProspectAttribute_Attribute] FOREIGN KEY ([AttributeId]) REFERENCES [dbo].[Attribute] ([GUIDReference]),
    CONSTRAINT [FK_ProspectAttribute_ProspectParty] FOREIGN KEY ([ProspectId], [CountryId]) REFERENCES [dbo].[ProspectParty] ([ProspectId], [CountryId])
);






GO



GO



GO



GO
CREATE TRIGGER dbo.trgProspectAttribute_U 
ON dbo.[ProspectAttribute] FOR update 
AS 
insert into audit.[ProspectAttribute](	 [CountryId]	 ,[AttributeId]	 ,[ProspectId]	 ,AuditOperation) select 	 d.[CountryId]	 ,d.[AttributeId]	 ,d.[ProspectId],'O'  from 	 deleted d join inserted i on d.AttributeId = i.AttributeId	 and d.CountryId = i.CountryId	 and d.ProspectId = i.ProspectId 
insert into audit.[ProspectAttribute](	 [CountryId]	 ,[AttributeId]	 ,[ProspectId]	 ,AuditOperation) select 	 i.[CountryId]	 ,i.[AttributeId]	 ,i.[ProspectId],'N'  from 	 deleted d join inserted i on d.AttributeId = i.AttributeId	 and d.CountryId = i.CountryId	 and d.ProspectId = i.ProspectId
GO
CREATE TRIGGER dbo.trgProspectAttribute_I
ON dbo.[ProspectAttribute] FOR insert 
AS 
insert into audit.[ProspectAttribute](	 [CountryId]	 ,[AttributeId]	 ,[ProspectId]	 ,AuditOperation) select 	 i.[CountryId]	 ,i.[AttributeId]	 ,i.[ProspectId],'I' from inserted i
GO
CREATE TRIGGER dbo.trgProspectAttribute_D
ON dbo.[ProspectAttribute] FOR delete 
AS 
insert into audit.[ProspectAttribute](	 [CountryId]	 ,[AttributeId]	 ,[ProspectId]	 ,AuditOperation) select 	 d.[CountryId]	 ,d.[AttributeId]	 ,d.[ProspectId],'D' from deleted d