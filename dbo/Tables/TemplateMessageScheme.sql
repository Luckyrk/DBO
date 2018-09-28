﻿CREATE TABLE [dbo].[TemplateMessageScheme] (
    [TemplateMessageSchemeId] INT              IDENTITY (1, 1) NOT NULL,
    [Description]             NVARCHAR (100)   NULL,
    [CountryId]               UNIQUEIDENTIFIER NULL,
	[Email]					  NVARCHAR (100)   NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.TemplateMessageScheme] PRIMARY KEY CLUSTERED ([TemplateMessageSchemeId] ASC)
);










GO
CREATE TRIGGER dbo.trgTemplateMessageScheme_U 
ON dbo.[TemplateMessageScheme] FOR update 
AS 
insert into audit.[TemplateMessageScheme](
insert into audit.[TemplateMessageScheme](
GO
CREATE TRIGGER dbo.trgTemplateMessageScheme_I
ON dbo.[TemplateMessageScheme] FOR insert 
AS 
insert into audit.[TemplateMessageScheme](
GO
CREATE TRIGGER dbo.trgTemplateMessageScheme_D
ON dbo.[TemplateMessageScheme] FOR delete 
AS 
insert into audit.[TemplateMessageScheme](