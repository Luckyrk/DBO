CREATE TABLE [dbo].[EligibilityFailureReason] (
    [EligibilityFailureReasonId] UNIQUEIDENTIFIER NOT NULL,
    [Description]                NVARCHAR (200)   NULL,
    [Country_Id]                 UNIQUEIDENTIFIER NOT NULL,
    [GPSUser]                    NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]         DATETIME         NULL,
    [CreationTimeStamp]          DATETIME         NULL,
    CONSTRAINT [PK_dbo.EligibilityFailureReason] PRIMARY KEY CLUSTERED ([EligibilityFailureReasonId] ASC),
    CONSTRAINT [FK_dbo.EligibilityFailureReason_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId])
);










GO

GO

GO
CREATE TRIGGER dbo.trgEligibilityFailureReason_U 
ON dbo.[EligibilityFailureReason] FOR update 
AS 
insert into audit.[EligibilityFailureReason](
insert into audit.[EligibilityFailureReason](
GO
CREATE TRIGGER dbo.trgEligibilityFailureReason_I
ON dbo.[EligibilityFailureReason] FOR insert 
AS 
insert into audit.[EligibilityFailureReason](
GO
CREATE TRIGGER dbo.trgEligibilityFailureReason_D
ON dbo.[EligibilityFailureReason] FOR delete 
AS 
insert into audit.[EligibilityFailureReason](