/*##########################################################################

-- Name				: CreateFromCloseAction

-- Date             : 2015-04-26

-- Author           : 

-- Purpose          : 

-- Usage            : 

-- Impact           : 

-- Required grants  : 

-- Called by        : 

-- PARAM Definitions

       @pCandidateId UNIQUEIDENTIFIER 

       @pAssigneeName VARCHAR(50)  

	   @pActionComment VARCHAR(50)

	   @pCountryId UNIQUEIDENTIFIER

	   @pFromId UNIQUEIDENTIFIER

-- Sample Execution :

		exec CreateFromCloseAction '46DA6EA7-09B9-C8B8-FE31-08D24C0DD6E3','testuser','Formsaved','46DA6EA7-09B9-C8B8-FE31-08D24C0DD6E3'

##########################################################################

-- version  user						date        change 

-- 1.0  Jagadeesh Boddu				  2015-04-26   Initial

##########################################################################*/

CREATE PROCEDURE [dbo].[CreateFromCloseAction] (

	@pCandidateId UNIQUEIDENTIFIER

	,@pAssigneeName VARCHAR(50)

	,@pActionComment VARCHAR(50)

	,@pCountryId UNIQUEIDENTIFIER

	,@pFromId UNIQUEIDENTIFIER = NULL

	)

AS

BEGIN

	SET NOCOUNT ON
BEGIN TRY 


	DECLARE @ActiontaskId UNIQUEIDENTIFIER = newid();

	DECLARE @countryid UNIQUEIDENTIFIER;

	DECLARE @TypeTranslationid UNIQUEIDENTIFIER;

	DECLARE @TranslaionIds UNIQUEIDENTIFIER;

	DECLARE @AssigneeId UNIQUEIDENTIFIER;

	DECLARE @GUIDRefActionTask UNIQUEIDENTIFIER;

	DECLARE @getdate DATETIME 

	DECLARE @TranslationKeyName NVARCHAR(256)

	DECLARE @FieldConfigurationKeyName NVARCHAR(256)

	SET @getdate = (select dbo.GetLocalDateTimeByCountryId(GETDATE(),@pCountryId))

	SET @AssigneeId = (

			SELECT TOP 1 Id

			FROM IdentityUser

			WHERE UserName = @pAssigneeName AND Country_Id=@pCountryId

			)



	IF @pFromId = '00000000-0000-0000-0000-000000000000'

		SET @pFromId = NULL



	IF @pFromId IS NOT NULL

	BEGIN

		SET @TranslationKeyName = 'FormSubmited'

		SET @FieldConfigurationKeyName = 'FromSavedChanges:ActionCreation'

	END

	ELSE

	BEGIN

		SET @TranslationKeyName = 'TitleChanged'

		SET @FieldConfigurationKeyName = 'TitlecardChanges:ActionCreation'

		SET @pActionComment = 'A change in the name has occurred'

	END



	SET @TranslaionIds = (

			SELECT TOP 1 TranslationId

			FROM Translation

			WHERE KeyName = @TranslationKeyName

			)

	SET @TypeTranslationid = (

			SELECT TOP 1 TranslationId

			FROM Translation

			WHERE KeyName = 'DealtByCommunicationTeamActionTaskTypeTypeDescriptor'

			)

	SET @GUIDRefActionTask = (

			SELECT TOP 1 GUIDReference

			FROM ActionTaskType axc

			WHERE TagTranslation_Id = @TranslaionIds

				AND axc.Country_Id = @pCountryId

			)



	IF (

			@pCountryId IN (

				SELECT C.CountryId

				FROM FieldConfiguration FC

				INNER JOIN Country C ON C.Configuration_Id = FC.CountryConfiguration_Id

				WHERE [Key] = @FieldConfigurationKeyName

					AND [Visible] = 1

				)

			)

	BEGIN

		IF NOT EXISTS (

				SELECT 1

				FROM ActionTaskType

				WHERE [TagTranslation_Id] = @TranslaionIds

					AND [Country_Id] = @pCountryId

				)

		BEGIN

			INSERT INTO [dbo].[ActionTaskType] (

				[GUIDReference]

				,[IsForDpa]

				,[IsForFqs]

				,[GPSUser]

				,[GPSUpdateTimestamp]

				,[CreationTimeStamp]

				,[Duration]

				,[TagTranslation_Id]

				,[DescriptionTranslation_Id]

				,[TypeTranslation_Id]

				,[Country_Id]

				,[Type]

				,[IsClosed]

				)

			VALUES (

				NEWID()

				,0

				,0

				,@pAssigneeName

				,@getdate

				,@getdate

				,NULL

				,@TranslaionIds

				,@TranslaionIds

				,@TypeTranslationid

				,@pCountryId

				,'DealtByCommunicationTeam'

				,0

				)

		END



		IF (@GUIDRefActionTask IS NOT NULL)

		BEGIN

			INSERT INTO [dbo].[ActionTask] (

				[GUIDReference]

				,[StartDate]

				,[EndDate]

				,[CompletionDate]

				,[ActionComment]

				,[InternalOrExternal]

				,[GPSUser]

				,[GPSUpdateTimestamp]

				,[CreationTimeStamp]

				,[State]

				,[CommunicationCompletion_Id]

				,[ActionTaskType_Id]

				,[Candidate_Id]

				,[Country_Id]

				,[FormId]

				,[Assignee_Id]

				,[Panel_Id]

				)

			VALUES (

				@ActiontaskId

				,@getdate

				,@getdate

				,@getdate

				,@pActionComment

				,0

				,@pAssigneeName

				,@getdate

				,@getdate

				,4

				,NULL

				,@GUIDRefActionTask

				,@pCandidateId

				,@pCountryId

				,@pFromId

				,@AssigneeId

				,NULL

				)

		END

	END
END TRY
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH
END
