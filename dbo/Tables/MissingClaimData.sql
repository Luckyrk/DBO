﻿CREATE TABLE [dbo].[MissingClaimData] (
    [UndoClaimId]      UNIQUEIDENTIFIER NOT NULL,
    [MissingDiariesId] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [FK_MissingClaimData_UndoClaimData] FOREIGN KEY ([UndoClaimId]) REFERENCES [dbo].[UndoClaimData] ([Id])
);


GO
CREATE TRIGGER dbo.trgMissingClaimData_U 
ON dbo.[MissingClaimData] FOR update 
AS 
insert into audit.[MissingClaimData](
insert into audit.[MissingClaimData](
GO
CREATE TRIGGER dbo.trgMissingClaimData_D
ON dbo.[MissingClaimData] FOR delete 
AS 
insert into audit.[MissingClaimData](
GO
CREATE TRIGGER dbo.trgMissingClaimData_I
ON dbo.[MissingClaimData] FOR insert 
AS 
insert into audit.[MissingClaimData](