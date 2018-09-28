﻿CREATE TABLE [dbo].[IndividualComment] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Comment]            NVARCHAR (200)   NULL,
    [GPSUser]            NVARCHAR (100)   NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Individual_Id]      UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.IndividualComment] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.IndividualComment_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.IndividualComment_dbo.Individual_Individual_Id] FOREIGN KEY ([Individual_Id]) REFERENCES [dbo].[Individual] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[IndividualComment]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Individual_Id]
    ON [dbo].[IndividualComment]([Individual_Id] ASC);


GO
CREATE TRIGGER dbo.trgIndividualComment_U 
ON dbo.[IndividualComment] FOR update 
AS 
insert into audit.[IndividualComment](
insert into audit.[IndividualComment](
GO
CREATE TRIGGER dbo.trgIndividualComment_I
ON dbo.[IndividualComment] FOR insert 
AS 
insert into audit.[IndividualComment](
GO
CREATE TRIGGER dbo.trgIndividualComment_D
ON dbo.[IndividualComment] FOR delete 
AS 
insert into audit.[IndividualComment](