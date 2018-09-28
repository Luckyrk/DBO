
CREATE TABLE [dbo].DemandedProductCategoryAnswerMapping (
    [Id]								UNIQUEIDENTIFIER NOT NULL,
	[DemandedProductCategory_Id]		UNIQUEIDENTIFIER NOT NULL,
	[DemandedProductCategoryAnswer_Id]	UNIQUEIDENTIFIER NOT NULL,
	[DoNotCallAgain]					BIT NOT NULL DEFAULT(0),
	[AskAgainInterval]					INT NULL,
    [GPSUser]							NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]				DATETIME         NULL,
    [CreationTimeStamp]					DATETIME         NULL,
    CONSTRAINT [PK_dbo.DemandedProductCategoryAnswerMapping] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.DemandedProductCategoryAnswerMapping_dbo.DemandedProductCategory_Id] FOREIGN KEY ([DemandedProductCategory_Id]) REFERENCES [dbo].[DemandedProductCategory] ([Id]),
    CONSTRAINT [FK_dbo.DemandedProductCategoryAnswerMapping_dbo.DemandedProductCategoryAnswer_Id] FOREIGN KEY ([DemandedProductCategoryAnswer_Id]) REFERENCES [dbo].[DemandedProductCategoryAnswer] ([Id])
);
