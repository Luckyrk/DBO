CREATE TABLE [dbo].[Frozen_Individual_CL_Delta_BackUp](
	[idDomicilio] [int] NULL,
	[idIndividuo] [nvarchar](50) NULL,
	[data_Inicial] [varchar](100) NULL,
	[nome_individuo] [nvarchar](800) NULL,
	[Sexo] [nvarchar](max) NULL,
	[Data_Nascimento] [datetime] NULL,
	[idInstrucao] [nvarchar](800) NULL,
	[idParentesco] [nvarchar](800) NULL,
	[idEstadoCivil] [nvarchar](800) NULL,
	[DonadeCasa] [int] NULL,
	[ChefedeFamilia] [int] NULL,
	[idAtividade] [nvarchar](800) NULL,
	[flgativo] [int] NULL,
	[peso] [nvarchar](800) NULL,
	[Altura] [nvarchar](800) NULL,
	[Anos_Estudo] [nvarchar](800) NULL,
	[ocupacao] [nvarchar](800) NULL,
	[idTipoEscuela] [nvarchar](800) NULL,
	[Iduso_internet] [nvarchar](800) NULL,
	[Idlocal_internet] [nvarchar](800) NULL,
	[Load_date] [datetime] NULL,
	[isUpdated] [int] NOT NULL,
	[Country_Load_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[Frozen_Individual_CL_Delta_BackUp] ADD  DEFAULT ((1)) FOR [isUpdated]
GO