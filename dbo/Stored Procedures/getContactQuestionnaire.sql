ALTER PROCEDURE [dbo].[getContactQuestionnaire] (
	@COUNTRYID UNIQUEIDENTIFIER
	,@CULTURECODE INT
	,@ACTIONTASKTYPEID UNIQUEIDENTIFIER
	,@IndividualId UNIQUEIDENTIFIER
	)
AS
BEGIN
	DECLARE @QUESTIONCODE INT
	DECLARE @GetDate DATETIME

	SET @GetDate = (
			SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @COUNTRYID)
			)

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
	WHERE ATT.GUIDReference = @ACTIONTASKTYPEID
		AND ATT.COUNTRY_ID = @COUNTRYID
	ORDER BY CODE

	SELECT @QUESTIONCODE = QUESTIONCODE
	FROM @TEMP
	WHERE ID = 1

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
		,ISNULL(CONVERT(INT, QM.NextQuestion), '') AS NextQuestion
		,AM.GuidReference AS [AnswerId]
		,CASE @CULTURECODE
			WHEN 2057
				THEN AM.[Description]
			ELSE AM.LocalDescription
			END AS [AnswerDescription]
		,ISNULL(AM.NextQuestion, '') AS [NextQuestionBasedOnAns]
		,ATQA.AnswerText AS [AnswerSubmitted]
	FROM QuestionMaster QM
	LEFT JOIN AnswersMaster AM ON QM.GuidReference = AM.QuestionId
	JOIN @TEMP T ON QM.CODE = T.QUESTIONCODE
	LEFT JOIN ActionTaskQuestionAnswerMapping ATQA ON ATQA.QuestionId = QM.GuidReference
		AND ATQA.IndividualId = @IndividualId
	LEFT JOIN AnswersMaster AM1 ON ATQA.AnswerId = AM1.GuidReference
	WHERE QM.Code = @QUESTIONCODE
	ORDER BY AM.AnswerSequence

	SELECT DISTINCT [TYPE]
	FROM QuestionMaster
END
