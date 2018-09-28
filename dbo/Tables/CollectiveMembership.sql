CREATE TABLE [dbo].[CollectiveMembership] (
    [CollectiveMembershipId] UNIQUEIDENTIFIER NOT NULL,
    [Sequence]               BIGINT           NOT NULL,
    [SignUpDate]             DATETIME         NOT NULL,
    [DeletedDate]            DATETIME         NULL,
    [GPSUser]                NVARCHAR (50)    NOT NULL,
    [GPSUpdateTimestamp]     DATETIME         NOT NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    [State_Id]               UNIQUEIDENTIFIER NULL,
    [Group_Id]               UNIQUEIDENTIFIER NOT NULL,
    [Individual_Id]          UNIQUEIDENTIFIER NOT NULL,
    [DiscriminatorType]      NVARCHAR (128)   NOT NULL,
	[Country_Id]		     UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.CollectiveMembership] PRIMARY KEY CLUSTERED ([CollectiveMembershipId] ASC),
    CONSTRAINT [FK_dbo.CollectiveMembership_dbo.Collective_Group_Id] FOREIGN KEY ([Group_Id]) REFERENCES [dbo].[Collective] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.CollectiveMembership_dbo.Individual_Individual_Id] FOREIGN KEY ([Individual_Id]) REFERENCES [dbo].[Individual] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.CollectiveMembership_dbo.StateDefinition_State_Id] FOREIGN KEY ([State_Id]) REFERENCES [dbo].[StateDefinition] ([Id])
);








GO
CREATE NONCLUSTERED INDEX [IX_State_Id]
    ON [dbo].[CollectiveMembership]([State_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Group_Id]
    ON [dbo].[CollectiveMembership]([Group_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Individual_Id]
    ON [dbo].[CollectiveMembership]([Individual_Id] ASC);


GO
CREATE TRIGGER dbo.trgCollectiveMembership_U 
ON dbo.[CollectiveMembership] FOR update 
AS 
insert into audit.[CollectiveMembership](	 [CollectiveMembershipId]	 ,[Sequence]	 ,[SignUpDate]	 ,[DeletedDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[State_Id]	 ,[Group_Id]	 ,[Individual_Id]	 ,[DiscriminatorType]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[CollectiveMembershipId]	 ,d.[Sequence]	 ,d.[SignUpDate]	 ,d.[DeletedDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[State_Id]	 ,d.[Group_Id]	 ,d.[Individual_Id]	 ,d.[DiscriminatorType],d.[Country_Id],'O'  from 	 deleted d join inserted i on d.CollectiveMembershipId = i.CollectiveMembershipId 
insert into audit.[CollectiveMembership](	 [CollectiveMembershipId]	 ,[Sequence]	 ,[SignUpDate]	 ,[DeletedDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[State_Id]	 ,[Group_Id]	 ,[Individual_Id]	 ,[DiscriminatorType]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[CollectiveMembershipId]	 ,i.[Sequence]	 ,i.[SignUpDate]	 ,i.[DeletedDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[State_Id]	 ,i.[Group_Id]	 ,i.[Individual_Id]	 ,i.[DiscriminatorType],i.[Country_Id],'N'  from 	 deleted d join inserted i on d.CollectiveMembershipId = i.CollectiveMembershipId
GO
CREATE TRIGGER dbo.trgCollectiveMembership_I
ON dbo.[CollectiveMembership] FOR insert 
AS 
insert into audit.[CollectiveMembership](	 [CollectiveMembershipId]	 ,[Sequence]	 ,[SignUpDate]	 ,[DeletedDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[State_Id]	 ,[Group_Id]	 ,[Individual_Id]	 ,[DiscriminatorType]	 ,[Country_Id]	 ,AuditOperation) select 	 i.[CollectiveMembershipId]	 ,i.[Sequence]	 ,i.[SignUpDate]	 ,i.[DeletedDate]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp]	 ,i.[State_Id]	 ,i.[Group_Id]	 ,i.[Individual_Id]	 ,i.[DiscriminatorType],i.[Country_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgCollectiveMembership_D
ON dbo.[CollectiveMembership] FOR delete 
AS 
insert into audit.[CollectiveMembership](	 [CollectiveMembershipId]	 ,[Sequence]	 ,[SignUpDate]	 ,[DeletedDate]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,[State_Id]	 ,[Group_Id]	 ,[Individual_Id]	 ,[DiscriminatorType]	 ,[Country_Id]	 ,AuditOperation) select 	 d.[CollectiveMembershipId]	 ,d.[Sequence]	 ,d.[SignUpDate]	 ,d.[DeletedDate]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp]	 ,d.[State_Id]	 ,d.[Group_Id]	 ,d.[Individual_Id]	 ,d.[DiscriminatorType],d.[Country_Id],'D' from deleted d
GO
