CREATE TABLE [dbo].[ImportColumnMapping] (
    [Id]                    UNIQUEIDENTIFIER NOT NULL,
    [IsIdentifier]          BIT              NOT NULL,
    [IsGroupAlias]          BIT              NOT NULL,
    [IsRefererAlias]        BIT              NOT NULL,
    [IsIncentiveAlias]      BIT              NOT NULL,
    [IsConditionalRequired] BIT              NOT NULL,
    [FixedLength]           INT              NULL,
    [ColumnIndex]           INT              NOT NULL,
    [Property]              NVARCHAR (1000)  NULL,
    [Discriminator]         NVARCHAR (128)   NOT NULL,
    [Demographic_Id]        UNIQUEIDENTIFIER NULL,
    [Alias_Id]              UNIQUEIDENTIFIER NULL,
	[Reference_Id]			UNIQUEIDENTIFIER NULL,
    [ImportFormat_Id]       UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ImportColumnMapping] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.ImportColumnMapping_dbo.Attribute_Demographic_Id] FOREIGN KEY ([Demographic_Id]) REFERENCES [dbo].[Attribute] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ImportColumnMapping_dbo.ImportFormat_ImportFormat_Id] FOREIGN KEY ([ImportFormat_Id]) REFERENCES [dbo].[ImportFormat] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ImportColumnMapping_dbo.NamedAliasContext_Alias_Id] FOREIGN KEY ([Alias_Id]) REFERENCES [dbo].[NamedAliasContext] ([NamedAliasContextId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Demographic_Id]
    ON [dbo].[ImportColumnMapping]([Demographic_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Alias_Id]
    ON [dbo].[ImportColumnMapping]([Alias_Id] ASC);
	

GO
CREATE NONCLUSTERED INDEX [IX_Reference_Id]
    ON [dbo].[ImportColumnMapping]([Reference_Id] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_ImportFormat_Id]
    ON [dbo].[ImportColumnMapping]([ImportFormat_Id] ASC);


GO
CREATE TRIGGER dbo.trgImportColumnMapping_U 
ON dbo.[ImportColumnMapping] FOR update 
AS 
insert into audit.[ImportColumnMapping](	 [Id]	 ,[IsIdentifier]	 ,[IsGroupAlias]	 ,[IsRefererAlias]	 ,[IsIncentiveAlias]	 ,[IsConditionalRequired]	 ,[FixedLength]	 ,[ColumnIndex]	 ,[Property]	 ,[Discriminator]	 ,[Demographic_Id]	 ,[Alias_Id]	 ,[Reference_Id]	 ,[ImportFormat_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[IsIdentifier]	 ,d.[IsGroupAlias]	 ,d.[IsRefererAlias]	 ,d.[IsIncentiveAlias]	 ,d.[IsConditionalRequired]	 ,d.[FixedLength]	 ,d.[ColumnIndex]	 ,d.[Property]	 ,d.[Discriminator]	 ,d.[Demographic_Id]	 ,d.[Alias_Id]	 ,d.[Reference_Id]	 ,d.[ImportFormat_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[ImportColumnMapping](	 [Id]	 ,[IsIdentifier]	 ,[IsGroupAlias]	 ,[IsRefererAlias]	 ,[IsIncentiveAlias]	 ,[IsConditionalRequired]	 ,[FixedLength]	 ,[ColumnIndex]	 ,[Property]	 ,[Discriminator]	 ,[Demographic_Id]	 ,[Alias_Id]	 ,[Reference_Id]	 ,[ImportFormat_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[IsIdentifier]	 ,i.[IsGroupAlias]	 ,i.[IsRefererAlias]	 ,i.[IsIncentiveAlias]	 ,i.[IsConditionalRequired]	 ,i.[FixedLength]	 ,i.[ColumnIndex]	 ,i.[Property]	 ,i.[Discriminator]	 ,i.[Demographic_Id]	 ,i.[Alias_Id]	 ,i.[Reference_Id]	 ,i.[ImportFormat_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgImportColumnMapping_I
ON dbo.[ImportColumnMapping] FOR insert 
AS 
insert into audit.[ImportColumnMapping](	 [Id]	 ,[IsIdentifier]	 ,[IsGroupAlias]	 ,[IsRefererAlias]	 ,[IsIncentiveAlias]	 ,[IsConditionalRequired]	 ,[FixedLength]	 ,[ColumnIndex]	 ,[Property]	 ,[Discriminator]	 ,[Demographic_Id]	 ,[Alias_Id]	 ,[Reference_Id]	 ,[ImportFormat_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[IsIdentifier]	 ,i.[IsGroupAlias]	 ,i.[IsRefererAlias]	 ,i.[IsIncentiveAlias]	 ,i.[IsConditionalRequired]	 ,i.[FixedLength]	 ,i.[ColumnIndex]	 ,i.[Property]	 ,i.[Discriminator]	 ,i.[Demographic_Id]	 ,i.[Alias_Id]	 ,i.[Reference_Id]	 ,i.[ImportFormat_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgImportColumnMapping_D
ON dbo.[ImportColumnMapping] FOR delete 
AS 
insert into audit.[ImportColumnMapping](	 [Id]	 ,[IsIdentifier]	 ,[IsGroupAlias]	 ,[IsRefererAlias]	 ,[IsIncentiveAlias]	 ,[IsConditionalRequired]	 ,[FixedLength]	 ,[ColumnIndex]	 ,[Property]	 ,[Discriminator]	 ,[Demographic_Id]	 ,[Alias_Id]	 ,[Reference_Id]	 ,[ImportFormat_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[IsIdentifier]	 ,d.[IsGroupAlias]	 ,d.[IsRefererAlias]	 ,d.[IsIncentiveAlias]	 ,d.[IsConditionalRequired]	 ,d.[FixedLength]	 ,d.[ColumnIndex]	 ,d.[Property]	 ,d.[Discriminator]	 ,d.[Demographic_Id]	 ,d.[Alias_Id]	 ,d.[Reference_Id]	 ,d.[ImportFormat_Id],'D' from deleted d