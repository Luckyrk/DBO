CREATE TABLE [dbo].[Respondent] (
    [GUIDReference]     UNIQUEIDENTIFIER NOT NULL,
    [DiscriminatorType] NVARCHAR (50)    NULL,
    [CountryID]         UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.Respondent] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Respondent_dbo.Country_CountryID] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_CountryID]
    ON [dbo].[Respondent]([CountryID] ASC);


GO
CREATE TRIGGER dbo.trgRespondent_U 
ON dbo.[Respondent] FOR update 
AS 
insert into audit.[Respondent](	 [GUIDReference]	 ,[DiscriminatorType]	 ,[CountryID]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[DiscriminatorType]	 ,d.[CountryID],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[Respondent](	 [GUIDReference]	 ,[DiscriminatorType]	 ,[CountryID]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[DiscriminatorType]	 ,i.[CountryID],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgRespondent_I
ON dbo.[Respondent] FOR insert 
AS 
insert into audit.[Respondent](	 [GUIDReference]	 ,[DiscriminatorType]	 ,[CountryID]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[DiscriminatorType]	 ,i.[CountryID],'I' from inserted i
GO
CREATE TRIGGER dbo.trgRespondent_D
ON dbo.[Respondent] FOR delete 
AS 
insert into audit.[Respondent](	 [GUIDReference]	 ,[DiscriminatorType]	 ,[CountryID]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[DiscriminatorType]	 ,d.[CountryID],'D' from deleted d