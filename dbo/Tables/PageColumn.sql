﻿CREATE TABLE [dbo].[PageColumn] (
    [PageColumnId]       UNIQUEIDENTIFIER NOT NULL,
    [ColumnNumber]       INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Page_Id]            UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.PageColumn] PRIMARY KEY CLUSTERED ([PageColumnId] ASC),
    CONSTRAINT [FK_dbo.PageColumn_dbo.FormPage_Page_Id] FOREIGN KEY ([Page_Id]) REFERENCES [dbo].[FormPage] ([Id]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_Page_Id]
    ON [dbo].[PageColumn]([Page_Id] ASC);


GO
CREATE TRIGGER dbo.trgPageColumn_U 
ON dbo.[PageColumn] FOR update 
AS 
insert into audit.[PageColumn](
insert into audit.[PageColumn](
GO
CREATE TRIGGER dbo.trgPageColumn_I
ON dbo.[PageColumn] FOR insert 
AS 
insert into audit.[PageColumn](
GO
CREATE TRIGGER dbo.trgPageColumn_D
ON dbo.[PageColumn] FOR delete 
AS 
insert into audit.[PageColumn](