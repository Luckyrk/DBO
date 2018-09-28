CREATE TABLE [dbo].[FormRule](
	[GUIDReference] [uniqueidentifier] NOT NULL,
	[FormId] [uniqueidentifier] NOT NULL,
	[RuleId] [uniqueidentifier] NOT NULL,
	[CreationTimeStamp] [datetime] NULL,
	[GPSUser] [nvarchar](50) NULL,
	[GPSUpdateTimestamp] [datetime] NULL,
	CONSTRAINT [PK_dbo.FormRule] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.FormRule_dbo.BusinessRule_RuleId] FOREIGN KEY ([RuleId]) REFERENCES [dbo].[BusinessRule] ([GUIDReference]) ON DELETE CASCADE
	);
GO