CREATE TABLE [dbo].[ClaimProfile] (
    [ClaimProfileId] BIGINT   IDENTITY (1, 1) NOT NULL,
    [ClaimContextId] BIGINT   NOT NULL,
    [ClaimRoleId]    BIGINT   NOT NULL,
    [ActiveFrom]     DATETIME NOT NULL,
    [ActiveTo]       DATETIME NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ClaimProfile] PRIMARY KEY CLUSTERED ([ClaimProfileId] ASC),
    CONSTRAINT [FK_dbo.ClaimProfile_dbo.ClaimContext_ClaimContextId] FOREIGN KEY ([ClaimContextId]) REFERENCES [dbo].[ClaimContext] ([ClaimContextId]),
    CONSTRAINT [FK_dbo.ClaimProfile_dbo.ClaimRole_ClaimRoleId] FOREIGN KEY ([ClaimRoleId]) REFERENCES [dbo].[ClaimRole] ([ClaimRoleId])
);






GO
CREATE NONCLUSTERED INDEX [IX_ClaimContextId]
    ON [dbo].[ClaimProfile]([ClaimContextId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ClaimRoleId]
    ON [dbo].[ClaimProfile]([ClaimRoleId] ASC);


GO
CREATE TRIGGER dbo.trgClaimProfile_U 
ON dbo.[ClaimProfile] FOR update 
AS 
insert into audit.[ClaimProfile](	 [ClaimProfileId]	 ,[ClaimContextId]	 ,[ClaimRoleId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[ClaimProfileId]	 ,d.[ClaimContextId]	 ,d.[ClaimRoleId]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'O'  from 	 deleted d join inserted i on d.ClaimProfileId = i.ClaimProfileId 
insert into audit.[ClaimProfile](	 [ClaimProfileId]	 ,[ClaimContextId]	 ,[ClaimRoleId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[ClaimProfileId]	 ,i.[ClaimContextId]	 ,i.[ClaimRoleId]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'N'  from 	 deleted d join inserted i on d.ClaimProfileId = i.ClaimProfileId
GO
CREATE TRIGGER dbo.trgClaimProfile_I
ON dbo.[ClaimProfile] FOR insert 
AS 
insert into audit.[ClaimProfile](	 [ClaimProfileId]	 ,[ClaimContextId]	 ,[ClaimRoleId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[ClaimProfileId]	 ,i.[ClaimContextId]	 ,i.[ClaimRoleId]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'I' from inserted i
GO
CREATE TRIGGER dbo.trgClaimProfile_D
ON dbo.[ClaimProfile] FOR delete 
AS 
insert into audit.[ClaimProfile](	 [ClaimProfileId]	 ,[ClaimContextId]	 ,[ClaimRoleId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[ClaimProfileId]	 ,d.[ClaimContextId]	 ,d.[ClaimRoleId]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'D' from deleted d