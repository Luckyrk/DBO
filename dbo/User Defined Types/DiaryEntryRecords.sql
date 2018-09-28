CREATE TYPE [dbo].[DiaryEntryRecords] AS TABLE(
	[Id] [uniqueidentifier] NOT NULL,
	[PanelId] [uniqueidentifier] NOT NULL,
	[PanelName] [nvarchar](150) NULL,
	[DiaryDateYear] [int] NOT NULL,
	[DiaryDatePeriod] [int] NOT NULL,
	[DiaryDateWeek] [int] NOT NULL,
	[NumberOfDaysLate] [int] NOT NULL,
	[NumberOfDaysEarly] [int] NOT NULL,
	[ReceivedDate] [varchar](50) NOT NULL,
	[Points] [int] NOT NULL,
	[CumulativePoints] [int] NOT NULL,
	[PointId] [uniqueidentifier] NOT NULL,
	[DiarySource] [nvarchar](150) NULL,
	[DiaryState] [nvarchar](150) NULL,
	[BusinessId] [nvarchar](50) NULL,
	[Together] [int] NOT NULL,
	[IncentiveCode] [int] NOT NULL,
	[ClaimFlag] [int] NOT NULL,
	[TransactionInfoId] [uniqueidentifier] NOT NULL,
	[IndividualId] [uniqueidentifier] NOT NULL,
	[Balance] [int] NOT NULL
)
GO