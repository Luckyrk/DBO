﻿CREATE TABLE [dbo].[TransitionBehavior] (
    [GUIDReference]         UNIQUEIDENTIFIER NOT NULL,
    [TransitionStrategy_Id] UNIQUEIDENTIFIER NOT NULL,
    [Type]                  NVARCHAR (100)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.TransitionBehavior] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.TransitionBehavior_dbo.StateTransitionStrategy_TransitionStrategy_Id] FOREIGN KEY ([TransitionStrategy_Id]) REFERENCES [dbo].[StateTransitionStrategy] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_TransitionStrategy_Id]
    ON [dbo].[TransitionBehavior]([TransitionStrategy_Id] ASC);


GO
CREATE TRIGGER dbo.trgTransitionBehavior_U 
ON dbo.[TransitionBehavior] FOR update 
AS 
insert into audit.[TransitionBehavior](
insert into audit.[TransitionBehavior](
GO
CREATE TRIGGER dbo.trgTransitionBehavior_I
ON dbo.[TransitionBehavior] FOR insert 
AS 
insert into audit.[TransitionBehavior](
GO
CREATE TRIGGER dbo.trgTransitionBehavior_D
ON dbo.[TransitionBehavior] FOR delete 
AS 
insert into audit.[TransitionBehavior](