CREATE TABLE [dbo].[ClaimProfileMapping] (
    [AccessContextId]  BIGINT   NOT NULL,
    [ClaimProfileId]   BIGINT   NOT NULL,
    [SystemRoleTypeId] BIGINT   NOT NULL,
    [ActiveFrom]       DATETIME NOT NULL,
    [ActiveTo]         DATETIME NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ClaimProfileMapping] PRIMARY KEY CLUSTERED ([AccessContextId] ASC, [ClaimProfileId] ASC, [SystemRoleTypeId] ASC),
    CONSTRAINT [FK_dbo.ClaimProfileMapping_dbo.AccessContext_AccessContextId] FOREIGN KEY ([AccessContextId]) REFERENCES [dbo].[AccessContext] ([AccessContextId]),
    CONSTRAINT [FK_dbo.ClaimProfileMapping_dbo.ClaimProfile_ClaimProfileId] FOREIGN KEY ([ClaimProfileId]) REFERENCES [dbo].[ClaimProfile] ([ClaimProfileId])
);






GO
CREATE NONCLUSTERED INDEX [IX_AccessContextId]
    ON [dbo].[ClaimProfileMapping]([AccessContextId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ClaimProfileId]
    ON [dbo].[ClaimProfileMapping]([ClaimProfileId] ASC);


GO
CREATE TRIGGER dbo.trgClaimProfileMapping_U 
ON dbo.[ClaimProfileMapping] FOR update 
AS 
insert into audit.[ClaimProfileMapping](	 [AccessContextId]	 ,[ClaimProfileId]	 ,[SystemRoleTypeId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[AccessContextId]	 ,d.[ClaimProfileId]	 ,d.[SystemRoleTypeId]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'O'  from 	 deleted d join inserted i on d.AccessContextId = i.AccessContextId	 and d.ClaimProfileId = i.ClaimProfileId	 and d.SystemRoleTypeId = i.SystemRoleTypeId 
insert into audit.[ClaimProfileMapping](	 [AccessContextId]	 ,[ClaimProfileId]	 ,[SystemRoleTypeId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[AccessContextId]	 ,i.[ClaimProfileId]	 ,i.[SystemRoleTypeId]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'N'  from 	 deleted d join inserted i on d.AccessContextId = i.AccessContextId	 and d.ClaimProfileId = i.ClaimProfileId	 and d.SystemRoleTypeId = i.SystemRoleTypeId
GO
CREATE TRIGGER dbo.trgClaimProfileMapping_I
ON dbo.[ClaimProfileMapping] FOR insert 
AS 
insert into audit.[ClaimProfileMapping](	 [AccessContextId]	 ,[ClaimProfileId]	 ,[SystemRoleTypeId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 i.[AccessContextId]	 ,i.[ClaimProfileId]	 ,i.[SystemRoleTypeId]	 ,i.[ActiveFrom]	 ,i.[ActiveTo],'I' from inserted i
GO
CREATE TRIGGER dbo.trgClaimProfileMapping_D
ON dbo.[ClaimProfileMapping] FOR delete 
AS 
insert into audit.[ClaimProfileMapping](	 [AccessContextId]	 ,[ClaimProfileId]	 ,[SystemRoleTypeId]	 ,[ActiveFrom]	 ,[ActiveTo]	 ,AuditOperation) select 	 d.[AccessContextId]	 ,d.[ClaimProfileId]	 ,d.[SystemRoleTypeId]	 ,d.[ActiveFrom]	 ,d.[ActiveTo],'D' from deleted d