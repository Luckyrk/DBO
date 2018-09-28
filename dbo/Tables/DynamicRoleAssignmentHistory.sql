﻿CREATE TABLE [dbo].[DynamicRoleAssignmentHistory] (
    [GUIDReference]            UNIQUEIDENTIFIER NOT NULL,
    [DateFrom]                 DATETIME         NOT NULL,
    [DateTo]                   DATETIME         NULL,
    [CreationTimeStamp]        DATETIME         NULL,
    [GPSUser]                  NVARCHAR (100)   NULL,
    [GPSUpdateTimestamp]       DATETIME         NULL,
    [DynamicRoleAssignment_Id] UNIQUEIDENTIFIER NOT NULL,
    [DynamicRole_Id]           UNIQUEIDENTIFIER NOT NULL,
    [Candidate_Id]             UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.DynamicRoleAssignmentHistory] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.DynamicRoleAssignmentHistory_dbo.Candidate_Candidate_Id] FOREIGN KEY ([Candidate_Id]) REFERENCES [dbo].[Candidate] ([GUIDReference]),
    CONSTRAINT [FK_dbo.DynamicRoleAssignmentHistory_dbo.DynamicRole_DynamicRole_Id] FOREIGN KEY ([DynamicRole_Id]) REFERENCES [dbo].[DynamicRole] ([DynamicRoleId]),
    CONSTRAINT [FK_dbo.DynamicRoleAssignmentHistory_dbo.DynamicRoleAssignment_DynamicRoleAssignment_Id] FOREIGN KEY ([DynamicRoleAssignment_Id]) REFERENCES [dbo].[DynamicRoleAssignment] ([DynamicRoleAssignmentId])
);




GO
CREATE NONCLUSTERED INDEX [IX_Candidate_Id]
    ON [dbo].[DynamicRoleAssignmentHistory]([Candidate_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DynamicRole_Id]
    ON [dbo].[DynamicRoleAssignmentHistory]([DynamicRole_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DynamicRoleAssignment_Id]
    ON [dbo].[DynamicRoleAssignmentHistory]([DynamicRoleAssignment_Id] ASC);


GO
CREATE TRIGGER dbo.trgDynamicRoleAssignmentHistory_U 
ON dbo.[DynamicRoleAssignmentHistory] FOR update 
AS 
insert into audit.[DynamicRoleAssignmentHistory](
insert into audit.[DynamicRoleAssignmentHistory](
GO
CREATE TRIGGER dbo.trgDynamicRoleAssignmentHistory_I
ON dbo.[DynamicRoleAssignmentHistory] FOR insert 
AS 
insert into audit.[DynamicRoleAssignmentHistory](
GO
CREATE TRIGGER dbo.trgDynamicRoleAssignmentHistory_D
ON dbo.[DynamicRoleAssignmentHistory] FOR delete 
AS 
insert into audit.[DynamicRoleAssignmentHistory](