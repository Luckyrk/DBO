﻿CREATE TABLE [dbo].[Reports] (
    [ReportsId]          UNIQUEIDENTIFIER NOT NULL,
    [ReportName]         NVARCHAR (100)   NULL,
    [ReportPath]         VARCHAR (500)    NOT NULL,
    [Country_id]         UNIQUEIDENTIFIER NOT NULL,
    [IsParametersExist]  BIT              NOT NULL,
    [GPSUser]            VARCHAR (50)     NOT NULL,
    [GPSUpdateTimeStamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [ReportType]         VARCHAR (100)    NULL,
	SaveReportPath		 VARCHAR (500)    NULL,
    PRIMARY KEY CLUSTERED ([ReportsId] ASC),
    FOREIGN KEY ([Country_id]) REFERENCES [dbo].[Country] ([CountryId])
);












GO
CREATE TRIGGER dbo.trgReports_U 
ON dbo.[Reports] FOR update 
AS 
insert into audit.[Reports](
insert into audit.[Reports](
GO
CREATE TRIGGER dbo.trgReports_D
ON dbo.[Reports] FOR delete 
AS 
insert into audit.[Reports](
GO
CREATE TRIGGER dbo.trgReports_I
ON dbo.[Reports] FOR insert 
AS 
insert into audit.[Reports](