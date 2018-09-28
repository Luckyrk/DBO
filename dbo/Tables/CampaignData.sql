CREATE TABLE [dbo].[CampaignData] (
    [ReferenceId]            INT           IDENTITY (1, 1) NOT NULL,
    [PhoneNumber]            NVARCHAR (50) NULL,
    [MessageReferenceNumber] NVARCHAR (50) NULL,
    [Status]                 NVARCHAR (50) NULL,
    [BusinessId]             NVARCHAR (50) NULL,
    [GPSUser]                NVARCHAR (50) NULL,
    [GPSUpdateTimestamp]     DATETIME      NULL,
    [CreationTimeStamp]      DATETIME      NULL,
    CONSTRAINT [PK_dbo.CampaignData] PRIMARY KEY CLUSTERED ([ReferenceId] ASC) WITH (FILLFACTOR = 90)
);



