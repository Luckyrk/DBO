﻿CREATE TABLE [dbo].[StateDefinition] (
    [Id]                                     UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]                                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]                     DATETIME         NULL,
    [CreationTimeStamp]                      DATETIME         NULL,
    [Code]                                   NVARCHAR (50)    NOT NULL,
    [StateBehaviorName]                      NVARCHAR (50)    NULL,
    [TrafficLightBehavior]                   NVARCHAR (50)    NULL,
    [InactiveBehavior]                       BIT              NOT NULL,
    [DisplayBehaviorFullyQualifiedTypeName]  NVARCHAR (250)   NULL,
    [ActivityBehaviorFullyQualifiedTypeName] NVARCHAR (250)   NULL,
    [Label_Id]                               UNIQUEIDENTIFIER NOT NULL,
    [StateModel_Id]                          UNIQUEIDENTIFIER NOT NULL,
    [StateDefinitionBehavior_Id]             UNIQUEIDENTIFIER NULL,
    [Country_Id]                             UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.StateDefinition] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.StateDefinition_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.StateDefinition_dbo.StateModel_StateModel_Id] FOREIGN KEY ([StateModel_Id]) REFERENCES [dbo].[StateModel] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.StateDefinition_dbo.TransitionBehavior_StateDefinitionBehavior_Id] FOREIGN KEY ([StateDefinitionBehavior_Id]) REFERENCES [dbo].[TransitionBehavior] ([GUIDReference]),
    CONSTRAINT [FK_dbo.StateDefinition_dbo.Translation_Label_Id] FOREIGN KEY ([Label_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueStateDefinitionTranslation] UNIQUE NONCLUSTERED ([Label_Id] ASC, [Country_Id] ASC, [StateModel_Id] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Label_Id]
    ON [dbo].[StateDefinition]([Label_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_StateModel_Id]
    ON [dbo].[StateDefinition]([StateModel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_StateDefinitionBehavior_Id]
    ON [dbo].[StateDefinition]([StateDefinitionBehavior_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[StateDefinition]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgStateDefinition_U 
ON dbo.[StateDefinition] FOR update 
AS 
insert into audit.[StateDefinition](
insert into audit.[StateDefinition](
GO
CREATE TRIGGER dbo.trgStateDefinition_I
ON dbo.[StateDefinition] FOR insert 
AS 
insert into audit.[StateDefinition](
GO
CREATE TRIGGER dbo.trgStateDefinition_D
ON dbo.[StateDefinition] FOR delete 
AS 
insert into audit.[StateDefinition](