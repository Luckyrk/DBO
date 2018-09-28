CREATE PROCEDURE [dbo].[NewMorpheusCommunications]
(
 @pAppUserGUID NVARCHAR(MAX),
 @pCommunicationDateTime DATETIME,
 @pCommunicationReasonCode INT,
 @pCommunicationDescription  NVARCHAR(MAX)=null,
 @CommunicationMethodCode INT,
 @CommunicationMethodDescription  NVARCHAR(MAX)=null,
 @CommunicationComments  NVARCHAR(MAX)=null,
 @pCountryCode NVARCHAR(300)
,@pMessageID UNIQUEIDENTIFIER 	
,@pCultureCode INT
)
AS
BEGIN
SET NOCOUNT ON;
DECLARE @CountryId UNIQUEIDENTIFIER,@CommunicationReasonId UNIQUEIDENTIFIER,
@CommunicationEventId UNIQUEIDENTIFIER,
@ContactMechanismTypeId UNIQUEIDENTIFIER,
@CandidateId UNIQUEIDENTIFIER

DECLARE @MorpheusApplicationUpdateTagTranslationId  uniqueIdentifier
DECLARE @MorpheusApplicationUpdateDescTranslationId uniqueIdentifier
DECLARE @MorpheusApplicationUpdateTypeTranslationId uniqueIdentifier
DECLARE @MorpheusCommsTagTranslationId  uniqueIdentifier
DECLARE @MorpheusCommsDescTranslationId uniqueIdentifier
DECLARE @MorpheusCommsTypeTranslationId uniqueIdentifier

DECLARE @GPSUser VARCHAR(100) = 'MorpheusUser'

DECLARE @GetDate				DATETIME
SELECT  @CountryId=CountryId FROM Country WHERE CountryISO2A=@pCountryCode


IF (SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(),@CountryId)) IS NOT NULL
BEGIN
	SET @GetDate = (SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(),@CountryId))
END
ELSE
BEGIN
	SET @GetDate=GETDATE()
END


DECLARE @MorphesAppUserContext AS NVARCHAR(MAX) ='MorphesAppUserContext'



BEGIN TRANSACTION
BEGIN TRY
IF NOT EXISTS( SELECT 1
 FROM NamedAlias NA 
 INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId AND NAC.[Name]=@MorphesAppUserContext 
 WHERE  NA.[Key]=@pAppUserGUID
)
 BEGIN
	DECLARE @Msg NVARCHAR(MAX)
				SET @Msg='AppUserGUID NOT FOUND'
			RAISERROR(@Msg,16,1)
 END
IF EXISTS (SELECT  1 FROM [CommunicationEventReasonType] WHERE Country_Id=@CountryId AND CommEventReasonCode=@pCommunicationReasonCode)
BEGIN
	
SELECT  @CommunicationReasonId=GUIDReference FROM [CommunicationEventReasonType] WHERE Country_Id=@CountryId AND CommEventReasonCode=@pCommunicationReasonCode
END
ELSE 
BEGIN
	
	declare @pCommunicationDescriptionKey varchar(100) = REPLACE(@pCommunicationDescription,' ','') + cast(@pCommunicationReasonCode as varchar(100)) ;

    SET @CommunicationReasonId=NEWID()
	if exists (select TranslationId from Translation where KeyName =(@pCommunicationDescriptionKey))
	BEGIN
		set @MorpheusCommsTagTranslationId = (select TranslationId from Translation where KeyName =@pCommunicationDescriptionKey)
	END
	ELSE 
	BEGIN 
		set @MorpheusCommsTagTranslationId = NEWID();
		Insert into Translation(TranslationId,KeyName,LastUpdateDate,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Discriminator) values 
		(@MorpheusCommsTagTranslationId, @pCommunicationDescriptionKey, @GetDate,@gpsuser,@GetDate,@GetDate,'BusinessTranslation' );
	
		Insert into TranslationTerm (GUIDReference, CultureCode, Value, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, Translation_Id) values
		(NEWID(), @pCultureCode, @pCommunicationDescription, @gpsUser, @GetDate, @GetDate, @MorpheusCommsTagTranslationId);
	END

	if exists (select TranslationId from Translation where KeyName =(REPLACE(@pCommunicationDescription,' ','')+'Desc'))
	BEGIN
		set @MorpheusCommsDescTranslationId = (select TranslationId from Translation where KeyName =(REPLACE(@pCommunicationDescription,' ','')+'Desc'))
	END
	ELSE 
	BEGIN 
		set @MorpheusCommsDescTranslationId = NEWID();
		Insert into Translation(TranslationId,KeyName,LastUpdateDate,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Discriminator) values 
		(@MorpheusCommsDescTranslationId, (REPLACE(@pCommunicationDescription,' ','')+'Desc'), @GetDate,@gpsuser,@GetDate,@GetDate,'BusinessTranslation' );
	
		Insert into TranslationTerm (GUIDReference, CultureCode, Value, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, Translation_Id) values
		(NEWID(), @pCultureCode, @pCommunicationDescription, @gpsUser, @GetDate, @GetDate, @MorpheusCommsDescTranslationId);
	END

	if exists (select TranslationId from Translation where KeyName =(REPLACE(@pCommunicationDescription,' ','')+'Type'))
	BEGIN
		set @MorpheusCommsTypeTranslationId = (select TranslationId from Translation where KeyName =(REPLACE(@pCommunicationDescription,' ','')+'Type'))
	END
	ELSE 
	BEGIN 
		set @MorpheusCommsTypeTranslationId = NEWID();
		Insert into Translation(TranslationId,KeyName,LastUpdateDate,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Discriminator) values 
		(@MorpheusCommsTypeTranslationId, (REPLACE(@pCommunicationDescription,' ','')+'Type'), @GetDate,@gpsuser,@GetDate,@GetDate,'SystemTranslation' );
	
		Insert into TranslationTerm (GUIDReference, CultureCode, Value, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, Translation_Id) values
		(NEWID(), @pCultureCode, @pCommunicationDescription, @gpsUser, @GetDate, @GetDate, @MorpheusCommsTypeTranslationId);
	END

	SET IDENTITY_INSERT [CommunicationEventReasonType] ON

	INSERT INTO [CommunicationEventReasonType](
	GUIDReference,CommEventReasonCode,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,RelatedActionType_Id,TagTranslation_Id,DescriptionTranslation_Id,
	TypeTranslation_Id,Country_Id,IsDealtByCommunicationTeam,IsClosed,IsForFqs,PanelRestriction_Id,FqsUrl
	)
	VALUES
	(@CommunicationReasonId,@pCommunicationReasonCode,@gpsUser,@GetDate,@GetDate,NULL,@MorpheusCommsTagTranslationId,@MorpheusCommsDescTranslationId,@MorpheusCommsTypeTranslationId,
	@CountryId,0,0,0,NULL,NULL)

	SET IDENTITY_INSERT [CommunicationEventReasonType] OFF

