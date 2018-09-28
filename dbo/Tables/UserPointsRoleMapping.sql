CREATE TABLE [dbo].[UserPointsRoleMapping] (
    [Id]               UNIQUEIDENTIFIER NOT NULL,
    [SystemRoleTypeId] BIGINT           NOT NULL,
    [Points]           INT              NOT NULL,
    [CountryId]        UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [fk_CountryId] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [fk_UserPointsRoleMapping] FOREIGN KEY ([SystemRoleTypeId]) REFERENCES [dbo].[SystemRoleType] ([SystemRoleTypeId])
);



