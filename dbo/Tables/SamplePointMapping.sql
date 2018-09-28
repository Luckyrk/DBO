CREATE TABLE [dbo].[SamplePointMapping](
	[GuidReference] [uniqueidentifier] NOT NULL,
	[IdentityUserID] [uniqueidentifier] NULL,
	[DiscriminatorType] [varchar](50) NULL,
	[Value] [uniqueidentifier] NULL,
	[FromDate] [datetime] NULL,
	[ToDate] [datetime] NULL,
	[CreatedBy] [nvarchar](200) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [nvarchar](200) NULL,
	[ModifiedDate] [datetime] NULL,
	[IsDeleted] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[GuidReference] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[SamplePointMapping] ADD  DEFAULT ((0)) FOR [IsDeleted]
GO

ALTER TABLE [dbo].[SamplePointMapping]  WITH CHECK ADD FOREIGN KEY([IdentityUserID])
REFERENCES [dbo].[IdentityUser] ([Id])
GO