END


IF EXISTS (SELECT GUIDReference  FROM ContactMechanismType WHERE  Country_Id=@CountryId AND  ContactMechanismCode=@CommunicationMethodCode )
BEGIN
	
	SELECT @ContactMechanismTypeId=GUIDReference  FROM ContactMechanismType WHERE  Country_Id=@CountryId AND  ContactMechanismCode=@CommunicationMethodCode 
END
ELSE
BEGIN

	declare @CommunicationMethodDescriptionKey nvarchar(max) = REPLACE(@CommunicationMethodDescription,' ','') + cast(@CommunicationMethodCode  as varchar(10))

	if EXISTS (select TranslationId from Translation where KeyName =@CommunicationMethodDescriptionKey)
	BEGIN
		SET @MorpheusApplicationUpdateTagTranslationId = (select TranslationId from Translation where KeyName =@CommunicationMethodDescriptionKey)
	END
	ELSE 
	BEGIN 
		SET @MorpheusApplicationUpdateTagTranslationId = NEWID();
		INSERT INTO Translation(TranslationId,KeyName,LastUpdateDate,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Discriminator) values 
		(@MorpheusApplicationUpdateTagTranslationId, @CommunicationMethodDescriptionKey, @GetDate,@gpsuser,@GetDate,@GetDate,'BusinessTranslation' );
	
		INSERT INTO TranslationTerm (GUIDReference, CultureCode, Value, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, Translation_Id) values
		(NEWID(), @pCultureCode, @CommunicationMethodDescription, @gpsUser, @GetDate,@GetDate, @MorpheusApplicationUpdateTagTranslationId);
	END 

	IF EXISTS (SELECT TranslationId FROM Translation WHERE KeyName =(REPLACE(@CommunicationMethodDescription,' ','')+'Desc'))
	BEGIN
		SET @MorpheusApplicationUpdateDescTranslationId = (SELECT TranslationId FROM Translation WHERE KeyName =(REPLACE(@CommunicationMethodDescription,' ','')+'Desc'))
	END
	ELSE 
	BEGIN 
		set @MorpheusApplicationUpdateDescTranslationId = newID();
		Insert into Translation(TranslationId,KeyName,LastUpdateDate,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Discriminator) values 
		(@MorpheusApplicationUpdateDescTranslationId, (REPLACE(@CommunicationMethodDescription,' ','')+'Desc'), @GetDate,@gpsuser,@GetDate,@GetDate,'BusinessTranslation' );
	
		Insert into TranslationTerm (GUIDReference, CultureCode, Value, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, Translation_Id) values
		(NEWID(), @pCultureCode, @CommunicationMethodDescription, @gpsUser, @GetDate, @GetDate, @MorpheusApplicationUpdateDescTranslationId);
	END 
	if exists (select TranslationId from Translation where KeyName =(REPLACE(@CommunicationMethodDescription,' ','')+'OtherContactType'))
	BEGIN
		set @MorpheusApplicationUpdateTypeTranslationId = (select TranslationId from Translation where KeyName =(REPLACE(@CommunicationMethodDescription,' ','')+'OtherContactType'))
	END
	ELSE 
	BEGIN 
		set @MorpheusApplicationUpdateTypeTranslationId = NEWID();
		Insert into Translation(TranslationId,KeyName,LastUpdateDate,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Discriminator) values 
		(@MorpheusApplicationUpdateTypeTranslationId, (REPLACE(@CommunicationMethodDescription,' ','')+'OtherContactType'), @GetDate,@gpsuser,@GetDate,@GetDate,'SystemTranslation' );
	
		Insert into TranslationTerm (GUIDReference, CultureCode, Value, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, Translation_Id) values
		(NEWID(), @pCultureCode, @CommunicationMethodDescription, @gpsUser, @GetDate, @GetDate, @MorpheusApplicationUpdateTypeTranslationId);
	END
	
	SET @ContactMechanismTypeId= NEWID()
	SET IDENTITY_INSERT [ContactMechanismType] ON
	INSERT INTO ContactMechanismType(GUIDReference,ContactMechanismCode,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,TagTranslation_Id,DescriptionTranslation_Id,TypeTranslation_Id,Country_Id,[Types]) 
	VALUES (@ContactMechanismTypeId,@CommunicationMethodCode,@gpsUser, @GetDate,@GetDate,@MorpheusApplicationUpdateTagTranslationId,@MorpheusApplicationUpdateDescTranslationId,@MorpheusApplicationUpdateTypeTranslationId,@countryId,'Other')
	SET IDENTITY_INSERT [ContactMechanismType] OFF
