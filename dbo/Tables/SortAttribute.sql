﻿CREATE TABLE [dbo].[SortAttribute] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Order]              INT              NOT NULL,
    [Compulsory]         BIT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Demographic_Id]     UNIQUEIDENTIFIER NULL,
    [PageSection_Id]     UNIQUEIDENTIFIER NOT NULL,
    [BelongingType_Id] UNIQUEIDENTIFIER NULL, 
    [FieldConfiguration_Id] BIGINT NULL, 
    [Type] NVARCHAR(128) NULL, 
	[UseShortCode]       BIT              NULL DEFAULT(0),
    CONSTRAINT [PK_dbo.SortAttribute] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.SortAttribute_dbo.Attribute_Demographic_Id] FOREIGN KEY ([Demographic_Id]) REFERENCES [dbo].[Attribute] ([GUIDReference]),
	CONSTRAINT [FK_dbo.SortAttribute_dbo.BelongingType_Id] FOREIGN KEY ([BelongingType_Id]) REFERENCES [dbo].[BelongingType] ([Id]),
    CONSTRAINT [FK_dbo.SortAttribute_dbo.PageSection_PageSection_Id] FOREIGN KEY ([PageSection_Id]) REFERENCES [dbo].[PageSection] ([Id]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_Demographic_Id]
    ON [dbo].[SortAttribute]([Demographic_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_PageSection_Id]
    ON [dbo].[SortAttribute]([PageSection_Id] ASC);


GO
CREATE TRIGGER dbo.trgSortAttribute_U 
ON dbo.[SortAttribute] FOR update 
AS 
insert into audit.[SortAttribute](
insert into audit.[SortAttribute](
GO
CREATE TRIGGER dbo.trgSortAttribute_I
ON dbo.[SortAttribute] FOR insert 
AS 
insert into audit.[SortAttribute](
GO
CREATE TRIGGER dbo.trgSortAttribute_D
ON dbo.[SortAttribute] FOR delete 
AS 
insert into audit.[SortAttribute](