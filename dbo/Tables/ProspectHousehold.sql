CREATE TABLE [dbo].[ProspectHousehold] (
    [CountryId]                UNIQUEIDENTIFIER NOT NULL,
    [ProspectPartyId]          BIGINT           NOT NULL,
    [ProspectParty_ProspectId] BIGINT           NULL,
    [ProspectParty_CountryId]  UNIQUEIDENTIFIER NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ProspectHousehold] PRIMARY KEY CLUSTERED ([CountryId] ASC, [ProspectPartyId] ASC),
    CONSTRAINT [FK_dbo.ProspectHousehold_dbo.Country_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ProspectHousehold_dbo.ProspectParty_ProspectParty_ProspectId_ProspectParty_CountryId] FOREIGN KEY ([ProspectParty_ProspectId], [ProspectParty_CountryId]) REFERENCES [dbo].[ProspectParty] ([ProspectId], [CountryId])
);




GO
CREATE NONCLUSTERED INDEX [IX_ProspectParty_ProspectId_ProspectParty_CountryId]
    ON [dbo].[ProspectHousehold]([ProspectParty_ProspectId] ASC, [ProspectParty_CountryId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CountryId]
    ON [dbo].[ProspectHousehold]([CountryId] ASC);


GO
CREATE TRIGGER dbo.trgProspectHousehold_U 
ON dbo.[ProspectHousehold] FOR update 
AS 
insert into audit.[ProspectHousehold](	 [CountryId]	 ,[ProspectPartyId]	 ,[ProspectParty_ProspectId]	 ,[ProspectParty_CountryId]	 ,AuditOperation) select 	 d.[CountryId]	 ,d.[ProspectPartyId]	 ,d.[ProspectParty_ProspectId]	 ,d.[ProspectParty_CountryId],'O'  from 	 deleted d join inserted i on d.CountryId = i.CountryId	 and d.ProspectPartyId = i.ProspectPartyId 
insert into audit.[ProspectHousehold](	 [CountryId]	 ,[ProspectPartyId]	 ,[ProspectParty_ProspectId]	 ,[ProspectParty_CountryId]	 ,AuditOperation) select 	 i.[CountryId]	 ,i.[ProspectPartyId]	 ,i.[ProspectParty_ProspectId]	 ,i.[ProspectParty_CountryId],'N'  from 	 deleted d join inserted i on d.CountryId = i.CountryId	 and d.ProspectPartyId = i.ProspectPartyId
GO
CREATE TRIGGER dbo.trgProspectHousehold_I
ON dbo.[ProspectHousehold] FOR insert 
AS 
insert into audit.[ProspectHousehold](	 [CountryId]	 ,[ProspectPartyId]	 ,[ProspectParty_ProspectId]	 ,[ProspectParty_CountryId]	 ,AuditOperation) select 	 i.[CountryId]	 ,i.[ProspectPartyId]	 ,i.[ProspectParty_ProspectId]	 ,i.[ProspectParty_CountryId],'I' from inserted i
GO
CREATE TRIGGER dbo.trgProspectHousehold_D
ON dbo.[ProspectHousehold] FOR delete 
AS 
insert into audit.[ProspectHousehold](	 [CountryId]	 ,[ProspectPartyId]	 ,[ProspectParty_ProspectId]	 ,[ProspectParty_CountryId]	 ,AuditOperation) select 	 d.[CountryId]	 ,d.[ProspectPartyId]	 ,d.[ProspectParty_ProspectId]	 ,d.[ProspectParty_CountryId],'D' from deleted d