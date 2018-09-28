﻿CREATE TABLE [dbo].[SocialGradingAttribute]
(
	[Country_Id]		UNIQUEIDENTIFIER NOT NULL, 
    [AttributeKey]		NVARCHAR(200) NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.SocialGradingAttribute] PRIMARY KEY CLUSTERED ([Country_Id] ASC, [AttributeKey] ASC),
    CONSTRAINT [FK_dbo.SocialGradingAttribute_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]) ON DELETE CASCADE
);

GO
CREATE TRIGGER dbo.trgSocialGradingAttribute_U 
ON dbo.[SocialGradingAttribute] FOR update 
AS 
insert into audit.[SocialGradingAttribute](
insert into audit.[SocialGradingAttribute](
GO

CREATE TRIGGER dbo.trgSocialGradingAttribute_I
ON dbo.[SocialGradingAttribute] FOR insert 
AS 
insert into audit.[SocialGradingAttribute](
GO

CREATE TRIGGER dbo.trgSocialGradingAttribute_D
ON dbo.[SocialGradingAttribute] FOR delete 
AS 
insert into audit.[SocialGradingAttribute](