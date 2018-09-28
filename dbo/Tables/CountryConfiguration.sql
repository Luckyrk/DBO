CREATE TABLE [dbo].[CountryConfiguration] (
    [Id]                                UNIQUEIDENTIFIER NOT NULL,
    [BalanceLimit]                      INT              NULL,
    [BalanceWarning]                    INT              NULL,
    [GroupBusinessIdDigits]             INT              NOT NULL,
    [IndividualBusinessIdDigits]        INT              NOT NULL,
    [IndBusinessIdStartWith]            INT              NOT NULL,
    [SocialGradingActionTaskTypeId]                  UNIQUEIDENTIFIER CONSTRAINT [DF_CountryConfiguration_ActionTaskTypeId] DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    [GeographicAreaCalculation_Id]      UNIQUEIDENTIFIER NULL,
    [SocialGradingReview_Id]            UNIQUEIDENTIFIER NULL,
    [SocialGradingAttributeId]          UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    [SocialGradingCallActionTaskTypeId] UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    [SocialGradingLetterActionTaskTypeId] UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    [SocialGradingDiscussionActionTaskTypeId] UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    [IndividualConfigurationSet_Id]     UNIQUEIDENTIFIER NULL,
    [GroupConfigurationSet_Id]          UNIQUEIDENTIFIER NULL,
    [ShowCalendarFormatDates]           BIT              DEFAULT ((0)) NOT NULL,
	[IsPanelCalendarRequired]           BIT              DEFAULT ((0)) NOT NULL,
	[PostalAddressConfigurationSet_Id]   UNIQUEIDENTIFIER NULL,
    [HasPostalCodeAssociatedInformation] BIT DEFAULT ((0)) NOT NULL, 
    [PostalCodeAssociatedInformationUrl] NVARCHAR(512) NULL,	
    [CheckNewSignupActionTaskTypeId] UNIQUEIDENTIFIER NOT NULL DEFAULT ('00000000-0000-0000-0000-000000000000'),
    [CheckNewSignupCallRequiredActionTaskTypeId] UNIQUEIDENTIFIER NOT NULL DEFAULT ('00000000-0000-0000-0000-000000000000'),	 
    [CheckNewSignupRule_Id] UNIQUEIDENTIFIER NULL, 
    [TeenAccountAttributeId]          UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
	[TeenAccountReviewId]            UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    [TeenAccountCallActionTaskTypeId] UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    [TeenAccountLetterActionTaskTypeId] UNIQUEIDENTIFIER DEFAULT ('00000000-0000-0000-0000-000000000000') NOT NULL,
    [ReserveIdForDropAndRecreate] BIT NOT NULL DEFAULT 0, 
	[DiaryPointsLimitationDigits] INT NOT NULL DEFAULT 6, 
	[GPSUser]                NVARCHAR (50)    NULL,
    [GPSUpdateTimestamp]     DATETIME         NULL,
    [CreationTimeStamp]      DATETIME         NULL,
    CONSTRAINT [PK_dbo.CountryConfiguration] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.CountryConfiguration_dbo.BusinessRule_GeographicAreaCalculation_Id] FOREIGN KEY ([GeographicAreaCalculation_Id]) REFERENCES [dbo].[BusinessRule] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CountryConfiguration_dbo.BusinessRule_SocialGradingReview_Id] FOREIGN KEY ([SocialGradingReview_Id]) REFERENCES [dbo].[BusinessRule] ([GUIDReference]),
    CONSTRAINT [FK_dbo.CountryConfiguration_dbo.ConfigurationSet_GroupConfigurationSet_Id] FOREIGN KEY ([GroupConfigurationSet_Id]) REFERENCES [dbo].[ConfigurationSet] ([ConfigurationSetId]),
    CONSTRAINT [FK_dbo.CountryConfiguration_dbo.ConfigurationSet_IndividualConfigurationSet_Id] FOREIGN KEY ([IndividualConfigurationSet_Id]) REFERENCES [dbo].[ConfigurationSet] ([ConfigurationSetId]),
	CONSTRAINT [FK_dbo.CountryConfiguration_dbo.ConfigurationSet_PostalAddressConfigurationSet_Id] FOREIGN KEY ([PostalAddressConfigurationSet_Id]) REFERENCES [dbo].[ConfigurationSet] ([ConfigurationSetId])
);






GO

