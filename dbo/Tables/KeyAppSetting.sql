CREATE TABLE [dbo].[KeyAppSetting]
(
    [GUIDReference]             UNIQUEIDENTIFIER NOT NULL,
    [KeyName]                   NVARCHAR (50)    NOT NULL,
    [Comment]                   NVARCHAR (500)   NULL,
    [DefaultValue]              NVARCHAR (160)   NOT NULL,
    [GPSUser]                   NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]        DATETIME         NULL,
    [CreationTimeStamp]         DATETIME         NULL,
    CONSTRAINT [PK_dbo.KeyAppSetting] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [UniqueKeyAppSettingKeyName] UNIQUE NONCLUSTERED ([KeyName] ASC)
)
