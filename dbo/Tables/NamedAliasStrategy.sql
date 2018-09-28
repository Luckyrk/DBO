﻿CREATE TABLE [dbo].[NamedAliasStrategy] (
    [NamedAliasStrategyId] UNIQUEIDENTIFIER NOT NULL,
    [Max]                  INT              NOT NULL,
    [Min]                  INT              NOT NULL,
    [GPSUser]              NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]   DATETIME         NULL,
    [CreationTimeStamp]    DATETIME         NULL,
    [Prefix]               NVARCHAR (20)    NULL,
    [Postfix]              NVARCHAR (20)    NULL,
    [Next]                 INT              NULL,
    [Nullable]             BIT              NULL,
    [TypeTranslation_Id]   UNIQUEIDENTIFIER NULL,
    [Type]                 NVARCHAR (100)   NOT NULL,
    CONSTRAINT [PK_dbo.NamedAliasStrategy] PRIMARY KEY CLUSTERED ([NamedAliasStrategyId] ASC),
    CONSTRAINT [FK_dbo.NamedAliasStrategy_dbo.Translation_TypeTranslation_Id] FOREIGN KEY ([TypeTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_TypeTranslation_Id]
    ON [dbo].[NamedAliasStrategy]([TypeTranslation_Id] ASC);


GO
CREATE TRIGGER dbo.trgNamedAliasStrategy_U 
ON dbo.[NamedAliasStrategy] FOR update 
AS 
insert into audit.[NamedAliasStrategy](
insert into audit.[NamedAliasStrategy](
GO
CREATE TRIGGER dbo.trgNamedAliasStrategy_I
ON dbo.[NamedAliasStrategy] FOR insert 
AS 
insert into audit.[NamedAliasStrategy](
GO
CREATE TRIGGER dbo.trgNamedAliasStrategy_D
ON dbo.[NamedAliasStrategy] FOR delete 
AS 
insert into audit.[NamedAliasStrategy](