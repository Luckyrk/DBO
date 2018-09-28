﻿CREATE TABLE [dbo].[Iteration] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Index]              INT              NOT NULL,
    [Begin]              DATETIME         NOT NULL,
    [End]                DATETIME         NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Discriminator]      NVARCHAR (128)   NOT NULL,
    [Previous_Id]        UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.Iteration] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Iteration_dbo.Iteration_Previous_Id] FOREIGN KEY ([Previous_Id]) REFERENCES [dbo].[Iteration] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Previous_Id]
    ON [dbo].[Iteration]([Previous_Id] ASC);


GO
CREATE TRIGGER dbo.trgIteration_U 
ON dbo.[Iteration] FOR update 
AS 
insert into audit.[Iteration](
insert into audit.[Iteration](
GO
CREATE TRIGGER dbo.trgIteration_I
ON dbo.[Iteration] FOR insert 
AS 
insert into audit.[Iteration](
GO
CREATE TRIGGER dbo.trgIteration_D
ON dbo.[Iteration] FOR delete 
AS 
insert into audit.[Iteration](