﻿CREATE TABLE [dbo].[ProspectAttribute] (
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
insert into audit.[ProspectAttribute](
insert into audit.[ProspectAttribute](
GO
CREATE TRIGGER dbo.trgProspectAttribute_I
ON dbo.[ProspectAttribute] FOR insert 
AS 
insert into audit.[ProspectAttribute](
GO
CREATE TRIGGER dbo.trgProspectAttribute_D
ON dbo.[ProspectAttribute] FOR delete 
AS 
insert into audit.[ProspectAttribute](