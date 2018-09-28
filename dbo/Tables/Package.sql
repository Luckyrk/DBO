﻿CREATE TABLE [dbo].[Package] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [State_Id]           UNIQUEIDENTIFIER NOT NULL,
    [Reward_Id]          UNIQUEIDENTIFIER NOT NULL,
    [Debit_Id]           UNIQUEIDENTIFIER NOT NULL,
    [Country_Id]         UNIQUEIDENTIFIER NOT NULL,
	[DateSent]			 DATETIME		  NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [GPSUser]            VARCHAR (50)     NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [ReferenceId] NVARCHAR(50) NULL, 
    [Courier] NVARCHAR(50) NULL, 
    CONSTRAINT [PK_dbo.Package] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Package_dbo.Country_Country_Id] FOREIGN KEY ([Country_Id]) REFERENCES [dbo].[Country] ([CountryId]),
    CONSTRAINT [FK_dbo.Package_dbo.IncentiveAccountTransaction_Debit_Id] FOREIGN KEY ([Debit_Id]) REFERENCES [dbo].[IncentiveAccountTransaction] ([IncentiveAccountTransactionId]),
    CONSTRAINT [FK_dbo.Package_dbo.IncentivePoint_Reward_Id] FOREIGN KEY ([Reward_Id]) REFERENCES [dbo].[IncentivePoint] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Package_dbo.StateDefinition_State_Id] FOREIGN KEY ([State_Id]) REFERENCES [dbo].[StateDefinition] ([Id])
);








GO
CREATE NONCLUSTERED INDEX [IX_State_Id]
    ON [dbo].[Package]([State_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Reward_Id]
    ON [dbo].[Package]([Reward_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Debit_Id]
    ON [dbo].[Package]([Debit_Id] ASC);

	GO
CREATE NONCLUSTERED INDEX [IX_Country_Id]
    ON [dbo].[Package]([Country_Id] ASC);

GO
CREATE TRIGGER dbo.trgPackage_U 
ON dbo.[Package] FOR update 
AS 
insert into audit.[Package](
insert into audit.[Package](
GO
CREATE TRIGGER dbo.trgPackage_I
ON dbo.[Package] FOR insert 
AS 
insert into audit.[Package](
GO
CREATE TRIGGER dbo.trgPackage_D
ON dbo.[Package] FOR delete 
AS 
insert into audit.[Package](