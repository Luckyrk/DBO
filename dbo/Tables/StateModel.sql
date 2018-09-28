﻿CREATE TABLE [dbo].[StateModel] (
    [GUIDReference]             UNIQUEIDENTIFIER NOT NULL,
    [Type]                      NVARCHAR (100)   NOT NULL,
    [GPSUser]                   NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]        DATETIME         NULL,
    [CreationTimeStamp]         DATETIME         NULL,
    [IsAutomaticTransitionable] BIT              NOT NULL,
    [Name_Id]                   UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]                UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.StateModel] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StateModel_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.StateModel_dbo.Translation_Name_Id] FOREIGN KEY ([Name_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueStateModelTranslation] UNIQUE NONCLUSTERED ([Name_Id] ASC, [Country_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Name_Id]
    ON [dbo].[StateModel]([Name_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[StateModel]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgStateModel_U 
ON dbo.[StateModel] FOR update 
AS 
insert into audit.[StateModel](
insert into audit.[StateModel](
GO
CREATE TRIGGER dbo.trgStateModel_I
ON dbo.[StateModel] FOR insert 
AS 
insert into audit.[StateModel](
GO
CREATE TRIGGER dbo.trgStateModel_D
ON dbo.[StateModel] FOR delete 
AS 
insert into audit.[StateModel](