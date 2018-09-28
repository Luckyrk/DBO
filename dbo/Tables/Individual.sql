CREATE TABLE [dbo].[Individual] (
    [GUIDReference]            UNIQUEIDENTIFIER NOT NULL,
    [PersonalIdentificationId] BIGINT           NULL,
    [Sex_Id]                   UNIQUEIDENTIFIER NOT NULL,
    [Referer]                  UNIQUEIDENTIFIER NULL,
    [Event_Id]                 UNIQUEIDENTIFIER NULL,
    [CharitySubscription_Id]   UNIQUEIDENTIFIER NULL,
    [Participant]              BIT              NOT NULL,
    [IndividualId]             NVARCHAR (30)    NULL,
    [CATI3DCode]               NVARCHAR (30)    NULL,
    [MainPostalAddress_Id]     UNIQUEIDENTIFIER NULL,
    [MainPhoneAddress_Id]      UNIQUEIDENTIFIER NULL,
    [MainEmailAddress_Id]      UNIQUEIDENTIFIER NULL,
    [CountryId]                UNIQUEIDENTIFIER NULL,
    [GPSUser]                  NVARCHAR (50)    DEFAULT ('DefaultGPSUser') NOT NULL,
    [CreationTimeStamp]        DATETIME         DEFAULT ('2012/01/01') NOT NULL,
    [GPSUpdateTimestamp]       DATETIME         DEFAULT ('2012/01/01') NOT NULL,
	[ReservedIndividualId]     NVARCHAR (30)    NULL,
	[IsAnonymized]			   BIT NOT NULL DEFAULT 0,
    CONSTRAINT [PK_dbo.Individual] PRIMARY KEY CLUSTERED ([GUIDReference] ASC),
    CONSTRAINT [FK_dbo.Individual_dbo.Address_MainEmailAddress_Id] FOREIGN KEY ([MainEmailAddress_Id]) REFERENCES [dbo].[Address] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Individual_dbo.Address_MainPhoneAddress_Id] FOREIGN KEY ([MainPhoneAddress_Id]) REFERENCES [dbo].[Address] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Individual_dbo.Address_MainPostalAddress_Id] FOREIGN KEY ([MainPostalAddress_Id]) REFERENCES [dbo].[Address] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Individual_dbo.CalendarEvent_Event_Id] FOREIGN KEY ([Event_Id]) REFERENCES [dbo].[CalendarEvent] ([Id]),
    CONSTRAINT [FK_dbo.Individual_dbo.Candidate_GUIDReference] FOREIGN KEY ([GUIDReference]) REFERENCES [dbo].[Candidate] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Individual_dbo.CharitySubscription_CharitySubscription_Id] FOREIGN KEY ([CharitySubscription_Id]) REFERENCES [dbo].[CharitySubscription] ([Id]),
    CONSTRAINT [FK_dbo.Individual_dbo.Individual_Referer] FOREIGN KEY ([Referer]) REFERENCES [dbo].[Individual] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Individual_dbo.IndividualSex_Sex_Id] FOREIGN KEY ([Sex_Id]) REFERENCES [dbo].[IndividualSex] ([GUIDReference]),
    CONSTRAINT [FK_dbo.Individual_dbo.PersonalIdentification_PersonalIdentificationId] FOREIGN KEY ([PersonalIdentificationId]) REFERENCES [dbo].[PersonalIdentification] ([PersonalIdentificationId])
);






