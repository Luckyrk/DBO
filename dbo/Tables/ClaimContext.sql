CREATE TABLE [dbo].[ClaimContext] (
    [ClaimContextId] BIGINT         IDENTITY (1, 1) NOT NULL,
    [Description]    NVARCHAR (MAX) NULL,
    [ActiveFrom]     DATETIME       NOT NULL,
    [ActiveTo]       DATETIME       NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ClaimContext] PRIMARY KEY CLUSTERED ([ClaimContextId] ASC)
);




GO
CREATE TRIGGER dbo.trgClaimContext_U 
ON dbo.[ClaimContext] FOR update 
AS 
insert into audit.[ClaimContext](	 [ClaimContextId]	 ,[Description]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[ClaimContextId]	 ,d.[Description]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'O'  from 	 deleted d join inserted i on d.ClaimContextId = i.ClaimContextId 
insert into audit.[ClaimContext](	 [ClaimContextId]	 ,[Description]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[ClaimContextId]	 ,i.[Description]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'N'  from 	 deleted d join inserted i on d.ClaimContextId = i.ClaimContextId
GO
CREATE TRIGGER dbo.trgClaimContext_I
ON dbo.[ClaimContext] FOR insert 
AS 
insert into audit.[ClaimContext](	 [ClaimContextId]	 ,[Description]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[ClaimContextId]	 ,i.[Description]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'I' from inserted i
GO
CREATE TRIGGER dbo.trgClaimContext_D
ON dbo.[ClaimContext] FOR delete 
AS 
insert into audit.[ClaimContext](	 [ClaimContextId]	 ,[Description]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[ClaimContextId]	 ,d.[Description]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'D' from deleted d