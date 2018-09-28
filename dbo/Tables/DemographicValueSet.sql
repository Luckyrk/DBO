CREATE TABLE [dbo].[DemographicValueSet] (
    [GUIDReference] UNIQUEIDENTIFIER NOT NULL,
    [Type]          NVARCHAR (100)   NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.DemographicValueSet] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.DemographicValueSet_dbo.DemographicValue_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[DemographicValue] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[DemographicValueSet]([GUIDReference] ASC);


GO
CREATE TRIGGER dbo.trgDemographicValueSet_U 
ON dbo.[DemographicValueSet] FOR update 
AS 
insert into audit.[DemographicValueSet](	 [GUIDReference]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Type],'O'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
insert into audit.[DemographicValueSet](	 [GUIDReference]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Type],'N'  from 	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER dbo.trgDemographicValueSet_I
ON dbo.[DemographicValueSet] FOR insert 
AS 
insert into audit.[DemographicValueSet](	 [GUIDReference]	 ,[Type]	 ,AuditOperation) select 	 i.[GUIDReference]	 ,i.[Type],'I' from inserted i
GO
CREATE TRIGGER dbo.trgDemographicValueSet_D
ON dbo.[DemographicValueSet] FOR delete 
AS 
insert into audit.[DemographicValueSet](	 [GUIDReference]	 ,[Type]	 ,AuditOperation) select 	 d.[GUIDReference]	 ,d.[Type],'D' from deleted d