﻿CREATE TABLE [dbo].[Calendar] (
    [GUIDReference]       UNIQUEIDENTIFIER NOT NULL,
    [CalendarDescription] NVARCHAR (256)   NULL,
    [GPSUser]             NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]  DATETIME         NULL,
    [CreationTimeStamp]   DATETIME         NULL,
    [Country_Id]          UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.Calendar] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Calendar_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);






GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[Calendar]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgCalendar_U 
ON dbo.[Calendar] FOR update 
AS 
insert into audit.[Calendar](
insert into audit.[Calendar](
GO
CREATE TRIGGER dbo.trgCalendar_I
ON dbo.[Calendar] FOR insert 
AS 
insert into audit.[Calendar](
GO
CREATE TRIGGER dbo.trgCalendar_D
ON dbo.[Calendar] FOR delete 
AS 
insert into audit.[Calendar](