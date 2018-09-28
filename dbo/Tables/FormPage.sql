﻿CREATE TABLE [dbo].[FormPage] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Number]             INT              NOT NULL,
	[Translation_Id]     UNIQUEIDENTIFIER NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Form_Id]            UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.FormPage] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.FormPage_dbo.Form_Form_Id] FOREIGN KEY ([Form_Id]) REFERENCES [dbo].[Form] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_Form_Id]
    ON [dbo].[FormPage]([Form_Id] ASC);


GO
CREATE TRIGGER dbo.trgFormPage_U 
ON dbo.[FormPage] FOR update 
AS 
insert into audit.[FormPage](
insert into audit.[FormPage](
GO
CREATE TRIGGER dbo.trgFormPage_I
ON dbo.[FormPage] FOR insert 
AS 
insert into audit.[FormPage](
GO
CREATE TRIGGER dbo.trgFormPage_D
ON dbo.[FormPage] FOR delete 
AS 
insert into audit.[FormPage](