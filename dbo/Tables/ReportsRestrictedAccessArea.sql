CREATE TABLE [dbo].[ReportsRestrictedAccessArea] (
    [ReportsId]              UNIQUEIDENTIFIER NOT NULL,
    [RestrictedAccessAreaId] BIGINT           NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ReportsRestrictedAccessArea] PRIMARY KEY CLUSTERED ([ReportsId] ASC, [RestrictedAccessAreaId] ASC),
    CONSTRAINT [FK_dbo.ReportsRestrictedAccessArea_dbo.Reports_ReportsId] FOREIGN KEY ([ReportsId]) REFERENCES [dbo].[Reports] ([ReportsId]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.ReportsRestrictedAccessArea_dbo.RestrictedAccessArea_RestrictedAccessAreaId] FOREIGN KEY ([RestrictedAccessAreaId]) REFERENCES [dbo].[RestrictedAccessArea] ([RestrictedAccessAreaId]) ON DELETE CASCADE
);

