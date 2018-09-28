CREATE TABLE [dbo].[OrderedContactMechanism] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Order]              INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NOT NULL,
    [GPSUpdateTimestamp] DATETIME         NOT NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Address_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Candidate_Id]       UNIQUEIDENTIFIER NOT NULL,
	[Country_Id]		 UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.OrderedContactMechanism] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.OrderedContactMechanism_dbo.Address_Address_Id] FOREIGN KEY ([Address_Id]) REFERENCES [dbo].[Address] ([GUIDReference]),
    CONSTRAINT [FK_dbo.OrderedContactMechanism_dbo.Candidate_Candidate_Id] FOREIGN KEY ([Candidate_Id]) REFERENCES [dbo].[Candidate] ([GUIDReference])
);








GO
CREATE NONCLUSTERED INDEX [IX_Address_Id]
    ON [dbo].[OrderedContactMechanism]([Address_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Candidate_Id]
    ON [dbo].[OrderedContactMechanism]([Candidate_Id] ASC);


GO
CREATE TRIGGER dbo.trgOrderedContactMechanism_U 
ON dbo.[OrderedContactMechanism] FOR update 
AS 
insert into audit.[OrderedContactMechanism](	 [Id]	 ,[Order]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Address_Id]	 ,[Candidate_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Order]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Address_Id]	 ,d.[Candidate_Id],d.[Country_Id],'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[OrderedContactMechanism](	 [Id]	 ,[Order]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Address_Id]	 ,[Candidate_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Order]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Address_Id]	 ,i.[Candidate_Id],i.[Country_Id],'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgOrderedContactMechanism_I
ON dbo.[OrderedContactMechanism] FOR insert 
AS 
insert into audit.[OrderedContactMechanism](	 [Id]	 ,[Order]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Address_Id]	 ,[Candidate_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[Id]	 ,i.[Order]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Address_Id]	 ,i.[Candidate_Id],i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER [dbo].[trgOrderedContactMechanism_D]
ON [dbo].[OrderedContactMechanism] FOR delete 
AS 
insert into audit.[OrderedContactMechanism](	 [Id]	 ,[Order]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Address_Id]	 ,[Candidate_Id]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[Id]	 ,d.[Order]	 ,d.[GPSUser]	 ,GETDATE()	 ,d.[CreationTimeStamp]	 ,d.[Address_Id]	 ,d.[Candidate_Id],d.[Country_Id],'D' from deleted d