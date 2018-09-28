CREATE PROCEDURE [dbo].[GetCommunicationReasonTypeId]
	@pCountryID UNIQUEIDENTIFIER
	,@pUsername VARCHAR(50)
	,@pCommunicationReasonTypeId UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
BEGIN TRY
	DECLARE @ReasonTypeId UNIQUEIDENTIFIER
		,@TranslationId_Diarymanagement UNIQUEIDENTIFIER
		,@TranslationId_DescDiarymanagement UNIQUEIDENTIFIER

		DECLARE @GetDate DATETIME
	SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryID))

	SET @TranslationId_Diarymanagement = (
			SELECT TranslationId
			FROM Translation
			WHERE [KeyName] = N'Diarymanagement'
				AND [Discriminator] = 'BusinessTranslation'
			)

	IF @TranslationId_Diarymanagement IS NULL
	BEGIN
		INSERT [dbo].[Translation] (
			[TranslationId]
			,[KeyName]
			,[LastUpdateDate]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Discriminator]
			)
		VALUES (
			NEWID()
			,N'Diarymanagement'
			,@GetDate
			,@pUsername
			,@GetDate
			,@GetDate
			,N'BusinessTranslation'
			)

		SET @TranslationId_Diarymanagement = (
				SELECT TranslationId
				FROM Translation
				WHERE [KeyName] = N'Diarymanagement'
				)
	END

	IF NOT EXISTS (
			SELECT 1
			FROM TranslationTerm
			WHERE Translation_Id = @TranslationId_Diarymanagement
				AND CultureCode = 2057
			)
		INSERT [dbo].[TranslationTerm] (
			[GUIDReference]
			,[CultureCode]
			,[Value]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Translation_Id]
			)
		VALUES (
			NEWID()
			,2057
			,N'Diary Management'
			,@pUsername
			,@GetDate
			,@GetDate
			,@TranslationId_Diarymanagement
			)

	IF NOT EXISTS (
			SELECT 1
			FROM TranslationTerm
			WHERE Translation_Id = @TranslationId_Diarymanagement
				AND CultureCode = 1028
			)
		INSERT [dbo].[TranslationTerm] (
			[GUIDReference]
			,[CultureCode]
			,[Value]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Translation_Id]
			)
		VALUES (
			NEWID()
			,1028
			,N'日記管理'
			,@pUsername
			,@GetDate
			,@GetDate
			,@TranslationId_Diarymanagement
			)

	IF NOT EXISTS (
			SELECT 1
			FROM TranslationTerm
			WHERE Translation_Id = @TranslationId_Diarymanagement
				AND CultureCode = 1036
			)
		INSERT [dbo].[TranslationTerm] (
			[GUIDReference]
			,[CultureCode]
			,[Value]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Translation_Id]
			)
		VALUES (
			NEWID()
			,1036
			,N'gestion Diary'
			,@pUsername
			,@GetDate
			,@GetDate
			,@TranslationId_Diarymanagement
			)

	SET @TranslationId_DescDiarymanagement = (
			SELECT TranslationId
			FROM Translation
			WHERE [KeyName] = N'DescDiarymanagement'
			)

	IF @TranslationId_DescDiarymanagement IS NULL
	BEGIN
		INSERT [dbo].[Translation] (
			[TranslationId]
			,[KeyName]
			,[LastUpdateDate]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Discriminator]
			)
		VALUES (
			NEWID()
			,N'DescDiarymanagement'
			,@GetDate
			,@pUsername
			,@GetDate
			,@GetDate
			,N'BusinessTranslation'
			)

		SET @TranslationId_DescDiarymanagement = (
				SELECT TranslationId
				FROM Translation
				WHERE [KeyName] = N'DescDiarymanagement'
				)
	END

	IF NOT EXISTS (
			SELECT 1
			FROM TranslationTerm
			WHERE Translation_Id = @TranslationId_DescDiarymanagement
				AND CultureCode = 2057
			)
		INSERT [dbo].[TranslationTerm] (
			[GUIDReference]
			,[CultureCode]
			,[Value]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Translation_Id]
			)
		VALUES (
			NEWID()
			,2057
			,N'Diary Management'
			,@pUsername
			,@GetDate
			,@GetDate
			,@TranslationId_DescDiarymanagement
			)

	IF NOT EXISTS (
			SELECT 1
			FROM TranslationTerm
			WHERE Translation_Id = @TranslationId_DescDiarymanagement
				AND CultureCode = 1028
			)
		INSERT [dbo].[TranslationTerm] (
			[GUIDReference]
			,[CultureCode]
			,[Value]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Translation_Id]
			)
		VALUES (
			NEWID()
			,1028
			,N'日記管理'
			,@pUsername
			,@GetDate
			,@GetDate
			,@TranslationId_DescDiarymanagement
			)

	IF NOT EXISTS (
			SELECT 1
			FROM TranslationTerm
			WHERE Translation_Id = @TranslationId_DescDiarymanagement
				AND CultureCode = 1036
			)
		INSERT [dbo].[TranslationTerm] (
			[GUIDReference]
			,[CultureCode]
			,[Value]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[Translation_Id]
			)
		VALUES (
			NEWID()
			,1036
			,N'gestion Diary'
			,@pUsername
			,@GetDate
			,@GetDate
			,@TranslationId_DescDiarymanagement
			)

	IF NOT EXISTS (
			SELECT 1
			FROM CommunicationEventReasonType
			WHERE TagTranslation_Id = @TranslationId_Diarymanagement
				AND DescriptionTranslation_Id = @TranslationId_DescDiarymanagement
				AND Country_Id = @pCountryID
			)
		INSERT [dbo].[CommunicationEventReasonType] (
			[GUIDReference]
			,[IsClosed]
			,[IsDealtByCommunicationTeam]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,[RelatedActionType_Id]
			,[TagTranslation_Id]
			,[DescriptionTranslation_Id]
			,[TypeTranslation_Id]
			,[Country_Id]
			)
		VALUES (
			NEWID()
			,0
			,1
			,@pUsername
			,@GetDate
			,@GetDate
			,NULL
			,@TranslationId_Diarymanagement
			,@TranslationId_DescDiarymanagement
			,NULL
			,@pCountryID
			)

	SELECT @pCommunicationReasonTypeId = GUIDReference
	FROM CommunicationEventReasonType
	WHERE Country_Id = @pCountryID
		AND TagTranslation_Id IN (
			SELECT TranslationId
			FROM Translation
			WHERE KeyName = 'Diarymanagement'
			)
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH
END
