CREATE PROCEDURE [dbo].[getContactPreviousQuestionnaire] (
	@COUNTRYID UNIQUEIDENTIFIER
	,@CULTURECODE INT
	,@ACTIONTASKTYPEID UNIQUEIDENTIFIER
	,@IndividualId UNIQUEIDENTIFIER
	,@CurrentQuestionCode INT
	,@AnswerSubmitted NVARCHAR(1000)
	,@AnswerId UNIQUEIDENTIFIER
	,@GPSuser VARCHAR(100)
	)
AS
BEGIN
	--select * from country
	--d9461b98-7f06-c743-a7c1-08d59f891510
	DECLARE @GetDate DATETIME

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
			WHERE QM.CODE = @CurrentQuestionCode
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

	DECLARE @QUESTIONCODE INT
	DECLARE @TEMP TABLE (
		ID INT IDENTITY
		,ACTIONTASKTYPEID UNIQUEIDENTIFIER
		,QUESTIONCODE INT
		)

	INSERT INTO @TEMP (
		ACTIONTASKTYPEID
		,QUESTIONCODE
		)
	SELECT DISTINCT ATT.GuidReference
		,QM.CODE
	FROM ACTIONTASKTYPE ATT
	JOIN CONTACTTYPE CT ON ATT.ACTIONCODE = CT.CODE
	JOIN QuestionMaster QM ON CT.GuidReference = QM.ContactTypeId
	LEFT JOIN ActionTaskQuestionAnswerMapping ATQA ON ATQA.QuestionId = ATQA.GuidReference
	WHERE ATT.GUIDReference = @ACTIONTASKTYPEID
		AND ATT.COUNTRY_ID = @COUNTRYID
	ORDER BY CODE

	DECLARE @FIRSTQUESTIONCODE INT

	SELECT @FIRSTQUESTIONCODE = MIN(QUESTIONCODE)
	FROM @TEMP

	SELECT TOP 1 @QUESTIONCODE = QUESTIONCODE
	FROM @TEMP
	WHERE QUESTIONCODE < @CurrentQuestionCode
	ORDER BY QUESTIONCODE DESC

	--SELECT @QUESTIONCODE
	SELECT @ACTIONTASKTYPEID AS [ActionTaskTypeId]
		,QM.GuidReference AS [QuestionId]
		,QM.CODE AS [QuestionCode]
		,T.ID AS [QuestionSequence]
		,QM.[Type]
		,CASE @CULTURECODE
			WHEN 2057
				THEN QM.[Description]
			ELSE QM.LocalDescription
			END AS [QuestionDescription]
		,ISNULL(CONVERT(INT, QM.NextQuestion), 0) AS NextQuestion
		,AM.GuidReference AS [AnswerId]
		,CASE @CULTURECODE
			WHEN 2057
				THEN AM.[Description]
			ELSE AM.LocalDescription
			END AS [AnswerDescription]
		,ISNULL(AM.NextQuestion, 0) AS [NextQuestionBasedOnAns]
		,ATQA.AnswerText AS [AnswerSubmitted]
		,@FIRSTQUESTIONCODE AS [FirstQuestionCode]
	FROM QuestionMaster QM
	LEFT JOIN AnswersMaster AM ON QM.GuidReference = AM.QuestionId
	JOIN @TEMP T ON QM.CODE = T.QUESTIONCODE
	LEFT JOIN ActionTaskQuestionAnswerMapping ATQA ON ATQA.QuestionId = QM.GuidReference
		AND ATQA.IndividualId = @IndividualId
	LEFT JOIN AnswersMaster AM1 ON ATQA.AnswerId = AM1.GuidReference
	WHERE QM.Code = @QUESTIONCODE
	ORDER BY AM.AnswerSequence
END
