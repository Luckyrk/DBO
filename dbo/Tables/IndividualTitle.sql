﻿CREATE TABLE [dbo].[IndividualTitle] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Code]               INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NULL,
    [Sex_Id]             UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.IndividualTitle] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.IndividualTitle_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.IndividualTitle_dbo.IndividualSex_Sex_Id] FOREIGN KEY ([Sex_Id]) REFERENCES [dbo].[IndividualSex] ([GUIDReference]),
    CONSTRAINT [FK_dbo.IndividualTitle_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[IndividualTitle]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Sex_Id]
    ON [dbo].[IndividualTitle]([Sex_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[IndividualTitle]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgIndividualTitle_U 
ON dbo.[IndividualTitle] FOR update 
AS 
insert into audit.[IndividualTitle](
insert into audit.[IndividualTitle](
GO
CREATE TRIGGER dbo.trgIndividualTitle_I
ON dbo.[IndividualTitle] FOR insert 
AS 
insert into audit.[IndividualTitle](
GO
CREATE TRIGGER dbo.trgIndividualTitle_D
ON dbo.[IndividualTitle] FOR delete 
AS 
insert into audit.[IndividualTitle](