END

SET @CommunicationEventId=NEWID()

--IF NOT EXISTS (SELECT  1
--FROM [CommunicationEventReasonType] 
--WHERE Country_Id=@CountryId AND CommEventReasonCode=@pCommunicationReasonCode)
--BEGIN
--	INSERT INTO [MorpheusErrorLog] ([MessageId],[ErrorMessage])
--	SELECT @pMessageID,'Communication Reason Code not found'+cast(@pCommunicationReasonCode as varchar(200))
--END



SELECT @CandidateId=C.GroupContact_Id
FROM NamedAlias NA 
INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
WHERE NAC.[Name]=@MorphesAppUserContext AND NA.[Key]=@pAppUserGUID

INSERT INTO CommunicationEvent 
(GUIDReference,CreationDate,Incoming,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,[State],CallLength,ContactMechanism_Id,Country_Id,Candidate_Id)
SELECT @CommunicationEventId,
CASE WHEN @pCommunicationDateTime IS NOT NULL THEN DATEADD(day,0,@pCommunicationDateTime) ELSE @pCommunicationDateTime END,0,@GPSUser,GETDATE(),GETDATE(),2,CAST('00:00' as TIME),@ContactMechanismTypeId,@CountryId,@CandidateId


INSERT INTO CommunicationEventReason (GUIDReference,Comment,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,ReasonType_Id,Country_Id,communication_Id,panel_id) 
VALUES (NEWID(),@CommunicationComments,@GPSUser,@GetDate,(IIF(@pCommunicationDateTime IS NOT NULL,DATEADD(day,0,@pCommunicationDateTime),@pCommunicationDateTime)),@CommunicationReasonId,@CountryId,@CommunicationEventId,null)

DECLARE @ActionTaskType_Id UNIQUEIDENTIFIER

IF EXISTS (SELECT 1 FROM CommunicationEventReasonTypeActionTaskType WHERE CommunicationEventReasonType_Id=@CommunicationReasonId)
BEGIN
	
	SELECT @ActionTaskType_Id=ActionTaskType_Id FROM CommunicationEventReasonTypeActionTaskType WHERE CommunicationEventReasonType_Id=@CommunicationReasonId

	INSERT INTO ActionTask
	(GUIDReference,StartDate,EndDate,CompletionDate,ActionComment,InternalOrExternal,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,[State],
	CommunicationCompletion_Id,ActionTaskType_Id,Country_Id,Candidate_Id,FormId,Assignee_Id,Panel_Id)
	VALUES
	(NEWID(),@GetDate,@GetDate,NULL,'',0,@GPSUser,@GetDate,@GetDate,1,@CommunicationEventId,@ActionTaskType_Id,@CountryId,@CandidateId,NULL,NULL,NULL)
END

COMMIT TRANSACTION
END TRY
BEGIN CATCH
	print error_line();
 ROLLBACK TRANSACTION
 INSERT INTO MorpheusErrorLog ([MessageId],[ErrorMessage]) VALUES (@pMessageID,ERROR_MESSAGE())

 DECLARE @ERROR_MESSAGE NVARCHAR(MAX)
 SET @ERROR_MESSAGE=ERROR_MESSAGE()
 RAISERROR(@ERROR_MESSAGE,16,1)
END CATCH 
END
