﻿CREATE TABLE [dbo].[IndividualSex] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Code]               INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.IndividualSex] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.IndividualSex_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.IndividualSex_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[IndividualSex]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[IndividualSex]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgIndividualSex_U 
ON dbo.[IndividualSex] FOR update 
AS 
insert into audit.[IndividualSex](
insert into audit.[IndividualSex](
GO
CREATE TRIGGER dbo.trgIndividualSex_I
ON dbo.[IndividualSex] FOR insert 
AS 
insert into audit.[IndividualSex](
GO
CREATE TRIGGER dbo.trgIndividualSex_D
ON dbo.[IndividualSex] FOR delete 
AS 
insert into audit.[IndividualSex](