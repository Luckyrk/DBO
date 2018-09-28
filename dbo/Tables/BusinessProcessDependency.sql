CREATE TABLE [dbo].[BusinessProcessDependency] (
    [GUIDReference] UNIQUEIDENTIFIER NOT NULL,
    [Parent_Id]     UNIQUEIDENTIFIER NOT NULL,
    [Child_Id]      UNIQUEIDENTIFIER NOT NULL,
    [Type]          NVARCHAR (100)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.BusinessProcessDependency] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.BusinessProcessDependency_dbo.BusinessProcess_Child_Id] FOREIGN KEY ([Child_Id]) REFERENCES [dbo].[BusinessProcess] ([GUIDReference]),
    CONSTRAINT [FK_dbo.BusinessProcessDependency_dbo.BusinessProcess_Parent_Id] FOREIGN KEY ([Parent_Id]) REFERENCES [dbo].[BusinessProcess] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Parent_Id]
    ON [dbo].[BusinessProcessDependency]([Parent_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Child_Id]
    ON [dbo].[BusinessProcessDependency]([Child_Id] ASC);


GO
CREATE TRIGGER dbo.trgBusinessProcessDependency_U 
ON dbo.[BusinessProcessDependency] FOR update 
AS 
insert into audit.[BusinessProcessDependency](	 [GUIDReference]	 ,[Parent_Id]	 ,[Child_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Parent_Id]	 ,d.[Child_Id]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[BusinessProcessDependency](	 [GUIDReference]	 ,[Parent_Id]	 ,[Child_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Parent_Id]	 ,i.[Child_Id]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgBusinessProcessDependency_I
ON dbo.[BusinessProcessDependency] FOR insert 
AS 
insert into audit.[BusinessProcessDependency](	 [GUIDReference]	 ,[Parent_Id]	 ,[Child_Id]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Parent_Id]	 ,i.[Child_Id]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgBusinessProcessDependency_D
ON dbo.[BusinessProcessDependency] FOR delete 
AS 
insert into audit.[BusinessProcessDependency](	 [GUIDReference]	 ,[Parent_Id]	 ,[Child_Id]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Parent_Id]	 ,d.[Child_Id]	 ,d.[Type],'D' from deleted d