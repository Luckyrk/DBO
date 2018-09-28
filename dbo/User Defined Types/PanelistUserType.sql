CREATE TYPE [dbo].[PanelistUserType] AS TABLE(
	[Rownumber] [int] NULL,
	[IndividualBusinessId] [nvarchar](max) NOT NULL,
	[PanelCode] [nvarchar](max) NOT NULL,
	[ExpectedKitCode] [nvarchar](max) NULL,
	[SignUpDate] [nvarchar](max) NULL,
	[State] [nvarchar](max) NULL,
	[CollaborationMethodologyCode] [nvarchar](max) NULL,
	[CollaborationMethodologyChangeReasonCode] [nvarchar](max) NULL,
	[CollaborationMethodologyChangeComments] [nvarchar](max) NULL,
	[StateChangeComments] [nvarchar](max) NULL,
	[MethodologyChangeDate] [nvarchar](max) NULL,
	[PanelTaskNameOrCode] [nvarchar](max) NULL,
	[PanelTaskIsRemoved] [nvarchar](max) NULL,
	[PanelTaskDateFrom] [nvarchar](max) NULL,
	[PanelTaskDateTo] [nvarchar](max) NULL,
	[ReasonCodeForChangeStatus] [nvarchar](max) NULL,
	[ReasonForChangeStatus] [nvarchar](max) NULL,
	[CollaborateInFuture] [nvarchar](max) NULL,
	[PanelistRule] [nvarchar](max) NULL,
	[StateChangeDate] [nvarchar](max) NULL,
	[FullRow] [nvarchar](max) NULL

)