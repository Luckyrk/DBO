﻿CREATE TABLE [dbo].[QueryQueryAction] (
    [Query_Id]       UNIQUEIDENTIFIER NOT NULL,
    [QueryAction_Id] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.QueryQueryAction] PRIMARY KEY CLUSTERED ([Query_Id] ASC, [QueryAction_Id] ASC),
    CONSTRAINT [FK_dbo.QueryQueryAction_dbo.PreDefinedQuery_Query_Id] FOREIGN KEY ([Query_Id]) REFERENCES [dbo].[PreDefinedQuery] ([PreDefinedQueryId]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.QueryQueryAction_dbo.QueryAction_QueryAction_Id] FOREIGN KEY ([QueryAction_Id]) REFERENCES [dbo].[QueryAction] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_Query_Id]
    ON [dbo].[QueryQueryAction]([Query_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_QueryAction_Id]
    ON [dbo].[QueryQueryAction]([QueryAction_Id] ASC);


GO
CREATE TRIGGER dbo.trgQueryQueryAction_U 
ON dbo.[QueryQueryAction] FOR update 
AS 
insert into audit.[QueryQueryAction](
insert into audit.[QueryQueryAction](
GO
CREATE TRIGGER dbo.trgQueryQueryAction_I
ON dbo.[QueryQueryAction] FOR insert 
AS 
insert into audit.[QueryQueryAction](
GO
CREATE TRIGGER dbo.trgQueryQueryAction_D
ON dbo.[QueryQueryAction] FOR delete 
AS 
insert into audit.[QueryQueryAction](