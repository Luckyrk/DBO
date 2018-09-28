

CREATE TABLE [dbo].[SetThreshold](
[id] [int] IDENTITY(1,1) NOT NULL,
[ThresholdName] [varchar](100)  NULL,
[ThresholdValue] int null
 CONSTRAINT [pk_SetThreshold] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) 
GO

