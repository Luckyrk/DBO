﻿CREATE TABLE [dbo].[IncentiveLevelValue] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [LevelValue]         INT              NOT NULL,
    [CanOverride]        BIT              NOT NULL,
    [IncentiveLevel_Id]  UNIQUEIDENTIFIER NOT NULL,
    [Incentive_Id]       UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.IncentiveLevelValue] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.IncentiveLevelValue_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.IncentiveLevelValue_dbo.IncentiveLevel_IncentiveLevel_Id] FOREIGN KEY ([IncentiveLevel_Id]) REFERENCES [dbo].[IncentiveLevel] ([GUIDReference]),
    CONSTRAINT [FK_dbo.IncentiveLevelValue_dbo.IncentivePoint_Incentive_Id] FOREIGN KEY ([Incentive_Id]) REFERENCES [dbo].[IncentivePoint] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_IncentiveLevel_Id]
    ON [dbo].[IncentiveLevelValue]([IncentiveLevel_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Incentive_Id]
    ON [dbo].[IncentiveLevelValue]([Incentive_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[IncentiveLevelValue]([Country_Id] ASC);


GO
CREATE TRIGGER dbo.trgIncentiveLevelValue_U 
ON dbo.[IncentiveLevelValue] FOR update 
AS 
insert into audit.[IncentiveLevelValue](
insert into audit.[IncentiveLevelValue](
GO
CREATE TRIGGER dbo.trgIncentiveLevelValue_I
ON dbo.[IncentiveLevelValue] FOR insert 
AS 
insert into audit.[IncentiveLevelValue](
GO
CREATE TRIGGER dbo.trgIncentiveLevelValue_D
ON dbo.[IncentiveLevelValue] FOR delete 
AS 
insert into audit.[IncentiveLevelValue](