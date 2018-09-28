CREATE PROCEDURE [dbo].[saveCloseContactQuestionnaire] (
	@COUNTRYID UNIQUEIDENTIFIER
	,@CULTURECODE INT
	,@ACTIONTASKTYPEID UNIQUEIDENTIFIER
	,@NextQuestionCode INT
	,@IndividualId UNIQUEIDENTIFIER
	,@CurrentQuestionCode INT
	,@AnswerSubmitted NVARCHAR(1000)
	,@GPSuser VARCHAR(100)
	)
AS
BEGIN
	DECLARE @AnswerId UNIQUEIDENTIFIER
	DECLARE @GetDate DATETIME
	DECLARE @DefaultContactMechanismTypeId UNIQUEIDENTIFIER
	DECLARE @CommunicationEventId UNIQUEIDENTIFIER = NEWID()
	DECLARE @DefaultPanelId UNIQUEIDENTIFIER

	SELECT @DefaultContactMechanismTypeId = GUIDReference
	FROM CONTACTMECHANISMTYPE
	WHERE Types = 'Phone'

	SELECT @DefaultPanelId = GUIDReference
	FROM PANEL
	WHERE NAME = 'Worldpanel'

	SET @GetDate = (
			SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @COUNTRYID)
			)

	IF (@CULTURECODE = 2057)
		SELECT @AnswerId = GuidReference
		FROM AnswersMaster
		WHERE LocalDescription = @AnswerSubmitted
	ELSE
		SELECT @AnswerId = GuidReference
		FROM AnswersMaster
		WHERE Description = @AnswerSubmitted

	IF NOT EXISTS (
			SELECT 1
			FROM QUESTIONMASTER QM
			JOIN ActionTaskQuestionAnswerMapping ATQA ON QM.GuidReference = ATQA.QuestionId
				AND ATQA.IndividualId = @IndividualId
			WHERE QM.CODE = 23601
			)
	BEGIN
		INSERT INTO ActionTaskQuestionAnswerMapping (
			GuidReference
			,IndividualId
			,ActionTaskTypeId
			,QuestionId
			,AnswerId
			,AnswerText
			,GPSUser
			,CreationTimeStamp
			,GPSUpdateTimestamp
			)
		SELECT NEWID()
			,@IndividualId
			,@ACTIONTASKTYPEID
			,QM.GuidReference
			,@AnswerId
			,@AnswerSubmitted
			,@GPSUser
			,@GetDate
			,@GetDate
		FROM QuestionMaster QM
		LEFT JOIN AnswersMaster AM ON QM.GuidReference = AM.QuestionId
			AND AM.GuidReference = @AnswerId
		WHERE QM.CODE = @CurrentQuestionCode
	END
	ELSE
	BEGIN
		UPDATE ATQA
		SET ATQA.AnswerId = @AnswerId
			,ATQA.AnswerText = @AnswerSubmitted
			,ATQA.GPSUser = @GPSuser
			,ATQA.CreationTimeStamp = @GetDate
			,ATQA.GPSUpdateTimestamp = @GetDate
		FROM ActionTaskQuestionAnswerMapping ATQA
		JOIN QuestionMaster QM ON QM.GuidReference = ATQA.QuestionId
		WHERE ATQA.IndividualId = @IndividualId
			AND ATQA.ActionTaskTypeId = @ACTIONTASKTYPEID
			AND QM.CODE = @CurrentQuestionCode
	END

	UPDATE ActionTask
	SET CompletionDate = @GetDate
		,[State] = 4
		,GPSUser = @GPSuser
		,GPSUpdateTimestamp = @GetDate
	WHERE Candidate_Id = @IndividualId
		AND ActionTaskType_Id = @ACTIONTASKTYPEID

	IF NOT EXISTS (
			SELECT 1
			FROM CommunicationEventReason CER
			JOIN communicationevent CE ON CE.GUIDReference = CER.Communication_Id
			JOIN CommunicationEventReasonType certy ON certy.RelatedActionType_Id = @ACTIONTASKTYPEID
				AND CER.ReasonType_Id = CERTY.GUIDReference
			WHERE Candidate_Id = @IndividualId
			)
	BEGIN
		INSERT INTO communicationevent (
			GUIDReference
			,CreationDate
			,Incoming
			,STATE
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			,CallLength
			,ContactMechanism_Id
			,Country_Id
			,Candidate_Id
			)
		SELECT @CommunicationEventId
			,@GetDate
			,0
			,2
			,@GPSuser
			,@GetDate
			,@GetDate
			,'00:00:00.0000000'
			,@DefaultContactMechanismTypeId
			,@COUNTRYID
			,@IndividualId

		INSERT INTO CommunicationEventReason (
			GUIDReference
			,Comment
			,GPSUser
			,GPSUpdateTimestamp
			,CreationTimeStamp
			,ReasonType_Id
			,Country_Id
			,Communication_Id
			,panel_id
			)
		SELECT NEWID()
			,NULL
			,@GPSuser
			,@GetDate
			,@GetDate
			,certy.GUIDReference
			,@COUNTRYID
			,@CommunicationEventId
			,ISNULL(certy.PanelRestriction_Id, @DefaultPanelId)
		FROM CommunicationEventReasonType certy
		WHERE certy.RelatedActionType_Id = @ACTIONTASKTYPEID
	END
END
