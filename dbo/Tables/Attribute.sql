CREATE TABLE [dbo].[Attribute] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [IsCalculated]       BIT              NOT NULL,
    [IsReadOnly]         BIT              NOT NULL,
    [Key]                NVARCHAR (200)   NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [MinLength]          INT              NULL,
    [MaxLength]          INT              NULL,
    [DateFrom]           DATETIME         NULL,
    [DateTo]             DATETIME         NULL,
    [Today]              BIT              NULL,
    [From]               DECIMAL (18, 2)  NULL,
    [To]                 DECIMAL (18, 2)  NULL,
    [Scope_Id]           UNIQUEIDENTIFIER NULL,
    [Category_Id]        UNIQUEIDENTIFIER NOT NULL,
    [TypeDescriptor_Id]  UNIQUEIDENTIFIER NULL,
    [Calculation_Id]     UNIQUEIDENTIFIER NULL,
    [Translation_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    [EnumSetId]          UNIQUEIDENTIFIER NULL,
    [Type]               NVARCHAR (128)   NOT NULL,
    [ShortCode]          NVARCHAR (30)        NULL,
    [StartDate]          DATETIME         NULL,
    [EndDate]            DATETIME         NULL,
    [Active]             BIT              DEFAULT ((1)) NOT NULL,
	[CritxlDefaultValue] NVARCHAR(200)	  NULL,
	[MustAnonymize]		 BIT              DEFAULT (1) NOT NULL,
    [TimeDisplay] BIT NOT NULL DEFAULT (0), 
    [IsQueueable] BIT NOT NULL DEFAULT (0), 
    CONSTRAINT [PK_dbo.Attribute] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Attribute_dbo.AttributeCategory_Category_Id] FOREIGN KEY ([Category_Id]) REFERENCES [dbo].[AttributeCategory] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Attribute_dbo.AttributeScope_Scope_Id] FOREIGN KEY ([Scope_Id]) REFERENCES [dbo].[AttributeScope] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Attribute_dbo.BusinessRule_Calculation_Id] FOREIGN KEY ([Calculation_Id]) REFERENCES [dbo].[BusinessRule] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Attribute_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.Attribute_dbo.EnumSet_EnumSetId] FOREIGN KEY ([EnumSetId]) REFERENCES [dbo].[EnumSet] ([Id]),
    CONSTRAINT [FK_dbo.Attribute_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [FK_dbo.Attribute_dbo.Translation_TypeDescriptor_Id] FOREIGN KEY ([TypeDescriptor_Id]) REFERENCES [dbo].[Translation] ([TranslationId]),
    CONSTRAINT [UniqueAttributeTranslation] UNIQUE NONCLUSTERED ([Translation_Id] ASC, [Country_Id] ASC)
);








GO
CREATE NONCLUSTERED INDEX [IX_Scope_Id]
    ON [dbo].[Attribute]([Scope_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Category_Id]
    ON [dbo].[Attribute]([Category_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TypeDescriptor_Id]
    ON [dbo].[Attribute]([TypeDescriptor_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Calculation_Id]
    ON [dbo].[Attribute]([Calculation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[Attribute]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[Attribute]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_EnumSetId]
    ON [dbo].[Attribute]([EnumSetId] ASC);


GO

CREATE TRIGGER dbo.Attribute_Trigger_Update
ON dbo.[Attribute] FOR update 
AS
BEGIN
	DECLARE @Countries TABLE (Country_Id UNIQUEIDENTIFIER)
	INSERT INTO @Countries SELECT [Country_Id] FROM inserted UNION	SELECT [Country_Id] FROM deleted
	DECLARE @Country UNIQUEIDENTIFIER; SELECT @Country = IIF(@@ROWCOUNT=1, Country_Id, NULL) FROM @Countries
	EXEC RebuildCountryRelatedViews @Country
END
GO

CREATE TRIGGER dbo.Attribute_Trigger_Insert
ON dbo.[Attribute] FOR insert 
AS
BEGIN
	DECLARE @Countries TABLE (Country_Id UNIQUEIDENTIFIER)
	INSERT INTO @Countries SELECT [Country_Id] FROM inserted UNION	SELECT [Country_Id] FROM deleted
	DECLARE @Country UNIQUEIDENTIFIER; SELECT @Country = IIF(@@ROWCOUNT=1, Country_Id, NULL) FROM @Countries
	EXEC RebuildCountryRelatedViews @Country
END
GO

CREATE TRIGGER dbo.Attribute_Trigger_Delete
ON dbo.[Attribute] FOR delete 
AS
BEGIN
	DECLARE @Countries TABLE (Country_Id UNIQUEIDENTIFIER)
	INSERT INTO @Countries SELECT [Country_Id] FROM inserted UNION	SELECT [Country_Id] FROM deleted
	DECLARE @Country UNIQUEIDENTIFIER; SELECT @Country = IIF(@@ROWCOUNT=1, Country_Id, NULL) FROM @Countries
	EXEC RebuildCountryRelatedViews @CountryEND