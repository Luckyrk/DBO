CREATE TABLE [dbo].[SmsConfiguration] (
    [GUIDReference]       UNIQUEIDENTIFIER NOT NULL,
    [QueryParameterName]  NVARCHAR (MAX)   NOT NULL,
    [QueryParameterValue] NVARCHAR (MAX)   NOT NULL,
    [QueryParameterOrder] INT              NOT NULL,
    [Country_Id]          UNIQUEIDENTIFIER NOT NULL,
    [Type]                NVARCHAR (MAX)   NOT NULL,
    [EncodeType]          NVARCHAR (MAX)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [FK_dbo.SmsConfiguration_dbo.Country_CountryId] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);