CREATE NONCLUSTERED INDEX [IX_GeographicAreaCalculation_Id]
    ON [dbo].[CountryConfiguration]([GeographicAreaCalculation_Id] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_GroupConfigurationSet_Id]
    ON [dbo].[CountryConfiguration]([GroupConfigurationSet_Id] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_IndividualConfigurationSet_Id]
    ON [dbo].[CountryConfiguration]([IndividualConfigurationSet_Id] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_PostalAddressConfigurationSet_Id]
    ON [dbo].[CountryConfiguration]([PostalAddressConfigurationSet_Id] ASC);
GO

CREATE NONCLUSTERED INDEX [IX_SocialGradingReview_Id]
    ON [dbo].[CountryConfiguration]([SocialGradingReview_Id] ASC);
GO

CREATE TRIGGER dbo.trgCountryConfiguration_U 
ON dbo.[CountryConfiguration] FOR update 
AS 
insert into audit.[CountryConfiguration](	 [Id]	 ,[BalanceLimit]	 ,[BalanceWarning]	 ,[GroupBusinessIdDigits]	 ,[IndividualBusinessIdDigits]	 ,[IndBusinessIdStartWith]	 ,[SocialGradingActionTaskTypeId]	 ,[GeographicAreaCalculation_Id]	 ,[SocialGradingReview_Id]	 ,[SocialGradingAttributeId]	 ,[SocialGradingCallActionTaskTypeId]	 ,[SocialGradingLetterActionTaskTypeId]	 ,[SocialGradingDiscussionActionTaskTypeId]	 ,[IndividualConfigurationSet_Id]	 ,[GroupConfigurationSet_Id]	 ,[ShowCalendarFormatDates]	 ,[IsPanelCalendarRequired]	 ,[PostalAddressConfigurationSet_Id]
     ,[HasPostalCodeAssociatedInformation]
     ,[PostalCodeAssociatedInformationUrl]	 ,[CheckNewSignupActionTaskTypeId]	 ,[CheckNewSignupCallRequiredActionTaskTypeId]	 ,[CheckNewSignupRule_Id]	 ,[TeenAccountAttributeId]	 ,[TeenAccountReviewId]	 ,[TeenAccountCallActionTaskTypeId]	 ,[TeenAccountLetterActionTaskTypeId]	 ,[ReserveIdForDropAndRecreate]	 ,[DiaryPointsLimitationDigits]	 ,AuditOperation) select 	 d.[Id]	 ,d.[BalanceLimit]	 ,d.[BalanceWarning]	 ,d.[GroupBusinessIdDigits]	 ,d.[IndividualBusinessIdDigits]	 ,d.[IndBusinessIdStartWith]	 ,d.[SocialGradingActionTaskTypeId]	 ,d.[GeographicAreaCalculation_Id]	 ,d.[SocialGradingReview_Id]	 ,d.[SocialGradingAttributeId]	 ,d.[SocialGradingCallActionTaskTypeId]	 ,d.[SocialGradingLetterActionTaskTypeId]	 ,d.[SocialGradingDiscussionActionTaskTypeId]	 ,d.[IndividualConfigurationSet_Id]	 ,d.[GroupConfigurationSet_Id]	 ,d.[ShowCalendarFormatDates]	 ,d.[IsPanelCalendarRequired]	 ,d.[PostalAddressConfigurationSet_Id]   
	 ,d.[HasPostalCodeAssociatedInformation] 	 ,d.[PostalCodeAssociatedInformationUrl]	 ,d.[CheckNewSignupActionTaskTypeId]	 ,d.[CheckNewSignupCallRequiredActionTaskTypeId]	 ,d.[CheckNewSignupRule_Id]	 ,d.[TeenAccountAttributeId]	 ,d.[TeenAccountReviewId]	 ,d.[TeenAccountCallActionTaskTypeId]	 ,d.[TeenAccountLetterActionTaskTypeId]	 	 ,d.[ReserveIdForDropAndRecreate]	 ,d.[DiaryPointsLimitationDigits]	 ,'O'  from 	 deleted d join inserted i on d.Id = i.Id 
