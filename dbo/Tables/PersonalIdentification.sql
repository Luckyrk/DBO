CREATE TABLE [dbo].[PersonalIdentification] (
    [PersonalIdentificationId] BIGINT           IDENTITY (1, 1) NOT NULL,
    [DateOfBirth]              DATETIME         NULL,
    [LastOrderedName]          NVARCHAR (150)   NULL,
    [MiddleOrderedName]        NVARCHAR (150)   NULL,
    [FirstOrderedName]         NVARCHAR (150)   NULL,
    [TitleId]                  UNIQUEIDENTIFIER NULL,
    [CreationTimeStamp]        DATETIME         DEFAULT ('01/01/2012') NOT NULL,
    [GPSUpdateTimestamp]       DATETIME         DEFAULT ('01/01/2012') NOT NULL,
    [GPSUser]                  NVARCHAR (50)    DEFAULT ('DefaultGPSUser') NOT NULL,
	[Country_Id]		       UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.PersonalIdentification] PRIMARY KEY CLUSTERED ([PersonalIdentificationId] ASC),
    CONSTRAINT [FK_dbo.PersonalIdentification_dbo.IndividualTitle_TitleId] FOREIGN KEY ([TitleId]) REFERENCES [dbo].[IndividualTitle] ([GUIDReference])
);





GO
CREATE NONCLUSTERED INDEX [IX_Title_Id]
    ON [dbo].[PersonalIdentification]([TitleId] ASC);

GO


CREATE TRIGGER dbo.trgPersonalIdentification_U 
ON dbo.[PersonalIdentification] FOR update 
AS 
insert into audit.[PersonalIdentification](
	 [PersonalIdentificationId]
	 ,[DateOfBirth]
	 ,[LastOrderedName]
	 ,[MiddleOrderedName]
	 ,[FirstOrderedName]
	 ,[TitleId],[Country_Id],[CreationTimeStamp],[GPSUpdateTimestamp],[GPSUser]	 
	 ,AuditOperation) select 
	 d.[PersonalIdentificationId]
	 ,d.[DateOfBirth]
	 ,d.[LastOrderedName]
	 ,d.[MiddleOrderedName]
	 ,d.[FirstOrderedName]
	 ,d.[TitleId],d.[Country_Id],d.[CreationTimeStamp],GETDATE(),d.[GPSUser]
	 ,'O'  from 
	 deleted d join inserted i on d.PersonalIdentificationId = i.[PersonalIdentificationId]
insert into audit.[PersonalIdentification](
	 [PersonalIdentificationId]
	 ,[DateOfBirth]
	 ,[LastOrderedName]
	 ,[MiddleOrderedName]
	 ,[FirstOrderedName]
	 ,[TitleId],[Country_Id],[CreationTimeStamp],[GPSUpdateTimestamp],[GPSUser]
	 ,AuditOperation) select 
	 i.[PersonalIdentificationId]
	 ,i.[DateOfBirth]
	 ,i.[LastOrderedName]
	 ,i.[MiddleOrderedName]
	 ,i.[FirstOrderedName]
	 ,i.[TitleId],i.[Country_Id],i.[CreationTimeStamp],GETDATE(),i.[GPSUser]
	 ,'N'  from 
	 deleted d join inserted i on d.PersonalIdentificationId = i.PersonalIdentificationId
GO
CREATE TRIGGER dbo.trgPersonalIdentification_D
ON dbo.[PersonalIdentification] FOR delete 
AS 
insert into audit.[PersonalIdentification](
	 [PersonalIdentificationId]
	 ,[DateOfBirth]
	 ,[LastOrderedName]
	 ,[MiddleOrderedName]
	 ,[FirstOrderedName]
	 ,[TitleId],[Country_Id],[CreationTimeStamp],[GPSUpdateTimestamp],[GPSUser]
	 ,AuditOperation) select 
	 d.[PersonalIdentificationId]
	 ,d.[DateOfBirth]
	 ,d.[LastOrderedName]
	 ,d.[MiddleOrderedName]
	 ,d.[FirstOrderedName]
	 ,d.[TitleId],d.[Country_Id],d.[CreationTimeStamp],GETDATE(),d.[GPSUser]
	 ,'D' from deleted d
GO
CREATE TRIGGER dbo.trgPersonalIdentification_I
ON dbo.[PersonalIdentification] FOR insert 
AS 
insert into audit.[PersonalIdentification](	 [PersonalIdentificationId]	 ,[DateOfBirth]	 ,[LastOrderedName]	 ,[MiddleOrderedName]	 ,[FirstOrderedName]	 ,[TitleId],[Country_Id],[CreationTimeStamp],[GPSUpdateTimestamp],[GPSUser]	 ,AuditOperation) select 	 i.[PersonalIdentificationId]	 ,i.[DateOfBirth]	 ,i.[LastOrderedName]	 ,i.[MiddleOrderedName]	 ,i.[FirstOrderedName]	 ,i.[TitleId],i.[Country_Id],i.[CreationTimeStamp],i.[GPSUpdateTimestamp],i.[GPSUser]	 ,'I' from inserted i