CREATE TABLE [dbo].[Critxl] (
    [Id]           INT              IDENTITY (1, 1) NOT NULL,
    [Year]         INT              NOT NULL,
    [Period]       INT              NOT NULL,
    [AttributeKey] NVARCHAR (200)   NOT NULL,
    [Country_Id]   UNIQUEIDENTIFIER NOT NULL,
    [Locked]       BIT              DEFAULT ((0)) NOT NULL,
    [Status]       NVARCHAR (20)    NULL,
    [UseShortCode] BIT              DEFAULT ((0)) NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.Critxl] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.Critxl_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
	CONSTRAINT UC_CountryPeriodAttribute UNIQUE ([Year], [Period], [AttributeKey], [Country_Id])
);