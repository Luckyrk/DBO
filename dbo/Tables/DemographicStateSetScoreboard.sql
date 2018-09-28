﻿CREATE TABLE [dbo].[DemographicStateSetScoreboard] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Target]             BIGINT           NOT NULL,
    [Actual]             BIGINT           NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [StateSet_Id]        UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.DemographicStateSetScoreboard] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.DemographicStateSetScoreboard_dbo.StateGroupDefinition_StateSet_Id] FOREIGN KEY ([StateSet_Id]) REFERENCES [dbo].[StateGroupDefinition] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_StateSet_Id]
    ON [dbo].[DemographicStateSetScoreboard]([StateSet_Id] ASC);


GO
CREATE TRIGGER dbo.trgDemographicStateSetScoreboard_U 
ON dbo.[DemographicStateSetScoreboard] FOR update 
AS 
insert into audit.[DemographicStateSetScoreboard](
insert into audit.[DemographicStateSetScoreboard](
GO
CREATE TRIGGER dbo.trgDemographicStateSetScoreboard_I
ON dbo.[DemographicStateSetScoreboard] FOR insert 
AS 
insert into audit.[DemographicStateSetScoreboard](
GO
CREATE TRIGGER dbo.trgDemographicStateSetScoreboard_D
ON dbo.[DemographicStateSetScoreboard] FOR delete 
AS 
insert into audit.[DemographicStateSetScoreboard](