CREATE TABLE [dbo].[ExclusionPanelist] (
    [Exclusion_Id] UNIQUEIDENTIFIER NOT NULL,
    [Panelist_Id]  UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ExclusionPanelist] PRIMARY KEY CLUSTERED ([Exclusion_Id] ASC, [Panelist_Id] ASC),
    CONSTRAINT [FK_dbo.ExclusionPanelist_dbo.Exclusion_Exclusion_Id] FOREIGN KEY ([Exclusion_Id]) REFERENCES [dbo].[Exclusion] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.ExclusionPanelist_dbo.Panelist_Panelist_Id] FOREIGN KEY ([Panelist_Id]) REFERENCES [dbo].[Panelist] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_Exclusion_Id]
    ON [dbo].[ExclusionPanelist]([Exclusion_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Panelist_Id]
    ON [dbo].[ExclusionPanelist]([Panelist_Id] ASC);


GO
CREATE TRIGGER dbo.trgExclusionPanelist_U 
ON dbo.[ExclusionPanelist] FOR update 
AS 
insert into audit.[ExclusionPanelist](	 [Exclusion_Id]	 ,[Panelist_Id]	 ,AuditOperation) select 	 d.[Exclusion_Id]	 ,d.[Panelist_Id],'O'  from 	 deleted d join inserted i on d.Exclusion_Id = i.Exclusion_Id	 and d.Panelist_Id = i.Panelist_Id 
insert into audit.[ExclusionPanelist](	 [Exclusion_Id]	 ,[Panelist_Id]	 ,AuditOperation) select 	 i.[Exclusion_Id]	 ,i.[Panelist_Id],'N'  from 	 deleted d join inserted i on d.Exclusion_Id = i.Exclusion_Id	 and d.Panelist_Id = i.Panelist_Id
GO
CREATE TRIGGER dbo.trgExclusionPanelist_I
ON dbo.[ExclusionPanelist] FOR insert 
AS 
insert into audit.[ExclusionPanelist](	 [Exclusion_Id]	 ,[Panelist_Id]	 ,AuditOperation) select 	 i.[Exclusion_Id]	 ,i.[Panelist_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgExclusionPanelist_D
ON dbo.[ExclusionPanelist] FOR delete 
AS 
insert into audit.[ExclusionPanelist](	 [Exclusion_Id]	 ,[Panelist_Id]	 ,AuditOperation) select 	 d.[Exclusion_Id]	 ,d.[Panelist_Id],'D' from deleted d