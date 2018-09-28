﻿CREATE TABLE [dbo].[TextDocument] (
    [DocumentId]         BIGINT         NOT NULL,
    [TextDate]           DATETIME       NOT NULL,
    [SenderId]           NVARCHAR (200) NOT NULL,
    [Recipient]          NVARCHAR (200) NOT NULL,
    [Message]            NVARCHAR (200) NOT NULL,
    [GPSUser]            NVARCHAR (50)  NOT NULL,
    [GPSUpdateTimestamp] DATETIME       NULL,
    [CreationTimeStamp]  DATETIME       NULL,
    [Unusable] BIT NULL DEFAULT 0, 
    CONSTRAINT [PK_dbo.TextDocument] PRIMARY KEY CLUSTERED ([DocumentId] ASC),
    CONSTRAINT [FK_dbo.TextDocument_dbo.Document_DocumentId] FOREIGN KEY ([DocumentId]) REFERENCES [dbo].[Document] ([DocumentId])
);






GO
CREATE NONCLUSTERED INDEX [IX_DocumentId]
    ON [dbo].[TextDocument]([DocumentId] ASC);


GO
CREATE TRIGGER dbo.trgTextDocument_U 
ON dbo.[TextDocument] FOR update 
AS 
insert into audit.[TextDocument](
insert into audit.[TextDocument](
GO
CREATE TRIGGER dbo.trgTextDocument_I
ON dbo.[TextDocument] FOR insert 
AS 
insert into audit.[TextDocument](
GO
CREATE TRIGGER dbo.trgTextDocument_D
ON dbo.[TextDocument] FOR delete 
AS 
insert into audit.[TextDocument](