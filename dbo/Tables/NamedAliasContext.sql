CREATE TABLE [dbo].[NamedAliasContext] (
    [NamedAliasContextId] UNIQUEIDENTIFIER NOT NULL,
    [Name]                NVARCHAR (150)   NOT NULL,
    [GPSUser]             NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]  DATETIME         NULL,
    [CreationTimeStamp]   DATETIME         NULL,
    [Discriminator]       NVARCHAR (128)   NOT NULL,
    [Strategy_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]          UNIQUEIDENTIFIER NOT NULL,
    [Panel_Id]            UNIQUEIDENTIFIER NULL,
	[AutomaticallyGenerated]	BIT NULL,
    CONSTRAINT [PK_dbo.NamedAliasContext] PRIMARY KEY CLUSTERED ([NamedAliasContextId] ASC),
    CONSTRAINT [FK_dbo.NamedAliasContext_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.NamedAliasContext_dbo.NamedAliasStrategy_Strategy_Id] FOREIGN KEY ([Strategy_Id]) REFERENCES [dbo].[NamedAliasStrategy] ([NamedAliasStrategyId]),
    CONSTRAINT [FK_dbo.NamedAliasContext_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]),
    CONSTRAINT [UniqueAliasContextName] UNIQUE NONCLUSTERED ([Name] ASC)
);






GO
CREATE NONCLUSTERED INDEX [IX_Strategy_Id]
    ON [dbo].[NamedAliasContext]([Strategy_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[NamedAliasContext]([Country_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[NamedAliasContext]([Panel_Id] ASC);


GO

CREATE TRIGGER dbo.NamedAliasContext_Trigger_Update
ON dbo.[NamedAliasContext] FOR update 
AS 
BEGIN
	DECLARE @Countries TABLE (Country_Id UNIQUEIDENTIFIER)
	INSERT INTO @Countries SELECT [Country_Id] FROM inserted UNION	SELECT [Country_Id] FROM deleted
	DECLARE @Country UNIQUEIDENTIFIER; SELECT @Country = IIF(@@ROWCOUNT=1, Country_Id, NULL) FROM @Countries
	EXEC RebuildCountryRelatedViews @Country
END
GO

CREATE TRIGGER dbo.NamedAliasContext_Trigger_Insert
ON dbo.[NamedAliasContext] FOR insert 
AS 
BEGIN
	DECLARE @Countries TABLE (Country_Id UNIQUEIDENTIFIER)
	INSERT INTO @Countries SELECT [Country_Id] FROM inserted UNION	SELECT [Country_Id] FROM deleted
	DECLARE @Country UNIQUEIDENTIFIER; SELECT @Country = IIF(@@ROWCOUNT=1, Country_Id, NULL) FROM @Countries
	EXEC RebuildCountryRelatedViews @Country
END
GO

CREATE TRIGGER dbo.NamedAliasContext_Trigger_Delete
ON dbo.[NamedAliasContext] FOR delete 
AS
BEGIN
	DECLARE @Countries TABLE (Country_Id UNIQUEIDENTIFIER)
	INSERT INTO @Countries SELECT [Country_Id] FROM inserted UNION	SELECT [Country_Id] FROM deleted
	DECLARE @Country UNIQUEIDENTIFIER; SELECT @Country = IIF(@@ROWCOUNT=1, Country_Id, NULL) FROM @Countries
	EXEC RebuildCountryRelatedViews @Country
END
GO