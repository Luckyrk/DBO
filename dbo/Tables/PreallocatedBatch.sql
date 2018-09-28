﻿CREATE TABLE [dbo].[PreallocatedBatch] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [CreationDate]       DATETIME         NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    CONSTRAINT [PK_dbo.PreallocatedBatch] PRIMARY KEY CLUSTERED ([Id] ASC)
);




GO
CREATE TRIGGER dbo.trgPreallocatedBatch_U 
ON dbo.[PreallocatedBatch] FOR update 
AS 
insert into audit.[PreallocatedBatch](
insert into audit.[PreallocatedBatch](
GO
CREATE TRIGGER dbo.trgPreallocatedBatch_I
ON dbo.[PreallocatedBatch] FOR insert 
AS 
insert into audit.[PreallocatedBatch](
GO
CREATE TRIGGER dbo.trgPreallocatedBatch_D
ON dbo.[PreallocatedBatch] FOR delete 
AS 
insert into audit.[PreallocatedBatch](