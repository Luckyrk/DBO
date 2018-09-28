﻿CREATE TABLE [dbo].[DemographicValueInterval] (
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
insert into audit.[DemographicValueInterval](
insert into audit.[DemographicValueInterval](
GO
CREATE TRIGGER dbo.trgDemographicValueInterval_I
ON dbo.[DemographicValueInterval] FOR insert 
AS 
insert into audit.[DemographicValueInterval](
GO
CREATE TRIGGER dbo.trgDemographicValueInterval_D
ON dbo.[DemographicValueInterval] FOR delete 
AS 
insert into audit.[DemographicValueInterval](