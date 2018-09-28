CREATE TABLE [dbo].[Collective] (
    [GUIDReference]      UNIQUEIDENTIFIER NOT NULL,
    [TypeTranslation_Id] UNIQUEIDENTIFIER NOT NULL,
    [Sequence]           INT              NOT NULL,
    [DiscriminatorType]  NVARCHAR (128)   NOT NULL,
    [GroupContact_Id]    UNIQUEIDENTIFIER NULL,
    [IsDuplicate]        BIT              NULL,
    [CountryId]          UNIQUEIDENTIFIER NULL,
	[ReservedSequence]	 INT			  NULL,
	[Interviewer_Id]     UNIQUEIDENTIFIER NULL,
    [GPSUser]            NVARCHAR (50)    DEFAULT ('DefaultGPSUser') NOT NULL,
    [CreationTimeStamp]  DATETIME         DEFAULT ('2012/01/01') NOT NULL,
    [GPSUpdateTimestamp] DATETIME         DEFAULT ('2012/01/01') NOT NULL,
	[OldGroupId]         INT              NULL,
    CONSTRAINT [PK_dbo.Collective] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Collective_dbo.Candidate_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[Candidate] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Collective_dbo.Individual_GroupContact_Id] FOREIGN KEY ([GroupContact_Id]) REFERENCES [dbo].[Individual] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Collective_dbo.Translation_TypeTranslation_Id] FOREIGN KEY ([TypeTranslation_Id]) REFERENCES [dbo].[Translation] ([TranslationId])
);





GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[Collective]([GUIDReference] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_TypeTranslation_Id]
    ON [dbo].[Collective]([TypeTranslation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_GroupContact_Id]
    ON [dbo].[Collective]([GroupContact_Id] ASC);


GO
CREATE TRIGGER [dbo].[trgCollective_U] 
ON [dbo].[Collective] FOR update 
AS 
insert into audit.[Collective](
	 [GUIDReference]
	 ,[TypeTranslation_Id]
	 ,[Sequence]
	 ,[DiscriminatorType]
	 ,[GroupContact_Id]
	 ,[ReservedSequence]
	 ,[CreationTimeStamp],[GPSUpdateTimestamp],[GPSUser]
	 ,AuditOperation) select 
	 d.[GUIDReference]
	 ,d.[TypeTranslation_Id]
	 ,d.[Sequence]
	 ,d.[DiscriminatorType]
	 ,d.[GroupContact_Id]
	 ,d.[ReservedSequence]
	 ,d.[CreationTimeStamp],d.[GPSUpdateTimestamp],d.[GPSUser]
	 ,'O'  from 
	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
	 WHERE d.[GPSUser]<>'DefaultGPSUser'
insert into audit.[Collective](
	 [GUIDReference]
	 ,[TypeTranslation_Id]
	 ,[Sequence]
	 ,[DiscriminatorType]
	 ,[GroupContact_Id]
	 ,[ReservedSequence]
	 ,[CreationTimeStamp],[GPSUpdateTimestamp],[GPSUser]
	 ,AuditOperation) select 
	 i.[GUIDReference]
	 ,i.[TypeTranslation_Id]
	 ,i.[Sequence]
	 ,i.[DiscriminatorType]
	 ,i.[GroupContact_Id]	 
	 ,i.[ReservedSequence]
	 ,i.[CreationTimeStamp],i.[GPSUpdateTimestamp],i.[GPSUser]
	 ,'N'  from 
	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
	 WHERE i.[GPSUser]<>'DefaultGPSUser'

UPDATE i1 SET i1.CreationTimeStamp=C.CreationTimeStamp,i1.GPSUpdateTimestamp=GETDATE(),i1.GPSUser=C.GPSUser
FROM
Collective i1
join Candidate c on c.GUIDReference=i1.GUIDReference
JOIN inserted i ON i.GUIDReference=i1.GUIDReference
JOIN deleted d ON d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER [dbo].[trgCollective_I]
ON [dbo].[Collective] FOR insert 
AS 
begin
insert into audit.[Collective](
	 [GUIDReference]
	 ,[TypeTranslation_Id]
	 ,[Sequence]
	 ,[DiscriminatorType]
	 ,[GroupContact_Id]
	 ,[ReservedSequence]
	 ,[CreationTimeStamp],[GPSUpdateTimestamp],[GPSUser]
	 ,AuditOperation) select 
	 i.[GUIDReference]
	 ,i.[TypeTranslation_Id]
	 ,i.[Sequence]
	 ,i.[DiscriminatorType]
	 ,i.[GroupContact_Id]	 
	 ,i.[ReservedSequence]
	 ,i.[CreationTimeStamp],i.[GPSUpdateTimestamp],i.[GPSUser]
	 ,'I' from inserted i
	

UPDATE i1 SET i1.CreationTimeStamp=C.CreationTimeStamp,i1.GPSUpdateTimestamp=GETDATE(),i1.GPSUser=C.GPSUser
	FROM
	Collective i1
	join Candidate c on c.GUIDReference=i1.GUIDReference
	JOIN inserted i ON i.GUIDReference=i1.GUIDReference
end
GO

--Collective
CREATE TRIGGER [dbo].[trgCollective_D]
ON [dbo].[Collective] FOR delete 
AS 
insert into audit.[Collective](
	 [GUIDReference]
	 ,[TypeTranslation_Id]
	 ,[Sequence]
	 ,[DiscriminatorType]
	 ,[GroupContact_Id]
	 ,[ReservedSequence]
	 ,[CreationTimeStamp],[GPSUpdateTimestamp],[GPSUser]
	 ,AuditOperation) select 
	 d.[GUIDReference]
	 ,d.[TypeTranslation_Id]
	 ,d.[Sequence]
	 ,d.[DiscriminatorType]
	 ,d.[GroupContact_Id]
	 ,d.[ReservedSequence]
	 ,d.[CreationTimeStamp],d.[GPSUpdateTimestamp],d.[GPSUser]
	 ,'D' from deleted d
	 WHERE d.[GPSUser]<>'DefaultGPSUser'

	UPDATE i1 SET i1.CreationTimeStamp=C.CreationTimeStamp,i1.GPSUpdateTimestamp=GETDATE(),i1.GPSUser=C.GPSUser
	FROM
	Collective i1
	join Candidate c on c.GUIDReference=i1.GUIDReference
	JOIN deleted i ON i.GUIDReference=i1.GUIDReference
GO
CREATE NONCLUSTERED INDEX [idx_Collective_CountryId]
    ON [dbo].[Collective]([CountryId] ASC);


GO
CREATE NONCLUSTERED INDEX [_dta_index_Collective_5_622625261__K4_K1_K7]
    ON [dbo].[Collective]([DiscriminatorType] ASC, [GUIDReference] ASC, [GroupContact_Id] ASC);


GO
CREATE STATISTICS [_dta_stat_622625261_7_4_1_2]
    ON [dbo].[Collective]([GroupContact_Id], [DiscriminatorType], [GUIDReference], [TypeTranslation_Id]);


GO
CREATE STATISTICS [_dta_stat_622625261_4_1_2]
    ON [dbo].[Collective]([DiscriminatorType], [GUIDReference], [TypeTranslation_Id]);


GO
CREATE STATISTICS [_dta_stat_622625261_3_1_4]
    ON [dbo].[Collective]([Sequence], [GUIDReference], [DiscriminatorType]);


GO
CREATE STATISTICS [_dta_stat_622625261_2_4]
    ON [dbo].[Collective]([TypeTranslation_Id], [DiscriminatorType]);


GO
CREATE STATISTICS [_dta_stat_622625261_1_2_7]
    ON [dbo].[Collective]([GUIDReference], [TypeTranslation_Id], [GroupContact_Id]);

