﻿CREATE TABLE [dbo].[TemplateUsageIntent] (
    [TemplateUsageIntentId] INT            IDENTITY (1, 1) NOT NULL,
    [Description]           NVARCHAR (100) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.TemplateUsageIntent] PRIMARY KEY CLUSTERED ([TemplateUsageIntentId] ASC)
);








GO
CREATE TRIGGER dbo.trgTemplateUsageIntent_U 
ON dbo.[TemplateUsageIntent] FOR update 
AS 
insert into audit.[TemplateUsageIntent](
insert into audit.[TemplateUsageIntent](
GO
CREATE TRIGGER dbo.trgTemplateUsageIntent_I
ON dbo.[TemplateUsageIntent] FOR insert 
AS 
insert into audit.[TemplateUsageIntent](
GO
CREATE TRIGGER dbo.trgTemplateUsageIntent_D
ON dbo.[TemplateUsageIntent] FOR delete 
AS 
insert into audit.[TemplateUsageIntent](