CREATE TABLE [dbo].[tbTimeZoneInfo] (
	--[TimeZoneID] [int] IDENTITY (1, 1) NOT NULL ,
	[CountryISO2A] char(2),
	[Display] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL ,
	[Bias] [smallint] NOT NULL ,
	[StdBias] [smallint] NOT NULL ,
	[DltBias] [smallint] NOT NULL ,
	[StdMonth] [smallint] NOT NULL ,
	[StdDayOfWeek] [smallint] NOT NULL ,
	[StdWeek] [smallint] NOT NULL ,
	[StdHour] [smallint] NOT NULL ,
	[DltMonth] [smallint] NOT NULL ,
	[DltDayOfWeek] [smallint] NOT NULL ,
	[DltWeek] [smallint] NOT NULL ,
	[DltHour] [smallint] NOT NULL,
	CountryId UniqueIdentifier
) ON [PRIMARY]
GO