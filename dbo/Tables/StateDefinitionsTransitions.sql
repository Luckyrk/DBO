﻿CREATE TABLE [dbo].[StateDefinitionsTransitions] (
    [StateDefinition_Id]     UNIQUEIDENTIFIER NOT NULL,
    [AvailableTransition_Id] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.StateDefinitionsTransitions] PRIMARY KEY CLUSTERED ([StateDefinition_Id] ASC, [AvailableTransition_Id] ASC),
    CONSTRAINT [FK_dbo.StateDefinitionsTransitions_dbo.StateDefinition_StateDefinition_Id] FOREIGN KEY ([StateDefinition_Id]) REFERENCES [dbo].[StateDefinition] ([Id]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.StateDefinitionsTransitions_dbo.StateTransition_AvailableTransition_Id] FOREIGN KEY ([AvailableTransition_Id]) REFERENCES [dbo].[StateTransition] ([Id]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_StateDefinition_Id]
    ON [dbo].[StateDefinitionsTransitions]([StateDefinition_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_AvailableTransition_Id]
    ON [dbo].[StateDefinitionsTransitions]([AvailableTransition_Id] ASC);


GO
CREATE TRIGGER dbo.trgStateDefinitionsTransitions_U 
ON dbo.[StateDefinitionsTransitions] FOR update 
AS 
insert into audit.[StateDefinitionsTransitions](
insert into audit.[StateDefinitionsTransitions](
GO
CREATE TRIGGER dbo.trgStateDefinitionsTransitions_I
ON dbo.[StateDefinitionsTransitions] FOR insert 
AS 
insert into audit.[StateDefinitionsTransitions](
GO
CREATE TRIGGER dbo.trgStateDefinitionsTransitions_D
ON dbo.[StateDefinitionsTransitions] FOR delete 
AS 
insert into audit.[StateDefinitionsTransitions](