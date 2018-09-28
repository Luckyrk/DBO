﻿CREATE TABLE [dbo].[AddressType] (
    [Id]                UNIQUEIDENTIFIER NOT NULL,
    [IsDefault]         BIT              NOT NULL,
    [Description_Id]    UNIQUEIDENTIFIER NOT NULL,
    [DiscriminatorType] NVARCHAR (128)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.AddressType] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.AddressType_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[AddressType]([Description_Id] ASC);


GO
CREATE TRIGGER dbo.trgAddressType_U 
ON dbo.[AddressType] FOR update 
AS 
insert into audit.[AddressType](
insert into audit.[AddressType](
GO
CREATE TRIGGER dbo.trgAddressType_I
ON dbo.[AddressType] FOR insert 
AS 
insert into audit.[AddressType](
GO
CREATE TRIGGER dbo.trgAddressType_D
ON dbo.[AddressType] FOR delete 
AS 
insert into audit.[AddressType](