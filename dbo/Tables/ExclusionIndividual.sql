﻿CREATE TABLE [dbo].[ExclusionIndividual] (
    [Exclusion_Id]  UNIQUEIDENTIFIER NOT NULL,
    [Individual_Id] UNIQUEIDENTIFIER NOT NULL,
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.ExclusionIndividual] PRIMARY KEY CLUSTERED ([Exclusion_Id] ASC, [Individual_Id] ASC),
    CONSTRAINT [FK_dbo.ExclusionIndividual_dbo.Exclusion_Exclusion_Id] FOREIGN KEY ([Exclusion_Id]) REFERENCES [dbo].[Exclusion] ([GUIDReference]) ON DELETE CASCADE,
    CONSTRAINT [FK_dbo.ExclusionIndividual_dbo.Individual_Individual_Id] FOREIGN KEY ([Individual_Id]) REFERENCES [dbo].[Individual] ([GUIDReference]) ON DELETE CASCADE
);






GO
CREATE NONCLUSTERED INDEX [IX_Exclusion_Id]
    ON [dbo].[ExclusionIndividual]([Exclusion_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Individual_Id]
    ON [dbo].[ExclusionIndividual]([Individual_Id] ASC);


GO
CREATE TRIGGER dbo.trgExclusionIndividual_U 
ON dbo.[ExclusionIndividual] FOR update 
AS 
insert into audit.[ExclusionIndividual](
insert into audit.[ExclusionIndividual](
GO
CREATE TRIGGER dbo.trgExclusionIndividual_I
ON dbo.[ExclusionIndividual] FOR insert 
AS 
insert into audit.[ExclusionIndividual](
GO
CREATE TRIGGER dbo.trgExclusionIndividual_D
ON dbo.[ExclusionIndividual] FOR delete 
AS 
insert into audit.[ExclusionIndividual](