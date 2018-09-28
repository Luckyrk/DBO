﻿CREATE TABLE [dbo].[CharitySubscription] (
    [Id]        UNIQUEIDENTIFIER NOT NULL,
    [Amount_Id] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CharitySubscription] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.CharitySubscription_dbo.CharityAmount_Amount_Id] FOREIGN KEY ([Amount_Id]) REFERENCES [dbo].[CharityAmount] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Amount_Id]
    ON [dbo].[CharitySubscription]([Amount_Id] ASC);


GO
CREATE TRIGGER dbo.trgCharitySubscription_U 
ON dbo.[CharitySubscription] FOR update 
AS 
insert into audit.[CharitySubscription](
insert into audit.[CharitySubscription](
GO
CREATE TRIGGER dbo.trgCharitySubscription_I
ON dbo.[CharitySubscription] FOR insert 
AS 
insert into audit.[CharitySubscription](
GO
CREATE TRIGGER dbo.trgCharitySubscription_D
ON dbo.[CharitySubscription] FOR delete 
AS 
insert into audit.[CharitySubscription](