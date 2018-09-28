﻿CREATE TABLE [dbo].[BelongingTypeConfiguration] (
    [BelongingTypeConfigurationId] UNIQUEIDENTIFIER NOT NULL,
    [Order]                        INT              NOT NULL,
    [BelongingTypeId]              UNIQUEIDENTIFIER NOT NULL,
    [ConfigurationSetId]           UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.BelongingTypeConfiguration] PRIMARY KEY CLUSTERED ([BelongingTypeConfigurationId] ASC),
    CONSTRAINT [FK_dbo.BelongingTypeConfiguration_dbo.BelongingType_BelongingTypeId] FOREIGN KEY ([BelongingTypeId]) REFERENCES [dbo].[BelongingType] ([Id]),
    CONSTRAINT [FK_dbo.BelongingTypeConfiguration_dbo.ConfigurationSet_ConfigurationSetId] FOREIGN KEY ([ConfigurationSetId]) REFERENCES [dbo].[ConfigurationSet] ([ConfigurationSetId])
);






GO
CREATE NONCLUSTERED INDEX [IX_BelongingTypeId]
    ON [dbo].[BelongingTypeConfiguration]([BelongingTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ConfigurationSetId]
    ON [dbo].[BelongingTypeConfiguration]([ConfigurationSetId] ASC);


GO
CREATE TRIGGER dbo.trgBelongingTypeConfiguration_U 
ON dbo.[BelongingTypeConfiguration] FOR update 
AS 
insert into audit.[BelongingTypeConfiguration](
insert into audit.[BelongingTypeConfiguration](
GO
CREATE TRIGGER dbo.trgBelongingTypeConfiguration_I
ON dbo.[BelongingTypeConfiguration] FOR insert 
AS 
insert into audit.[BelongingTypeConfiguration](
GO
CREATE TRIGGER dbo.trgBelongingTypeConfiguration_D
ON dbo.[BelongingTypeConfiguration] FOR delete 
AS 
insert into audit.[BelongingTypeConfiguration](