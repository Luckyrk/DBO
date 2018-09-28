CREATE PROCEDURE [dbo].[CreateorUpdate_AppUser_Level]
(
 @MorpheusDemographicType MorpheusDemographicType READONLY, 
 @pCountryCode NVARCHAR(300)
 ,@pMessageID UNIQUEIDENTIFIER 
 ,@pCultureCode INT
)
AS
BEGIN
 DECLARE @MprphesAppUserContext AS NVARCHAR(MAX) ='MorphesAppUserContext'
 DECLARE @pCountryId UNIQUEIDENTIFIER
 DECLARE @GPSUser VARCHAR(100) = 'MorpheusUser'
 SELECT  @pCountryId=CountryId FROM Country WHERE CountryISO2A=@pCountryCode

BEGIN TRANSACTION
BEGIN TRY

 DECLARE @GetDate	DATETIME

	IF (SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(),@pCountryId)) IS NOT NULL
	BEGIN
		SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(GETDATE(),@pCountryId))
	END
	ELSE
	BEGIN
		SET @GetDate = GETDATE()
	END

	IF EXISTS (SELECT 1 FROM 
	@MorpheusDemographicType D 
	LEFT JOIN Attribute A ON A.[Key]=D.AttributeKey
	WHERE A.GUIDReference IS NULL)
	BEGIN
		INSERT INTO [MorpheusErrorLog] ([MessageId],[ErrorMessage])
		SELECT @pMessageID,'Invalid Attribute keys '+ D.AttributeKey
		FROM 
		@MorpheusDemographicType D 
		LEFT JOIN Attribute A ON A.[Key]=D.AttributeKey
		WHERE A.GUIDReference IS NULL

		RAISERROR('Invalid Attribute keys ',16,1)
	END

	DECLARE @NamedAliasContextId UNIQUEIDENTIFIER
	SELECT @NamedAliasContextId=NamedAliasContextId FROM NamedAliasContext WHERE [Name]=@MprphesAppUserContext

	IF EXISTS(
	SELECT 1
	FROM @MorpheusDemographicType D 
	LEFT OUTER JOIN NamedAlias NA ON NA.[Key]=D.AppUserGUID AND AliasContext_Id=@NamedAliasContextId
	WHERE NA.NamedAliasId IS NULL 
	)
	BEGIN
		DECLARE @Msg NVARCHAR(MAX)
		SET @Msg='AppUserGUID NOT FOUND'
		RAISERROR(@Msg,16,1)
	END

 DECLARE @MorpheusLevelTest AS TABLE 
 (
	 AppUserGUID	NVARCHAR (300),
	 AttributeKey	NVARCHAR (300),
	 AttributeName  NVARCHAR (MAX),
	 AttributeValue  NVARCHAR (MAX),
	 CandidateId     UNIQUEIDENTIFIER,
	 AttributeId     UNIQUEIDENTIFIER,
	 DemographicType NVARCHAR (300)
 )


 

 INSERT INTO @MorpheusLevelTest(AppUserGUID,AttributeKey,AttributeName,AttributeValue,CandidateId,AttributeId,DemographicType)
 SELECT D.AppUserGUID,D.AttributeKey,D.AttributeName,
 (CASE WHEN A.[Type] = 'Boolean' THEN 
													(CASE UPPER(D.AttributeValue)
														WHEN 'YES' THEN '1'
														WHEN 'NO'  THEN '0'
														WHEN 'TRUE' THEN '1'
														WHEN 'FALSE' THEN '0' 
													ELSE D.AttributeValue END)
								ELSE D.AttributeValue
								END)
 ,NA.Candidate_Id,A.GUIDReference,A.[Type]
 FROM NamedAlias NA 
 INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
 INNER JOIN @MorpheusDemographicType D ON NA.[Key]=D.AppUserGUID
 INNER JOIN Attribute A ON A.[Key]=D.AttributeKey
 WHERE NAC.[Name]=@MprphesAppUserContext

	IF EXISTS (SELECT 1
	FROM  @MorpheusLevelTest D 
	INNER JOIN AttributeValue AV ON D.AttributeId=AV.DemographicId AND AV.CandidateId=D.CandidateId
	LEFT OUTER JOIN dbo.EnumDefinition ED ON ED.Demographic_Id = D.AttributeId AND ED.Value = D.AttributeValue COLLATE SQL_Latin1_General_CP1_CI_AI
	WHERE DemographicType = 'Enum')
	BEGIN
		INSERT INTO [MorpheusErrorLog] ([MessageId],[ErrorMessage])
		SELECT @pMessageID,'Enum definition not found for attribute key:'+ D.AttributeKey
		FROM  @MorpheusLevelTest D 
		INNER JOIN AttributeValue AV ON D.AttributeId=AV.DemographicId AND AV.CandidateId=D.CandidateId
		LEFT OUTER JOIN dbo.EnumDefinition ED ON ED.Demographic_Id = D.AttributeId AND ED.Value = D.AttributeValue COLLATE SQL_Latin1_General_CP1_CI_AI
		WHERE DemographicType = 'Enum'

		RAISERROR('Enum definition not found for attribute key:',16,1)
	END

	--IF EXISTS( SELECT 1 FROM [MorpheusErrorLog] WHERE [MessageId]=@pMessageID)
	--begin
	-- RETURN;
	--end


 UPDATE AV SET AV.Value= CASE WHEN DemographicType = 'Boolean'
									THEN 
										CASE UPPER(D.AttributeValue)
										WHEN 'YES'
											THEN '1'
										WHEN 'NO'
											THEN '0'
										WHEN 'TRUE'
											THEN '1'
										WHEN 'FALSE'
											THEN '0'
										ELSE D.AttributeValue
								END
								ELSE 
									D.AttributeValue
							END,
							AV.GPSUpdateTimestamp=@GetDate,AV.GPSUser=@GPSUser
						FROM  @MorpheusLevelTest D 					
						INNER JOIN AttributeValue AV ON D.AttributeId=AV.DemographicId AND AV.CandidateId=D.CandidateId 
						WHERE DemographicType <> 'Enum'

 UPDATE AV SET AV.Value= D.AttributeValue,AV.GPSUpdateTimestamp=@GetDate,AV.EnumDefinition_Id=ED.Id,AV.GPSUser=@GPSUser
 FROM  @MorpheusLevelTest D 
 INNER JOIN AttributeValue AV ON D.AttributeId=AV.DemographicId AND AV.CandidateId=D.CandidateId
 INNER JOIN dbo.EnumDefinition ED ON ED.Demographic_Id = D.AttributeId AND ED.Value = D.AttributeValue COLLATE SQL_Latin1_General_CP1_CI_AI
 WHERE DemographicType = 'Enum'

 INSERT INTO AttributeValue
 (
 GUIDReference,DemographicId,CandidateId,RespondentId,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Address_Id,[Value],
 [ValueDesc],Country_Id,[FreeText],[Discriminator],[EnumDefinition_Id]
 ) 					
 SELECT NEWID(),D.AttributeId,D.CandidateId,NULL,@GPSUser,@GetDate,@GetDate,NULL,D.AttributeValue,NULL,@pCountryId,NULL,
							(
							CASE WHEN D.DemographicType = 'String' THEN 'StringAttributeValue'
								 WHEN D.DemographicType = 'Int' THEN 'IntAttributeValue'
								 WHEN DemographicType = 'Float' THEN 'FloatAttributeValue'
								 WHEN LOWER(DemographicType) IN ('date','datetime') THEN 'DateAttributeValue'
								 WHEN DemographicType = 'Boolean' THEN 'BooleanAttributeValue'
							     WHEN DemographicType = 'Enum' THEN 'EnumAttributeValue'
							END) AS [Discriminator]
							,CASE 
								WHEN DemographicType <> 'Enum' THEN NULL
								WHEN DemographicType = 'Enum'
								THEN ( SELECT ed.ID FROM dbo.EnumDefinition ED 
								WHERE ED.Demographic_Id = D.AttributeId
								AND ED.Value = d.AttributeValue COLLATE SQL_Latin1_General_CP1_CI_AI) END [EnumDefinition_Id]
 FROM @MorpheusLevelTest D 
 WHERE NOT EXISTS
 (
  SELECT 1 FROM AttributeValue AV 
  WHERE D.AttributeId=AV.DemographicId AND AV.CandidateId=D.CandidateId 
 )

 COMMIT TRANSACTION
 END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE()
	ROLLBACK TRANSACTION
	INSERT INTO MorpheusErrorLog ([MessageId],[ErrorMessage]) VALUES (@pMessageID,ERROR_MESSAGE())

	DECLARE @ERROR_MESSAGE NVARCHAR(MAX)
	SET @ERROR_MESSAGE=ERROR_MESSAGE()
	RAISERROR(@ERROR_MESSAGE,16,1)
END CATCH
  
END