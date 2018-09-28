﻿CREATE TABLE [dbo].[Respondent] (
    [GUIDReference]     UNIQUEIDENTIFIER NOT NULL,
    [DiscriminatorType] NVARCHAR (50)    NULL,
    [CountryID]         UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.Respondent] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Respondent_dbo.Country_CountryID] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_CountryID]
    ON [dbo].[Respondent]([CountryID] ASC);


GO
CREATE TRIGGER dbo.trgRespondent_U 
ON dbo.[Respondent] FOR update 
AS 
insert into audit.[Respondent](
insert into audit.[Respondent](
GO
CREATE TRIGGER dbo.trgRespondent_I
ON dbo.[Respondent] FOR insert 
AS 
insert into audit.[Respondent](
GO
CREATE TRIGGER dbo.trgRespondent_D
ON dbo.[Respondent] FOR delete 
AS 
insert into audit.[Respondent](