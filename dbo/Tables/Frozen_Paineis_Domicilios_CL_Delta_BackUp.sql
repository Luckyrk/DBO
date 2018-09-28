CREATE TABLE [dbo].[Frozen_Paineis_Domicilios_CL_Delta_BackUp](
	[idpainel] [int] NULL,
	[iddomicilio] [int] NULL,
	[Data_Entrada] [datetime] NULL,
	[Data_Saida] [datetime] NULL,
	[Cause_Saida] [int] NULL,
	[Tipo_Envio] [nvarchar](max) NULL,
	[Load_date] [datetime] NULL,
	[isUpdated] [int] NOT NULL,
	[Country_Load_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[Frozen_Paineis_Domicilios_CL_Delta_BackUp] ADD  DEFAULT ((1)) FOR [isUpdated]
GO