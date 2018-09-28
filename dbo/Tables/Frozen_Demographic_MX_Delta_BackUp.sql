CREATE TABLE [dbo].[Frozen_Demographic_MX_Delta_BackUp](
	[idDomicilio] [varchar](100) NOT NULL,
	[idPosse_Bem] [nvarchar](800) NULL,
	[data] [nvarchar](800) NULL,
	[Quantidade] [nvarchar](800) NULL,
	[Load_date] [datetime] NULL,
	[isUpdated] [int] NOT NULL,
	[Country_Load_date] [datetime] NULL
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[Frozen_Demographic_MX_Delta_BackUp] ADD  DEFAULT ((1)) FOR [isUpdated]
GO