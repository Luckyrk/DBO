﻿CREATE TABLE [dbo].[UndoClaimData] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [DiaryDateYear]      INT              NOT NULL,
    [DiaryDatePeriod]    INT              NOT NULL,
    [DiaryDateWeek]      INT              NOT NULL,
    [DiarySourceFull]    NVARCHAR (40)    NOT NULL,
    [PanelName]          NVARCHAR (200)   NULL,
    [PanelId]            UNIQUEIDENTIFIER NOT NULL,
    [UndoClaimFlag]      INT              NOT NULL,
    [GPSUser]            NVARCHAR (100)   NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    CONSTRAINT [PK_UndoClaimData] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE TRIGGER dbo.trgUndoClaimData_U 
ON dbo.[UndoClaimData] FOR update 
AS 
insert into audit.[UndoClaimData](
insert into audit.[UndoClaimData](
GO
CREATE TRIGGER dbo.trgUndoClaimData_D
ON dbo.[UndoClaimData] FOR delete 
AS 
insert into audit.[UndoClaimData](
GO
CREATE TRIGGER dbo.trgUndoClaimData_I
ON dbo.[UndoClaimData] FOR insert 
AS 
insert into audit.[UndoClaimData](