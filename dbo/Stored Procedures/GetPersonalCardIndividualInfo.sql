CREATE PROCEDURE [dbo].[GetPersonalCardIndividualInfo] @pBusinessId UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE @IsFutureDateForNextCallAllowed BIT
			,@IsFutureDateOfBirthAllowed BIT

			DECLARE @GetDate DATETIME
	SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryId))

		SELECT @IsFutureDateForNextCallAllowed = dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'NextCallDate', 1)

		SELECT @IsFutureDateOfBirthAllowed = dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'FutureDateOfBirth', 1)

	DECLARE @IsGAInterviewer NVARCHAR(1)
	SET @IsGAInterviewer = (SELECT TOP 1 KV.Value FROM KeyAppSetting K
					JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=K.GUIDReference
					WHERE K.KeyName='IsGeographicAreaLinkedInterviewer' AND KV.Country_Id=@pCountryId)


		--IndividualPersonalInformation   
		SELECT DISTINCT I.GUIDReference AS Id
			,I.IndividualId AS BusinessId
			,P.LastOrderedName AS LastName
			,P.MiddleOrderedName AS MiddleName
			,P.FirstOrderedName AS FirstName
			,P.DateOfBirth AS DateOfBirth
			,C.EnrollmentDate
			,INSS.Code
			,dbo.GetTranslationValue(INSS.Translation_Id, @pCultureCode) AS NAME
		FROM Individual I
		INNER JOIN PersonalIdentification P ON P.PersonalIdentificationId = I.PersonalIdentificationId
		INNER JOIN IndividualSex INSS ON INSS.GUIDReference = I.Sex_Id
		INNER JOIN Candidate C ON C.GUIDReference = I.GUIDReference
		WHERE I.GUIDReference = @pBusinessId

		SELECT @IsFutureDateForNextCallAllowed

		SELECT @IsFutureDateOfBirthAllowed

		---- CalenderEvents
		IF EXISTS (
				SELECT 1
				FROM Individual I
				INNER JOIN CalendarEvent CE ON CE.Id = I.Event_Id
				WHERE I.GUIDReference = @pBusinessId
				)
			SELECT 
				 ISNULL(CE.[Date], @GetDate) as [EventDate]
				,EF.GUIDReference AS Frequency
				,dbo.GetTranslationValue(EF.Translation_Id, @pCultureCode) AS FrequencyName
				, IIF(CE.[Date] IS NOT NULL, 1, 0) as HasDate
			FROM Individual I
			LEFT JOIN CalendarEvent CE ON CE.Id = I.Event_Id
			LEFT JOIN EventFrequency EF ON EF.Country_Id = @pCountryId
				AND CE.Frequency_Id = EF.GUIDReference
			WHERE I.GUIDReference = @pBusinessId
		ELSE
			SELECT @GetDate as [EventDate]
				,EF.GUIDReference AS Frequency
				,dbo.GetTranslationValue(EF.Translation_Id, @pCultureCode) AS FrequencyName
				, 0 as HasDate
			FROM EventFrequency EF
			WHERE EF.Country_Id = @pCountryId
				AND IsDefault = 1

		--BelongingQuantity
		DECLARE @GroupID UNIQUEIDENTIFIER

		SELECT TOP 1 @GroupID = Group_Id
		FROM CollectiveMembership cm
		JOIN StateDefinition sd on sd.Id = cm.State_Id
		WHERE Individual_Id = @pBusinessId
		AND sd.InactiveBehavior != 1

		SELECT count(1)
              FROM (
                     SELECT DISTINCT B.GUIDReference --av.guidreference
                     FROM BelongingTypeConfiguration BTC
                     INNER JOIN ConfigurationSet CS ON BTC.ConfigurationSetId = CS.ConfigurationSetId
                     INNER JOIN BelongingType BT ON BT.Id = BTC.BelongingTypeId
                     INNER JOIN SortAttribute SA ON SA.BelongingType_Id = BT.Id
                     INNER JOIN Belonging B ON B.TypeId = BT.Id
                     INNER JOIN OrderedBelonging OB ON OB.Belonging_Id = B.GUIDReference
                           AND OB.BelongingSection_Id = SA.Id
                     INNER JOIN AttributeValue AV ON AV.RespondentId = B.GUIDReference
                     INNER JOIN Attribute a ON a.GUIDReference = av.DemographicId
                     WHERE B.CandidateId IN (
                                  @pBusinessId
                                  ,@GroupID
                                  )
                           AND cs.Type = 'Individual'
                     ) ss

		--CharityAmount
		SELECT I.IndividualId AS BusinessId
			,I.GUIDReference AS IndividualId
			,CA.GUIDReference AS CharityAmountCode
		FROM Individual I
		LEFT JOIN [dbo].[CharitySubscription] CS ON I.CharitySubscription_Id = CS.Id
		LEFT JOIN CharityAmount CA ON CA.GUIDReference = CS.Amount_Id
		WHERE I.GUIDReference = @pBusinessId

		--AliasAndExclusions
		SELECT  I.GUIDReference AS IndividualId
			,I.IndividualId AS BusinessId
			,E.AllPanels
			,dbo.GetTranslationValue(ET.Translation_Id, @pCultureCode) AS TypeKeyName
			,(SELECT Stuff( (SELECT N', ' + P.Name 
				FROM ExclusionPanelist EP
				JOIN Panelist PL ON EP.Panelist_Id = PL.GUIDReference
				JOIN Panel P ON PL.Panel_Id = p.GUIDReference
				WHERE EP.Exclusion_Id = E.GUIDReference
				FOR XML PATH(''),TYPE)
				.value('text()[1]','nvarchar(max)'),1,2,N'')
			) AS PanelName
			,E.Range_From AS [From]
			,E.Range_To AS [To]
			,E.IsClosed AS IsClosed
		FROM Exclusion E 
		INNER JOIN ExclusionIndividual EI ON EI.Exclusion_Id = E.GUIDReference AND EI.Individual_Id=@pBusinessId
		INNER JOIN Individual I ON EI.Individual_Id=I.GUIDReference
		INNER JOIN ExclusionType ET ON ET.GUIDReference = E.[Type_Id]
       INNER JOIN CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
		INNER JOIN StateDefinition SD ON SD.ID = CM.State_Id
		WHERE I.GUIDReference = @pBusinessId
			AND E.IsClosed = 0 AND  SD.InactiveBehavior !=1
			AND NOT (
				E.Range_To IS NOT NULL
				AND E.Range_To < @GetDate
				)
		ORDER BY [From]
		
		DECLARE @mytable TABLE (
			Id UNIQUEIDENTIFIER
			,NAME NVARCHAR(100)
			)

		INSERT INTO @mytable (
			Id
			,NAME
			)
		SELECT NAC.NamedAliasContextId AS Id
			,NAC.Name AS NAME
		FROM NamedAliasContext NAC
		WHERE NAC.Country_Id = @pCountryId
			AND NAC.Discriminator = 'CountryAliasContext'

		SELECT *
		FROM @mytable

		SELECT NA.NamedAliasId AS Id
			,NA.[Key] AS [Key]
			,NA.AliasContext_Id AS AliasContextId
		FROM NamedAlias NA
		INNER JOIN @mytable myt ON NA.AliasContext_Id = myt.Id and Candidate_Id=@pBusinessId

		IF (@IsGAInterviewer = '1')
		BEGIN
		SELECT I.ID, CAST(InterviewerCode AS VARCHAR(100))+ '-'  + Name as Name FROM Collective C
		JOIN Candidate Cd ON Cd.GUIDReference = C.GUIDReference
		JOIN InterviewerGeographicArea IG ON IG.GeographicArea_Id = Cd.GeographicArea_Id
		JOIN Interviewer I ON I.Id = IG.Interviewer_Id
		WHERE C.GUIDReference = @GroupID
		END
		ELSE
		BEGIN
		SELECT I.ID, CAST(InterviewerCode AS VARCHAR(100))+ '-'  + Name as Name FROM Collective C
		JOIN Interviewer I ON C.Interviewer_Id = I.ID
		WHERE C.GUIDReference = @GroupID
		END

		IF (@IsGAInterviewer <> '1')
		BEGIN
		SELECT ID, CAST(InterviewerCode AS VARCHAR(100))+ '-'  + Name as Name  FROM Interviewer
		WHERE Country_Id = @pCountryId AND @GetDate >= StartDate AND (@GetDate <= EndDate OR EndDate IS NULL)
		ORDER BY InterviewerCode
		END

	END TRY

	BEGIN CATCH
		/****Logging goes here for exceptions***/
		SELECT ERROR_NUMBER() AS ErrorNumber
			,ERROR_MESSAGE() AS ErrorMessage;
	END CATCH


	
	DECLARE @PanelDropOffRequired BIT
	SELECT @PanelDropOffRequired = dbo.[IsFieldRequiredOrFieldVisible](@pCountryId, 'PanelDropOffRequired', 1)

	SELECT @PanelDropOffRequired
END