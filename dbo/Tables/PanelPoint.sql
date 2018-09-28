CREATE TABLE [dbo].[PanelPoint] (
    [Panel_Id] UNIQUEIDENTIFIER NOT NULL,
    [Point_Id] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.PanelPoint] PRIMARY KEY CLUSTERED ([Panel_Id] ASC, [Point_Id] ASC),
    CONSTRAINT [FK_dbo.PanelPoint_dbo.IncentivePoint_Point_Id] FOREIGN KEY ([Point_Id]) REFERENCES [dbo].[IncentivePoint] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.PanelPoint_dbo.Panel_Panel_Id] FOREIGN KEY ([Panel_Id]) REFERENCES [dbo].[Panel] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_Panel_Id]
    ON [dbo].[PanelPoint]([Panel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Point_Id]
    ON [dbo].[PanelPoint]([Point_Id] ASC);


GO
CREATE TRIGGER dbo.trgPanelPoint_U 
ON dbo.[PanelPoint] FOR update 
AS 
insert into audit.[PanelPoint](	 [Panel_Id]	 ,[Point_Id]	 ,AuditOperation) select 	 d.[Panel_Id]	 ,d.[Point_Id],'O'  from 	 deleted d join inserted i on d.Panel_Id = i.Panel_Id	 and d.Point_Id = i.Point_Id 
insert into audit.[PanelPoint](	 [Panel_Id]	 ,[Point_Id]	 ,AuditOperation) select 	 i.[Panel_Id]	 ,i.[Point_Id],'N'  from 	 deleted d join inserted i on d.Panel_Id = i.Panel_Id	 and d.Point_Id = i.Point_Id
GO
CREATE TRIGGER dbo.trgPanelPoint_I
ON dbo.[PanelPoint] FOR insert 
AS 
insert into audit.[PanelPoint](	 [Panel_Id]	 ,[Point_Id]	 ,AuditOperation) select 	 i.[Panel_Id]	 ,i.[Point_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgPanelPoint_D
ON dbo.[PanelPoint] FOR delete 
AS 
insert into audit.[PanelPoint](	 [Panel_Id]	 ,[Point_Id]	 ,AuditOperation) select 	 d.[Panel_Id]	 ,d.[Point_Id],'D' from deleted d