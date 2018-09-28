CREATE TABLE [dbo].[ProspectParty] (
    [ProspectId]     BIGINT           IDENTITY (1, 1) NOT NULL,
    [CountryId]      UNIQUEIDENTIFIER NOT NULL,
    [ProspectTypeId] BIGINT           NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ProspectParty] PRIMARY KEY CLUSTERED ([ProspectId] ASC, [CountryId] ASC),
    CONSTRAINT [FK_dbo.ProspectParty_dbo.Country_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ProspectParty_dbo.ProspectType_ProspectTypeId] FOREIGN KEY ([ProspectTypeId]) REFERENCES [dbo].[ProspectType] ([ProspectTypeId])
);




GO
CREATE NONCLUSTERED INDEX [IX_ProspectTypeId]
    ON [dbo].[ProspectParty]([ProspectTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CountryId]
    ON [dbo].[ProspectParty]([CountryId] ASC);


GO
CREATE TRIGGER dbo.trgProspectParty_U 
ON dbo.[ProspectParty] FOR update 
AS 
insert into audit.[ProspectParty](	 [ProspectId]	 ,[CountryId]	 ,[ProspectTypeId]	 ,AuditOperation) select 	 d.[ProspectId]	 ,d.[CountryId]	 ,d.[ProspectTypeId],'O'  from 	 deleted d join inserted i on d.CountryId = i.CountryId	 and d.ProspectId = i.ProspectId 
insert into audit.[ProspectParty](	 [ProspectId]	 ,[CountryId]	 ,[ProspectTypeId]	 ,AuditOperation) select 	 i.[ProspectId]	 ,i.[CountryId]	 ,i.[ProspectTypeId],'N'  from 	 deleted d join inserted i on d.CountryId = i.CountryId	 and d.ProspectId = i.ProspectId
GO
CREATE TRIGGER dbo.trgProspectParty_I
ON dbo.[ProspectParty] FOR insert 
AS 
insert into audit.[ProspectParty](	 [ProspectId]	 ,[CountryId]	 ,[ProspectTypeId]	 ,AuditOperation) select 	 i.[ProspectId]	 ,i.[CountryId]	 ,i.[ProspectTypeId],'I' from inserted i
GO
CREATE TRIGGER dbo.trgProspectParty_D
ON dbo.[ProspectParty] FOR delete 
AS 
insert into audit.[ProspectParty](	 [ProspectId]	 ,[CountryId]	 ,[ProspectTypeId]	 ,AuditOperation) select 	 d.[ProspectId]	 ,d.[CountryId]	 ,d.[ProspectTypeId],'D' from deleted d