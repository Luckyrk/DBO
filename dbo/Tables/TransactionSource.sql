CREATE TABLE [dbo].[TransactionSource] (
    [TransactionSourceId] UNIQUEIDENTIFIER NOT NULL,
    [Code]                NVARCHAR (10)    NULL,
    [IsDefault]           BIT              NOT NULL,
    [Description_Id]      UNIQUEIDENTIFIER NULL,
    [Country_Id]          UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.TransactionSource] PRIMARY KEY CLUSTERED ([TransactionSourceId] ASC),
    CONSTRAINT [FK_dbo.TransactionSource_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.TransactionSource_dbo.Translation_Description_Id] FOREIGN KEY ([Description_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Description_Id]
    ON [dbo].[TransactionSource]([Description_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[TransactionSource]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgTransactionSource_U 
ON dbo.[TransactionSource] FOR update 
AS 
insert into audit.[TransactionSource](	 [TransactionSourceId]	 ,[Code]	 ,[IsDefault]	 ,[Description_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[TransactionSourceId]	 ,d.[Code]	 ,d.[IsDefault]	 ,d.[Description_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.TransactionSourceId = i.TransactionSourceId 
insert into audit.[TransactionSource](	 [TransactionSourceId]	 ,[Code]	 ,[IsDefault]	 ,[Description_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[TransactionSourceId]	 ,i.[Code]	 ,i.[IsDefault]	 ,i.[Description_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.TransactionSourceId = i.TransactionSourceId
GO
CREATE TRIGGER dbo.trgTransactionSource_I
ON dbo.[TransactionSource] FOR insert 
AS 
insert into audit.[TransactionSource](	 [TransactionSourceId]	 ,[Code]	 ,[IsDefault]	 ,[Description_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[TransactionSourceId]	 ,i.[Code]	 ,i.[IsDefault]	 ,i.[Description_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgTransactionSource_D
ON dbo.[TransactionSource] FOR delete 
AS 
insert into audit.[TransactionSource](	 [TransactionSourceId]	 ,[Code]	 ,[IsDefault]	 ,[Description_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[TransactionSourceId]	 ,d.[Code]	 ,d.[IsDefault]	 ,d.[Description_Id]	 ,d.[Country_Id],'D' from deleted d