GO
CREATE NONCLUSTERED INDEX [IX_GUIDReference]
    ON [dbo].[Individual]([GUIDReference] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_PersonalIdentificationId]
	ON [dbo].[Individual]([PersonalIdentificationId] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_Sex_Id]
    ON [dbo].[Individual]([Sex_Id] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_Referer]
    ON [dbo].[Individual]([Referer] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_Event_Id]
    ON [dbo].[Individual]([Event_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_CharitySubscription_Id]
    ON [dbo].[Individual]([CharitySubscription_Id] ASC);

GO
	CREATE NONCLUSTERED INDEX [IX_MainEmailAddress_Id]
    ON [dbo].[Individual]([MainEmailAddress_Id] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_MainPhoneAddress_Id]
    ON [dbo].[Individual]([MainPhoneAddress_Id] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_MainPostalAddress_Id]
    ON [dbo].[Individual]([MainPostalAddress_Id] ASC);

GO
CREATE TRIGGER [dbo].[trgIndividual_U] 
ON [dbo].[Individual] FOR update 
AS 
insert into audit.[Individual](
	 [GUIDReference]
	 ,[PersonalIdentificationId]
	 ,[Sex_Id]
	 ,[Referer]
	 ,[Event_Id]
	 ,[CharitySubscription_Id]
	 ,[Participant]
	 ,[IndividualId]
	 ,[CATI3DCode]
	 ,[MainEmailAddress_Id]
	 ,[MainPhoneAddress_Id]
	 ,[MainPostalAddress_Id]
	 ,[ReservedIndividualId]
	 ,AuditOperation,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) select 
	 d.[GUIDReference]
	 ,d.[PersonalIdentificationId]
	 ,d.[Sex_Id]
	 ,d.[Referer]
	 ,d.[Event_Id]
	 ,d.[CharitySubscription_Id]
	 ,d.[Participant]
	 ,d.[IndividualId]
	 ,d.[CATI3DCode]
	 ,d.[MainEmailAddress_Id]
	 ,d.[MainPhoneAddress_Id]
	 ,d.[MainPostalAddress_Id]	 
	 ,d.[ReservedIndividualId]
	 ,'O',d.GPSUser,d.GPSUpdateTimestamp,d.CreationTimeStamp  from 
	 deleted d join inserted i on d.GUIDReference = i.GUIDReference 
	 WHERE d.[GPSUser]<>'DefaultGPSUser'
insert into audit.[Individual](
	 [GUIDReference]
	 ,[PersonalIdentificationId]
	 ,[Sex_Id]
	 ,[Referer]
	 ,[Event_Id]
	 ,[CharitySubscription_Id]
	 ,[Participant]
	 ,[IndividualId]
	 ,[CATI3DCode]
	 ,[MainEmailAddress_Id]
	 ,[MainPhoneAddress_Id]
	 ,[MainPostalAddress_Id]
	 ,[ReservedIndividualId]
	 ,AuditOperation,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) select 
	 i.[GUIDReference]
	 ,i.[PersonalIdentificationId]
	 ,i.[Sex_Id]
	 ,i.[Referer]
	 ,i.[Event_Id]
	 ,i.[CharitySubscription_Id]
	 ,i.[Participant]
	 ,i.[IndividualId]
	 ,i.[CATI3DCode]
	 ,i.[MainEmailAddress_Id]
	 ,i.[MainPhoneAddress_Id]
	 ,i.[MainPostalAddress_Id]
	 ,i.[ReservedIndividualId]
	 ,'N',i.GPSUser,i.GPSUpdateTimestamp,i.CreationTimeStamp  from 
	 deleted d join inserted i on d.GUIDReference = i.GUIDReference
	 WHERE i.[GPSUser]<>'DefaultGPSUser'

UPDATE i1 SET i1.CreationTimeStamp=C.CreationTimeStamp,i1.GPSUpdateTimestamp=GETDATE(),i1.GPSUser=C.GPSUser
FROM
Individual i1
join Candidate c on c.GUIDReference=i1.GUIDReference
JOIN inserted i ON i.GUIDReference=i1.GUIDReference
JOIN deleted d ON d.GUIDReference = i.GUIDReference
GO
CREATE TRIGGER [dbo].[trgIndividual_I]
ON [dbo].[Individual] FOR insert 
AS 
insert into audit.[Individual](
	 [GUIDReference]
	 ,[PersonalIdentificationId]
	 ,[Sex_Id]
	 ,[Referer]
	 ,[Event_Id]
	 ,[CharitySubscription_Id]
	 ,[Participant]
	 ,[IndividualId]
	 ,[CATI3DCode]
	 ,[MainEmailAddress_Id]
	 ,[MainPhoneAddress_Id]
	 ,[MainPostalAddress_Id]
	 ,[ReservedIndividualId]
	 ,AuditOperation,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) select 
	 i.[GUIDReference]
	 ,i.[PersonalIdentificationId]
	 ,i.[Sex_Id]
	 ,i.[Referer]
	 ,i.[Event_Id]
	 ,i.[CharitySubscription_Id]
	 ,i.[Participant]
	 ,i.[IndividualId]
	 ,i.[CATI3DCode]
	 ,i.[MainEmailAddress_Id]
	 ,i.[MainPhoneAddress_Id]
	 ,i.[MainPostalAddress_Id]	 
	 ,i.[ReservedIndividualId]
	 ,'I',i.GPSUser,i.GPSUpdateTimestamp,i.CreationTimeStamp from inserted i
	 WHERE i.[GPSUser]<>'DefaultGPSUser'

UPDATE i1 SET i1.CreationTimeStamp=C.CreationTimeStamp,i1.GPSUpdateTimestamp=GETDATE(),i1.GPSUser=C.GPSUser
FROM
Individual i1
join Candidate c on c.GUIDReference=i1.GUIDReference
JOIN inserted i ON i.GUIDReference=i1.GUIDReference
GO
--individual
CREATE TRIGGER [dbo].[trgIndividual_D]
ON [dbo].[Individual] FOR delete 
AS 
insert into audit.[Individual](
	 [GUIDReference]
	 ,[PersonalIdentificationId]
	 ,[Sex_Id]
	 ,[Referer]
	 ,[Event_Id]
	 ,[CharitySubscription_Id]
	 ,[Participant]
	 ,[IndividualId]
	 ,[CATI3DCode]
	 ,[MainEmailAddress_Id]
	 ,[MainPhoneAddress_Id]
	 ,[MainPostalAddress_Id]
	 ,[ReservedIndividualId]
	 ,AuditOperation,GPSUser,GPSUpdateTimestamp,CreationTimeStamp) select 
	 d.[GUIDReference]
	 ,d.[PersonalIdentificationId]
	 ,d.[Sex_Id]
	 ,d.[Referer]
	 ,d.[Event_Id]
	 ,d.[CharitySubscription_Id]
	 ,d.[Participant]
	 ,d.[IndividualId]
	 ,d.[CATI3DCode]
	 ,d.[MainEmailAddress_Id]
	 ,d.[MainPhoneAddress_Id]
	 ,d.[MainPostalAddress_Id]
	 ,d.[ReservedIndividualId]
	 ,'D',d.GPSUser,d.GPSUpdateTimestamp,d.CreationTimeStamp from deleted d
	 WHERE d.[GPSUser]<>'DefaultGPSUser'

	UPDATE i1 SET i1.CreationTimeStamp=C.CreationTimeStamp,i1.GPSUpdateTimestamp=GETDATE(),i1.GPSUser=C.GPSUser
	FROM
	Individual i1
	join Candidate c on c.GUIDReference=i1.GUIDReference
	JOIN deleted i ON i.GUIDReference=i1.GUIDReference
GO
CREATE NONCLUSTERED INDEX [_dta_index_Individual_5_1035202788__K1_2_5_8_10_11_12]
    ON [dbo].[Individual]([GUIDReference] ASC)
    INCLUDE([PersonalIdentificationId], [Event_Id], [IndividualId], [MainPostalAddress_Id], [MainPhoneAddress_Id], [MainEmailAddress_Id]);


GO
CREATE STATISTICS [_dta_stat_1035202788_7_1]
    ON [dbo].[Individual]([Participant], [GUIDReference]);

