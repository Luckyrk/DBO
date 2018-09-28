
--CREATE







Create PROCEDURE GetTodaysCommunications (







	@pCountryId UNIQUEIDENTIFIER







	,@pCultureCode INT







	,@pDate DATETIME







	,@pGpsUser NVARCHAR(100)







	,@pInProgressStatus INT







	,@pIncomingTranslationKey NVARCHAR(1000)







	,@pOutgoingTranslationKey NVARCHAR(1000)







	,@pInProgressTranslationKey NVARCHAR(1000)







	,@pCompletedTranslationKey NVARCHAR(1000)







	,@pOrderBy VARCHAR(100)







	,@pOrderType VARCHAR(10)







	,@pPageNumber INT = 1







	,@pPageSize INT = 100







	,@pIsExport BIT = 0







	,@pParametersTable dbo.GridParametersTable readonly







	)







AS







BEGIN







	SET NOCOUNT ON;















	BEGIN TRY







		DECLARE @IncomingTranslation NVARCHAR(1000)







		DECLARE @OutgoingTranslation NVARCHAR(1000)







		DECLARE @InProgressLabel NVARCHAR(1000)







		DECLARE @CompletedLabel NVARCHAR(1000)







		DECLARE @BitTrue BIT = 1















		SELECT @IncomingTranslation = ISNULL(tr.Value, '{' + t.KeyName + '}')







		FROM Translation t







		LEFT JOIN TranslationTerm tr ON t.TranslationId = tr.Translation_Id







			AND tr.CultureCode = @pCultureCode







		WHERE t.KeyName = @pIncomingTranslationKey















		SELECT @OutgoingTranslation = ISNULL(tr.Value, '{' + t.KeyName + '}')







		FROM Translation t







		LEFT JOIN TranslationTerm tr ON t.TranslationId = tr.Translation_Id







			AND tr.CultureCode = @pCultureCode







		WHERE t.KeyName = @pOutgoingTranslationKey















		SELECT @InProgressLabel = ISNULL(tr.Value, '{' + t.KeyName + '}')







		FROM Translation t







		LEFT JOIN TranslationTerm tr ON t.TranslationId = tr.Translation_Id







			AND tr.CultureCode = @pCultureCode







		WHERE t.KeyName = @pInProgressTranslationKey















		SELECT @CompletedLabel = ISNULL(tr.Value, '{' + t.KeyName + '}')







		FROM Translation t







		LEFT JOIN TranslationTerm tr ON t.TranslationId = tr.Translation_Id







			AND tr.CultureCode = @pCultureCode







		WHERE t.KeyName = @pCompletedTranslationKey















		DECLARE @op1 VARCHAR(50)







			,@op2 VARCHAR(50)







			--,@op3 VARCHAR(50)







			--,@op4 VARCHAR(50)







			,@op5 VARCHAR(50)







			,@op6 VARCHAR(50)







			,@op7 VARCHAR(50)







			,@op8 VARCHAR(50)







			,@op9 VARCHAR(50)







		DECLARE @LogicalOperator5 VARCHAR(5)







		DECLARE @Secondop5 VARCHAR(50)







		DECLARE @SecondCreationDate DATETIME







		DECLARE @BusinessId NVARCHAR(100)







			,@Name NVARCHAR(MAX)







			,@CreationDate DATETIME







			,@IncomingOrOutGoingLabel NVARCHAR(1000)







			,@ContactMechanismLabel NVARCHAR(1000)







			,@StateLabel NVARCHAR(1000)







			,@Summary NVARCHAR(500)















		SELECT @op1 = Opertor







			,@BusinessId = ParameterValue







		FROM @pParametersTable







		WHERE ParameterName = 'BusinessId'















		SELECT @op2 = Opertor







			,@Name = ParameterValue







		FROM @pParametersTable







		WHERE ParameterName = 'Name'















		SELECT @op5 = Opertor







			,@CreationDate = ParameterValue







			,@Secondop5 = SecondParameterOperator







			,@SecondCreationDate = SecondParameterValue







			,@LogicalOperator5 = LogicalOperator







		FROM @pParametersTable







		WHERE ParameterName = 'CreationDate'















		SELECT @op6 = Opertor







			,@IncomingOrOutGoingLabel = ParameterValue







		FROM @pParametersTable







		WHERE ParameterName = 'IncomingOrOutGoingLabel'















		SELECT @op7 = Opertor







			,@ContactMechanismLabel = ParameterValue







		FROM @pParametersTable







		WHERE ParameterName = 'ContactMechanismLabel'















		SELECT @op8 = Opertor







			,@StateLabel = ParameterValue







		FROM @pParametersTable







		WHERE ParameterName = 'StateLabel'















		SELECT @op9 = Opertor







			,@Summary = ParameterValue







		FROM @pParametersTable







		WHERE ParameterName = 'Summary'















		DECLARE @CreationDateVarchar VARCHAR(100) = CAST(@CreationDate AS VARCHAR)







			,@SecondCreationDateVarchar VARCHAR(100) = CAST(@SecondCreationDate AS VARCHAR)







		DECLARE @WhereParameter VARCHAR(MAX)







			,@pOrderByParameter VARCHAR(MAX) = NULL







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















		IF (@pOrderBy IS NULL)







		BEGIN







			SET @pOrderBy = 'CreationTimeStamp'







		END















		IF (@pOrderType IS NULL)







			SET @pOrderType = 'desc'















		IF (@pIsExport = 0)







			SET @OFFSETRows = (@pPageSize * (@pPageNumber - 1))







		ELSE







			SET @pPageSize = 15000;















		IF (@pIsExport = 0)







		BEGIN







			SELECT count(0)







			FROM (







				SELECT CreationDate







					,GPSUser







					,BusinessId







					--,FirstName







					--,LastName







					--,MiddleName







					,NAME







					,CreationTimeStamp







					,Incoming







					,IncomingOrOutGoingLabel







					,ContactMechanismId







					,ContactMechanismCode







					,ContactMechanismTypeDescriptor







					,ContactMechanismLabel







					,StateLabel







					,Summary







				FROM (







					SELECT ce.CreationDate AS CreationDate







						,ce.GPSUser AS GPSUser







						,i.IndividualId AS BusinessId







						,i.GUIDReference AS Id







						,dbo.GetFullName(pIdenti.FirstOrderedName, pIdenti.MiddleOrderedName, pIdenti.LastOrderedName) AS NAME







						--,pIdenti.FirstOrderedName AS FirstName







						--,pIdenti.LastOrderedName AS LastName







						--,pIdenti.MiddleOrderedName AS MiddleName







						,candi.CreationTimeStamp AS CreationTimeStamp







						,ce.Incoming AS Incoming







						,(







							CASE 







								WHEN ce.Incoming = @BitTrue







									THEN @IncomingTranslation







								ELSE @OutgoingTranslation







								END







							) AS IncomingOrOutGoingLabel







						,cet.GUIDReference AS ContactMechanismId







						,cet.ContactMechanismCode AS ContactMechanismCode







						,t.KeyName AS ContactMechanismTypeDescriptor







						,dbo.GetTranslationValue(cet.DescriptionTranslation_Id, @pCultureCode) AS ContactMechanismLabel







						,(







							CASE 







								WHEN (ce.[state] = @pInProgressStatus)







									THEN @InProgressLabel







								ELSE @CompletedLabel







								END







							) AS StateLabel







						,(







							CASE 







								WHEN ISNULL(ED.[Subject], '') = ''







									THEN ISNULL(td.[Message], '')







								ELSE ED.[Subject]







								END







							) --+ ' ' + ISNULL(cer.Comment, '') 







						AS Summary







					FROM Individual i







					INNER JOIN Candidate candi ON i.GUIDReference = candi.GUIDReference







						AND candi.Country_Id = @pCountryId







					INNER JOIN CommunicationEvent ce ON i.GUIDReference = ce.Candidate_Id







					INNER JOIN CommunicationEventReason CER ON ce.GUIDReference= cer.Communication_Id







                    INNER JOIN CommunicationEventReasonType CERType ON CERType.GUIDReference=CER.ReasonType_Id







					INNER JOIN ContactMechanismType cet ON ce.ContactMechanism_Id = cet.GUIDReference







					INNER JOIN PersonalIdentification pIdenti ON pIdenti.PersonalIdentificationId = i.PersonalIdentificationId







					INNER JOIN Translation t ON t.TranslationId = cet.TypeTranslation_Id







					LEFT JOIN DocumentCommunicationEventAssociation DCEA ON DCEA.CommunicationEventId = ce.guidreference







					LEFT JOIN Document Doc ON doc.DocumentId = DCEA.DocumentId







					LEFT JOIN TextDocument TD ON TD.DocumentId = Doc.DocumentId







					LEFT JOIN emaildocument ED ON ed.DocumentId = Doc.DocumentId







					WHERE ce.Country_Id = @pCountryId







						AND ce.GPSUser = @pGpsUser







						AND ce.CreationDate >= @pDate







					) Tbl







				WHERE (







						(@op1 IS NULL)







						OR (







							@op1 = @IsEqualTo







							AND BusinessId = @BusinessId







							)







						OR (







							@op1 = @IsNotEqualTo







							AND BusinessId <> @BusinessId







							)







						OR (







							@op1 = @IsLessThan







							AND BusinessId < @BusinessId







							)







						OR (







							@op1 = @IsLessThanOrEqualTo







							AND BusinessId <= @BusinessId







							)







						OR (







							@op1 = @IsGreaterThan







							AND BusinessId > @BusinessId







							)







						OR (







							@op1 = @IsGreaterThanOrEqualTo







							AND BusinessId >= @BusinessId







							)







						OR (







							@op1 = @Contains







							AND BusinessId LIKE '%' + @BusinessId + '%'







							)







						OR (







							@op1 = @DoesNotContain







							AND BusinessId NOT LIKE '%' + @BusinessId + '%'







							)







						OR (







							@op1 = @StartsWith







							AND BusinessId LIKE '' + @BusinessId + '%'







							)







						OR (







							@op1 = @EndsWith







							AND BusinessId LIKE '%' + @BusinessId + ''







							)







						)







					AND (







						(@op2 IS NULL)







						OR (







							@op2 = @IsEqualTo







							AND NAME = @Name







							)







						OR (







							@op2 = @IsNotEqualTo







							AND NAME <> @Name







							)







						OR (







							@op2 = @IsLessThan







							AND NAME < @Name







							)







						OR (







							@op2 = @IsLessThanOrEqualTo







							AND NAME <= @Name







							)







						OR (







							@op2 = @IsGreaterThan







							AND NAME > @Name







							)







						OR (







							@op2 = @IsGreaterThanOrEqualTo







							AND NAME >= @Name







							)







						OR (







							@op2 = @Contains







							AND NAME LIKE '%' + @Name + '%'







							)







						OR (







							@op2 = @DoesNotContain







							AND NAME NOT LIKE '%' + @Name + '%'







							)







						OR (







							@op2 = @StartsWith







							AND NAME LIKE '' + @Name + '%'







							)







						OR (







							@op2 = @EndsWith







							AND NAME LIKE '%' + @Name + ''







							)







						)







					AND (







						(@op5 IS NULL)







						OR (







							@op5 IS NULL







							AND @LogicalOperator5 IS NULL







							)







						OR (







							@LogicalOperator5 = 'OR'







							AND (







								(







									(







										@op5 = @IsEqualTo







										AND CreationDate = @CreationDate







										)







									OR (







										@op5 = @IsNotEqualTo







										AND CreationDate <> @CreationDate







										)







									OR (







										@op5 = @IsLessThan







										AND CreationDate < @CreationDate







										)







									OR (







										@op5 = @IsLessThanOrEqualTo







										AND CreationDate <= @CreationDate







										)







									OR (







										@op5 = @IsGreaterThan







										AND CreationDate > @CreationDate







										)







									OR (







										@op5 = @IsGreaterThanOrEqualTo







										AND CreationDate >= @CreationDate







										)







									OR (







										@op5 = @Contains







										AND CreationDate LIKE '%' + @CreationDateVarchar + '%'







										)







									OR (







										@op5 = @DoesNotContain







										AND CreationDate NOT LIKE '%' + @CreationDateVarchar + '%'







										)







									OR (







										@op5 = @StartsWith







										AND CreationDate LIKE '' + @CreationDateVarchar + '%'







										)







									OR (







										@op5 = @EndsWith







										AND CreationDate LIKE '%' + @CreationDateVarchar + ''







										)







									)







								OR (







									(







										@Secondop5 = @IsEqualTo







										AND CreationDate = @SecondCreationDate







										)







									OR (







										@Secondop5 = @IsNotEqualTo







										AND CreationDate <> @SecondCreationDate







										)







									OR (







										@Secondop5 = @IsLessThan







										AND CreationDate < @SecondCreationDate







										)







									OR (







										@Secondop5 = @IsLessThanOrEqualTo







										AND CreationDate <= @SecondCreationDate







										)







									OR (







										@Secondop5 = @IsGreaterThan







										AND CreationDate > @SecondCreationDate







										)







									OR (







										@Secondop5 = @IsGreaterThanOrEqualTo







										AND CreationDate >= @SecondCreationDate





										)







									OR (







										@Secondop5 = @Contains







										AND CreationDate LIKE '%' + @SecondCreationDateVarchar + '%'







										)







									OR (







										@Secondop5 = @DoesNotContain







										AND CreationDate NOT LIKE '%' + @SecondCreationDateVarchar + '%'







										)







									OR (







										@Secondop5 = @StartsWith







										AND CreationDate LIKE '' + @SecondCreationDateVarchar + '%'







										)







									OR (







										@Secondop5 = @EndsWith







										AND CreationDate LIKE '%' + @SecondCreationDateVarchar + ''







										)







									)







								)







							)







						OR (







							@LogicalOperator5 = 'AND'







							AND (







								(







									(







										@op5 = @IsEqualTo







										AND CreationDate = @CreationDate







										)







									OR (







										@op5 = @IsNotEqualTo







										AND CreationDate <> @CreationDate







										)







									OR (







										@op5 = @IsLessThan







										AND CreationDate < @CreationDate







										)







									OR (







										@op5 = @IsLessThanOrEqualTo







										AND CreationDate <= @CreationDate







										)







									OR (







										@op5 = @IsGreaterThan







										AND CreationDate > @CreationDate







										)







									OR (







										@op5 = @IsGreaterThanOrEqualTo







										AND CreationDate >= @CreationDate







										)







									OR (







										@op5 = @Contains







										AND CreationDate LIKE '%' + @CreationDateVarchar + '%'







										)







									OR (







										@op5 = @DoesNotContain







										AND CreationDate NOT LIKE '%' + @CreationDateVarchar + '%'







										)







									OR (







										@op5 = @StartsWith







										AND CreationDate LIKE '' + @CreationDateVarchar + '%'







										)







									OR (







										@op5 = @EndsWith







										AND CreationDate LIKE '%' + @CreationDateVarchar + ''







										)







									)







								AND (







									(







										@Secondop5 = @IsEqualTo







										AND CreationDate = @SecondCreationDate







										)







									OR (







										@Secondop5 = @IsNotEqualTo







										AND CreationDate <> @SecondCreationDate







										)






									OR (







										@Secondop5 = @IsLessThan







										AND CreationDate < @SecondCreationDate







										)







									OR (







										@Secondop5 = @IsLessThanOrEqualTo







										AND CreationDate <= @SecondCreationDate







										)







									OR (







										@Secondop5 = @IsGreaterThan







										AND CreationDate > @SecondCreationDate







										)







									OR (







										@Secondop5 = @IsGreaterThanOrEqualTo







										AND CreationDate >= @SecondCreationDate







										)







									OR (







										@Secondop5 = @Contains







										AND CreationDate LIKE '%' + @SecondCreationDateVarchar + '%'







										)







									OR (







										@Secondop5 = @DoesNotContain







										AND CreationDate NOT LIKE '%' + @SecondCreationDateVarchar + '%'







										)







									OR (







										@Secondop5 = @StartsWith







										AND CreationDate LIKE '' + @SecondCreationDateVarchar + '%'







										)







									OR (







										@Secondop5 = @EndsWith







										AND CreationDate LIKE '%' + @SecondCreationDateVarchar + ''







										)







									)







								)







							)







						OR (







							@Secondop5 IS NULL







							AND (







								(







									@op5 = @IsEqualTo







									AND CreationDate = @CreationDate







									)







								OR (







									@op5 = @IsNotEqualTo







									AND CreationDate <> @CreationDate







									)







								OR (







									@op5 = @IsLessThan







									AND CreationDate < @CreationDate







									)







								OR (







									@op5 = @IsLessThanOrEqualTo







									AND CreationDate <= @CreationDate







									)







								OR (







									@op5 = @IsGreaterThan







									AND CreationDate > @CreationDate







									)







								OR (







									@op5 = @IsGreaterThanOrEqualTo







									AND CreationDate >= @CreationDate







									)







								OR (







									@op5 = @Contains







									AND CreationDate LIKE '%' + @CreationDateVarchar + '%'







									)







								OR (







									@op5 = @DoesNotContain







									AND CreationDate NOT LIKE '%' + @CreationDateVarchar + '%'







									)







								OR (







									@op5 = @StartsWith







									AND CreationDate LIKE '' + @CreationDateVarchar + '%'







									)







								OR (







									@op5 = @EndsWith







									AND CreationDate LIKE '%' + @CreationDateVarchar + ''







									)







								)







							)







						)







					AND (







						(@op6 IS NULL)







						OR (







							@op6 = @IsEqualTo







							AND IncomingOrOutGoingLabel = @IncomingOrOutGoingLabel







							)







						OR (







							@op6 = @IsNotEqualTo







							AND IncomingOrOutGoingLabel <> @IncomingOrOutGoingLabel







							)







						OR (







							@op6 = @IsLessThan







							AND IncomingOrOutGoingLabel < @IncomingOrOutGoingLabel







							)







						OR (







							@op6 = @IsLessThanOrEqualTo







							AND IncomingOrOutGoingLabel <= @IncomingOrOutGoingLabel







							)







						OR (







							@op6 = @IsGreaterThan







							AND IncomingOrOutGoingLabel > @IncomingOrOutGoingLabel







							)







						OR (







							@op6 = @IsGreaterThanOrEqualTo







							AND IncomingOrOutGoingLabel >= @IncomingOrOutGoingLabel







							)







						OR (







							@op6 = @Contains







							AND IncomingOrOutGoingLabel LIKE '%' + @IncomingOrOutGoingLabel + '%'







							)







						OR (







							@op6 = @DoesNotContain







							AND IncomingOrOutGoingLabel NOT LIKE '%' + @IncomingOrOutGoingLabel + '%'







							)







						OR (







							@op6 = @StartsWith







							AND IncomingOrOutGoingLabel LIKE '' + @IncomingOrOutGoingLabel + '%'







							)







						OR (







							@op6 = @EndsWith







							AND IncomingOrOutGoingLabel LIKE '%' + @IncomingOrOutGoingLabel + ''







							)







						)







					AND (







						(@op7 IS NULL)







						OR (







							@op7 = @IsEqualTo







							AND ContactMechanismLabel = @ContactMechanismLabel







							)







						OR (







							@op7 = @IsNotEqualTo







							AND ContactMechanismLabel <> @ContactMechanismLabel







							)







						OR (







							@op7 = @IsLessThan







							AND ContactMechanismLabel < @ContactMechanismLabel







							)







						OR (







							@op7 = @IsLessThanOrEqualTo







							AND ContactMechanismLabel <= @ContactMechanismLabel







							)







						OR (







							@op7 = @IsGreaterThan







							AND ContactMechanismLabel > @ContactMechanismLabel







							)







						OR (







							@op7 = @IsGreaterThanOrEqualTo







							AND ContactMechanismLabel >= @ContactMechanismLabel







							)







						OR (







							@op7 = @Contains







							AND ContactMechanismLabel LIKE '%' + @ContactMechanismLabel + '%'







							)







						OR (







							@op7 = @DoesNotContain







							AND ContactMechanismLabel NOT LIKE '%' + @ContactMechanismLabel + '%'







							)







						OR (







							@op7 = @StartsWith







							AND ContactMechanismLabel LIKE '' + @ContactMechanismLabel + '%'







							)







						OR (







							@op7 = @EndsWith







							AND ContactMechanismLabel LIKE '%' + @ContactMechanismLabel + ''







							)







						)







					AND (







						(@op8 IS NULL)







						OR (







							@op8 = @IsEqualTo







							AND StateLabel = @StateLabel







							)







						OR (







							@op8 = @IsNotEqualTo







							AND StateLabel <> @StateLabel







							)







						OR (







							@op8 = @IsLessThan







							AND StateLabel < @StateLabel







							)







						OR (







							@op8 = @IsLessThanOrEqualTo







							AND StateLabel <= @StateLabel







							)







						OR (







							@op8 = @IsGreaterThan







							AND StateLabel > @StateLabel







							)







						OR (







							@op8 = @IsGreaterThanOrEqualTo







							AND StateLabel >= @StateLabel







							)







						OR (







							@op8 = @Contains







							AND StateLabel LIKE '%' + @StateLabel + '%'







							)







						OR (







							@op8 = @DoesNotContain







							AND StateLabel NOT LIKE '%' + @StateLabel + '%'







							)







						OR (







							@op8 = @StartsWith







							AND StateLabel LIKE '' + @StateLabel + '%'







							)







						OR (







							@op8 = @EndsWith







							AND StateLabel LIKE '%' + @StateLabel + ''







							)







						)







					AND (







						(@op9 IS NULL)







						OR (







							@op9 = @IsEqualTo







							AND Summary = @Summary







							)







						OR (







							@op9 = @IsNotEqualTo







							AND Summary <> @Summary







							)







						OR (







							@op9 = @IsLessThan







							AND Summary < @Summary







							)







						OR (







							@op9 = @IsLessThanOrEqualTo







							AND Summary <= @Summary







							)







						OR (







							@op9 = @IsGreaterThan







							AND Summary > @Summary







							)







						OR (







							@op9 = @IsGreaterThanOrEqualTo







							AND Summary >= @Summary







							)







						OR (







							@op9 = @Contains







							AND Summary LIKE '%' + @Summary + '%'







							)







						OR (







							@op9 = @DoesNotContain







							AND Summary NOT LIKE '%' + @Summary + '%'







							)







						OR (







							@op9 = @StartsWith







							AND Summary LIKE '' + @Summary + '%'







							)







						OR (







							@op9 = @EndsWith







							AND Summary LIKE '%' + @Summary + ''







							)







						)







					union

					Select   Doc.CreationTimeStamp  AS CreationDate,Doc.GPSUser AS[GPSUser], null AS BusinessId, null AS NAME, 
					
				    Doc.CreationTimeStamp   AS CreationTimeStamp,
					

				    0 As Incoming,@OutgoingTranslation AS IncomingOrOutGoingLabel, null As ContactMechanismId,

					
					null As ContactMechanismCode,
					
					null As ContactMechanismTypeDescriptor,

					
					(SELECT distinct dbo.GetTranslationValue(DescriptionTranslation_Id,@pCultureCode)FROM ContactMechanismType 
					
                      WHERE [Types]='Email')   As ContactMechanismLabel,

					  
					@CompletedLabel As StateLabel,

					
					ED.[Subject] As Summary

					From Document Doc 
					LEFT JOIN TextDocument TD ON TD.DocumentId = Doc.DocumentId
					
					LEFT JOIN emaildocument ED ON ed.DocumentId = Doc.DocumentId
					

					left join DocumentCommunicationEventAssociation DC on Doc.DocumentId=DC.Documentid

					where  DC.CommunicationeventId is null and   Doc.CreationTimeStamp >= @pDate
					
					and Doc.GPSUser=@pGpsUser
					and Doc.Countryid=@pCountryId
				) t







			OPTION (RECOMPILE);







		END















		Select * from(SELECT CreationDate







			,GPSUser







			,BusinessId







			,NAME







			,CreationTimeStamp







			,Incoming







			,IncomingOrOutGoingLabel







			,ContactMechanismId







			,ContactMechanismCode







			,ContactMechanismTypeDescriptor







			,ContactMechanismLabel







			,StateLabel







			,Summary







		FROM (







			SELECT ce.CreationDate AS CreationDate







				,ce.GPSUser AS GPSUser







				,i.IndividualId AS BusinessId







				,i.GUIDReference AS Id







				,dbo.GetFullName(pIdenti.FirstOrderedName, pIdenti.MiddleOrderedName, pIdenti.LastOrderedName) AS NAME







				,candi.CreationTimeStamp AS CreationTimeStamp







				,ce.Incoming AS Incoming







				,(







					CASE 







						WHEN ce.Incoming = @BitTrue







							THEN @IncomingTranslation







						ELSE @OutgoingTranslation







						END







					) AS IncomingOrOutGoingLabel







				,cet.GUIDReference AS ContactMechanismId







				,cet.ContactMechanismCode AS ContactMechanismCode







				,t.KeyName AS ContactMechanismTypeDescriptor







				,dbo.GetTranslationValue(cet.DescriptionTranslation_Id, @pCultureCode) AS ContactMechanismLabel







				,(







					CASE 







						WHEN (ce.[state] = @pInProgressStatus)







							THEN @InProgressLabel







						ELSE @CompletedLabel







						END







					) AS StateLabel







				,(







					CASE 







						WHEN ISNULL(ED.[Subject], '') = '' AND ISNULL(td.[Message], '') = ''







							THEN cer.Comment







						WHEN ISNULL(ED.[Subject], '') = ''







							THEN ISNULL(td.[Message], '')







						ELSE ED.[Subject]





						END







					)







				AS Summary







			FROM Individual i







			INNER JOIN Candidate candi ON i.GUIDReference = candi.GUIDReference







				AND candi.Country_Id = @pCountryId







			INNER JOIN CommunicationEvent ce ON i.GUIDReference = ce.Candidate_Id







			INNER JOIN CommunicationEventReason CER ON ce.GUIDReference= cer.Communication_Id







            INNER JOIN CommunicationEventReasonType CERType ON CERType.GUIDReference=CER.ReasonType_Id







			INNER JOIN ContactMechanismType cet ON ce.ContactMechanism_Id = cet.GUIDReference







			INNER JOIN PersonalIdentification pIdenti ON pIdenti.PersonalIdentificationId = i.PersonalIdentificationId







			INNER JOIN Translation t ON t.TranslationId = cet.TypeTranslation_Id







			LEFT JOIN DocumentCommunicationEventAssociation DCEA ON DCEA.CommunicationEventId = ce.guidreference







			LEFT JOIN Document Doc ON doc.DocumentId = DCEA.DocumentId







			LEFT JOIN TextDocument TD ON TD.DocumentId = Doc.DocumentId







			LEFT JOIN emaildocument ED ON ed.DocumentId = Doc.DocumentId







			WHERE ce.Country_Id = @pCountryId







				AND ce.GPSUser = @pGpsUser







				AND ce.CreationDate >= @pDate







			) Tbl







		WHERE (







				(@op1 IS NULL)







				OR (







					@op1 = @IsEqualTo







					AND BusinessId = @BusinessId







					)







				OR (







					@op1 = @IsNotEqualTo







					AND BusinessId <> @BusinessId







					)







				OR (







					@op1 = @IsLessThan







					AND BusinessId < @BusinessId







					)







				OR (







					@op1 = @IsLessThanOrEqualTo







					AND BusinessId <= @BusinessId







					)







				OR (







					@op1 = @IsGreaterThan







					AND BusinessId > @BusinessId







					)







				OR (







					@op1 = @IsGreaterThanOrEqualTo







					AND BusinessId >= @BusinessId







					)







				OR (







					@op1 = @Contains







					AND BusinessId LIKE '%' + @BusinessId + '%'







					)







				OR (







					@op1 = @DoesNotContain







					AND BusinessId NOT LIKE '%' + @BusinessId + '%'







					)







				OR (







					@op1 = @StartsWith







					AND BusinessId LIKE '' + @BusinessId + '%'







					)







				OR (







					@op1 = @EndsWith







					AND BusinessId LIKE '%' + @BusinessId + ''







					)







				)







			AND (







				(@op2 IS NULL)







				OR (







					@op2 = @IsEqualTo







					AND NAME = @Name







					)







				OR (







					@op2 = @IsNotEqualTo







					AND NAME <> @Name







					)







				OR (







					@op2 = @IsLessThan







					AND NAME < @Name







					)







				OR (







					@op2 = @IsLessThanOrEqualTo







					AND NAME <= @Name







					)







				OR (







					@op2 = @IsGreaterThan







					AND NAME > @Name







					)







				OR (







					@op2 = @IsGreaterThanOrEqualTo







					AND NAME >= @Name







					)







				OR (







					@op2 = @Contains







					AND NAME LIKE '%' + @Name + '%'







					)







				OR (







					@op2 = @DoesNotContain







					AND NAME NOT LIKE '%' + @Name + '%'







					)







				OR (







					@op2 = @StartsWith







					AND NAME LIKE '' + @Name + '%'







					)







				OR (







					@op2 = @EndsWith







					AND NAME LIKE '%' + @Name + ''







					)







				)







			AND (







				(@op5 IS NULL)







				OR (







					@op5 IS NULL







					AND @LogicalOperator5 IS NULL







					)







				OR (







					@LogicalOperator5 = 'OR'







					AND (







						(







							(







								@op5 = @IsEqualTo







								AND CreationDate = @CreationDate







								)







							OR (







								@op5 = @IsNotEqualTo







								AND CreationDate <> @CreationDate







								)







							OR (







								@op5 = @IsLessThan







								AND CreationDate < @CreationDate







								)







							OR (







								@op5 = @IsLessThanOrEqualTo







								AND CreationDate <= @CreationDate







								)







							OR (







								@op5 = @IsGreaterThan







								AND CreationDate > @CreationDate







								)







							OR (







								@op5 = @IsGreaterThanOrEqualTo







								AND CreationDate >= @CreationDate







								)







							OR (







								@op5 = @Contains







								AND CreationDate LIKE '%' + @CreationDateVarchar + '%'







								)







							OR (







								@op5 = @DoesNotContain







								AND CreationDate NOT LIKE '%' + @CreationDateVarchar + '%'







								)







							OR (







								@op5 = @StartsWith







								AND CreationDate LIKE '' + @CreationDateVarchar + '%'







								)







							OR (







								@op5 = @EndsWith







								AND CreationDate LIKE '%' + @CreationDateVarchar + ''







								)







							)







						OR (







							(







								@Secondop5 = @IsEqualTo







								AND CreationDate = @SecondCreationDate







								)







							OR (







								@Secondop5 = @IsNotEqualTo







								AND CreationDate <> @SecondCreationDate







								)







							OR (







								@Secondop5 = @IsLessThan







								AND CreationDate < @SecondCreationDate







								)







							OR (







								@Secondop5 = @IsLessThanOrEqualTo







								AND CreationDate <= @SecondCreationDate







								)







							OR (







								@Secondop5 = @IsGreaterThan







								AND CreationDate > @SecondCreationDate







								)







							OR (







								@Secondop5 = @IsGreaterThanOrEqualTo







								AND CreationDate >= @SecondCreationDate







								)







							OR (







								@Secondop5 = @Contains







								AND CreationDate LIKE '%' + @SecondCreationDateVarchar + '%'







								)







							OR (







								@Secondop5 = @DoesNotContain







								AND CreationDate NOT LIKE '%' + @SecondCreationDateVarchar + '%'







								)







							OR (







								@Secondop5 = @StartsWith







								AND CreationDate LIKE '' + @SecondCreationDateVarchar + '%'







								)







							OR (







								@Secondop5 = @EndsWith







								AND CreationDate LIKE '%' + @SecondCreationDateVarchar + ''







								)







							)







						)







					)







				OR (







					@LogicalOperator5 = 'AND'







					AND (







						(







							(







								@op5 = @IsEqualTo







								AND CreationDate = @CreationDate







								)







							OR (







								@op5 = @IsNotEqualTo







								AND CreationDate <> @CreationDate







								)







							OR (







								@op5 = @IsLessThan







								AND CreationDate < @CreationDate







								)







							OR (







								@op5 = @IsLessThanOrEqualTo







								AND CreationDate <= @CreationDate







								)







							OR (







								@op5 = @IsGreaterThan







								AND CreationDate > @CreationDate







								)







							OR (







								@op5 = @IsGreaterThanOrEqualTo







								AND CreationDate >= @CreationDate







								)







							OR (







								@op5 = @Contains







								AND CreationDate LIKE '%' + @CreationDateVarchar + '%'







								)







							OR (







								@op5 = @DoesNotContain







								AND CreationDate NOT LIKE '%' + @CreationDateVarchar + '%'







								)







							OR (







								@op5 = @StartsWith







								AND CreationDate LIKE '' + @CreationDateVarchar + '%'







								)







							OR (







								@op5 = @EndsWith







								AND CreationDate LIKE '%' + @CreationDateVarchar + ''







								)







							)







						AND (







							(







								@Secondop5 = @IsEqualTo







								AND CreationDate = @SecondCreationDate







								)







							OR (







								@Secondop5 = @IsNotEqualTo







								AND CreationDate <> @SecondCreationDate







								)







							OR (







								@Secondop5 = @IsLessThan







								AND CreationDate < @SecondCreationDate







								)







							OR (







								@Secondop5 = @IsLessThanOrEqualTo







								AND CreationDate <= @SecondCreationDate







								)







							OR (







								@Secondop5 = @IsGreaterThan







								AND CreationDate > @SecondCreationDate







								)







							OR (







								@Secondop5 = @IsGreaterThanOrEqualTo







								AND CreationDate >= @SecondCreationDate







								)







							OR (







								@Secondop5 = @Contains







								AND CreationDate LIKE '%' + @SecondCreationDateVarchar + '%'







								)







							OR (







								@Secondop5 = @DoesNotContain







								AND CreationDate NOT LIKE '%' + @SecondCreationDateVarchar + '%'







								)







							OR (







								@Secondop5 = @StartsWith







								AND CreationDate LIKE '' + @SecondCreationDateVarchar + '%'







								)







							OR (







								@Secondop5 = @EndsWith







								AND CreationDate LIKE '%' + @SecondCreationDateVarchar + ''







								)







							)







						)







					)







				OR (







					@Secondop5 IS NULL







					AND (







						(







							@op5 = @IsEqualTo







							AND CreationDate = @CreationDate







							)







						OR (







							@op5 = @IsNotEqualTo







							AND CreationDate <> @CreationDate







							)







						OR (







							@op5 = @IsLessThan







							AND CreationDate < @CreationDate







							)







						OR (







							@op5 = @IsLessThanOrEqualTo







							AND CreationDate <= @CreationDate







							)







						OR (







							@op5 = @IsGreaterThan







							AND CreationDate > @CreationDate







							)







						OR (







							@op5 = @IsGreaterThanOrEqualTo







							AND CreationDate >= @CreationDate







							)







						OR (







							@op5 = @Contains







							AND CreationDate LIKE '%' + @CreationDateVarchar + '%'







							)







						OR (







							@op5 = @DoesNotContain







							AND CreationDate NOT LIKE '%' + @CreationDateVarchar + '%'







							)







						OR (







							@op5 = @StartsWith







							AND CreationDate LIKE '' + @CreationDateVarchar + '%'







							)







						OR (







							@op5 = @EndsWith







							AND CreationDate LIKE '%' + @CreationDateVarchar + ''







							)







						)







					)







				)







			AND (







				(@op6 IS NULL)







				OR (







					@op6 = @IsEqualTo







					AND IncomingOrOutGoingLabel = @IncomingOrOutGoingLabel







					)







				OR (







					@op6 = @IsNotEqualTo







					AND IncomingOrOutGoingLabel <> @IncomingOrOutGoingLabel







					)







				OR (







					@op6 = @IsLessThan







					AND IncomingOrOutGoingLabel < @IncomingOrOutGoingLabel







					)







				OR (







					@op6 = @IsLessThanOrEqualTo







					AND IncomingOrOutGoingLabel <= @IncomingOrOutGoingLabel







					)







				OR (







					@op6 = @IsGreaterThan







					AND IncomingOrOutGoingLabel > @IncomingOrOutGoingLabel







					)







				OR (







					@op6 = @IsGreaterThanOrEqualTo







					AND IncomingOrOutGoingLabel >= @IncomingOrOutGoingLabel







					)







				OR (







					@op6 = @Contains







					AND IncomingOrOutGoingLabel LIKE '%' + @IncomingOrOutGoingLabel + '%'







					)







				OR (







					@op6 = @DoesNotContain







					AND IncomingOrOutGoingLabel NOT LIKE '%' + @IncomingOrOutGoingLabel + '%'







					)







				OR (







					@op6 = @StartsWith







					AND IncomingOrOutGoingLabel LIKE '' + @IncomingOrOutGoingLabel + '%'







					)







				OR (







					@op6 = @EndsWith







					AND IncomingOrOutGoingLabel LIKE '%' + @IncomingOrOutGoingLabel + ''







					)







				)







			AND (







				(@op7 IS NULL)







				OR (







					@op7 = @IsEqualTo







					AND ContactMechanismLabel = @ContactMechanismLabel







					)







				OR (







					@op7 = @IsNotEqualTo







					AND ContactMechanismLabel <> @ContactMechanismLabel







					)







				OR (







					@op7 = @IsLessThan







					AND ContactMechanismLabel < @ContactMechanismLabel







					)







				OR (







					@op7 = @IsLessThanOrEqualTo







					AND ContactMechanismLabel <= @ContactMechanismLabel







					)







				OR (







					@op7 = @IsGreaterThan







					AND ContactMechanismLabel > @ContactMechanismLabel







					)







				OR (







					@op7 = @IsGreaterThanOrEqualTo







					AND ContactMechanismLabel >= @ContactMechanismLabel







					)







				OR (







					@op7 = @Contains







					AND ContactMechanismLabel LIKE '%' + @ContactMechanismLabel + '%'







					)







				OR (







					@op7 = @DoesNotContain







					AND ContactMechanismLabel NOT LIKE '%' + @ContactMechanismLabel + '%'







					)







				OR (







					@op7 = @StartsWith







					AND ContactMechanismLabel LIKE '' + @ContactMechanismLabel + '%'







					)







				OR (







					@op7 = @EndsWith







					AND ContactMechanismLabel LIKE '%' + @ContactMechanismLabel + ''







					)







				)







			AND (







				(@op8 IS NULL)







				OR (







					@op8 = @IsEqualTo







					AND StateLabel = @StateLabel







					)







				OR (







					@op8 = @IsNotEqualTo







					AND StateLabel <> @StateLabel







					)







				OR (







					@op8 = @IsLessThan







					AND StateLabel < @StateLabel







					)







				OR (







					@op8 = @IsLessThanOrEqualTo







					AND StateLabel <= @StateLabel







					)







				OR (







					@op8 = @IsGreaterThan







					AND StateLabel > @StateLabel







					)







				OR (







					@op8 = @IsGreaterThanOrEqualTo







					AND StateLabel >= @StateLabel







					)







				OR (







					@op8 = @Contains







					AND StateLabel LIKE '%' + @StateLabel + '%'







					)







				OR (







					@op8 = @DoesNotContain







					AND StateLabel NOT LIKE '%' + @StateLabel + '%'







					)







				OR (







					@op8 = @StartsWith







					AND StateLabel LIKE '' + @StateLabel + '%'







					)







				OR (







					@op8 = @EndsWith







					AND StateLabel LIKE '%' + @StateLabel + ''







					)







				)







			AND (







				(@op9 IS NULL)







				OR (







					@op9 = @IsEqualTo







					AND Summary = @Summary







					)







				OR (







					@op9 = @IsNotEqualTo







					AND Summary <> @Summary







					)







				OR (







					@op9 = @IsLessThan







					AND Summary < @Summary







					)







				OR (







					@op9 = @IsLessThanOrEqualTo







					AND Summary <= @Summary







					)







				OR (







					@op9 = @IsGreaterThan







					AND Summary > @Summary







					)







				OR (







					@op9 = @IsGreaterThanOrEqualTo







					AND Summary >= @Summary







					)







				OR (







					@op9 = @Contains







					AND Summary LIKE '%' + @Summary + '%'







					)







				OR (







					@op9 = @DoesNotContain







					AND Summary NOT LIKE '%' + @Summary + '%'







					)







				OR (







					@op9 = @StartsWith







					AND Summary LIKE '' + @Summary + '%'







					)







				OR (







					@op9 = @EndsWith







					AND Summary LIKE '%' + @Summary + ''







					))

					union
					
				    Select   Doc.CreationTimeStamp  AS CreationDate,Doc.GPSUser AS[GPSUser], null AS BusinessId, null AS NAME, 
					Doc.CreationTimeStamp   AS CreationTimeStamp,
					0 As Incoming,@OutgoingTranslation AS IncomingOrOutGoingLabel, null As ContactMechanismId,
					null As ContactMechanismCode,

					null As ContactMechanismTypeDescriptor,

					(SELECT distinct dbo.GetTranslationValue(DescriptionTranslation_Id,@pCultureCode)FROM ContactMechanismType 
					
                      WHERE [Types]='Email')   As ContactMechanismLabel,

					  @CompletedLabel As StateLabel,

					  
					ED.[Subject] As Summary

					
					From Document Doc 

					
					LEFT JOIN TextDocument TD ON TD.DocumentId = Doc.DocumentId

					
					LEFT JOIN emaildocument ED ON ed.DocumentId = Doc.DocumentId

					
					left join DocumentCommunicationEventAssociation DC on Doc.DocumentId=DC.Documentid
					
					where  DC.CommunicationeventId is null and   Doc.CreationTimeStamp >= @pDate
										
					and Doc.GPSUser=@pGpsUser

					and Doc.Countryid=@pCountryId
					
				)tt







		ORDER BY CASE 







				WHEN @pOrderBy = 'BusinessId'







					AND @pOrderType = 'desc'







					THEN BusinessId







				END DESC







			,CASE 







				WHEN @pOrderBy = 'BusinessId'







					AND @pOrderType = 'asc'







					THEN BusinessId







				END ASC







			,CASE 







				WHEN @pOrderBy = 'Name'







					AND @pOrderType = 'desc'







					THEN NAME







				END DESC







			,CASE 







				WHEN @pOrderBy = 'Name'







					AND @pOrderType = 'asc'







					THEN NAME







				END ASC







			,CASE 







				WHEN @pOrderBy = 'CreationDate'







					AND @pOrderType = 'desc'







					THEN CreationDate







				END DESC







			,CASE 







				WHEN @pOrderBy = 'CreationDate'







					AND @pOrderType = 'asc'







					THEN CreationDate







				END ASC







			,CASE 







				WHEN @pOrderBy = 'IncomingOrOutGoingLabel'







					AND @pOrderType = 'desc'







					THEN IncomingOrOutGoingLabel







				END DESC







			,CASE 







				WHEN @pOrderBy = 'IncomingOrOutGoingLabel'







					AND @pOrderType = 'asc'







					THEN IncomingOrOutGoingLabel







				END ASC







			,CASE 







				WHEN @pOrderBy = 'ContactMechanismLabel'







					AND @pOrderType = 'desc'







					THEN ContactMechanismLabel







				END DESC







			,CASE 







				WHEN @pOrderBy = 'ContactMechanismLabel'







					AND @pOrderType = 'asc'







					THEN ContactMechanismLabel







				END ASC







			,CASE 







				WHEN @pOrderBy = 'StateLabel'







					AND @pOrderType = 'desc'







					THEN StateLabel







				END DESC







			,CASE 







				WHEN @pOrderBy = 'StateLabel'







					AND @pOrderType = 'asc'







					THEN StateLabel







				END ASC OFFSET @OFFSETRows ROWS















		FETCH NEXT @pPageSize ROWS ONLY







		OPTION (RECOMPILE);







			/**/







	END TRY















	BEGIN CATCH







		DECLARE @ERR_MSG AS NVARCHAR(4000)







			,@ERR_STA AS SMALLINT















		SET @ERR_MSG = ERROR_MESSAGE();







		SET @ERR_STA = ERROR_STATE();















		THROW 50001







			,@ERR_MSG







			,@ERR_STA;







	END CATCH







END
