CREATE TABLE [dbo].[Reports] (
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
insert into audit.[Reports](	 [ReportsId]	 ,[ReportName]	 ,[ReportPath]	 ,[Country_id]	 ,[IsParametersExist]	 ,[GPSUser]	 ,[GPSUpdateTimeStamp]	 ,[CreationTimeStamp]	 ,[ReportType]	 ,AuditOperation) select 	 d.[ReportsId]	 ,d.[ReportName]	 ,d.[ReportPath]	 ,d.[Country_id]	 ,d.[IsParametersExist]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimeStamp]	 ,d.[CreationTimeStamp]	 ,d.[ReportType],'O'  from 	 deleted d join inserted i on d.ReportsId = i.ReportsId 
insert into audit.[Reports](	 [ReportsId]	 ,[ReportName]	 ,[ReportPath]	 ,[Country_id]	 ,[IsParametersExist]	 ,[GPSUser]	 ,[GPSUpdateTimeStamp]	 ,[CreationTimeStamp]	 ,[ReportType]	 ,AuditOperation) select 	 i.[ReportsId]	 ,i.[ReportName]	 ,i.[ReportPath]	 ,i.[Country_id]	 ,i.[IsParametersExist]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimeStamp]	 ,i.[CreationTimeStamp]	 ,i.[ReportType],'N'  from 	 deleted d join inserted i on d.ReportsId = i.ReportsId
GO
CREATE TRIGGER dbo.trgReports_D
ON dbo.[Reports] FOR delete 
AS 
insert into audit.[Reports](	 [ReportsId]	 ,[ReportName]	 ,[ReportPath]	 ,[Country_id]	 ,[IsParametersExist]	 ,[GPSUser]	 ,[GPSUpdateTimeStamp]	 ,[CreationTimeStamp]	 ,[ReportType]	 ,AuditOperation) select 	 d.[ReportsId]	 ,d.[ReportName]	 ,d.[ReportPath]	 ,d.[Country_id]	 ,d.[IsParametersExist]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimeStamp]	 ,d.[CreationTimeStamp]	 ,d.[ReportType],'D' from deleted d
GO
CREATE TRIGGER dbo.trgReports_I
ON dbo.[Reports] FOR insert 
AS 
insert into audit.[Reports](	 [ReportsId]	 ,[ReportName]	 ,[ReportPath]	 ,[Country_id]	 ,[IsParametersExist]	 ,[GPSUser]	 ,[GPSUpdateTimeStamp]	 ,[CreationTimeStamp]	 ,[ReportType]	 ,AuditOperation) select 	 i.[ReportsId]	 ,i.[ReportName]	 ,i.[ReportPath]	 ,i.[Country_id]	 ,i.[IsParametersExist]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimeStamp]	 ,i.[CreationTimeStamp]	 ,i.[ReportType],'I' from inserted i