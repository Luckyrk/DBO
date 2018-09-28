CREATE TABLE [dbo].[MissingClaimData] (
    [UndoClaimId]      UNIQUEIDENTIFIER NOT NULL,
    [MissingDiariesId] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [FK_MissingClaimData_UndoClaimData] FOREIGN KEY ([UndoClaimId]) REFERENCES [dbo].[UndoClaimData] ([Id])
);


GO
CREATE TRIGGER dbo.trgMissingClaimData_U 
ON dbo.[MissingClaimData] FOR update 
AS 
insert into audit.[MissingClaimData](	 [UndoClaimId]	 ,[MissingDiariesId]	 ,AuditOperation) select 	 d.[UndoClaimId]	 ,d.[MissingDiariesId],'O' from deleted d, inserted i 
insert into audit.[MissingClaimData](	 [UndoClaimId]	 ,[MissingDiariesId]	 ,AuditOperation) select 	 i.[UndoClaimId]	 ,i.[MissingDiariesId],'N' from deleted d, inserted i
GO
CREATE TRIGGER dbo.trgMissingClaimData_D
ON dbo.[MissingClaimData] FOR delete 
AS 
insert into audit.[MissingClaimData](	 [UndoClaimId]	 ,[MissingDiariesId]	 ,AuditOperation) select 	 d.[UndoClaimId]	 ,d.[MissingDiariesId],'D' from deleted d
GO
CREATE TRIGGER dbo.trgMissingClaimData_I
ON dbo.[MissingClaimData] FOR insert 
AS 
insert into audit.[MissingClaimData](	 [UndoClaimId]	 ,[MissingDiariesId]	 ,AuditOperation) select 	 i.[UndoClaimId]	 ,i.[MissingDiariesId],'I' from inserted i