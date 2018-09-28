CREATE PROCEDURE [dbo].[GetIndividualCommunicationReasons] @pIndividualId UNIQUEIDENTIFIER
	,@pGPSUser VARCHAR(100)
	,@pStateInProgress INT
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
	,@pOrderBy VARCHAR(100)
	,@pOrderType VARCHAR(10) -- ASC OR DESC
	,@pdays NVARCHAR(10)
	,@pIsExport BIT = 0
	,@pParametersTable dbo.GridParametersTable readonly
AS
BEGIN
	DECLARE @IncomingTranslation NVARCHAR(100)
	DECLARE @OutgoingTranslation NVARCHAR(100)
	DECLARE @IsCountryEnabledRecordConfig BIT
	DECLARE @EmailSentTransalationId UNIQUEIDENTIFIER
	DECLARE @Configuration_Id UNIQUEIDENTIFIER

	SELECT @EmailSentTransalationId = TranslationId
	FROM Translation
	WHERE KeyName = 'EmailSent'

	DECLARE @EndDate DATETIME
	DECLARE @GetDate DATETIME

	SET @GetDate = (
			SELECT dbo.GetLocalDateTimeByCountryId(getdate(), @pCountryId)
			)

	SELECT @Configuration_Id = Configuration_Id
	FROM Country
	WHERE CountryId = @pCountryId

	SELECT @IsCountryEnabledRecordConfig = Visible
	FROM FieldConfiguration
	WHERE [Key] = 'IsRecordsEnable'
		AND CountryConfiguration_Id = @Configuration_Id

	IF (@IsCountryEnabledRecordConfig = 0)
	BEGIN
		IF (
				@pdays = 'All'
				OR @pIsExport = 1
				)
			SET @EndDate = '1900-01-01'
		ELSE
			SET @EndDate = DATEADD(DD, - CAST(@pdays AS INT), @GetDate)
	END
	ELSE
	BEGIN
		SET @EndDate = '1900-01-01'
	END

	BEGIN TRY
		DECLARE @GroupID UNIQUEIDENTIFIER
		DECLARE @Individuals AS TABLE (id UNIQUEIDENTIFIER);

		IF (@IsCountryEnabledRecordConfig = 1)
		BEGIN
			INSERT INTO @Individuals
			SELECT CM.Individual_Id
			FROM CollectiveMembership CM1
			JOIN CollectiveMembership CM ON CM.Group_Id = CM1.Group_Id
			JOIN StateDefinition SD ON sd.Id = cm.State_Id --AND sd.InactiveBehavior = 0
			WHERE CM1.Individual_Id = @pIndividualId
		END
		ELSE
		BEGIN
			INSERT INTO @Individuals
			SELECT CM.Individual_Id
			FROM CollectiveMembership CM1
			JOIN CollectiveMembership CM ON CM.Group_Id = CM1.Group_Id
			JOIN StateDefinition SD ON sd.Id = cm.State_Id
				AND sd.InactiveBehavior = 0
			WHERE CM1.Individual_Id = @pIndividualId
		END

		IF (@pOrderBy IS NULL)
			SET @pOrderBy = 'CreationDate'

		IF (@pOrderType IS NULL)
			SET @pOrderType = 'DESC'
		SET @IncomingTranslation = (
				SELECT TOP 1 VALUE
				FROM TRANSLATION T
				INNER JOIN TRANSLATIONTERM TT ON TT.TRANSLATION_ID = T.TRANSLATIONID
				WHERE T.KEYNAME = 'CommunicationEvent:Incoming:True'
					AND CultureCode = @pCultureCode
				)
		SET @OutgoingTranslation = (
				SELECT TOP 1 VALUE
				FROM TRANSLATION T
				INNER JOIN TRANSLATIONTERM TT ON TT.TRANSLATION_ID = T.TRANSLATIONID
				WHERE T.KEYNAME = 'CommunicationEvent:Incoming:False'
					AND CultureCode = @pCultureCode
				)

		DECLARE @op1 VARCHAR(50)
			,@op2 VARCHAR(50)
			,@op3 VARCHAR(50)
			,@op4 VARCHAR(50)
			,@op5 VARCHAR(50)
			,@op6 VARCHAR(50)
			,@op7 VARCHAR(50)
		DECLARE @LogicalOperator3 VARCHAR(5)
			,@LogicalOperator4 VARCHAR(5)
		DECLARE @Secondop3 VARCHAR(50)
		DECLARE @SecondCreationDate DATETIME
		DECLARE @GpsUser NVARCHAR(100)
			,@FirstName NVARCHAR(1000)
			,@CreationDate DATETIME --,@CallLength Time
			,@ReasonCode INT
			,@ReasonLabel NVARCHAR(1000)
			,@ReasonPanel NVARCHAR(100)
			,@Summary NVARCHAR(1500)

		SELECT @op1 = Opertor
			,@GpsUser = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'GpsUser'

		SELECT @op2 = Opertor
			,@FirstName = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'FirstName'

		SELECT @op3 = Opertor
			,@CreationDate = CAST(ParameterValue AS DATETIME)
			,@Secondop3 = SecondParameterOperator
			,@SecondCreationDate = CAST(SecondParameterValue AS DATETIME)
			,@LogicalOperator3 = LogicalOperator
		FROM @pParametersTable
		WHERE ParameterName = 'CreationDate'

		--SELECT @op4=Opertor,@CallLength=ParameterValue FROM @pParametersTable WHERE ParameterName='CallLength'
		SELECT @op4 = Opertor
			,@ReasonCode = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'ReasonCode'

		SELECT @op5 = Opertor
			,@ReasonLabel = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'ReasonLabel'

		SELECT @op6 = Opertor
			,@ReasonPanel = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'ReasonPanel'

		SELECT @op7 = Opertor
			,@Summary = ParameterValue
		FROM @pParametersTable
		WHERE ParameterName = 'Summary'

		DECLARE @CreationDateVARCHAR VARCHAR(100) = CAST(@CreationDate AS VARCHAR)
			,@SecondCreationDateVARCHAR VARCHAR(100) = CAST(@SecondCreationDate AS VARCHAR)
			,@ReasonCodeVARCHAR VARCHAR(10) = CAST(@ReasonCode AS VARCHAR)
		DECLARE @OFFSETRows INT = 0
		DECLARE @IsLessThan VARCHAR(50) = 'IsLessThan'
			,@IsLessThanOrEqualTo VARCHAR(50) = 'IsLessThanOrEqualTo'
			,@IsEqualTo VARCHAR(50) = 'IsEqualTo'
			,@IsNotEqualTo VARCHAR(50) = 'IsNotEqualTo'
			,@IsGreaterThanOrEqualTo VARCHAR(50) = 'IsGreaterThanOrEqualTo'
			,@IsGreaterThan VARCHAR(50) = 'IsGreaterThan'
			,@StartsWith VARCHAR(50) = 'StartsWith'
			,@EndsWith VARCHAR(50) = 'EndsWith'
			,@Contains VARCHAR(50) = 'Contains'
			,@IsContainedIn VARCHAR(50) = 'IsContainedIn'
			,@DoesNotContain VARCHAR(50) = 'DoesNotContain'

		--IF (@pIsExport = 0)
		--       SET @OFFSETRows = (@pPageSize * (@pPageNumber - 1))
		--ELSE
		--       SET @pPageSize = 65000
		IF (
				@IsCountryEnabledRecordConfig = 0
				OR (
					@IsCountryEnabledRecordConfig = 1
					AND @pdays = 'All'
					)
				)
		BEGIN
			SELECT *
			FROM (
				SELECT T.IsUpdateReasonAllowed
					,T.IsDeleteReasonAllowed
					,T.CreationTimeStamp
					,T.GPSUser
					,T.CommEventId
					,T.Comment
					,T.ReasonId
					,T.ReasonCode
					,dbo.GetTranslationValue(TagTranslation_Id, @pCultureCode) AS ReasonLabel
					,ISNULL(p.NAME, '') AS ReasonPanel
					,CAST(CONVERT(VARCHAR(16), CONVERT(DATETIME, T.CreationDate, 103), 121) AS DATETIME) AS CreationDate
					,(FirstName + MiddleName + LastName) AS FirstName
					,T.MiddleName
					,T.LastName
					,T.Incoming
					,T.CallLength
					,IIF(Incoming = 1, @IncomingTranslation, @OutgoingTranslation) AS IncomingOrOutGoingLabel
					,T.ContactMechanismId
					,T.ContactMechanismCode
					,T.ContactMechanismTypeDescriptor
					,T.ContactMechanismLabel
					,T.summary AS Summary
					,T.Content AS Content
					,IIF(@EmailSentTransalationId = TagTranslation_Id, 1, 0) AS IsResendEmailAllowed
				FROM (
					SELECT IIF(cer.GPSUser = @pGPSUser, 1, 0) AS IsUpdateReasonAllowed
						,IIF(ce.STATE = @pStateInProgress
							AND cer.GPSUser = @pGPSUser, 1, 0) AS IsDeleteReasonAllowed
						,Ce.GUIDReference AS CommEventId
						,CE.GPSUSER AS GPSUser
						,IIF(dbo.IsFieldRequiredOrFieldVisible(@pCountryId, 'FirstName', 1) = 1, PersIdentity.FirstOrderedName + ' ', '') AS FirstName
						,IIF(dbo.IsFieldRequiredOrFieldVisible(@pCountryId, 'MiddleName', 1) = 1, PersIdentity.MiddleOrderedName + ' ', '') AS MiddleName
						,IIF(dbo.IsFieldRequiredOrFieldVisible(@pCountryId, 'LastName', 1) = 1, PersIdentity.LastOrderedName + ' ', '') AS LastName
						,CER.CreationTimeStamp AS CreationDate
						,ce.CallLength
						,cer.GUIDReference AS ReasonId
						,CERType.CommEventReasonCode AS ReasonCode
						,cer.Comment
						,ce.Incoming
						,cer.CreationTimeStamp AS CreationTimeStamp
						,IIF(ISNULL(ED.[Subject], '') = '', ISNULL(td.[Message], ''), ED.[Subject]) AS Summary
						,SUBSTRING(IIF(ISNULL(ED.EmailContent, '') = '', ISNULL(td.[Message], ''), ED.EmailContent),0,500) AS Content
						,CONVERT(NVARCHAR(MAX), cer.panel_id) AS panel_id
						,CERType.TagTranslation_Id
						,CMT.GUIDReference AS ContactMechanismId
						,CMT.ContactMechanismCode
						,dbo.GetTranslationValue(CMT.TypeTranslation_Id, NULL) AS ContactMechanismTypeDescriptor
						,dbo.GetTranslationValue(CMT.DescriptionTranslation_Id, @pCultureCode) AS ContactMechanismLabel
						,ED.[Subject] AS ESubject
						,td.[Message] AS EMessage
						,cer.Comment AS EComment
					FROM @Individuals i
					JOIN Individual Indv ON i.Id = Indv.GUIDReference
					JOIN PersonalIdentification PersIdentity ON Indv.PersonalIdentificationId = PersIdentity.PersonalIdentificationId
					JOIN CommunicationEvent CE ON Indv.GUIDReference = ce.Candidate_Id
					JOIN CommunicationEventReason CER ON cer.Communication_Id = ce.GUIDReference
					JOIN CommunicationEventReasonType CERType ON CER.ReasonType_Id = CERType.GUIDReference
					LEFT JOIN DocumentCommunicationEventAssociation DCEA ON DCEA.CommunicationEventId = ce.guidreference
					LEFT JOIN Document Doc ON doc.DocumentId = DCEA.DocumentId
					LEFT JOIN ContactMechanismType CMT ON CE.ContactMechanism_Id = CMT.GUIDReference
					LEFT JOIN TextDocument TD ON TD.DocumentId = Doc.DocumentId
					LEFT JOIN emaildocument ED ON ed.DocumentId = Doc.DocumentId
					WHERE CER.CreationTimeStamp >= @EndDate
					) AS T
				LEFT JOIN panel p ON GUIDReference = panel_id
				) AS ResultTable
			WHERE (
					(@op1 IS NULL)
					OR (
						@op1 = @IsEqualTo
						AND GPSUser = @GPSUser
						)
					OR (
						@op1 = @IsNotEqualTo
						AND GPSUser <> @GPSUser
						)
					OR (
						@op1 = @IsLessThan
						AND GPSUser < @GPSUser
						)
					OR (
						@op1 = @IsLessThanOrEqualTo
						AND GPSUser <= @GPSUser
						)
					OR (
						@op1 = @IsGreaterThan
						AND GPSUser > @GPSUser
						)
					OR (
						@op1 = @IsGreaterThanOrEqualTo
						AND GPSUser >= @GPSUser
						)
					OR (
						@op1 = @Contains
						AND GPSUser LIKE '%' + @GPSUser + '%'
						)
					OR (
						@op1 = @DoesNotContain
						AND GPSUser NOT LIKE '%' + @GPSUser + '%'
						)
					OR (
						@op1 = @StartsWith
						AND GPSUser LIKE '' + @GPSUser + '%'
						)
					OR (
						@op1 = @EndsWith
						AND GPSUser LIKE '%' + @GPSUser + ''
						)
					)
				AND (
					(@op2 IS NULL)
					OR (
						@op2 = @IsEqualTo
						AND FirstName = @FirstName
						)
					OR (
						@op2 = @IsNotEqualTo
						AND FirstName <> @FirstName
						)
					OR (
						@op2 = @IsLessThan
						AND FirstName < @FirstName
						)
					OR (
						@op2 = @IsLessThanOrEqualTo
						AND FirstName <= @FirstName
						)
					OR (
						@op2 = @IsGreaterThan
						AND FirstName > @FirstName
						)
					OR (
						@op2 = @IsGreaterThanOrEqualTo
						AND FirstName >= @FirstName
						)
					OR (
						@op2 = @Contains
						AND FirstName LIKE '%' + @FirstName + '%'
						)
					OR (
						@op2 = @DoesNotContain
						AND FirstName NOT LIKE '%' + @FirstName + '%'
						)
					OR (
						@op2 = @StartsWith
						AND FirstName LIKE '' + @FirstName + '%'
						)
					OR (
						@op2 = @EndsWith
						AND FirstName LIKE '%' + @FirstName + ''
						)
					)
				AND (
					(@op3 IS NULL)
					OR (
						@op3 IS NULL
						AND @LogicalOperator3 IS NULL
						)
					OR (
						@LogicalOperator3 = 'OR'
						AND (
							(
								(
									@op3 = @IsEqualTo
									AND CreationDate = @CreationDate
									)
								OR (
									@op3 = @IsNotEqualTo
									AND CreationDate <> @CreationDate
									)
								OR (
									@op3 = @IsLessThan
									AND CreationDate < @CreationDate
									)
								OR (
									@op3 = @IsLessThanOrEqualTo
									AND CreationDate <= @CreationDate
									)
								OR (
									@op3 = @IsGreaterThan
									AND CreationDate > @CreationDate
									)
								OR (
									@op3 = @IsGreaterThanOrEqualTo
									AND CreationDate >= @CreationDate
									)
								OR (
									@op3 = @Contains
									AND CreationDate LIKE '%' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @DoesNotContain
									AND CreationDate NOT LIKE '%' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @StartsWith
									AND CreationDate LIKE '' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @EndsWith
									AND CreationDate LIKE '%' + @CreationDateVARCHAR + ''
									)
								)
							OR (
								(
									@Secondop3 = @IsEqualTo
									AND CreationDate = @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsNotEqualTo
									AND CreationDate <> @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsLessThan
									AND CreationDate < @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsLessThanOrEqualTo
									AND CreationDate <= @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsGreaterThan
									AND CreationDate > @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsGreaterThanOrEqualTo
									AND CreationDate >= @SecondCreationDate
									)
								OR (
									@Secondop3 = @Contains
									AND CreationDate LIKE '%' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @DoesNotContain
									AND CreationDate NOT LIKE '%' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @StartsWith
									AND CreationDate LIKE '' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @EndsWith
									AND CreationDate LIKE '%' + @SecondCreationDateVARCHAR + ''
									)
								)
							)
						)
					OR (
						@LogicalOperator3 = 'AND'
						AND (
							(
								(
									@op3 = @IsEqualTo
									AND CreationDate = @CreationDate
									)
								OR (
									@op3 = @IsNotEqualTo
									AND CreationDate <> @CreationDate
									)
								OR (
									@op3 = @IsLessThan
									AND CreationDate < @CreationDate
									)
								OR (
									@op3 = @IsLessThanOrEqualTo
									AND CreationDate <= @CreationDate
									)
								OR (
									@op3 = @IsGreaterThan
									AND CreationDate > @CreationDate
									)
								OR (
									@op3 = @IsGreaterThanOrEqualTo
									AND CreationDate >= @CreationDate
									)
								OR (
									@op3 = @Contains
									AND CreationDate LIKE '%' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @DoesNotContain
									AND CreationDate NOT LIKE '%' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @StartsWith
									AND CreationDate LIKE '' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @EndsWith
									AND CreationDate LIKE '%' + @CreationDateVARCHAR + ''
									)
								)
							AND (
								(
									@Secondop3 = @IsEqualTo
									AND CreationDate = @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsNotEqualTo
									AND CreationDate <> @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsLessThan
									AND CreationDate < @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsLessThanOrEqualTo
									AND CreationDate <= @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsGreaterThan
									AND CreationDate > @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsGreaterThanOrEqualTo
									AND CreationDate >= @SecondCreationDate
									)
								OR (
									@Secondop3 = @Contains
									AND CreationDate LIKE '%' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @DoesNotContain
									AND CreationDate NOT LIKE '%' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @StartsWith
									AND CreationDate LIKE '' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @EndsWith
									AND CreationDate LIKE '%' + @SecondCreationDateVARCHAR + ''
									)
								)
							)
						)
					OR (
						@op3 = @IsEqualTo
						AND @Secondop3 IS NULL
						AND CreationDate = @CreationDate
						)
					OR (
						@op3 = @IsNotEqualTo
						AND @Secondop3 IS NULL
						AND CreationDate <> @CreationDate
						)
					OR (
						@op3 = @IsLessThan
						AND @Secondop3 IS NULL
						AND CreationDate < @CreationDate
						)
					OR (
						@op3 = @IsLessThanOrEqualTo
						AND @Secondop3 IS NULL
						AND CreationDate <= @CreationDate
						)
					OR (
						@op3 = @IsGreaterThan
						AND @Secondop3 IS NULL
						AND CreationDate > @CreationDate
						)
					OR (
						@op3 = @IsGreaterThanOrEqualTo
						AND @Secondop3 IS NULL
						AND CreationDate >= @CreationDate
						)
					OR (
						@op3 = @Contains
						AND @Secondop3 IS NULL
						AND CreationDate LIKE '%' + @CreationDateVARCHAR + '%'
						)
					OR (
						@op3 = @DoesNotContain
						AND @Secondop3 IS NULL
						AND CreationDate NOT LIKE '%' + @CreationDateVARCHAR + '%'
						)
					OR (
						@op3 = @StartsWith
						AND @Secondop3 IS NULL
						AND CreationDate LIKE '' + @CreationDateVARCHAR + '%'
						)
					OR (
						@op3 = @EndsWith
						AND @Secondop3 IS NULL
						AND CreationDate LIKE '%' + @CreationDateVARCHAR + ''
						)
					)
				AND (
					(@op4 IS NULL)
					OR (
						@op4 = @IsEqualTo
						AND ReasonCode = @ReasonCode
						)
					OR (
						@op4 = @IsNotEqualTo
						AND ReasonCode <> @ReasonCode
						)
					OR (
						@op4 = @IsLessThan
						AND ReasonCode < @ReasonCode
						)
					OR (
						@op4 = @IsLessThanOrEqualTo
						AND ReasonCode <= @ReasonCode
						)
					OR (
						@op4 = @IsGreaterThan
						AND ReasonCode > @ReasonCode
						)
					OR (
						@op4 = @IsGreaterThanOrEqualTo
						AND ReasonCode >= @ReasonCode
						)
					OR (
						@op4 = @Contains
						AND ReasonCode LIKE '%' + @ReasonCode + '%'
						)
					OR (
						@op4 = @DoesNotContain
						AND ReasonCode NOT LIKE '%' + @ReasonCode + '%'
						)
					OR (
						@op4 = @StartsWith
						AND ReasonCode LIKE '' + @ReasonCode + '%'
						)
					OR (
						@op4 = @EndsWith
						AND ReasonCode LIKE '%' + @ReasonCode + ''
						)
					)
				AND (
					(@op5 IS NULL)
					OR (
						@op5 = @IsEqualTo
						AND ReasonLabel = @ReasonLabel
						)
					OR (
						@op5 = @IsNotEqualTo
						AND ReasonLabel <> @ReasonLabel
						)
					OR (
						@op5 = @IsLessThan
						AND ReasonLabel < @ReasonLabel
						)
					OR (
						@op5 = @IsLessThanOrEqualTo
						AND ReasonLabel <= @ReasonLabel
						)
					OR (
						@op5 = @IsGreaterThan
						AND ReasonLabel > @ReasonLabel
						)
					OR (
						@op5 = @IsGreaterThanOrEqualTo
						AND ReasonLabel >= @ReasonLabel
						)
					OR (
						@op5 = @Contains
						AND ReasonLabel LIKE '%' + @ReasonLabel + '%'
						)
					OR (
						@op5 = @DoesNotContain
						AND ReasonLabel NOT LIKE '%' + @ReasonLabel + '%'
						)
					OR (
						@op5 = @StartsWith
						AND ReasonLabel LIKE '' + @ReasonLabel + '%'
						)
					OR (
						@op5 = @EndsWith
						AND ReasonLabel LIKE '%' + @ReasonLabel + ''
						)
					)
				AND (
					(@op6 IS NULL)
					OR (
						@op6 = @IsEqualTo
						AND ReasonPanel = @ReasonPanel
						)
					OR (
						@op6 = @IsNotEqualTo
						AND ReasonPanel <> @ReasonPanel
						)
					OR (
						@op6 = @IsLessThan
						AND ReasonPanel < @ReasonPanel
						)
					OR (
						@op6 = @IsLessThanOrEqualTo
						AND ReasonPanel <= @ReasonPanel
						)
					OR (
						@op6 = @IsGreaterThan
						AND ReasonPanel > @ReasonPanel
						)
					OR (
						@op6 = @IsGreaterThanOrEqualTo
						AND ReasonPanel >= @ReasonPanel
						)
					OR (
						@op6 = @Contains
						AND ReasonPanel LIKE '%' + @ReasonPanel + '%'
						)
					OR (
						@op6 = @DoesNotContain
						AND ReasonPanel NOT LIKE '%' + @ReasonPanel + '%'
						)
					OR (
						@op6 = @StartsWith
						AND ReasonPanel LIKE '' + @ReasonPanel + '%'
						)
					OR (
						@op6 = @EndsWith
						AND ReasonPanel LIKE '%' + @ReasonPanel + ''
						)
					)
				AND (
					(@op7 IS NULL)
					OR (
						@op7 = @IsEqualTo
						AND Comment = @Summary
						)
					OR (
						@op7 = @IsNotEqualTo
						AND Comment <> @Summary
						)
					OR (
						@op7 = @IsLessThan
						AND Comment < @Summary
						)
					OR (
						@op7 = @IsLessThanOrEqualTo
						AND Comment <= @Summary
						)
					OR (
						@op7 = @IsGreaterThan
						AND Comment > @Summary
						)
					OR (
						@op7 = @IsGreaterThanOrEqualTo
						AND Comment >= @Summary
						)
					OR (
						@op7 = @Contains
						AND Comment LIKE '%' + @Summary + '%'
						)
					OR (
						@op7 = @DoesNotContain
						AND Comment NOT LIKE '%' + @Summary + '%'
						)
					OR (
						@op7 = @StartsWith
						AND Comment LIKE '' + @Summary + '%'
						)
					OR (
						@op7 = @EndsWith
						AND Summary LIKE '%' + @Summary + ''
						)
					)
			ORDER BY CASE 
					WHEN @pOrderBy = 'GpsUser'
						AND @pOrderType = 'asc'
						THEN GpsUser
					END ASC
				,CASE 
					WHEN @pOrderBy = 'GpsUser'
						AND @pOrderType = 'desc'
						THEN GpsUser
					END DESC
				,CASE 
					WHEN @pOrderBy = 'FirstName'
						AND @pOrderType = 'asc'
						THEN FirstName
					END ASC
				,CASE 
					WHEN @pOrderBy = 'FirstName'
						AND @pOrderType = 'desc'
						THEN FirstName
					END DESC
				,CASE 
					WHEN @pOrderBy = 'CreationDate'
						AND @pOrderType = 'asc'
						THEN CreationDate
					END ASC
				,CASE 
					WHEN @pOrderBy = 'CreationDate'
						AND @pOrderType = 'desc'
						THEN CreationDate
					END DESC
				,CASE 
					WHEN @pOrderBy = 'ReasonCode'
						AND @pOrderType = 'asc'
						THEN ReasonCode
					END ASC
				,CASE 
					WHEN @pOrderBy = 'ReasonCode'
						AND @pOrderType = 'desc'
						THEN ReasonCode
					END DESC
				,CASE 
					WHEN @pOrderBy = 'ReasonLabel'
						AND @pOrderType = 'asc'
						THEN ReasonLabel
					END ASC
				,CASE 
					WHEN @pOrderBy = 'ReasonLabel'
						AND @pOrderType = 'desc'
						THEN ReasonLabel
					END DESC
				,CASE 
					WHEN @pOrderBy = 'ReasonPanel'
						AND @pOrderType = 'asc'
						THEN ReasonPanel
					END ASC
				,CASE 
					WHEN @pOrderBy = 'ReasonPanel'
						AND @pOrderType = 'desc'
						THEN ReasonPanel
					END DESC
				,CASE 
					WHEN @pOrderBy = 'Summary'
						AND @pOrderType = 'asc'
						THEN Summary
					END ASC
				,CASE 
					WHEN @pOrderBy = 'Summary'
						AND @pOrderType = 'desc'
						THEN Summary
					ELSE CreationTimeStamp
					END DESC
			--OFFSET @OFFSETRows ROWS
			--    FETCH NEXT @pPageSize ROWS ONLY
			OPTION (RECOMPILE)
		END
		ELSE
		-- Implemented displaying records functionality for France
		IF (
				@pdays = '30'
				AND @IsCountryEnabledRecordConfig = 1
				)
		BEGIN
			SELECT TOP 30 *
			FROM (
				SELECT T.IsUpdateReasonAllowed
					,T.IsDeleteReasonAllowed
					,T.CreationTimeStamp
					,T.GPSUser
					,T.CommEventId
					,T.Comment
					,T.ReasonId
					,T.ReasonCode
					,dbo.GetTranslationValue(TagTranslation_Id, @pCultureCode) AS ReasonLabel
					,ISNULL(p.NAME, '') AS ReasonPanel
					,CAST(CONVERT(VARCHAR(16), CONVERT(DATETIME, T.CreationDate, 103), 121) AS DATETIME) AS CreationDate
					,(FirstName + MiddleName + LastName) AS FirstName
					,T.MiddleName
					,T.LastName
					,T.Incoming
					,T.CallLength
					,IIF(Incoming = 1, @IncomingTranslation, @OutgoingTranslation) AS IncomingOrOutGoingLabel
					,T.ContactMechanismId
					,T.ContactMechanismCode
					,T.ContactMechanismTypeDescriptor
					,T.ContactMechanismLabel
					,T.summary AS Summary
					,T.Content AS Content
					,IIF(@EmailSentTransalationId = TagTranslation_Id, 1, 0) AS IsResendEmailAllowed
				FROM (
					SELECT IIF(cer.GPSUser = @pGPSUser, 1, 0) AS IsUpdateReasonAllowed
						,IIF(ce.STATE = @pStateInProgress
							AND cer.GPSUser = @pGPSUser, 1, 0) AS IsDeleteReasonAllowed
						,Ce.GUIDReference AS CommEventId
						,CE.GPSUSER AS GPSUser
						,IIF(dbo.IsFieldRequiredOrFieldVisible(@pCountryId, 'FirstName', 1) = 1, PersIdentity.FirstOrderedName + ' ', '') AS FirstName
						,IIF(dbo.IsFieldRequiredOrFieldVisible(@pCountryId, 'MiddleName', 1) = 1, PersIdentity.MiddleOrderedName + ' ', '') AS MiddleName
						,IIF(dbo.IsFieldRequiredOrFieldVisible(@pCountryId, 'LastName', 1) = 1, PersIdentity.LastOrderedName + ' ', '') AS LastName
						,CER.CreationTimeStamp AS CreationDate
						,ce.CallLength
						,cer.GUIDReference AS ReasonId
						,CERType.CommEventReasonCode AS ReasonCode
						,cer.Comment
						,ce.Incoming
						,cer.CreationTimeStamp AS CreationTimeStamp
						,IIF(ISNULL(ED.[Subject], '') = '', ISNULL(td.[Message], ''), ED.[Subject]) AS Summary
						,SUBSTRING(IIF(ISNULL(ED.EmailContent, '') = '', ISNULL(td.[Message], ''), ED.EmailContent),0,500) AS Content
						,CONVERT(NVARCHAR(MAX), cer.panel_id) AS panel_id
						,CERType.TagTranslation_Id
						,CMT.GUIDReference AS ContactMechanismId
						,CMT.ContactMechanismCode
						,dbo.GetTranslationValue(CMT.TypeTranslation_Id, NULL) AS ContactMechanismTypeDescriptor
						,dbo.GetTranslationValue(CMT.DescriptionTranslation_Id, @pCultureCode) AS ContactMechanismLabel
						,ED.[Subject] AS ESubject
						,td.[Message] AS EMessage
						,cer.Comment AS EComment
					FROM @Individuals i
					JOIN Individual Indv ON i.Id = Indv.GUIDReference
					JOIN PersonalIdentification PersIdentity ON Indv.PersonalIdentificationId = PersIdentity.PersonalIdentificationId
					JOIN CommunicationEvent CE ON Indv.GUIDReference = ce.Candidate_Id
					JOIN CommunicationEventReason CER ON cer.Communication_Id = ce.GUIDReference
					JOIN CommunicationEventReasonType CERType ON CER.ReasonType_Id = CERType.GUIDReference
					LEFT JOIN DocumentCommunicationEventAssociation DCEA ON DCEA.CommunicationEventId = ce.guidreference
					LEFT JOIN Document Doc ON doc.DocumentId = DCEA.DocumentId
					LEFT JOIN ContactMechanismType CMT ON CE.ContactMechanism_Id = CMT.GUIDReference
					LEFT JOIN TextDocument TD ON TD.DocumentId = Doc.DocumentId
					LEFT JOIN emaildocument ED ON ed.DocumentId = Doc.DocumentId
					WHERE CER.CreationTimeStamp >= @EndDate
					) AS T
				LEFT JOIN panel p ON GUIDReference = panel_id
				) AS ResultTable
			WHERE (
					(@op1 IS NULL)
					OR (
						@op1 = @IsEqualTo
						AND GPSUser = @GPSUser
						)
					OR (
						@op1 = @IsNotEqualTo
						AND GPSUser <> @GPSUser
						)
					OR (
						@op1 = @IsLessThan
						AND GPSUser < @GPSUser
						)
					OR (
						@op1 = @IsLessThanOrEqualTo
						AND GPSUser <= @GPSUser
						)
					OR (
						@op1 = @IsGreaterThan
						AND GPSUser > @GPSUser
						)
					OR (
						@op1 = @IsGreaterThanOrEqualTo
						AND GPSUser >= @GPSUser
						)
					OR (
						@op1 = @Contains
						AND GPSUser LIKE '%' + @GPSUser + '%'
						)
					OR (
						@op1 = @DoesNotContain
						AND GPSUser NOT LIKE '%' + @GPSUser + '%'
						)
					OR (
						@op1 = @StartsWith
						AND GPSUser LIKE '' + @GPSUser + '%'
						)
					OR (
						@op1 = @EndsWith
						AND GPSUser LIKE '%' + @GPSUser + ''
						)
					)
				AND (
					(@op2 IS NULL)
					OR (
						@op2 = @IsEqualTo
						AND FirstName = @FirstName
						)
					OR (
						@op2 = @IsNotEqualTo
						AND FirstName <> @FirstName
						)
					OR (
						@op2 = @IsLessThan
						AND FirstName < @FirstName
						)
					OR (
						@op2 = @IsLessThanOrEqualTo
						AND FirstName <= @FirstName
						)
					OR (
						@op2 = @IsGreaterThan
						AND FirstName > @FirstName
						)
					OR (
						@op2 = @IsGreaterThanOrEqualTo
						AND FirstName >= @FirstName
						)
					OR (
						@op2 = @Contains
						AND FirstName LIKE '%' + @FirstName + '%'
						)
					OR (
						@op2 = @DoesNotContain
						AND FirstName NOT LIKE '%' + @FirstName + '%'
						)
					OR (
						@op2 = @StartsWith
						AND FirstName LIKE '' + @FirstName + '%'
						)
					OR (
						@op2 = @EndsWith
						AND FirstName LIKE '%' + @FirstName + ''
						)
					)
				AND (
					(@op3 IS NULL)
					OR (
						@op3 IS NULL
						AND @LogicalOperator3 IS NULL
						)
					OR (
						@LogicalOperator3 = 'OR'
						AND (
							(
								(
									@op3 = @IsEqualTo
									AND CreationDate = @CreationDate
									)
								OR (
									@op3 = @IsNotEqualTo
									AND CreationDate <> @CreationDate
									)
								OR (
									@op3 = @IsLessThan
									AND CreationDate < @CreationDate
									)
								OR (
									@op3 = @IsLessThanOrEqualTo
									AND CreationDate <= @CreationDate
									)
								OR (
									@op3 = @IsGreaterThan
									AND CreationDate > @CreationDate
									)
								OR (
									@op3 = @IsGreaterThanOrEqualTo
									AND CreationDate >= @CreationDate
									)
								OR (
									@op3 = @Contains
									AND CreationDate LIKE '%' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @DoesNotContain
									AND CreationDate NOT LIKE '%' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @StartsWith
									AND CreationDate LIKE '' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @EndsWith
									AND CreationDate LIKE '%' + @CreationDateVARCHAR + ''
									)
								)
							OR (
								(
									@Secondop3 = @IsEqualTo
									AND CreationDate = @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsNotEqualTo
									AND CreationDate <> @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsLessThan
									AND CreationDate < @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsLessThanOrEqualTo
									AND CreationDate <= @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsGreaterThan
									AND CreationDate > @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsGreaterThanOrEqualTo
									AND CreationDate >= @SecondCreationDate
									)
								OR (
									@Secondop3 = @Contains
									AND CreationDate LIKE '%' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @DoesNotContain
									AND CreationDate NOT LIKE '%' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @StartsWith
									AND CreationDate LIKE '' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @EndsWith
									AND CreationDate LIKE '%' + @SecondCreationDateVARCHAR + ''
									)
								)
							)
						)
					OR (
						@LogicalOperator3 = 'AND'
						AND (
							(
								(
									@op3 = @IsEqualTo
									AND CreationDate = @CreationDate
									)
								OR (
									@op3 = @IsNotEqualTo
									AND CreationDate <> @CreationDate
									)
								OR (
									@op3 = @IsLessThan
									AND CreationDate < @CreationDate
									)
								OR (
									@op3 = @IsLessThanOrEqualTo
									AND CreationDate <= @CreationDate
									)
								OR (
									@op3 = @IsGreaterThan
									AND CreationDate > @CreationDate
									)
								OR (
									@op3 = @IsGreaterThanOrEqualTo
									AND CreationDate >= @CreationDate
									)
								OR (
									@op3 = @Contains
									AND CreationDate LIKE '%' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @DoesNotContain
									AND CreationDate NOT LIKE '%' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @StartsWith
									AND CreationDate LIKE '' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @EndsWith
									AND CreationDate LIKE '%' + @CreationDateVARCHAR + ''
									)
								)
							AND (
								(
									@Secondop3 = @IsEqualTo
									AND CreationDate = @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsNotEqualTo
									AND CreationDate <> @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsLessThan
									AND CreationDate < @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsLessThanOrEqualTo
									AND CreationDate <= @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsGreaterThan
									AND CreationDate > @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsGreaterThanOrEqualTo
									AND CreationDate >= @SecondCreationDate
									)
								OR (
									@Secondop3 = @Contains
									AND CreationDate LIKE '%' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @DoesNotContain
									AND CreationDate NOT LIKE '%' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @StartsWith
									AND CreationDate LIKE '' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @EndsWith
									AND CreationDate LIKE '%' + @SecondCreationDateVARCHAR + ''
									)
								)
							)
						)
					OR (
						@op3 = @IsEqualTo
						AND @Secondop3 IS NULL
						AND CreationDate = @CreationDate
						)
					OR (
						@op3 = @IsNotEqualTo
						AND @Secondop3 IS NULL
						AND CreationDate <> @CreationDate
						)
					OR (
						@op3 = @IsLessThan
						AND @Secondop3 IS NULL
						AND CreationDate < @CreationDate
						)
					OR (
						@op3 = @IsLessThanOrEqualTo
						AND @Secondop3 IS NULL
						AND CreationDate <= @CreationDate
						)
					OR (
						@op3 = @IsGreaterThan
						AND @Secondop3 IS NULL
						AND CreationDate > @CreationDate
						)
					OR (
						@op3 = @IsGreaterThanOrEqualTo
						AND @Secondop3 IS NULL
						AND CreationDate >= @CreationDate
						)
					OR (
						@op3 = @Contains
						AND @Secondop3 IS NULL
						AND CreationDate LIKE '%' + @CreationDateVARCHAR + '%'
						)
					OR (
						@op3 = @DoesNotContain
						AND @Secondop3 IS NULL
						AND CreationDate NOT LIKE '%' + @CreationDateVARCHAR + '%'
						)
					OR (
						@op3 = @StartsWith
						AND @Secondop3 IS NULL
						AND CreationDate LIKE '' + @CreationDateVARCHAR + '%'
						)
					OR (
						@op3 = @EndsWith
						AND @Secondop3 IS NULL
						AND CreationDate LIKE '%' + @CreationDateVARCHAR + ''
						)
					)
				AND (
					(@op4 IS NULL)
					OR (
						@op4 = @IsEqualTo
						AND ReasonCode = @ReasonCode
						)
					OR (
						@op4 = @IsNotEqualTo
						AND ReasonCode <> @ReasonCode
						)
					OR (
						@op4 = @IsLessThan
						AND ReasonCode < @ReasonCode
						)
					OR (
						@op4 = @IsLessThanOrEqualTo
						AND ReasonCode <= @ReasonCode
						)
					OR (
						@op4 = @IsGreaterThan
						AND ReasonCode > @ReasonCode
						)
					OR (
						@op4 = @IsGreaterThanOrEqualTo
						AND ReasonCode >= @ReasonCode
						)
					OR (
						@op4 = @Contains
						AND ReasonCode LIKE '%' + @ReasonCode + '%'
						)
					OR (
						@op4 = @DoesNotContain
						AND ReasonCode NOT LIKE '%' + @ReasonCode + '%'
						)
					OR (
						@op4 = @StartsWith
						AND ReasonCode LIKE '' + @ReasonCode + '%'
						)
					OR (
						@op4 = @EndsWith
						AND ReasonCode LIKE '%' + @ReasonCode + ''
						)
					)
				AND (
					(@op5 IS NULL)
					OR (
						@op5 = @IsEqualTo
						AND ReasonLabel = @ReasonLabel
						)
					OR (
						@op5 = @IsNotEqualTo
						AND ReasonLabel <> @ReasonLabel
						)
					OR (
						@op5 = @IsLessThan
						AND ReasonLabel < @ReasonLabel
						)
					OR (
						@op5 = @IsLessThanOrEqualTo
						AND ReasonLabel <= @ReasonLabel
						)
					OR (
						@op5 = @IsGreaterThan
						AND ReasonLabel > @ReasonLabel
						)
					OR (
						@op5 = @IsGreaterThanOrEqualTo
						AND ReasonLabel >= @ReasonLabel
						)
					OR (
						@op5 = @Contains
						AND ReasonLabel LIKE '%' + @ReasonLabel + '%'
						)
					OR (
						@op5 = @DoesNotContain
						AND ReasonLabel NOT LIKE '%' + @ReasonLabel + '%'
						)
					OR (
						@op5 = @StartsWith
						AND ReasonLabel LIKE '' + @ReasonLabel + '%'
						)
					OR (
						@op5 = @EndsWith
						AND ReasonLabel LIKE '%' + @ReasonLabel + ''
						)
					)
				AND (
					(@op6 IS NULL)
					OR (
						@op6 = @IsEqualTo
						AND ReasonPanel = @ReasonPanel
						)
					OR (
						@op6 = @IsNotEqualTo
						AND ReasonPanel <> @ReasonPanel
						)
					OR (
						@op6 = @IsLessThan
						AND ReasonPanel < @ReasonPanel
						)
					OR (
						@op6 = @IsLessThanOrEqualTo
						AND ReasonPanel <= @ReasonPanel
						)
					OR (
						@op6 = @IsGreaterThan
						AND ReasonPanel > @ReasonPanel
						)
					OR (
						@op6 = @IsGreaterThanOrEqualTo
						AND ReasonPanel >= @ReasonPanel
						)
					OR (
						@op6 = @Contains
						AND ReasonPanel LIKE '%' + @ReasonPanel + '%'
						)
					OR (
						@op6 = @DoesNotContain
						AND ReasonPanel NOT LIKE '%' + @ReasonPanel + '%'
						)
					OR (
						@op6 = @StartsWith
						AND ReasonPanel LIKE '' + @ReasonPanel + '%'
						)
					OR (
						@op6 = @EndsWith
						AND ReasonPanel LIKE '%' + @ReasonPanel + ''
						)
					)
				AND (
					(@op7 IS NULL)
					OR (
						@op7 = @IsEqualTo
						AND Comment = @Summary
						)
					OR (
						@op7 = @IsNotEqualTo
						AND Comment <> @Summary
						)
					OR (
						@op7 = @IsLessThan
						AND Comment < @Summary
						)
					OR (
						@op7 = @IsLessThanOrEqualTo
						AND Comment <= @Summary
						)
					OR (
						@op7 = @IsGreaterThan
						AND Comment > @Summary
						)
					OR (
						@op7 = @IsGreaterThanOrEqualTo
						AND Comment >= @Summary
						)
					OR (
						@op7 = @Contains
						AND Comment LIKE '%' + @Summary + '%'
						)
					OR (
						@op7 = @DoesNotContain
						AND Comment NOT LIKE '%' + @Summary + '%'
						)
					OR (
						@op7 = @StartsWith
						AND Comment LIKE '' + @Summary + '%'
						)
					OR (
						@op7 = @EndsWith
						AND Summary LIKE '%' + @Summary + ''
						)
					)
			ORDER BY CASE 
					WHEN @pOrderBy = 'GpsUser'
						AND @pOrderType = 'asc'
						THEN GpsUser
					END ASC
				,CASE 
					WHEN @pOrderBy = 'GpsUser'
						AND @pOrderType = 'desc'
						THEN GpsUser
					END DESC
				,CASE 
					WHEN @pOrderBy = 'FirstName'
						AND @pOrderType = 'asc'
						THEN FirstName
					END ASC
				,CASE 
					WHEN @pOrderBy = 'FirstName'
						AND @pOrderType = 'desc'
						THEN FirstName
					END DESC
				,CASE 
					WHEN @pOrderBy = 'CreationDate'
						AND @pOrderType = 'asc'
						THEN CreationDate
					END ASC
				,CASE 
					WHEN @pOrderBy = 'CreationDate'
						AND @pOrderType = 'desc'
						THEN CreationDate
					END DESC
				,CASE 
					WHEN @pOrderBy = 'ReasonCode'
						AND @pOrderType = 'asc'
						THEN ReasonCode
					END ASC
				,CASE 
					WHEN @pOrderBy = 'ReasonCode'
						AND @pOrderType = 'desc'
						THEN ReasonCode
					END DESC
				,CASE 
					WHEN @pOrderBy = 'ReasonLabel'
						AND @pOrderType = 'asc'
						THEN ReasonLabel
					END ASC
				,CASE 
					WHEN @pOrderBy = 'ReasonLabel'
						AND @pOrderType = 'desc'
						THEN ReasonLabel
					END DESC
				,CASE 
					WHEN @pOrderBy = 'ReasonPanel'
						AND @pOrderType = 'asc'
						THEN ReasonPanel
					END ASC
				,CASE 
					WHEN @pOrderBy = 'ReasonPanel'
						AND @pOrderType = 'desc'
						THEN ReasonPanel
					END DESC
				,CASE 
					WHEN @pOrderBy = 'Summary'
						AND @pOrderType = 'asc'
						THEN Summary
					END ASC
				,CASE 
					WHEN @pOrderBy = 'Summary'
						AND @pOrderType = 'desc'
						THEN Summary
					ELSE CreationTimeStamp
					END DESC
			--OFFSET @OFFSETRows ROWS
			--    FETCH NEXT @pPageSize ROWS ONLY
			OPTION (RECOMPILE)
		END
		ELSE IF (
				(
					@pdays = '10'
					AND @IsCountryEnabledRecordConfig = 1
					)
				OR (
					@pdays = 'default'
					AND @IsCountryEnabledRecordConfig = 1
					)
				)
		BEGIN
			SELECT TOP 10 *
			FROM (
				SELECT T.IsUpdateReasonAllowed
					,T.IsDeleteReasonAllowed
					,T.CreationTimeStamp
					,T.GPSUser
					,T.CommEventId
					,T.Comment
					,T.ReasonId
					,T.ReasonCode
					,dbo.GetTranslationValue(TagTranslation_Id, @pCultureCode) AS ReasonLabel
					,ISNULL(p.NAME, '') AS ReasonPanel
					,CAST(CONVERT(VARCHAR(16), CONVERT(DATETIME, T.CreationDate, 103), 121) AS DATETIME) AS CreationDate
					,(FirstName + MiddleName + LastName) AS FirstName
					,T.MiddleName
					,T.LastName
					,T.Incoming
					,T.CallLength
					,IIF(Incoming = 1, @IncomingTranslation, @OutgoingTranslation) AS IncomingOrOutGoingLabel
					,T.ContactMechanismId
					,T.ContactMechanismCode
					,T.ContactMechanismTypeDescriptor
					,T.ContactMechanismLabel
					,T.summary AS Summary
					,T.Content AS Content
					,IIF(@EmailSentTransalationId = TagTranslation_Id, 1, 0) AS IsResendEmailAllowed
				FROM (
					SELECT IIF(cer.GPSUser = @pGPSUser, 1, 0) AS IsUpdateReasonAllowed
						,IIF(ce.STATE = @pStateInProgress
							AND cer.GPSUser = @pGPSUser, 1, 0) AS IsDeleteReasonAllowed
						,Ce.GUIDReference AS CommEventId
						,CE.GPSUSER AS GPSUser
						,IIF(dbo.IsFieldRequiredOrFieldVisible(@pCountryId, 'FirstName', 1) = 1, PersIdentity.FirstOrderedName + ' ', '') AS FirstName
						,IIF(dbo.IsFieldRequiredOrFieldVisible(@pCountryId, 'MiddleName', 1) = 1, PersIdentity.MiddleOrderedName + ' ', '') AS MiddleName
						,IIF(dbo.IsFieldRequiredOrFieldVisible(@pCountryId, 'LastName', 1) = 1, PersIdentity.LastOrderedName + ' ', '') AS LastName
						,CER.CreationTimeStamp AS CreationDate
						,ce.CallLength
						,cer.GUIDReference AS ReasonId
						,CERType.CommEventReasonCode AS ReasonCode
						,cer.Comment
						,ce.Incoming
						,cer.CreationTimeStamp AS CreationTimeStamp
						,IIF(ISNULL(ED.[Subject], '') = '', ISNULL(td.[Message], ''), ED.[Subject]) AS Summary
						,SUBSTRING(IIF(ISNULL(ED.EmailContent, '') = '', ISNULL(td.[Message], ''), ED.EmailContent),0,500) AS Content
						,CONVERT(NVARCHAR(MAX), cer.panel_id) AS panel_id
						,CERType.TagTranslation_Id
						,CMT.GUIDReference AS ContactMechanismId
						,CMT.ContactMechanismCode
						,dbo.GetTranslationValue(CMT.TypeTranslation_Id, NULL) AS ContactMechanismTypeDescriptor
						,dbo.GetTranslationValue(CMT.DescriptionTranslation_Id, @pCultureCode) AS ContactMechanismLabel
						,ED.[Subject] AS ESubject
						,td.[Message] AS EMessage
						,cer.Comment AS EComment
					FROM @Individuals i
					JOIN Individual Indv ON i.Id = Indv.GUIDReference
					JOIN PersonalIdentification PersIdentity ON Indv.PersonalIdentificationId = PersIdentity.PersonalIdentificationId
					JOIN CommunicationEvent CE ON Indv.GUIDReference = ce.Candidate_Id
					JOIN CommunicationEventReason CER ON cer.Communication_Id = ce.GUIDReference
					JOIN CommunicationEventReasonType CERType ON CER.ReasonType_Id = CERType.GUIDReference
					LEFT JOIN DocumentCommunicationEventAssociation DCEA ON DCEA.CommunicationEventId = ce.guidreference
					LEFT JOIN Document Doc ON doc.DocumentId = DCEA.DocumentId
					LEFT JOIN ContactMechanismType CMT ON CE.ContactMechanism_Id = CMT.GUIDReference
					LEFT JOIN TextDocument TD ON TD.DocumentId = Doc.DocumentId
					LEFT JOIN emaildocument ED ON ed.DocumentId = Doc.DocumentId
					WHERE CER.CreationTimeStamp >= @EndDate
					) AS T
				LEFT JOIN panel p ON GUIDReference = panel_id
				) AS ResultTable
			WHERE (
					(@op1 IS NULL)
					OR (
						@op1 = @IsEqualTo
						AND GPSUser = @GPSUser
						)
					OR (
						@op1 = @IsNotEqualTo
						AND GPSUser <> @GPSUser
						)
					OR (
						@op1 = @IsLessThan
						AND GPSUser < @GPSUser
						)
					OR (
						@op1 = @IsLessThanOrEqualTo
						AND GPSUser <= @GPSUser
						)
					OR (
						@op1 = @IsGreaterThan
						AND GPSUser > @GPSUser
						)
					OR (
						@op1 = @IsGreaterThanOrEqualTo
						AND GPSUser >= @GPSUser
						)
					OR (
						@op1 = @Contains
						AND GPSUser LIKE '%' + @GPSUser + '%'
						)
					OR (
						@op1 = @DoesNotContain
						AND GPSUser NOT LIKE '%' + @GPSUser + '%'
						)
					OR (
						@op1 = @StartsWith
						AND GPSUser LIKE '' + @GPSUser + '%'
						)
					OR (
						@op1 = @EndsWith
						AND GPSUser LIKE '%' + @GPSUser + ''
						)
					)
				AND (
					(@op2 IS NULL)
					OR (
						@op2 = @IsEqualTo
						AND FirstName = @FirstName
						)
					OR (
						@op2 = @IsNotEqualTo
						AND FirstName <> @FirstName
						)
					OR (
						@op2 = @IsLessThan
						AND FirstName < @FirstName
						)
					OR (
						@op2 = @IsLessThanOrEqualTo
						AND FirstName <= @FirstName
						)
					OR (
						@op2 = @IsGreaterThan
						AND FirstName > @FirstName
						)
					OR (
						@op2 = @IsGreaterThanOrEqualTo
						AND FirstName >= @FirstName
						)
					OR (
						@op2 = @Contains
						AND FirstName LIKE '%' + @FirstName + '%'
						)
					OR (
						@op2 = @DoesNotContain
						AND FirstName NOT LIKE '%' + @FirstName + '%'
						)
					OR (
						@op2 = @StartsWith
						AND FirstName LIKE '' + @FirstName + '%'
						)
					OR (
						@op2 = @EndsWith
						AND FirstName LIKE '%' + @FirstName + ''
						)
					)
				AND (
					(@op3 IS NULL)
					OR (
						@op3 IS NULL
						AND @LogicalOperator3 IS NULL
						)
					OR (
						@LogicalOperator3 = 'OR'
						AND (
							(
								(
									@op3 = @IsEqualTo
									AND CreationDate = @CreationDate
									)
								OR (
									@op3 = @IsNotEqualTo
									AND CreationDate <> @CreationDate
									)
								OR (
									@op3 = @IsLessThan
									AND CreationDate < @CreationDate
									)
								OR (
									@op3 = @IsLessThanOrEqualTo
									AND CreationDate <= @CreationDate
									)
								OR (
									@op3 = @IsGreaterThan
									AND CreationDate > @CreationDate
									)
								OR (
									@op3 = @IsGreaterThanOrEqualTo
									AND CreationDate >= @CreationDate
									)
								OR (
									@op3 = @Contains
									AND CreationDate LIKE '%' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @DoesNotContain
									AND CreationDate NOT LIKE '%' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @StartsWith
									AND CreationDate LIKE '' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @EndsWith
									AND CreationDate LIKE '%' + @CreationDateVARCHAR + ''
									)
								)
							OR (
								(
									@Secondop3 = @IsEqualTo
									AND CreationDate = @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsNotEqualTo
									AND CreationDate <> @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsLessThan
									AND CreationDate < @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsLessThanOrEqualTo
									AND CreationDate <= @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsGreaterThan
									AND CreationDate > @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsGreaterThanOrEqualTo
									AND CreationDate >= @SecondCreationDate
									)
								OR (
									@Secondop3 = @Contains
									AND CreationDate LIKE '%' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @DoesNotContain
									AND CreationDate NOT LIKE '%' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @StartsWith
									AND CreationDate LIKE '' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @EndsWith
									AND CreationDate LIKE '%' + @SecondCreationDateVARCHAR + ''
									)
								)
							)
						)
					OR (
						@LogicalOperator3 = 'AND'
						AND (
							(
								(
									@op3 = @IsEqualTo
									AND CreationDate = @CreationDate
									)
								OR (
									@op3 = @IsNotEqualTo
									AND CreationDate <> @CreationDate
									)
								OR (
									@op3 = @IsLessThan
									AND CreationDate < @CreationDate
									)
								OR (
									@op3 = @IsLessThanOrEqualTo
									AND CreationDate <= @CreationDate
									)
								OR (
									@op3 = @IsGreaterThan
									AND CreationDate > @CreationDate
									)
								OR (
									@op3 = @IsGreaterThanOrEqualTo
									AND CreationDate >= @CreationDate
									)
								OR (
									@op3 = @Contains
									AND CreationDate LIKE '%' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @DoesNotContain
									AND CreationDate NOT LIKE '%' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @StartsWith
									AND CreationDate LIKE '' + @CreationDateVARCHAR + '%'
									)
								OR (
									@op3 = @EndsWith
									AND CreationDate LIKE '%' + @CreationDateVARCHAR + ''
									)
								)
							AND (
								(
									@Secondop3 = @IsEqualTo
									AND CreationDate = @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsNotEqualTo
									AND CreationDate <> @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsLessThan
									AND CreationDate < @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsLessThanOrEqualTo
									AND CreationDate <= @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsGreaterThan
									AND CreationDate > @SecondCreationDate
									)
								OR (
									@Secondop3 = @IsGreaterThanOrEqualTo
									AND CreationDate >= @SecondCreationDate
									)
								OR (
									@Secondop3 = @Contains
									AND CreationDate LIKE '%' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @DoesNotContain
									AND CreationDate NOT LIKE '%' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @StartsWith
									AND CreationDate LIKE '' + @SecondCreationDateVARCHAR + '%'
									)
								OR (
									@Secondop3 = @EndsWith
									AND CreationDate LIKE '%' + @SecondCreationDateVARCHAR + ''
									)
								)
							)
						)
					OR (
						@op3 = @IsEqualTo
						AND @Secondop3 IS NULL
						AND CreationDate = @CreationDate
						)
					OR (
						@op3 = @IsNotEqualTo
						AND @Secondop3 IS NULL
						AND CreationDate <> @CreationDate
						)
					OR (
						@op3 = @IsLessThan
						AND @Secondop3 IS NULL
						AND CreationDate < @CreationDate
						)
					OR (
						@op3 = @IsLessThanOrEqualTo
						AND @Secondop3 IS NULL
						AND CreationDate <= @CreationDate
						)
					OR (
						@op3 = @IsGreaterThan
						AND @Secondop3 IS NULL
						AND CreationDate > @CreationDate
						)
					OR (
						@op3 = @IsGreaterThanOrEqualTo
						AND @Secondop3 IS NULL
						AND CreationDate >= @CreationDate
						)
					OR (
						@op3 = @Contains
						AND @Secondop3 IS NULL
						AND CreationDate LIKE '%' + @CreationDateVARCHAR + '%'
						)
					OR (
						@op3 = @DoesNotContain
						AND @Secondop3 IS NULL
						AND CreationDate NOT LIKE '%' + @CreationDateVARCHAR + '%'
						)
					OR (
						@op3 = @StartsWith
						AND @Secondop3 IS NULL
						AND CreationDate LIKE '' + @CreationDateVARCHAR + '%'
						)
					OR (
						@op3 = @EndsWith
						AND @Secondop3 IS NULL
						AND CreationDate LIKE '%' + @CreationDateVARCHAR + ''
						)
					)
				AND (
					(@op4 IS NULL)
					OR (
						@op4 = @IsEqualTo
						AND ReasonCode = @ReasonCode
						)
					OR (
						@op4 = @IsNotEqualTo
						AND ReasonCode <> @ReasonCode
						)
					OR (
						@op4 = @IsLessThan
						AND ReasonCode < @ReasonCode
						)
					OR (
						@op4 = @IsLessThanOrEqualTo
						AND ReasonCode <= @ReasonCode
						)
					OR (
						@op4 = @IsGreaterThan
						AND ReasonCode > @ReasonCode
						)
					OR (
						@op4 = @IsGreaterThanOrEqualTo
						AND ReasonCode >= @ReasonCode
						)
					OR (
						@op4 = @Contains
						AND ReasonCode LIKE '%' + @ReasonCode + '%'
						)
					OR (
						@op4 = @DoesNotContain
						AND ReasonCode NOT LIKE '%' + @ReasonCode + '%'
						)
					OR (
						@op4 = @StartsWith
						AND ReasonCode LIKE '' + @ReasonCode + '%'
						)
					OR (
						@op4 = @EndsWith
						AND ReasonCode LIKE '%' + @ReasonCode + ''
						)
					)
				AND (
					(@op5 IS NULL)
					OR (
						@op5 = @IsEqualTo
						AND ReasonLabel = @ReasonLabel
						)
					OR (
						@op5 = @IsNotEqualTo
						AND ReasonLabel <> @ReasonLabel
						)
					OR (
						@op5 = @IsLessThan
						AND ReasonLabel < @ReasonLabel
						)
					OR (
						@op5 = @IsLessThanOrEqualTo
						AND ReasonLabel <= @ReasonLabel
						)
					OR (
						@op5 = @IsGreaterThan
						AND ReasonLabel > @ReasonLabel
						)
					OR (
						@op5 = @IsGreaterThanOrEqualTo
						AND ReasonLabel >= @ReasonLabel
						)
					OR (
						@op5 = @Contains
						AND ReasonLabel LIKE '%' + @ReasonLabel + '%'
						)
					OR (
						@op5 = @DoesNotContain
						AND ReasonLabel NOT LIKE '%' + @ReasonLabel + '%'
						)
					OR (
						@op5 = @StartsWith
						AND ReasonLabel LIKE '' + @ReasonLabel + '%'
						)
					OR (
						@op5 = @EndsWith
						AND ReasonLabel LIKE '%' + @ReasonLabel + ''
						)
					)
				AND (
					(@op6 IS NULL)
					OR (
						@op6 = @IsEqualTo
						AND ReasonPanel = @ReasonPanel
						)
					OR (
						@op6 = @IsNotEqualTo
						AND ReasonPanel <> @ReasonPanel
						)
					OR (
						@op6 = @IsLessThan
						AND ReasonPanel < @ReasonPanel
						)
					OR (
						@op6 = @IsLessThanOrEqualTo
						AND ReasonPanel <= @ReasonPanel
						)
					OR (
						@op6 = @IsGreaterThan
						AND ReasonPanel > @ReasonPanel
						)
					OR (
						@op6 = @IsGreaterThanOrEqualTo
						AND ReasonPanel >= @ReasonPanel
						)
					OR (
						@op6 = @Contains
						AND ReasonPanel LIKE '%' + @ReasonPanel + '%'
						)
					OR (
						@op6 = @DoesNotContain
						AND ReasonPanel NOT LIKE '%' + @ReasonPanel + '%'
						)
					OR (
						@op6 = @StartsWith
						AND ReasonPanel LIKE '' + @ReasonPanel + '%'
						)
					OR (
						@op6 = @EndsWith
						AND ReasonPanel LIKE '%' + @ReasonPanel + ''
						)
					)
				AND (
					(@op7 IS NULL)
					OR (
						@op7 = @IsEqualTo
						AND Comment = @Summary
						)
					OR (
						@op7 = @IsNotEqualTo
						AND Comment <> @Summary
						)
					OR (
						@op7 = @IsLessThan
						AND Comment < @Summary
						)
					OR (
						@op7 = @IsLessThanOrEqualTo
						AND Comment <= @Summary
						)
					OR (
						@op7 = @IsGreaterThan
						AND Comment > @Summary
						)
					OR (
						@op7 = @IsGreaterThanOrEqualTo
						AND Comment >= @Summary
						)
					OR (
						@op7 = @Contains
						AND Comment LIKE '%' + @Summary + '%'
						)
					OR (
						@op7 = @DoesNotContain
						AND Comment NOT LIKE '%' + @Summary + '%'
						)
					OR (
						@op7 = @StartsWith
						AND Comment LIKE '' + @Summary + '%'
						)
					OR (
						@op7 = @EndsWith
						AND Summary LIKE '%' + @Summary + ''
						)
					)
			ORDER BY CASE 
					WHEN @pOrderBy = 'GpsUser'
						AND @pOrderType = 'asc'
						THEN GpsUser
					END ASC
				,CASE 
					WHEN @pOrderBy = 'GpsUser'
						AND @pOrderType = 'desc'
						THEN GpsUser
					END DESC
				,CASE 
					WHEN @pOrderBy = 'FirstName'
						AND @pOrderType = 'asc'
						THEN FirstName
					END ASC
				,CASE 
					WHEN @pOrderBy = 'FirstName'
						AND @pOrderType = 'desc'
						THEN FirstName
					END DESC
				,CASE 
					WHEN @pOrderBy = 'CreationDate'
						AND @pOrderType = 'asc'
						THEN CreationDate
					END ASC
				,CASE 
					WHEN @pOrderBy = 'CreationDate'
						AND @pOrderType = 'desc'
						THEN CreationDate
					END DESC
				,CASE 
					WHEN @pOrderBy = 'ReasonCode'
						AND @pOrderType = 'asc'
						THEN ReasonCode
					END ASC
				,CASE 
					WHEN @pOrderBy = 'ReasonCode'
						AND @pOrderType = 'desc'
						THEN ReasonCode
					END DESC
				,CASE 
					WHEN @pOrderBy = 'ReasonLabel'
						AND @pOrderType = 'asc'
						THEN ReasonLabel
					END ASC
				,CASE 
					WHEN @pOrderBy = 'ReasonLabel'
						AND @pOrderType = 'desc'
						THEN ReasonLabel
					END DESC
				,CASE 
					WHEN @pOrderBy = 'ReasonPanel'
						AND @pOrderType = 'asc'
						THEN ReasonPanel
					END ASC
				,CASE 
					WHEN @pOrderBy = 'ReasonPanel'
						AND @pOrderType = 'desc'
						THEN ReasonPanel
					END DESC
				,CASE 
					WHEN @pOrderBy = 'Summary'
						AND @pOrderType = 'asc'
						THEN Summary
					END ASC
				,CASE 
					WHEN @pOrderBy = 'Summary'
						AND @pOrderType = 'desc'
						THEN Summary
					ELSE CreationTimeStamp
					END DESC
			--OFFSET @OFFSETRows ROWS
			--    FETCH NEXT @pPageSize ROWS ONLY
			OPTION (RECOMPILE)
		END
	END TRY

	BEGIN CATCH
		RAISERROR (
				'Error executing the script'
				,16
				,1
				);
	END CATCH
END
