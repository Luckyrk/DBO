CREATE TABLE [dbo].[AddressDomain] (
    [CountryId] UNIQUEIDENTIFIER NOT NULL,
    [AddressId] UNIQUEIDENTIFIER NOT NULL,
    [Scheme_Id] INT              DEFAULT ((0)) NULL,
    [Panel_Id] UNIQUEIDENTIFIER NULL, 
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.AddressDomain] PRIMARY KEY CLUSTERED ([CountryId] ASC, [AddressId] ASC),
    CONSTRAINT [FK_dbo.AddressDomain_dbo.Address_AddressId] FOREIGN KEY ([AddressId]) REFERENCES [dbo].[Address] ([GUIDReference]),
    CONSTRAINT [FK_dbo.AddressDomain_dbo.Country_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country] ([CountryId])
);










GO
CREATE NONCLUSTERED INDEX [IX_CountryId]
    ON [dbo].[AddressDomain]([CountryId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AddressId]
    ON [dbo].[AddressDomain]([AddressId] ASC);


GO
CREATE TRIGGER dbo.trgAddressDomain_U 
ON dbo.[AddressDomain] FOR update 
AS 
insert into audit.[AddressDomain](	 [CountryId]	 ,[AddressId]	 ,AuditOperation) select 	 d.[CountryId]	 ,d.[AddressId],'O'  from 	 deleted d join inserted i on d.AddressId = i.AddressId	 and d.CountryId = i.CountryId 
insert into audit.[AddressDomain](	 [CountryId]	 ,[AddressId]	 ,AuditOperation) select 	 i.[CountryId]	 ,i.[AddressId],'N'  from 	 deleted d join inserted i on d.AddressId = i.AddressId	 and d.CountryId = i.CountryId
GO
CREATE TRIGGER dbo.trgAddressDomain_I
ON dbo.[AddressDomain] FOR insert 
AS 
insert into audit.[AddressDomain](	 [CountryId]	 ,[AddressId]	 ,AuditOperation) select 	 i.[CountryId]	 ,i.[AddressId],'I' from inserted i
GO
CREATE TRIGGER dbo.trgAddressDomain_D
ON dbo.[AddressDomain] FOR delete 
AS 
insert into audit.[AddressDomain](	 [CountryId]	 ,[AddressId]	 ,AuditOperation) select 	 d.[CountryId]	 ,d.[AddressId],'D' from deleted d