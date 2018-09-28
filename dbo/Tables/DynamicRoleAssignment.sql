CREATE TABLE [dbo].[DynamicRoleAssignment] (
    [DynamicRoleAssignmentId] UNIQUEIDENTIFIER NOT NULL,
    [DynamicRole_Id]          UNIQUEIDENTIFIER NOT NULL,
    [Candidate_Id]            UNIQUEIDENTIFIER NULL,
    [Panelist_Id]             UNIQUEIDENTIFIER NULL,
    [Group_Id]                UNIQUEIDENTIFIER NULL,
    [CreationTimeStamp]       DATETIME         DEFAULT ('01/01/2012') NOT NULL,
    [GPSUpdateTimestamp]      DATETIME         DEFAULT ('01/01/2012') NOT NULL,
    [GPSUser]                 NVARCHAR (50)    DEFAULT ('DefaultGPSUser') NOT NULL,
	[Country_Id]			  UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.DynamicRoleAssignment] PRIMARY KEY CLUSTERED ([DynamicRoleAssignmentId] ASC),
    CONSTRAINT [FK_dbo.DynamicRoleAssignment_dbo.Candidate_Candidate_Id] FOREIGN KEY ([Candidate_Id]) REFERENCES [dbo].[Candidate] ([GUIDReference]),
    CONSTRAINT [FK_dbo.DynamicRoleAssignment_dbo.Collective_Group_Id] FOREIGN KEY ([Group_Id]) REFERENCES [dbo].[Collective] ([GUIDReference]),
    CONSTRAINT [FK_dbo.DynamicRoleAssignment_dbo.DynamicRole_DynamicRole_Id] FOREIGN KEY ([DynamicRole_Id]) REFERENCES [dbo].[DynamicRole] ([DynamicRoleId]),
    CONSTRAINT [FK_dbo.DynamicRoleAssignment_dbo.Panelist_Panelist_Id] FOREIGN KEY ([Panelist_Id]) REFERENCES [dbo].[Panelist] ([GUIDReference])
);




GO

CREATE TRIGGER dbo.trgDynamicRoleAssignment_D
ON dbo.[DynamicRoleAssignment] FOR delete 
AS 
insert into audit.[DynamicRoleAssignment](
	 [DynamicRoleAssignmentId]
	 ,[DynamicRole_Id]
	 ,[Candidate_Id]
	 ,[Panelist_Id]
	 ,[Group_Id]
	 ,[CreationTimeStamp]
	 ,[GPSUpdateTimestamp]
	 ,[GPSUser]
	 ,AuditOperation) select 
	 d.[DynamicRoleAssignmentId]
	 ,d.[DynamicRole_Id]
	 ,d.[Candidate_Id]
	 ,d.[Panelist_Id]
	 ,d.[Group_Id],d.[CreationTimeStamp],GETDATE(),d.[GPSUser],'D' from deleted d
GO

CREATE TRIGGER dbo.trgDynamicRoleAssignment_I
ON dbo.[DynamicRoleAssignment] FOR insert 
AS 
insert into audit.[DynamicRoleAssignment](
	 [DynamicRoleAssignmentId]
	 ,[DynamicRole_Id]
	 ,[Candidate_Id]
	 ,[Panelist_Id]
	 ,[Group_Id],[CreationTimeStamp],[GPSUpdateTimestamp],[GPSUser]
	 ,AuditOperation) select 
	 i.[DynamicRoleAssignmentId]
	 ,i.[DynamicRole_Id]
	 ,i.[Candidate_Id]
	 ,i.[Panelist_Id]
	 ,i.[Group_Id],i.[CreationTimeStamp],i.[GPSUpdateTimestamp],i.[GPSUser],'I' from inserted i
GO

CREATE TRIGGER dbo.trgDynamicRoleAssignment_U 
ON dbo.[DynamicRoleAssignment] FOR update 
AS 
insert into audit.[DynamicRoleAssignment](
	 [DynamicRoleAssignmentId]
	 ,[DynamicRole_Id]
	 ,[Candidate_Id]
	 ,[Panelist_Id]
	 ,[Group_Id]
	 ,[CreationTimeStamp],[GPSUpdateTimestamp],[GPSUser]
	 ,AuditOperation) select 
	 d.[DynamicRoleAssignmentId]
	 ,d.[DynamicRole_Id]
	 ,d.[Candidate_Id]
	 ,d.[Panelist_Id]
	 ,d.[Group_Id],d.[CreationTimeStamp],GETDATE(),d.[GPSUser],'O'  from 
	 deleted d join inserted i on d.DynamicRoleAssignmentId = i.DynamicRoleAssignmentId 
insert into audit.[DynamicRoleAssignment](
	 [DynamicRoleAssignmentId]
	 ,[DynamicRole_Id]
	 ,[Candidate_Id]
	 ,[Panelist_Id]
	 ,[Group_Id],[CreationTimeStamp],[GPSUpdateTimestamp],[GPSUser]
	 ,AuditOperation) select 
	 i.[DynamicRoleAssignmentId]
	 ,i.[DynamicRole_Id]
	 ,i.[Candidate_Id]
	 ,i.[Panelist_Id]
	 ,i.[Group_Id],i.[CreationTimeStamp],GETDATE(),i.[GPSUser],'N'  from 
	 deleted d join inserted i on d.DynamicRoleAssignmentId = i.DynamicRoleAssignmentId
GO

CREATE NONCLUSTERED INDEX [Idx_PanelistDynamicRole]
ON [DynamicRoleAssignment] ([Panelist_Id])

GO
