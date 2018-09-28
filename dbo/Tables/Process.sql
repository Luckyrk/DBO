CREATE TABLE [dbo].[Process](
	[instance_id] [int] NULL,
	[ProcessGUID] [uniqueidentifier] NOT NULL,
	[ProcessStatus] [nvarchar](2000) NOT NULL,
	[StatusDescrip] [nvarchar](max) NOT NULL,
	[CountryISO2A] [nvarchar](40) NOT NULL,
	[ProcessType] [nvarchar](200) NOT NULL,
	[ProcessName] [nvarchar](3000) NOT NULL,
	[DatabaseName] [nvarchar](200) NOT NULL,
	[SYSTEM_USER] [nvarchar](200) NOT NULL,
	[HOST_NAME] [nvarchar](200) NULL,
	[StartDateTime] [datetime] NOT NULL,
	[StopDateTime] [datetime] NULL,
	[ExecTime_Mins_Complete] [float](53) NULL,
	[ParentId] [uniqueidentifier] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO

