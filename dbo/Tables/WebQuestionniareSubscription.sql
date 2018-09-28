CREATE TABLE [dbo].[WebQuestionniareSubscription] (
    [Id]             UNIQUEIDENTIFIER NOT NULL,
    [Code]           INT              NOT NULL,
    [Translation_Id] UNIQUEIDENTIFIER NULL,
    [Country_Id]     UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.WebQuestionniareSubscription] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.WebQuestionniareSubscription_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.WebQuestionniareSubscription_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);


GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[WebQuestionniareSubscription]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[WebQuestionniareSubscription]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgWebQuestionniareSubscription_U 
ON dbo.[WebQuestionniareSubscription] FOR update 
AS 
insert into audit.[WebQuestionniareSubscription](	 [Id]	 ,[Code]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Code]	 ,d.[Translation_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[WebQuestionniareSubscription](	 [Id]	 ,[Code]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Code]	 ,i.[Translation_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgWebQuestionniareSubscription_I
ON dbo.[WebQuestionniareSubscription] FOR insert 
AS 
insert into audit.[WebQuestionniareSubscription](	 [Id]	 ,[Code]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Code]	 ,i.[Translation_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgWebQuestionniareSubscription_D
ON dbo.[WebQuestionniareSubscription] FOR delete 
AS 
insert into audit.[WebQuestionniareSubscription](	 [Id]	 ,[Code]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Code]	 ,d.[Translation_Id]	 ,d.[Country_Id],'D' from deleted d