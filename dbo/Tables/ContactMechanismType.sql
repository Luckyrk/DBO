﻿CREATE TABLE [dbo].[ContactMechanismType] (
    [GUIDReference]             UNIQUEIDENTIFIER NOT NULL,
    [ContactMechanismCode]      INT              IDENTITY (1, 1) NOT NULL,
    [GPSUser]                   NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]        DATETIME         NULL,
    [CreationTimeStamp]         DATETIME         NULL,
    [TagTranslation_Id]         UNIQUEIDENTIFIER NOT NULL,
    [DescriptionTranslation_Id] UNIQUEIDENTIFIER NOT NULL,
    [TypeTranslation_Id]        UNIQUEIDENTIFIER NULL,
    [Country_Id]                UNIQUEIDENTIFIER NOT NULL,
    [Types]                     NVARCHAR (128)   NOT NULL,
    CONSTRAINT [PK_dbo.ContactMechanismType] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ContactMechanismType_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ContactMechanismType_dbo.Translation_DescriptionTranslation_Id] FOREIGN KEY ([DescriptionTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [FK_dbo.ContactMechanismType_dbo.Translation_TagTranslation_Id] FOREIGN KEY ([TagTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [FK_dbo.ContactMechanismType_dbo.Translation_TypeTranslation_Id] FOREIGN KEY ([TypeTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueContactMechanismTypeTranslation] UNIQUE NONCLUSTERED ([TagTranslation_Id] ASC, [Country_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_TagTranslation_Id]
    ON [dbo].[ContactMechanismType]([TagTranslation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DescriptionTranslation_Id]
    ON [dbo].[ContactMechanismType]([DescriptionTranslation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TypeTranslation_Id]
    ON [dbo].[ContactMechanismType]([TypeTranslation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ContactMechanismType]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgContactMechanismType_U 
ON dbo.[ContactMechanismType] FOR update 
AS 
insert into audit.[ContactMechanismType](
insert into audit.[ContactMechanismType](
GO
CREATE TRIGGER dbo.trgContactMechanismType_I
ON dbo.[ContactMechanismType] FOR insert 
AS 
insert into audit.[ContactMechanismType](
GO
CREATE TRIGGER dbo.trgContactMechanismType_D
ON dbo.[ContactMechanismType] FOR delete 
AS 
insert into audit.[ContactMechanismType](