insert into audit.[CountryConfiguration](	 [Id]	 ,[BalanceLimit]	 ,[BalanceWarning]	 ,[GroupBusinessIdDigits]	 ,[IndividualBusinessIdDigits]	 ,[IndBusinessIdStartWith]	 ,[SocialGradingActionTaskTypeId]	 ,[GeographicAreaCalculation_Id]	 ,[SocialGradingReview_Id]	 ,[SocialGradingAttributeId]	 ,[SocialGradingCallActionTaskTypeId]	 ,[SocialGradingLetterActionTaskTypeId]	 ,[SocialGradingDiscussionActionTaskTypeId]	 ,[IndividualConfigurationSet_Id]	 ,[GroupConfigurationSet_Id]	 ,[ShowCalendarFormatDates]	 ,[IsPanelCalendarRequired]	 ,[PostalAddressConfigurationSet_Id]
     ,[HasPostalCodeAssociatedInformation]
     ,[PostalCodeAssociatedInformationUrl]	 ,[CheckNewSignupActionTaskTypeId]	 ,[CheckNewSignupCallRequiredActionTaskTypeId]	 ,[CheckNewSignupRule_Id]	 ,[TeenAccountAttributeId]	 ,[TeenAccountReviewId]	 ,[TeenAccountCallActionTaskTypeId]	 ,[TeenAccountLetterActionTaskTypeId]	 ,[ReserveIdForDropAndRecreate]	 ,[DiaryPointsLimitationDigits]	 ,AuditOperation) select 	 i.[Id]	 ,i.[BalanceLimit]	 ,i.[BalanceWarning]	 ,i.[GroupBusinessIdDigits]	 ,i.[IndividualBusinessIdDigits]	 ,i.[IndBusinessIdStartWith]	 ,i.[SocialGradingActionTaskTypeId]	 ,i.[GeographicAreaCalculation_Id]	 ,i.[SocialGradingReview_Id]	 ,i.[SocialGradingAttributeId]	 ,i.[SocialGradingCallActionTaskTypeId]	 ,i.[SocialGradingLetterActionTaskTypeId]	 ,i.[SocialGradingDiscussionActionTaskTypeId]	 ,i.[IndividualConfigurationSet_Id]	 ,i.[GroupConfigurationSet_Id]	 ,i.[ShowCalendarFormatDates]	 ,i.[IsPanelCalendarRequired]	 ,i.[PostalAddressConfigurationSet_Id]   
	 ,i.[HasPostalCodeAssociatedInformation] 	 ,i.[PostalCodeAssociatedInformationUrl]	 ,i.[CheckNewSignupActionTaskTypeId]	 ,i.[CheckNewSignupCallRequiredActionTaskTypeId]	 ,i.[CheckNewSignupRule_Id]	 ,i.[TeenAccountAttributeId]	 ,i.[TeenAccountReviewId]	 ,i.[TeenAccountCallActionTaskTypeId]	 ,i.[TeenAccountLetterActionTaskTypeId]	 ,i.[ReserveIdForDropAndRecreate]	 ,i.[DiaryPointsLimitationDigits]	 ,'N'  from 	 deleted d join inserted i on d.Id = i.Id
GO
CREATE TRIGGER dbo.trgCountryConfiguration_I
ON dbo.[CountryConfiguration] FOR insert 
AS 
insert into audit.[CountryConfiguration](	 [Id]	 ,[BalanceLimit]	 ,[BalanceWarning]	 ,[GroupBusinessIdDigits]	 ,[IndividualBusinessIdDigits]	 ,[IndBusinessIdStartWith]	 ,[SocialGradingActionTaskTypeId]	 ,[GeographicAreaCalculation_Id]	 ,[SocialGradingReview_Id]	 ,[SocialGradingAttributeId]	 ,[SocialGradingCallActionTaskTypeId]	 ,[SocialGradingLetterActionTaskTypeId]	 ,[SocialGradingDiscussionActionTaskTypeId]	 ,[IndividualConfigurationSet_Id]	 ,[GroupConfigurationSet_Id]	 ,[ShowCalendarFormatDates]	 ,[IsPanelCalendarRequired]	 ,[PostalAddressConfigurationSet_Id]
     ,[HasPostalCodeAssociatedInformation]
     ,[PostalCodeAssociatedInformationUrl]	 ,[CheckNewSignupActionTaskTypeId]	 ,[CheckNewSignupCallRequiredActionTaskTypeId]	 ,[CheckNewSignupRule_Id]	 ,[TeenAccountAttributeId]	 ,[TeenAccountReviewId]	 ,[TeenAccountCallActionTaskTypeId]	 ,[TeenAccountLetterActionTaskTypeId]	 ,[ReserveIdForDropAndRecreate]	 ,[DiaryPointsLimitationDigits]	 ,AuditOperation) select 	 i.[Id]	 ,i.[BalanceLimit]	 ,i.[BalanceWarning]	 ,i.[GroupBusinessIdDigits]	 ,i.[IndividualBusinessIdDigits]	 ,i.[IndBusinessIdStartWith]	 ,i.[SocialGradingActionTaskTypeId]	 ,i.[GeographicAreaCalculation_Id]	 ,i.[SocialGradingReview_Id]	 ,i.[SocialGradingAttributeId]	 ,i.[SocialGradingCallActionTaskTypeId]	 ,i.[SocialGradingLetterActionTaskTypeId]	 ,i.[SocialGradingDiscussionActionTaskTypeId]	 ,i.[IndividualConfigurationSet_Id]	 ,i.[GroupConfigurationSet_Id]	 ,i.[ShowCalendarFormatDates]
	 ,i.[IsPanelCalendarRequired]
	 ,i.[PostalAddressConfigurationSet_Id]   
	 ,i.[HasPostalCodeAssociatedInformation] 	 ,i.[PostalCodeAssociatedInformationUrl]
	 ,i.[CheckNewSignupActionTaskTypeId]	 ,[CheckNewSignupCallRequiredActionTaskTypeId]	 ,i.[CheckNewSignupRule_Id]	 ,i.[TeenAccountAttributeId]	 ,i.[TeenAccountReviewId]	 ,i.[TeenAccountCallActionTaskTypeId]	 ,i.[TeenAccountLetterActionTaskTypeId]	 ,i.[ReserveIdForDropAndRecreate]
	 ,i.[DiaryPointsLimitationDigits]
	 ,'I' from inserted i
