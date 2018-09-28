/*##########################################################################
-- Name				: SaveOrderCommunication.sql
-- Date             : 2018-05-02
-- Author           : Sandhya Penumatsa
-- Company          : HCL
-- Purpose          : This Procedure Saves the communication done by the user for Orders
-- Usage			: 
-- Impact			: 
-- Required grants  : 
-- Called by        : GPS
-- PARAM Definitions
	@pCountryCode VARCHAR(10) -- Country code	
	@pUser NVARCHAR(100) -- Will be the caller of this SP whose details will be audited
	@pCultureCode INT -- Culture code
	@pOrderId -- Pass Order ID
-- Sample Execution :

	DECLARE @return_value INT
	EXEC @return_value = [dbo].[SaveOrderCommunication] @pBusinessId = '926086-00'
		,@pCountryCode = 'ES'
		,@pUser = 'Sandhya.Penumatsa@kantar.com'
		,@pCultureCode = 2057
		,@pOrderId = 105
	SELECT 'Return Value' = @return_value

##########################################################################
-- ver  user			 date        change 
-- 1.0  Sandhya	    2018-05-02	 initial
##########################################################################*/
CREATE PROCEDURE [dbo].[SaveOrderCommunication] @pBusinessId VARCHAR(50)
	,@pCountryCode VARCHAR(10)
	,@pUser NVARCHAR(100) = NULL
	,@pCultureCode INT
	,@pOrderId BIGINT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		DECLARE @CandidateId UNIQUEIDENTIFIER
		DECLARE @CountryId UNIQUEIDENTIFIER
		DECLARE @insertDate DATETIME
		DECLARE @CommsReasonTypeId UNIQUEIDENTIFIER
		DECLARE @CommunicationEventId UNIQUEIDENTIFIER
		DECLARE @ContactMechanismId UNIQUEIDENTIFIER
		DECLARE @Panel_Id UNIQUEIDENTIFIER
		DECLARE @FromEmail NVARCHAR(200)
		DECLARE @InProgressState INT = 0
			,@inComing BIT = 0
			,@CommEventCreateIncoming BIT = 0
			,@CEGUIDReference UNIQUEIDENTIFIER
			,@CEContactMechanism_Id UNIQUEIDENTIFIER
		DECLARE @Comment NVARCHAR(1000)
		DECLARE @GetDate DATETIME

		SET @GetDate = (
				SELECT dbo.GetLocalDateTime(getdate(), @pCountryCode)
				)
		SET @insertDate = @GetDate
		SET @CommunicationEventId = NEWID()

		SELECT @CountryId = CountryId
		FROM Country
		WHERE CountryISO2A = @pCountryCode

		SELECT @CandidateId = C.GUIDReference
		FROM Individual I
		INNER JOIN Candidate C ON C.GUIDReference = I.GUIDReference
		WHERE IndividualId = @pBusinessId
			AND I.CountryId = @CountryId

		SELECT @Comment = Comments
		FROM [order]
		WHERE CountryOrderid = @pOrderId

		SELECT @ContactMechanismId = GUIDReference
		FROM ContactMechanismType
		WHERE Country_Id = @CountryId
			AND Types = 'Other'

		SELECT TOP 1 @CEGUIDReference = CE.GUIDReference
			,@InProgressState = 1
			,@inComing = CE.Incoming
			,@CEContactMechanism_Id = CE.ContactMechanism_Id
		FROM CommunicationEvent CE
		WHERE CE.Candidate_Id = @CandidateId
			AND CE.GPSUser = @pUser
			AND CE.STATE = @InProgressState
		ORDER BY CE.CreationDate DESC

		SELECT @CommsReasonTypeId = CER.GUIDReference
			,@Panel_Id = at.Panel_Id
		FROM [dbo].[CommunicationEventReasonType] CER
		INNER JOIN actiontasktype att ON CER.RelatedActionType_Id = att.GUIDReference
		INNER JOIN actiontask at ON at.ActionTaskType_Id = att.guidreference
		INNER JOIN dbo.[order] o ON o.ActionTask_Id = at.guidreference
		INNER JOIN Translation T ON CER.TagTranslation_Id = T.TranslationId
		INNER JOIN TranslationTerm TT ON T.TranslationId = TT.Translation_Id
		WHERE o.OrderId = @pOrderId
			AND CER.Country_Id = @CountryId
			AND TT.CultureCode = @pCultureCode

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
			,@Panel_Id
			)

		COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT ERROR_NUMBER() AS ErrorNumber
			,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH
END