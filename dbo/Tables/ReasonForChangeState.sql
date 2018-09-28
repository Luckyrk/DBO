﻿CREATE TABLE [dbo].[ReasonForChangeState] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [BussinesInFuture]   BIT              NOT NULL,
    [Code]               INT              NOT NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [Description_Id]     UNIQUEIDENTIFIER NOT NULL,
    [StateModel_Id]      UNIQUEIDENTIFIER NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.ReasonForChangeState] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.ReasonForChangeState_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.ReasonForChangeState_dbo.StateModel_StateModel_Id] FOREIGN KEY ([StateModel_Id]) REFERENCES [dbo].[StateModel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ReasonForChangeState_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[ReasonForChangeState]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_StateModel_Id]
    ON [dbo].[ReasonForChangeState]([StateModel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[ReasonForChangeState]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgReasonForChangeState_U 
ON dbo.[ReasonForChangeState] FOR update 
AS 
insert into audit.[ReasonForChangeState](
insert into audit.[ReasonForChangeState](
GO
CREATE TRIGGER dbo.trgReasonForChangeState_I
ON dbo.[ReasonForChangeState] FOR insert 
AS 
insert into audit.[ReasonForChangeState](
GO
CREATE TRIGGER dbo.trgReasonForChangeState_D
ON dbo.[ReasonForChangeState] FOR delete 
AS 
insert into audit.[ReasonForChangeState](