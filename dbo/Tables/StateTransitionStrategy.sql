﻿CREATE TABLE [dbo].[StateTransitionStrategy] (
    [GUIDReference]   UNIQUEIDENTIFIER NOT NULL,
    [BusinessRule_Id] UNIQUEIDENTIFIER NULL,
    [Type]            NVARCHAR (128)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StateTransitionStrategy] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.StateTransitionStrategy_dbo.BusinessRule_BusinessRule_Id] FOREIGN KEY ([BusinessRule_Id]) REFERENCES [dbo].[BusinessRule] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_BusinessRule_Id]
    ON [dbo].[StateTransitionStrategy]([BusinessRule_Id] ASC);


GO
CREATE TRIGGER dbo.trgStateTransitionStrategy_U 
ON dbo.[StateTransitionStrategy] FOR update 
AS 
insert into audit.[StateTransitionStrategy](
insert into audit.[StateTransitionStrategy](
GO
CREATE TRIGGER dbo.trgStateTransitionStrategy_I
ON dbo.[StateTransitionStrategy] FOR insert 
AS 
insert into audit.[StateTransitionStrategy](
GO
CREATE TRIGGER dbo.trgStateTransitionStrategy_D
ON dbo.[StateTransitionStrategy] FOR delete 
AS 
insert into audit.[StateTransitionStrategy](