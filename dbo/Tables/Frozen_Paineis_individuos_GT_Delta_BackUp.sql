CREATE TABLE [dbo].[Frozen_Paineis_individuos_GT_Delta_BackUp](
	[idpainel] [int] NULL,
	[iddomicilio] [int] NULL,
	[idindividuo] [bigint] NULL,
	[Data_Entrada] [nvarchar](max) NULL,
	[Data_Saida] [datetime] NULL,
	[Cause_Saida] [int] NULL,
	[Tipo_Envio] [varchar](max) NULL,
	[Censo_Year] [nvarchar](800) NULL,
	[Load_date] [datetime] NULL,
	[isUpdated] [int] NOT NULL,
	[Country_Load_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[Frozen_Paineis_individuos_GT_Delta_BackUp] ADD  DEFAULT ((1)) FOR [isUpdated]
GO