CREATE TABLE [dbo].[JobStatus]
(
	[Name] VARCHAR(100) NOT NULL PRIMARY KEY,
	[LastRun] DATETIME,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL
)
