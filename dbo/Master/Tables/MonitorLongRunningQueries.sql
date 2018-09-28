


CREATE TABLE [dbo].[MonitorLongRunningQueries](
    [id] [int] IDENTITY(1,1) NOT NULL,
	[Query] [nvarchar](100)  NULL,
	[StartTime] [datetime] NULL,
	[DB_Id] int NULL,
	[TimeElapsed] int NULL,
	[Status] [varchar](1000) NULL,
	[DB_Name] [varchar](1000) NULL,
	[Login_Name] [varchar](1000) NULL,
	[host_name] [varchar](100) NULL,
	[program_name] [varchar](max) null,
	[CurrentTimeStamp] [datetime] NULL,
	[Session_Id] int NULL,
	[History] [varchar](100) NuLL
 CONSTRAINT [pk_MonitorLongRunningQueries] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO


