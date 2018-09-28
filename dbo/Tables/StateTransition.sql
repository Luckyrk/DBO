﻿CREATE TABLE [dbo].[StateTransition] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [Priority]           INT              NOT NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [IsAdmin]            BIT              NOT NULL,
    [FromState_Id]       UNIQUEIDENTIFIER NULL,
    [ToState_Id]         UNIQUEIDENTIFIER NULL,
    [Action_Id]          UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.StateTransition] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.StateTransition_dbo.StateDefinition_FromState_Id] FOREIGN KEY ([FromState_Id]) REFERENCES [dbo].[StateDefinition] ([Id]),
    CONSTRAINT [FK_dbo.StateTransition_dbo.StateDefinition_ToState_Id] FOREIGN KEY ([ToState_Id]) REFERENCES [dbo].[StateDefinition] ([Id]),
    CONSTRAINT [FK_dbo.StateTransition_dbo.StateTransitionAction_Action_Id] FOREIGN KEY ([Action_Id]) REFERENCES [dbo].[StateTransitionAction] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_FromState_Id]
    ON [dbo].[StateTransition]([FromState_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_ToState_Id]
    ON [dbo].[StateTransition]([ToState_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Action_Id]
    ON [dbo].[StateTransition]([Action_Id] ASC);


GO
CREATE TRIGGER dbo.trgStateTransition_U 
ON dbo.[StateTransition] FOR update 
AS 
insert into audit.[StateTransition](
insert into audit.[StateTransition](
GO
CREATE TRIGGER dbo.trgStateTransition_I
ON dbo.[StateTransition] FOR insert 
AS 
insert into audit.[StateTransition](
GO
CREATE TRIGGER dbo.trgStateTransition_D
ON dbo.[StateTransition] FOR delete 
AS 
insert into audit.[StateTransition](