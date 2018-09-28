CREATE TABLE [dbo].[Frozen_Pet_MX_Delta_BackUp](
	[GroupBusinessId] [int] NULL,
	[idanimal] [nvarchar](max) NULL,
	[idtamanho] [nvarchar](800) NULL,
	[idtipo_alimentacao] [nvarchar](800) NULL,
	[edad] [nvarchar](800) NULL,
	[PetNO] [int] NULL,
	[Load_date] [datetime] NULL,
	[isUpdated] [int] NOT NULL,
	[Country_Load_date] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[Frozen_Pet_MX_Delta_BackUp] ADD  DEFAULT ((1)) FOR [isUpdated]
GO