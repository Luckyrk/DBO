﻿CREATE TABLE [dbo].[Exclusion] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [Range_From]         DATETIME         NOT NULL,
    [Range_To]           DATETIME         NULL,
    [AllIndividuals]     BIT              NOT NULL,
    [AllPanels]          BIT              NOT NULL,
    [IsClosed]           BIT              NOT NULL,
    [GPSUser]            NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp] DATETIME         NULL,
    [CreationTimeStamp]  DATETIME         NULL,
    [Type_Id]            UNIQUEIDENTIFIER NOT NULL,
    [Parent_Id]          UNIQUEIDENTIFIER NOT NULL,
    CONSTRAINT [PK_dbo.Exclusion] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Exclusion_dbo.ExclusionType_Type_Id] FOREIGN KEY ([Type_Id]) REFERENCES [dbo].[ExclusionType] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Exclusion_dbo.Individual_Parent_Id] FOREIGN KEY ([Parent_Id]) REFERENCES [dbo].[Individual] ([GUIDReference])
);






GO
CREATE NONCLUSTERED INDEX [IX_Type_Id]
    ON [dbo].[Exclusion]([Type_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Parent_Id]
    ON [dbo].[Exclusion]([Parent_Id] ASC);


GO
CREATE TRIGGER dbo.trgExclusion_U 
ON dbo.[Exclusion] FOR update 
AS 
insert into audit.[Exclusion](
insert into audit.[Exclusion](
GO
CREATE TRIGGER dbo.trgExclusion_I
ON dbo.[Exclusion] FOR insert 
AS 
insert into audit.[Exclusion](
GO
CREATE TRIGGER dbo.trgExclusion_D
ON dbo.[Exclusion] FOR delete 
AS 
insert into audit.[Exclusion](