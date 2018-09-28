﻿CREATE TABLE [dbo].[ProspectIndividual] (
    [CountryId]   UNIQUEIDENTIFIER NOT NULL,
    [ProspectId]  BIGINT           NOT NULL,
    [Title]       NVARCHAR (100)   NULL,
    [Name]        NVARCHAR (200)   NULL,
    [DateOfBirth] DATETIME         NULL,
    [Gender]      NVARCHAR (50)    NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_ProspectIndividual] PRIMARY KEY CLUSTERED ([CountryId] ASC, [ProspectId] ASC),
    CONSTRAINT [FK_ProspectIndividual_ProspectParty] FOREIGN KEY ([ProspectId], [CountryId]) REFERENCES [dbo].[ProspectParty] ([ProspectId], [CountryId])
);






GO



GO



GO
CREATE TRIGGER dbo.trgProspectIndividual_U 
ON dbo.[ProspectIndividual] FOR update 
AS 
insert into audit.[ProspectIndividual](
insert into audit.[ProspectIndividual](
GO
CREATE TRIGGER dbo.trgProspectIndividual_I
ON dbo.[ProspectIndividual] FOR insert 
AS 
insert into audit.[ProspectIndividual](
GO
CREATE TRIGGER dbo.trgProspectIndividual_D
ON dbo.[ProspectIndividual] FOR delete 
AS 
insert into audit.[ProspectIndividual](