CREATE TABLE [dbo].[DemographicValueInterval] (
    [GUIDReference] UNIQUEIDENTIFIER NOT NULL,
    [StartInt]      INT              NULL,
    [EndInt]        INT              NULL,
    [Type]          NVARCHAR (100)   NOT NULL,
    [StartDecimal]  DECIMAL (18, 2)  NULL,
    [EndDecimal]    DECIMAL (18, 2)  NULL,
    [StartDate]     DATETIME         NULL,
    [EndDate]       DATETIME         NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.DemographicValueInterval] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.DemographicValueInterval_dbo.DemographicValue_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[DemographicValue] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[DemographicValueInterval]([GUIDReference] ASC);


GO
CREATE TRIGGER dbo.trgDemographicValueInterval_U 
ON dbo.[DemographicValueInterval] FOR update 
AS 
insert into audit.[DemographicValueInterval](	 [GUIDReference]	 ,[StartInt]	 ,[EndInt]	 ,[Type]	 ,[StartDecimal]	 ,[EndDecimal]	 ,[StartDate]	 ,[EndDate]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[StartInt]	 ,d.[EndInt]	 ,d.[Type]	 ,d.[StartDecimal]	 ,d.[EndDecimal]	 ,d.[StartDate]	 ,d.[EndDate],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[DemographicValueInterval](	 [GUIDReference]	 ,[StartInt]	 ,[EndInt]	 ,[Type]	 ,[StartDecimal]	 ,[EndDecimal]	 ,[StartDate]	 ,[EndDate]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[StartInt]	 ,i.[EndInt]	 ,i.[Type]	 ,i.[StartDecimal]	 ,i.[EndDecimal]	 ,i.[StartDate]	 ,i.[EndDate],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgDemographicValueInterval_I
ON dbo.[DemographicValueInterval] FOR insert 
AS 
insert into audit.[DemographicValueInterval](	 [GUIDReference]	 ,[StartInt]	 ,[EndInt]	 ,[Type]	 ,[StartDecimal]	 ,[EndDecimal]	 ,[StartDate]	 ,[EndDate]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[StartInt]	 ,i.[EndInt]	 ,i.[Type]	 ,i.[StartDecimal]	 ,i.[EndDecimal]	 ,i.[StartDate]	 ,i.[EndDate],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDemographicValueInterval_D
ON dbo.[DemographicValueInterval] FOR delete 
AS 
insert into audit.[DemographicValueInterval](	 [GUIDReference]	 ,[StartInt]	 ,[EndInt]	 ,[Type]	 ,[StartDecimal]	 ,[EndDecimal]	 ,[StartDate]	 ,[EndDate]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[StartInt]	 ,d.[EndInt]	 ,d.[Type]	 ,d.[StartDecimal]	 ,d.[EndDecimal]	 ,d.[StartDate]	 ,d.[EndDate],'D' from deleted d