CREATE TABLE [dbo].[StringAttributeValue] (
    [GUIDReference] UNIQUEIDENTIFIER NOT NULL,
    [Value]         NVARCHAR (500)   NULL,
    CONSTRAINT [PK_dbo.StringAttributeValue] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StringAttributeValue_dbo.AttributeValue_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[AttributeValue] ([GUIDReference])
);








GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[StringAttributeValue]([GUIDReference] ASC);

GO
CREATE TRIGGER [dbo].[trgStringAttributeValue_U] 
ON [dbo].[StringAttributeValue] FOR update 
AS 
insert into audit.[StringAttributeValue](
	 [GUIDReference]
	 ,[Value]
	 ,AuditOperation) select 
	 d.[GUIDReference]
	 ,d.[Value],'O'  from 
	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[StringAttributeValue](
	 [GUIDReference]
	 ,[Value]
	 ,AuditOperation) select 
	 i.[GUIDReference]
	 ,i.[Value],'N'  from 
	 deleted d join inserted i on d.GUIDReference = i.GUIDReference



UPDATE AV SET GPSUpdateTimestamp=GETDATE(),Av.Value=StrAV.Value,Av.ValueDesc=NULL
FROM AttributeValue av
INNER JOIN StringAttributeValue StrAV ON AV.GUIDReference = StrAV.GUIDReference
JOIN inserted i ON i.GUIDReference=StrAV.GUIDReference
GO

GO
