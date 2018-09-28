CREATE TABLE [dbo].[ExclusionIndividual] (
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
insert into audit.[ExclusionIndividual](	 [Exclusion_Id]	 ,[Individual_Id]	 ,AuditOperation) select 	 d.[Exclusion_Id]	 ,d.[Individual_Id],'O'  from 	 deleted d join inserted i on d.Exclusion_Id = i.Exclusion_Id	 and d.Individual_Id = i.Individual_Id 
insert into audit.[ExclusionIndividual](	 [Exclusion_Id]	 ,[Individual_Id]	 ,AuditOperation) select 	 i.[Exclusion_Id]	 ,i.[Individual_Id],'N'  from 	 deleted d join inserted i on d.Exclusion_Id = i.Exclusion_Id	 and d.Individual_Id = i.Individual_Id
GO
CREATE TRIGGER dbo.trgExclusionIndividual_I
ON dbo.[ExclusionIndividual] FOR insert 
AS 
insert into audit.[ExclusionIndividual](	 [Exclusion_Id]	 ,[Individual_Id]	 ,AuditOperation) select 	 i.[Exclusion_Id]	 ,i.[Individual_Id],'I' from inserted i
GO
CREATE TRIGGER dbo.trgExclusionIndividual_D
ON dbo.[ExclusionIndividual] FOR delete 
AS 
insert into audit.[ExclusionIndividual](	 [Exclusion_Id]	 ,[Individual_Id]	 ,AuditOperation) select 	 d.[Exclusion_Id]	 ,d.[Individual_Id],'D' from deleted d