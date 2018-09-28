CREATE TABLE [dbo].[ReportParameters] (
    [ReportParametersId]       INT              IDENTITY (1, 1) NOT NULL,
    [ReportParameterName]      VARCHAR (100)    NOT NULL,
    [ReportParameterAliasName] VARCHAR (100)    NOT NULL,
    [ReportParameterTypeName]  VARCHAR (100)    NOT NULL,
    [ReportsId]                UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]                  VARCHAR (50)     NULL,
    [GPSUpdateTimestamp]       DATETIME         NULL,
    [CreationTimeStamp]        DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([ReportParametersId] ASC),
    FOREIGN KEY ([ReportsId]) REFERENCES [dbo].[Reports] ([ReportsId])
);


GO
CREATE TRIGGER dbo.trgReportParameters_U 
ON dbo.[ReportParameters] FOR update 
AS 
insert into audit.[ReportParameters](	 [ReportParametersId]	 ,[ReportParameterName]	 ,[ReportParameterAliasName]	 ,[ReportParameterTypeName]	 ,[ReportsId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[ReportParametersId]	 ,d.[ReportParameterName]	 ,d.[ReportParameterAliasName]	 ,d.[ReportParameterTypeName]	 ,d.[ReportsId]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'O'  from 	 deleted d join inserted i on d.ReportParametersId = i.ReportParametersId 
insert into audit.[ReportParameters](	 [ReportParametersId]	 ,[ReportParameterName]	 ,[ReportParameterAliasName]	 ,[ReportParameterTypeName]	 ,[ReportsId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[ReportParametersId]	 ,i.[ReportParameterName]	 ,i.[ReportParameterAliasName]	 ,i.[ReportParameterTypeName]	 ,i.[ReportsId]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'N'  from 	 deleted d join inserted i on d.ReportParametersId = i.ReportParametersId
GO
CREATE TRIGGER dbo.trgReportParameters_D
ON dbo.[ReportParameters] FOR delete 
AS 
insert into audit.[ReportParameters](	 [ReportParametersId]	 ,[ReportParameterName]	 ,[ReportParameterAliasName]	 ,[ReportParameterTypeName]	 ,[ReportsId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 d.[ReportParametersId]	 ,d.[ReportParameterName]	 ,d.[ReportParameterAliasName]	 ,d.[ReportParameterTypeName]	 ,d.[ReportsId]	 ,d.[GPSUser]	 ,d.[GPSUpdateTimestamp]	 ,d.[CreationTimeStamp],'D' from deleted d
GO
CREATE TRIGGER dbo.trgReportParameters_I
ON dbo.[ReportParameters] FOR insert 
AS 
insert into audit.[ReportParameters](	 [ReportParametersId]	 ,[ReportParameterName]	 ,[ReportParameterAliasName]	 ,[ReportParameterTypeName]	 ,[ReportsId]	 ,[GPSUser]	 ,[GPSUpdateTimestamp]	 ,[CreationTimeStamp]	 ,AuditOperation) select 	 i.[ReportParametersId]	 ,i.[ReportParameterName]	 ,i.[ReportParameterAliasName]	 ,i.[ReportParameterTypeName]	 ,i.[ReportsId]	 ,i.[GPSUser]	 ,i.[GPSUpdateTimestamp]	 ,i.[CreationTimeStamp],'I' from inserted i