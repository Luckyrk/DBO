CREATE TABLE [dbo].[Scheme] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Number]             INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Iteration_Id]       UNIQUEIDENTIFIER NULL,
    [Period_Id]          UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.Scheme] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Scheme_dbo.Iteration_Iteration_Id] FOREIGN KEY ([Iteration_Id]) REFERENCES [dbo].[Iteration] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Scheme_dbo.Period_Period_Id] FOREIGN KEY ([Period_Id]) REFERENCES [dbo].[Period] ([Id])
);






GO
CREATE NONCLUSTERED INDEX [IX_Iteration_Id]
    ON [dbo].[Scheme]([Iteration_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Period_Id]
    ON [dbo].[Scheme]([Period_Id] ASC);


GO
CREATE TRIGGER dbo.trgScheme_U 
ON dbo.[Scheme] FOR update 
AS 
insert into audit.[Scheme](	 [GUIDReference]	 ,[Number]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Iteration_Id]	 ,[Period_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Number]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Iteration_Id]	 ,d.[Period_Id],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[Scheme](	 [GUIDReference]	 ,[Number]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Iteration_Id]	 ,[Period_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Number]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Iteration_Id]	 ,i.[Period_Id],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgScheme_I
ON dbo.[Scheme] FOR insert 
AS 
insert into audit.[Scheme](	 [GUIDReference]	 ,[Number]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Iteration_Id]	 ,[Period_Id]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Number]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[Iteration_Id]	 ,i.[Period_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgScheme_D
ON dbo.[Scheme] FOR delete 
AS 
insert into audit.[Scheme](	 [GUIDReference]	 ,[Number]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[Iteration_Id]	 ,[Period_Id]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Number]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[Iteration_Id]	 ,d.[Period_Id],'D' from deleted d