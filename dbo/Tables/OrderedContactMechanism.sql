﻿CREATE TABLE [dbo].[OrderedContactMechanism] (
    [Id]                 UNIQUEIDENTIFIER NOT NULL,
    [Order]              INT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NOT NULL,
    [GPSUpdateTimestamp] DATETIME         NOT NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Address_Id]         UNIQUEIDENTIFIER NOT NULL,
    [Candidate_Id]       UNIQUEIDENTIFIER NOT NULL,
	[Country_Id]		 UNIQUEIDENTIFIER NULL,
    CONSTRAINT [PK_dbo.OrderedContactMechanism] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.OrderedContactMechanism_dbo.Address_Address_Id] FOREIGN KEY ([Address_Id]) REFERENCES [dbo].[Address] ([GUIDReference]),
    CONSTRAINT [FK_dbo.OrderedContactMechanism_dbo.Candidate_Candidate_Id] FOREIGN KEY ([Candidate_Id]) REFERENCES [dbo].[Candidate] ([GUIDReference])
);








GO
CREATE NONCLUSTERED INDEX [IX_Address_Id]
    ON [dbo].[OrderedContactMechanism]([Address_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Candidate_Id]
    ON [dbo].[OrderedContactMechanism]([Candidate_Id] ASC);


GO
CREATE TRIGGER dbo.trgOrderedContactMechanism_U 
ON dbo.[OrderedContactMechanism] FOR update 
AS 
insert into audit.[OrderedContactMechanism](
insert into audit.[OrderedContactMechanism](
GO
CREATE TRIGGER dbo.trgOrderedContactMechanism_I
ON dbo.[OrderedContactMechanism] FOR insert 
AS 
insert into audit.[OrderedContactMechanism](
GO
CREATE TRIGGER [dbo].[trgOrderedContactMechanism_D]
ON [dbo].[OrderedContactMechanism] FOR delete 
AS 
insert into audit.[OrderedContactMechanism](