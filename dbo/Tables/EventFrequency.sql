CREATE TABLE [dbo].[EventFrequency] (
    [GUIDReference]  UNIQUEIDENTIFIER NOT NULL,
    [IsDefault]      BIT              NOT NULL,
    [Translation_Id] UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]     UNIQUEIDENTIFIER NOT NULL,
    [IsNotApplicable] BIT NOT NULL DEFAULT 0, 
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.EventFrequency] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.EventFrequency_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.EventFrequency_dbo.Translation_Translation_Id] FOREIGN KEY ([Translation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Translation_Id]
    ON [dbo].[EventFrequency]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[EventFrequency]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgEventFrequency_U 
ON dbo.[EventFrequency] FOR update 
AS 
insert into audit.[EventFrequency](	 [GUIDReference]	 ,[IsDefault]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[IsDefault]	 ,d.[Translation_Id]	 ,d.[Country_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[EventFrequency](	 [GUIDReference]	 ,[IsDefault]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[IsDefault]	 ,i.[Translation_Id]	 ,i.[Country_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgEventFrequency_I
ON dbo.[EventFrequency] FOR insert 
AS 
insert into audit.[EventFrequency](	 [GUIDReference]	 ,[IsDefault]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[IsDefault]	 ,i.[Translation_Id]	 ,i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgEventFrequency_D
ON dbo.[EventFrequency] FOR delete 
AS 
insert into audit.[EventFrequency](	 [GUIDReference]	 ,[IsDefault]	 ,[Translation_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[IsDefault]	 ,d.[Translation_Id]	 ,d.[Country_Id],'D' from deleted d