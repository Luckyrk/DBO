CREATE TABLE [dbo].[SocialGradingAttribute]
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
insert into audit.[SocialGradingAttribute](	 [Country_Id]	 ,[AttributeKey]	 ,[AuditOperation]) select 	 d.[Country_Id]	 ,d.[AttributeKey],'O'  from 	 deleted d join inserted i on d.Country_Id = i.Country_Id 
insert into audit.[SocialGradingAttribute](	 [Country_Id]	 ,[AttributeKey]	 ,AuditOperation) select 	 i.[Country_Id]	 ,i.[AttributeKey],'N'  from 	 deleted d join inserted i on d.Country_Id = i.Country_Id
GO

CREATE TRIGGER dbo.trgSocialGradingAttribute_I
ON dbo.[SocialGradingAttribute] FOR insert 
AS 
insert into audit.[SocialGradingAttribute](	 [Country_Id]	 ,[AttributeKey]	 ,AuditOperation) select 	 i.[Country_Id]	 ,i.[AttributeKey],'I' from inserted i
GO

CREATE TRIGGER dbo.trgSocialGradingAttribute_D
ON dbo.[SocialGradingAttribute] FOR delete 
AS 
insert into audit.[SocialGradingAttribute](	 [Country_Id]	 ,[AttributeKey]	 ,AuditOperation) select 	 d.[Country_Id]	 ,d.[AttributeKey],'D' from deleted d