CREATE PROCEDURE [dbo].[getContactNextQuestionnaire] (
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

	--SELECT @QUESTIONCODE
	SELECT QM.GuidReference
		,QM.CODE AS [QuestionCode]
		,QM.[Type]
		,CASE @CULTURECODE
			WHEN 2057
				THEN QM.[Description]
			ELSE QM.LocalDescription
			END AS [QuestionDescription]
		,ISNULL(QM.NextQuestion, CONVERT(INT, 0)) AS NextQuestion
		,ISNULL(AM.GuidReference, CONVERT(UNIQUEIDENTIFIER, 'F6F7B616-ECDB-4B07-A46F-B6DAB3F86AB3')) AS [AnswerId]
		,CASE @CULTURECODE
			WHEN 2057
				THEN isnull(AM.[Description], '')
			ELSE isnull(AM.LocalDescription, '')
			END AS [AnswerDescription]
		,ISNULL(AM.NextQuestion, CONVERT(INT, 0)) AS [NextQuestionBasedOnAns]
		,ATQA.AnswerText AS [AnswerSubmitted]
	FROM QuestionMaster QM
	LEFT JOIN AnswersMaster AM ON QM.GuidReference = AM.QuestionId
	LEFT JOIN ActionTaskQuestionAnswerMapping ATQA ON QM.GuidReference = ATQA.QuestionId
		AND ATQA.IndividualId = @IndividualId
	LEFT JOIN AnswersMaster AM1 ON ATQA.AnswerId = AM1.GuidReference
	WHERE QM.Code = @NextQuestionCode
	ORDER BY AM.AnswerSequence
END
