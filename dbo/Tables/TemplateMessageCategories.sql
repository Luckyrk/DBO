CREATE TABLE [dbo].[TemplateMessageCategories] (
    [TemplateMessageCategoryId] BIGINT           IDENTITY (1, 1) NOT NULL,
    [Description]               NVARCHAR (500)   NULL,
    [CountryId]                 UNIQUEIDENTIFIER NULL,
    [CommsMessageTemplateType_Id] INT NULL, 
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([TemplateMessageCategoryId] ASC)
);

