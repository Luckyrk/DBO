/*##########################################################################
-- Name				: SaveCommunication.sql
-- Date             : 2015-02-04
-- Author           : GopiChand Parimi
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure Saves the communication done by the user
-- Usage			: 
-- Impact			: 
-- Required grants  : 
-- Called by        : GPS
-- PARAM Definitions
	@pCountryCode VARCHAR(10) -- Country code
	@pScope VARCHAR(50) -- Type of communication. Possible values are Email,Sms
	@pScopeReference NVARCHAR(100) - If scope is Email, it will be the email id and if scope is Sms, it is panelist mobile number
	@pDirection VARCHAR(50) -- Direction of communication. If its incoming or outgoing
	@pSubject VARCHAR(100) -- Subject
	@pContent VARCHAR(100) -- Message Content
	@pUser NVARCHAR(100) -- Will be the caller of this SP whose details will be audited
	@pCultureCode INT -- Culture code
-- Sample Execution :
	EXEC [SaveCommunication] '000001-00','ES','Email','Test@Gmail.com','Incoming','hi','hello','TestUser', 2057
	EXEC [SaveCommunication] '000002-00','GB','Sms','3216548976','OutGoing','hi','hello','SuperAdminUK', 2057
##########################################################################
-- ver  user			 date        change 
-- 1.0  GopiChand	    2015-02-04	 initial
##########################################################################*/
CREATE PROCEDURE [dbo].[SaveCommunication] @pBusinessId VARCHAR(50)
	,@pCountryCode VARCHAR(10)
	,@pScope VARCHAR(50)
	,@pScopeReference NVARCHAR(100)
	,@pDirection VARCHAR(50)
	,@pSubject VARCHAR(100)
	,@pContent VARCHAR(max)
	,@pUser NVARCHAR(100)=null
	,@pCultureCode INT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @CandidateId UNIQUEIDENTIFIER
		DECLARE @CountryId UNIQUEIDENTIFIER
		DECLARE @DocumentTypeId BIGINT
		DECLARE @DocumentSubTypeId BIGINT
		DECLARE @documentId BIGINT
		DECLARE @insertDate DATETIME
		DECLARE @CommsReasonTypeId UNIQUEIDENTIFIER
		DECLARE @CommunicationEventId UNIQUEIDENTIFIER
		DECLARE @ContactMechanismId UNIQUEIDENTIFIER
		DECLARE @FromEmail NVARCHAR(200)

		DECLARE @GetDate DATETIME
		SET @GetDate = (select dbo.GetLocalDateTime(getdate(),@pCountryCode))

		SET @insertDate = @GetDate
		SET @CommunicationEventId = NEWID()

		SELECT @CountryId = CountryId
		FROM Country
		WHERE CountryISO2A = @pCountryCode
		if(@pUser is null)
		  set @pUser='RuleComposerProcessor'
		SET @DocumentTypeId = (
				SELECT TOP 1 DocumentTypeId
				FROM DocumentType
				WHERE Description = CASE 
						WHEN @pScope = 'Email'
							THEN 'EmailDocument'
						ELSE 'TextDocument'
						END
				)
		SET @DocumentSubTypeId = (
				SELECT TOP 1 DocumentSubTypeId
				FROM DocumentSubType
				WHERE Description = 'InComing'
				)

		SELECT @CandidateId = C.GUIDReference
		FROM Individual I
		INNER JOIN Candidate C ON C.GUIDReference = I.GUIDReference
		WHERE IndividualId = @pBusinessId
			AND I.CountryId = @CountryId

		INSERT INTO Document (
			[DocumentTypeId]
			,[DocumentSubTypeId]
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			,CountryId
			)
		VALUES (
			@DocumentTypeId
			,@DocumentSubTypeId
			,@pUser
			,@insertDate
			,@insertDate
			,@CountryId
			)

		SET @documentId = @@IDENTITY

		IF (@pScope = 'Email')
		BEGIN
			SELECT @FromEmail = A.AddressLine1
			FROM AddressDomain Ad
			INNER JOIN Address A ON AD.AddressId = A.GUIDReference
			WHERE AD.CountryId = @CountryId

			INSERT INTO EmailDocument (
				[DocumentId]
				,[EmailDate]
				,[Subject]
				,[From]
				,[To]
				,[EmailContent]
				,[Unusable]
				,[GPSUser]
				,[GPSUpdateTimestamp]
				,[CreationTimeStamp]
				)
			VALUES (
				@documentId
				,@insertDate
				,@pSubject
				,@FromEmail
				,@pScopeReference
				,@pContent
				,0
				,@pUser
				,@insertDate
				,@insertDate
				)
		END
		ELSE
		BEGIN
			INSERT INTO TextDocument (
				[DocumentId]
				,[TextDate]
				,[SenderId]
				,[Recipient]
				,[Message]
				,[GPSUser]
				,[GPSUpdateTimestamp]
				,[CreationTimeStamp]
				)
			VALUES (
				@documentId
				,@insertDate
				,@pBusinessId
				,@pScopeReference
				,@pContent
				,@pUser
				,@insertDate
				,@insertDate
				)
		END

		SELECT @ContactMechanismId = GUIDReference
		FROM ContactMechanismType
		WHERE Country_Id = @CountryId
			AND Types = CASE 
				WHEN @pScope = 'Email'
					THEN 'Email'
				ELSE 'Sms'
				END

		DECLARE @InProgressState INT = 0
			,@inComing BIT = 0
			,@CommEventCreateIncoming BIT = 0
			,@ContactMechanismEnum INT
			,@onGoingStatus INT
			,@CEGUIDReference UNIQUEIDENTIFIER
			,@CEContactMechanism_Id UNIQUEIDENTIFIER
			,@OnGoingCommunicationInProgress INT = 1
		DECLARE @Comment NVARCHAR(1000)

		SET @Comment = CASE 
				WHEN @pScope = 'Email'
					THEN 'Email Sent to ' + @pScopeReference
				ELSE 'SMS sent to ' + @pScopeReference
				END
		SET @ContactMechanismEnum = CASE 
				WHEN @pScope = 'Email'
					THEN 1
				ELSE 2
				END
		SET @onGoingStatus = CASE 
				WHEN @ContactMechanismEnum = 2
					THEN 4 + 1 + 2
				ELSE 8 + 1 + 2
				END

		SELECT TOP 1 @CEGUIDReference = CE.GUIDReference
			,@InProgressState = 1
			,@inComing = CE.Incoming
			,@CEContactMechanism_Id = CE.ContactMechanism_Id
		FROM CommunicationEvent CE
		WHERE CE.Candidate_Id = @CandidateId
			AND CE.GPSUser = @pUser
			AND CE.State = @InProgressState
		ORDER BY CE.CreationDate DESC

		SELECT @CommsReasonTypeId = CER.GUIDReference
		FROM CommunicationEventReasonType CER
		INNER JOIN Translation T ON CER.TagTranslation_Id = T.TranslationId
		INNER JOIN TranslationTerm TT ON T.TranslationId = TT.Translation_Id
		WHERE T.KeyName = CASE 
				WHEN @pScope = 'Email'
					THEN 'EmailSent'
				ELSE 'SmsSent'
				END
			AND CER.Country_Id = @CountryId 
			AND TT.CultureCode = @pCultureCode

		IF (
				@InProgressState = 0
				OR @ContactMechanismId <> @CEContactMechanism_Id
				OR @inComing <> @CommEventCreateIncoming
				)
		BEGIN
			INSERT INTO CommunicationEvent (
				[GUIDReference]
				,[CreationDate]
				,[Incoming]
				,[State]
				,[GPSUser]
				,[GPSUpdateTimestamp]
				,[CreationTimeStamp]
				,[CallLength]
				,[ContactMechanism_Id]
				,[Country_Id]
				,[Candidate_Id]
				)
			VALUES (
				@CommunicationEventId
				,@insertDate
				,0
				,2
				,@pUser
				,@insertDate
				,@insertDate
				,'00:00:00.0000000'
				,@ContactMechanismId
				,@CountryId
				,@CandidateId
				)

			INSERT INTO CommunicationEventReason (
				[GUIDReference]
				,[Comment]
				,[GPSUser]
				,[GPSUpdateTimestamp]
				,[CreationTimeStamp]
				,[ReasonType_Id]
				,[Country_Id]
				,[Communication_Id]
				,[panel_id]
				)
			VALUES (
				NEWID()
				,@Comment
				,@pUser
				,@insertDate
				,@insertDate
				,@CommsReasonTypeId
				,@CountryId
				,@CommunicationEventId
				,NULL
				)
		END
		ELSE
		BEGIN
			SET @CommunicationEventId = @CEGUIDReference

			INSERT INTO CommunicationEventReason (
				[GUIDReference]
				,[Comment]
				,[GPSUser]
				,[GPSUpdateTimestamp]
				,[CreationTimeStamp]
				,[ReasonType_Id]
				,[Country_Id]
				,[Communication_Id]
				,[panel_id]
				)
			VALUES (
				NEWID()
				,@Comment
				,@pUser
				,@insertDate
				,@insertDate
				,@CommsReasonTypeId
				,@CountryId
				,@CommunicationEventId
				,NULL
				)
		END

		INSERT INTO DocumentCommunicationEventAssociation (
			[DocumentId]
			,[CommunicationEventId]
			,Country_Id
			,[GPSUser]
			,[GPSUpdateTimestamp]
			,[CreationTimeStamp]
			)
		VALUES (
			@documentId
			,@CommunicationEventId
			,@CountryId
			,@pUser
			,@insertDate
			,@insertDate
			)

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT ERROR_NUMBER() AS ErrorNumber
			,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END