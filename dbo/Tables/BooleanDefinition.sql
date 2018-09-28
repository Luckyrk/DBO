﻿CREATE TABLE [dbo].[BooleanDefinition] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Value]              BIT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.BooleanDefinition] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.BooleanDefinition_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[BooleanDefinition]([Translation_Id] ASC);


GO
CREATE TRIGGER dbo.trgBooleanDefinition_U 
ON dbo.[BooleanDefinition] FOR update 
AS 
insert into audit.[BooleanDefinition](
insert into audit.[BooleanDefinition](
GO
CREATE TRIGGER dbo.trgBooleanDefinition_I
ON dbo.[BooleanDefinition] FOR insert 
AS 
insert into audit.[BooleanDefinition](
GO
CREATE TRIGGER dbo.trgBooleanDefinition_D
ON dbo.[BooleanDefinition] FOR delete 
AS 
insert into audit.[BooleanDefinition](