GO
CREATE TRIGGER dbo.trgCountryConfiguration_D
ON dbo.[CountryConfiguration] FOR delete 
AS 
insert into audit.[CountryConfiguration](	 [Id]	 ,[BalanceLimit]	 ,[BalanceWarning]	 ,[GroupBusinessIdDigits]	 ,[IndividualBusinessIdDigits]	 ,[IndBusinessIdStartWith]	 ,[SocialGradingActionTaskTypeId]	 ,[GeographicAreaCalculation_Id]	 ,[SocialGradingReview_Id]	 ,[SocialGradingAttributeId]	 ,[SocialGradingCallActionTaskTypeId]	 ,[SocialGradingLetterActionTaskTypeId]	 ,[SocialGradingDiscussionActionTaskTypeId]	 ,[IndividualConfigurationSet_Id]	 ,[GroupConfigurationSet_Id]	 ,[ShowCalendarFormatDates]	 ,[IsPanelCalendarRequired]	 ,[PostalAddressConfigurationSet_Id]   
	 ,[HasPostalCodeAssociatedInformation] 	 ,[PostalCodeAssociatedInformationUrl]	 ,[CheckNewSignupActionTaskTypeId]	 ,[CheckNewSignupCallRequiredActionTaskTypeId]	 ,[CheckNewSignupRule_Id]	 ,[TeenAccountAttributeId]	 ,[TeenAccountReviewId]	 ,[TeenAccountCallActionTaskTypeId]	 ,[TeenAccountLetterActionTaskTypeId]	 ,[ReserveIdForDropAndRecreate]	 ,[DiaryPointsLimitationDigits]	 ,AuditOperation) select 	 d.[Id]	 ,d.[BalanceLimit]	 ,d.[BalanceWarning]	 ,d.[GroupBusinessIdDigits]	 ,d.[IndividualBusinessIdDigits]	 ,d.[IndBusinessIdStartWith]	 ,d.[SocialGradingActionTaskTypeId]	 ,d.[GeographicAreaCalculation_Id]	 ,d.[SocialGradingReview_Id]	 ,d.[SocialGradingAttributeId]	 ,d.[SocialGradingCallActionTaskTypeId]	 ,d.[SocialGradingLetterActionTaskTypeId]	 ,d.[SocialGradingDiscussionActionTaskTypeId]	 ,d.[IndividualConfigurationSet_Id]	 ,d.[GroupConfigurationSet_Id]	 ,d.[ShowCalendarFormatDates]	 ,d.[IsPanelCalendarRequired]	 ,d.[PostalAddressConfigurationSet_Id]   
	 ,d.[HasPostalCodeAssociatedInformation] 	 ,d.[PostalCodeAssociatedInformationUrl]	 ,d.[CheckNewSignupActionTaskTypeId]	 ,d.[CheckNewSignupCallRequiredActionTaskTypeId]	 ,d.[CheckNewSignupRule_Id]	 ,d.[TeenAccountAttributeId]	 ,d.[TeenAccountReviewId]	 ,d.[TeenAccountCallActionTaskTypeId]	 ,d.[TeenAccountLetterActionTaskTypeId]	 ,d.[ReserveIdForDropAndRecreate]	 ,d.[DiaryPointsLimitationDigits]	 ,'D' from deleted d