﻿CREATE TABLE [dbo].[ProspectAddress] (
    [CountryId]  UNIQUEIDENTIFIER NOT NULL,
    [AddressId]  UNIQUEIDENTIFIER NOT NULL,
    [ProspectId] BIGINT           NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_Table] PRIMARY KEY CLUSTERED ([CountryId] ASC, [AddressId] ASC, [ProspectId] ASC),
    CONSTRAINT [FK_ProspectAddress_Address] FOREIGN KEY ([AddressId]) REFERENCES [dbo].[Address] ([GUIDReference]),
    CONSTRAINT [FK_ProspectAddress_ProspectParty] FOREIGN KEY ([ProspectId], [CountryId]) REFERENCES [dbo].[ProspectParty] ([ProspectId], [CountryId])
);






GO



GO



GO



GO
CREATE TRIGGER dbo.trgProspectAddress_U 
ON dbo.[ProspectAddress] FOR update 
AS 
insert into audit.[ProspectAddress](
insert into audit.[ProspectAddress](
GO
CREATE TRIGGER dbo.trgProspectAddress_I
ON dbo.[ProspectAddress] FOR insert 
AS 
insert into audit.[ProspectAddress](
GO
CREATE TRIGGER dbo.trgProspectAddress_D
ON dbo.[ProspectAddress] FOR delete 
AS 
insert into audit.[ProspectAddress](