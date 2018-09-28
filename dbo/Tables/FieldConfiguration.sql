﻿CREATE TABLE [dbo].[FieldConfiguration](
	[Id] BIGINT NOT NULL IDENTITY,
	[CountryConfiguration_Id] [uniqueidentifier] NOT NULL,
	[Key] [varchar](100) NOT NULL,
	[Required] [bit] NOT NULL,
	[Visible] [bit] NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
	CONSTRAINT [PK_FieldConfiguration] PRIMARY KEY CLUSTERED([Id]),
	CONSTRAINT [FK_dbo.FieldConfiguration_dbo.CountryConfiguration_CountryConfiguration_Id] FOREIGN KEY ([CountryConfiguration_Id]) REFERENCES [dbo].[CountryConfiguration] ([Id])
 ) ON [PRIMARY]

GO

CREATE TRIGGER dbo.trgFieldConfiguration_D
ON dbo.[FieldConfiguration] FOR delete 
AS 
insert into audit.[FieldConfiguration](
GO

CREATE TRIGGER dbo.trgFieldConfiguration_I
ON dbo.[FieldConfiguration] FOR insert 
AS 
insert into audit.[FieldConfiguration](
GO

CREATE TRIGGER dbo.trgFieldConfiguration_U 
ON dbo.[FieldConfiguration] FOR update 
AS 
insert into audit.[FieldConfiguration](
insert into audit.[FieldConfiguration](
GO

--ALTER TABLE [dbo].[FieldConfiguration]  ADD  CONSTRAINT [FK_FieldConfiguration_CountryConfiguration] FOREIGN KEY([CountryConfiguration_Id])
--REFERENCES [dbo].[CountryConfiguration] ([Id])
--GO

--ALTER TABLE [dbo].[FieldConfiguration] CHECK CONSTRAINT [FK_FieldConfiguration_CountryConfiguration]
--GO
