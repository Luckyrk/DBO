﻿CREATE TABLE [dbo].[ActionTaskComEventTrigger] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [WhatInitiateWhat]   INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Action_Id]          UNIQUEIDENTIFIER NOT NULL,
    [Communication_Id]   UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.ActionTaskComEventTrigger] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.ActionTaskComEventTrigger_dbo.ActionTask_Action_Id] FOREIGN KEY ([Action_Id]) REFERENCES [dbo].[ActionTask] ([GUIDReference]),
    CONSTRAINT [FK_dbo.ActionTaskComEventTrigger_dbo.CommunicationEvent_Communication_Id] FOREIGN KEY ([Communication_Id]) REFERENCES [dbo].[CommunicationEvent] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Action_Id]
    ON [dbo].[ActionTaskComEventTrigger]([Action_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Communication_Id]
    ON [dbo].[ActionTaskComEventTrigger]([Communication_Id] ASC);


GO
CREATE TRIGGER dbo.trgActionTaskComEventTrigger_U 
ON dbo.[ActionTaskComEventTrigger] FOR update 
AS 
insert into audit.[ActionTaskComEventTrigger](
insert into audit.[ActionTaskComEventTrigger](
GO
CREATE TRIGGER dbo.trgActionTaskComEventTrigger_I
ON dbo.[ActionTaskComEventTrigger] FOR insert 
AS 
insert into audit.[ActionTaskComEventTrigger](
GO
CREATE TRIGGER dbo.trgActionTaskComEventTrigger_D
ON dbo.[ActionTaskComEventTrigger] FOR delete 
AS 
insert into audit.[ActionTaskComEventTrigger](