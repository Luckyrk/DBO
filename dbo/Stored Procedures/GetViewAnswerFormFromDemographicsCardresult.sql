CREATE PROCEDURE [dbo].[GetViewAnswerFormFromDemographicsCardresult] @pCountryID UNIQUEIDENTIFIER
	,@pindividualId UNIQUEIDENTIFIER
	,@pFormId UNIQUEIDENTIFIER
	,@pCultureCode INT
	,@pCultureName NVARCHAR(10)
AS
BEGIN
	--SELECT * FROM ATtributeScope
	--individualid, individualbusinessid,groupid,groupsequenceid,
	DECLARE @Group_Id UNIQUEIDENTIFIER
		,@GroupSequence VARCHAR(10)
		,@businessID VARCHAR(10)
		,@DefaultGuid UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
		,@InactiveBehviourIndividual bit
	SELECT @Group_Id = Group_Id
	FROM CollectiveMemberShip
	WHERE Individual_Id = @pindividualId

	SELECT @businessID = individualId
	FROM individual I
	WHERE I.GUIDReference = @pindividualId

	SELECT @GroupSequence = Sequence
	FROM Collective
	WHERE GUIDReference = @Group_Id

	set @InactiveBehviourIndividual=(SELECT top 1 sd.InactiveBehavior
										FROM CollectiveMemberShip CM
										INNER JOIN Individual I ON I.GUIDREFERENCE = CM.Individual_Id
										INNER JOIN Collective C ON C.GUIDReference = CM.Group_Id
										INNER JOIN StateDefinition SD ON SD.Id = CM.State_Id
										WHERE i.guidreference=@pindividualId AND CM.Group_Id=@Group_Id)

	SELECT F.GUIDReference AS Id
		,dbo.GetTranslationValue(F.Translation_Id, @pCultureCode) AS NAME
		,IsShowActiveBelonging
		,F.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(F.Translation_Id, @pCultureCode) AS Label
	FROM Form F
	WHERE GUIDReference = @pFormId

	--FormPages 
	SELECT F.GUIDReference AS FormId
		,FP.Id
		,FP.Number
		,FP.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(FP.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(FP.Translation_Id, @pCultureCode) AS Label
	FROM FormPage FP
	INNER JOIN Form F ON F.GUIDReference = FP.Form_Id
	WHERE F.GUIDReference = @pFormId
	ORDER BY FP.Number

	----ColumnDtos
	SELECT FP.Id AS PageId
		,PC.PageColumnId AS ID
		,PC.ColumnNumber AS Number
	FROM Form F
	INNER JOIN FormPage FP ON F.GUIDReference = FP.Form_Id
	INNER JOIN PageColumn PC ON FP.Id = PC.Page_Id
	WHERE F.GUIDReference = @pFormId
	ORDER BY PC.ColumnNumber

	--PageSectionDtos
	SELECT PC.PageColumnId AS PageColumnId
		,PS.Id
		,dbo.GetTranslationValue(PS.Translation_Id, @pCultureCode) AS NAME
		,PS.[Order]
		,PS.Orientation
		,PS.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(PS.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(PS.Translation_Id, @pCultureCode) AS Label
	FROM FormPage FP
	INNER JOIN Form F ON F.GUIDReference = FP.Form_Id
	INNER JOIN PageColumn PC ON FP.Id = PC.Page_Id
	INNER JOIN PageSection PS ON PS.Column_Id = PC.PageColumnId
	WHERE F.GUIDReference = @pFormId
	ORDER BY PS.[Order]



	--HardAttributesection (sort attribute)
	SELECT PS.Id AS PageSectionID
		,PS.Orientation
		,SA.Id
		,SA.[Order]
		,SA.FieldConfiguration_Id AS FieldConfigurationId
		,dbo.GetTranslationValue(T.TranslationId, @pCultureCode)+'' AS HardAttributeName
	FROM FormPage FP
	JOIN Form F ON F.GUIDReference = FP.Form_Id
	JOIN PageColumn PC ON FP.Id = PC.Page_Id
	JOIN PageSection PS ON PS.Column_Id = PC.PageColumnId
	JOIN SortAttribute SA ON SA.PageSection_Id = PS.Id
	JOIN FieldConfiguration FC ON FC.Id=SA.FieldConfiguration_Id
	JOIN Translation T ON T.KeyName=FC.[Key]
	WHERE F.GUIDReference = @pFormId

	--Attributesection (sort attribute)
	CREATE TABLE #TEMP (
		SectionID UNIQUEIDENTIFIER
		,Orientation INT
		,SortAttId UNIQUEIDENTIFIER
		,[SortOrder] INT
		,SortCompulsory BIT
		,SortUseShort BIT
		,Demographic_Id UNIQUEIDENTIFIER
		,ScopeType NVARCHAR(100) COLLATE DATABASE_DEFAULT
		,PageOrientation INT
		,AttributeName NVARCHAR(400) COLLATE DATABASE_DEFAULT
		,MustAnonymize BIT
		,TimeDisplay BIT
		)
		
	INSERT INTO #TEMP
	SELECT PS.Id AS SectionID
		,PS.Orientation
		,SA.Id
		,SA.[Order]
		,SA.Compulsory
		,SA.UseShortCode
		,SA.Demographic_Id
		,ATS.[Type]
		,PS.Orientation
		,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)
		,A.MustAnonymize
		,A.TimeDisplay
	FROM FormPage FP
	INNER JOIN Form F ON F.GUIDReference = FP.Form_Id
	INNER JOIN PageColumn PC ON FP.Id = PC.Page_Id
	INNER JOIN PageSection PS ON PS.Column_Id = PC.PageColumnId
	INNER JOIN SortAttribute SA ON SA.PageSection_Id = PS.Id
	INNER JOIN Attribute A ON A.GUIDReference = SA.Demographic_Id
	INNER JOIN ATtributeScope ATS ON ATS.GUIDReference = A.Scope_Id
	WHERE F.GUIDReference = @pFormId
		AND A.Active = 1
		AND ATS.Type IN (
			'Individual'
			,'HouseHold'
			)
	
	UNION
	
	SELECT PS.Id AS SectionID
		,PS.Orientation
		,SA.Id
		,SA.[Order]
		,SA.Compulsory
		,SA.UseShortCode
		,AC.AttributeId
		,ATS.[Type]
		,PS.Orientation
		,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)
		,A.MustAnonymize
		,A.TimeDisplay
	FROM FormPage FP
	INNER JOIN Form F ON F.GUIDReference = FP.Form_Id
	INNER JOIN PageColumn PC ON FP.Id = PC.Page_Id
	INNER JOIN PageSection PS ON PS.Column_Id = PC.PageColumnId
	INNER JOIN SortAttribute SA ON SA.PageSection_Id = PS.Id
	INNER JOIN AttributeConfiguration AC ON AC.BelongingTypeId = SA.BelongingType_Id
	INNER JOIN Attribute A ON A.GuidReference = AC.AttributeId
	INNER JOIN ATtributeScope ATS ON ATS.GUIDReference = A.Scope_Id
	WHERE F.GUIDReference = @pFormId
		AND A.Active = 1
		AND ATS.Type IN (
			'GroupBelongingType'
			,'IndividualBelongingType'
			)

	-- Group and Individuals in group
	CREATE TABLE #GroupCandidates (CandidateId UNIQUEIDENTIFIER, IsAnonymized BIT)

	INSERT INTO #GroupCandidates
	SELECT @Group_Id, 0
	
	UNION ALL
	
	SELECT CM.Individual_Id, I.IsAnonymized
	FROM CollectiveMembership CM
	JOIN Individual I on I.GUIDReference = CM.Individual_Id --AND I.IsAnonymized=0
	WHERE CM.Group_Id = @Group_Id

	--AttributeSectionDTO (Sort attribute collection)
	SELECT T.SectionID AS PageSectionId
		,T.SortAttId AS Id
		,T.SortOrder AS [Order]
		,T.SortCompulsory AS Compulsory
		,ScopeType
	FROM #TEmp T
	WHERE ScopeType IN (
			'Individual'
			,'HouseHold'
			)

	IF(@InactiveBehviourIndividual<>1)
	BEGIN
	SELECT CM.Individual_Id AS IndividualId
		,I.IndividualId AS IndividualBusinessId
		,CM.Group_Id AS GroupId
		,CASE 
			WHEN CM.Individual_Id = C.GroupContact_Id
				THEN 1
			ELSE 0
			END AS IsGroupContact
		,C.Sequence AS Groupsequence
	FROM CollectiveMemberShip CM
	INNER JOIN Individual I ON I.GUIDREFERENCE = CM.Individual_Id
	INNER JOIN Collective C ON C.GUIDReference = CM.Group_Id
	INNER JOIN StateDefinition SD ON SD.Id = CM.State_Id
	WHERE CM.Group_Id = @Group_Id
		AND SD.InactiveBehavior <> 1
	ORDER BY CM.Sequence
	END
	ELSE
	BEGIN
	SELECT CM.Individual_Id AS IndividualId
		,I.IndividualId AS IndividualBusinessId
		,CM.Group_Id AS GroupId
		,CASE 
			WHEN CM.Individual_Id = C.GroupContact_Id
				THEN 1
			ELSE 0
			END AS IsGroupContact
		,C.Sequence AS Groupsequence
	FROM CollectiveMemberShip CM
	INNER JOIN Individual I ON I.GUIDREFERENCE = CM.Individual_Id
	INNER JOIN Collective C ON C.GUIDReference = CM.Group_Id
	INNER JOIN StateDefinition SD ON SD.Id = CM.State_Id
	WHERE CM.Group_Id = @Group_Id
		AND SD.InactiveBehavior = 1
	ORDER BY CM.Sequence
	END

	--EnumAttributeDto 
	SELECT DISTINCT SA.Id AS SortAttributeId
		,A.GuidReference AS Id
		,IIF(SA.UseShortCode=1 AND A.ShortCode IS NOT NULL, A.ShortCode, dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)) AS NAME
		,[Key] AS Code --,
		,IsCalculated
		,Calculation_Id AS BusinessRuleId
		,Category_Id AS CategoryId
		,ScopeType
		,0 AS ShowScopeInfo
		,0 AS DemographicType
		,IsReadOnly
		,A.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN Attribute A ON A.GUIDReference = T.Demographic_Id
	WHERE A.[Type] = 'Enum'
		AND a.Active = 1

	--StringAttribute
	SELECT DISTINCT SA.Id AS SortAttributeId
		,A.GuidReference AS Id
		,IIF(SA.UseShortCode=1 AND A.ShortCode IS NOT NULL, A.ShortCode, dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)) AS NAME
		,[Key] AS Code --,
		,MinLength
		,MaxLength
		,IsCalculated
		,Calculation_Id AS BusinessRuleId
		,Category_Id AS CategoryId
		,ScopeType
		,0 AS ShowScopeInfo
		,3 AS DemographicType
		,IsReadOnly
		,A.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN Attribute A ON A.GUIDReference = T.Demographic_Id
	WHERE A.[Type] = 'String'
		AND a.Active = 1

	--BoolAttribute
	SELECT DISTINCT SA.Id AS SortAttributeId
		,A.GuidReference AS Id
		,IIF(SA.UseShortCode=1 AND A.ShortCode IS NOT NULL, A.ShortCode, dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)) AS NAME
		,[Key] AS Code --,
		,IsCalculated
		,Calculation_Id AS BusinessRuleId
		,Category_Id AS CategoryId
		,ScopeType
		,0 AS ShowScopeInfo
		,4 AS DemographicType
		,IsReadOnly
		,A.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN Attribute A ON A.GUIDReference = T.Demographic_Id
	WHERE A.[Type] = 'Boolean'
		AND A.Active = 1

	--DateAttribute
	SELECT DISTINCT SA.Id AS SortAttributeId
		,A.GuidReference AS Id
		,IIF(SA.UseShortCode=1 AND A.ShortCode IS NOT NULL, A.ShortCode, dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)) AS NAME
		,[Key] AS Code --,
		,DateFrom
		,DateTo
		,Today
		,IsCalculated
		,Calculation_Id AS BusinessRuleId
		,Category_Id AS CategoryId
		,ScopeType
		,0 AS ShowScopeInfo
		,3 AS DemographicType
		,IsReadOnly
		,A.Translation_Id AS TranslationId
		,A.TimeDisplay
		,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN Attribute A ON A.GUIDReference = T.Demographic_Id
	WHERE A.[Type] = 'Date'
		AND A.Active = 1

	--FloatAttribute
	SELECT DISTINCT SA.Id AS SortAttributeId
		,A.GuidReference AS Id
		,IIF(SA.UseShortCode=1 AND A.ShortCode IS NOT NULL, A.ShortCode, dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)) AS NAME
		,[Key] AS Code --,
		,[From]
		,[To]
		,IsCalculated
		,Calculation_Id AS BusinessRuleId
		,Category_Id AS CategoryId
		,ScopeType
		,0 AS ShowScopeInfo
		,3 AS DemographicType
		,IsReadOnly
		,A.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN Attribute A ON A.GUIDReference = T.Demographic_Id
	WHERE A.[Type] = 'Float'
		AND A.Active = 1

	--IntAttribute
	SELECT DISTINCT SA.Id AS SortAttributeId
		,A.GuidReference AS Id
		,IIF(SA.UseShortCode=1 AND A.ShortCode IS NOT NULL, A.ShortCode, dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)) AS NAME
		,[Key] AS Code
		,[From]
		,[To]
		,IsCalculated
		,Calculation_Id AS BusinessRuleId
		,Category_Id AS CategoryId
		,ScopeType
		,0 AS ShowScopeInfo
		,3 AS DemographicType
		,IsReadOnly
		,A.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN Attribute A ON A.GUIDReference = T.Demographic_Id
	WHERE A.[Type] = 'Int'
		AND A.Active = 1

	--Actual DefinitionDtos
	SELECT DISTINCT --SA.Id AS SortAttributeId
		A.GUIDReference AS AttributeId
		,ED.Id
		,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS NAME
		,ED.Value
		,ED.IsActive
		,IsFreeTextRequired
		,IsSelected
		,ISNULL(ED.EnumValueSet_Id, @DefaultGuid) AS EnumValueSetId
		,ED.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(ED.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Label
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN Attribute A ON A.GUIDReference = T.Demographic_Id --SA.Demographic_Id
	INNER JOIN EnumSet ES ON ES.Id = A.EnumSetId
	INNER JOIN EnumDefinition ED ON ED.EnumSet_Id = ES.Id
	WHERE ED.IsActive = 1
		AND A.Active = 1
		AND A.EnumSetId IS NOT NULL
	
	UNION
	
	SELECT DISTINCT --SA.Id AS SortAttId
		A.GUIDReference AS AttributeId
		,ED.Id
		,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS NAME
		,ED.Value
		,ED.IsActive
		,IsFreeTextRequired
		,IsSelected
		,ISNULL(ED.EnumValueSet_Id, @DefaultGuid) AS EnumValueSetId
		,ED.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(ED.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Label
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN Attribute A ON A.GUIDReference = T.Demographic_Id --SA.Demographic_Id
	INNER JOIN EnumDefinition ED ON ED.Demographic_Id = A.GUIDReference
	WHERE ED.IsActive = 1
		AND A.Active = 1
		AND A.EnumSetId IS NULL

	--EnumsetDTO
	SELECT DISTINCT SA.Id AS SortAttId
		,ES.ID AS Id
		,A.GUIDReference AS AttributeId
		,dbo.GetTranslationValue(ES.Translation_Id, @pCultureCode) AS NAME
		,ES.Translation_Id
		,dbo.GetTranslationValue(ES.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(ES.Translation_Id, @pCultureCode) AS Label
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN Attribute A ON A.GUIDReference = SA.Demographic_Id
	INNER JOIN EnumSet ES ON ES.Id = A.EnumSetId

	--EnumsetDTO.Definitions
	SELECT DISTINCT ES.ID AS EnumSetId
		,ED.Id
		,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS NAME
		,ED.Value
		,ED.IsActive
		,ED.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(ED.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Label
		,IsFreeTextRequired
		,IsSelected
		,ISNULL(ED.EnumValueSet_Id, @DefaultGuid) AS EnumValueSetId
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN Attribute A ON A.GUIDReference = SA.Demographic_Id
	INNER JOIN EnumSet ES ON ES.Id = A.EnumSetId
	INNER JOIN EnumDefinition ED ON ED.EnumSet_Id = ES.Id

	--ValueGroupings
	SELECT DISTINCT DVG.GUIDReference AS GroupingId
		,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Demographic
		,A.GUIDReference AS AttributeId
		,dbo.GetTranslationValue(DVG.Label_Id, @pCultureCode) AS GroupingName
		,DVG.[Type] AS DemographicType
		,A.Translation_Id AS Id
		,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN Attribute A ON A.GUIDReference = SA.Demographic_Id
	INNER JOIN DemographicValueGrouping DVG ON DVG.Demographic_Id = A.GUIDReference

	--Intervales
	SELECT DISTINCT DV.GUIDReference AS Id
		,DVG.GUIDReference AS DemographicGroupingId
		,dbo.GetTranslationValue(DV.Label_Id, @pCultureCode) AS IntervalDescription
		,dbo.GetTranslationValue(DV.Label_Id, @pCultureCode) AS IntervalDescriptionKey
		,CASE 
			WHEN DVG.[Type] = 'Decimal'
				THEN 'Float'
			WHEN DVG.[Type] = 'Int'
				THEN 'Integer'
			ELSE DVG.[Type]
			END AS DemographicType
		,DV.Label_Id AS TranslationId
		,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Demographic
		,A.GUIDReference AS AttributeId
		,dbo.GetTranslationValue(DVG.Label_Id, @pCultureCode) AS GroupingName
		,A.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
		,A.[From] AS [From]
		,A.[To] AS [To]
		,DVI.StartInt AS FromInteger
		,DVI.EndInt AS ToInteger
		,DVI.StartDate AS FromDate
		,DVI.EndDate AS ToDate
		,A.DateFrom AS MinDate
		,A.DateTo AS MaxDate
		,DVI.StartDecimal AS FromDecimal
		,DVI.EndDecimal AS ToDecimal
		,A.[From] AS MinDecimal
		,A.[To] AS MaxDecimal
	--,IsFreeTextRequired,IsSelected,ISNULL(ED.EnumSet_Id,@DefaultGuid) AS EnumValueSetId
	FROM SortAttribute SA --ON SA.PageSection_Id=PS.Id
	INNER JOIN Attribute A ON A.GUIDReference = SA.Demographic_Id
	INNER JOIN DemographicValueGrouping DVG ON DVG.Demographic_Id = A.GUIDReference
	INNER JOIN DemographicValue DV ON DV.DemographicValueGrouping_Id = DVG.GUIDReference
	LEFT JOIN DemographicValueInterval DVI ON DVI.GUIDReference = DV.GUIDReference
	WHERE DVG.[Type] <> 'Enum'
		AND A.Active = 1

	--Belonging section
	SELECT DISTINCT SectionID AS PageSectionId
		,SA.Id
		,BT.Id AS BelongingTypeId
		,dbo.GetTranslationValue(BT.Translation_Id, @pCultureCode) AS NAME
		,SA.[Order]
		,BT.Translation_Id AS TranslationId
		,dbo.GetTranslationValue(BT.Translation_Id, NULL) AS [Key]
		,@pCultureCode AS CultureCode
		,@pCultureName AS CultureName
		,dbo.GetTranslationValue(BT.Translation_Id, @pCultureCode) AS Label
		,CASE 
			WHEN BT.[Type] = 'GroupBelongingType'
				THEN 0
			WHEN BT.[Type] = 'IndividualBelongingType'
				THEN 1
			END AS BelongingTypeScope
		
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN BelongingType BT ON BT.Id = SA.BelongingType_Id
	Order By SA.[Order] DESC

	---BelongingSection AttributeConfigurationDTO
	SELECT SA.Id AS SortAttributeID
		,AC.AttributeConfigurationId AS Id
		,AC.BelongingTypeId
		,AC.[Order]
		,IIF((SA.UseShortCode=1 OR AC.UseShortCode=1) AND A.ShortCode IS NOT NULL, A.ShortCode, dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)) AS AttributeName
		--,IIF(SA.UseShortCode=1 AND A.ShortCode IS NOT NULL, A.ShortCode, dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)) AS AttributeName
		,AC.AttributeId
		,AC.IsRequired
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN AttributeConfiguration AC ON sa.BelongingType_Id = AC.BelongingTypeId
	INNER JOIN Attribute A on A.Guidreference=AC.AttributeId
		AND AC.AttributeId = T.Demographic_Id

	--OrderedBelongingDtos,Individual
	SELECT DISTINCT SA.Id AS SortAttributeId
		,'IndividualBelongingType' AS BelongingType
		,OB.[Order]
		,B.CandidateId
		,B.GUIDReference AS Id
		,BT.Id AS BelongingTypeId
		,b.BelongingCode
		,SD.Id AS StateId
		,SD.Code
		,dbo.GetTranslationValue(SD.Label_Id, @pCultureCode) AS NAME
		,SM.GUIDReference AS StateModelId
		,dbo.GetTranslationValue(SM.Name_Id, @pCultureCode) AS StateModelName
		,CASE 
			WHEN TB.[Type] = 'FinalTransitionBehavior'
				THEN 1
			ELSE 0
			END AS IsLast
		,SD.TrafficLightBehavior AS DisplayBehavior
		,SD.InactiveBehavior AS Inactive
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN BelongingType BT ON BT.Id = SA.BelongingType_Id
	INNER JOIN belonging bg ON bg.[TypeId] = bt.id
	--INNER JOIN (SELECT Belonging_Id, CandidateId, ROW_NUMBER() OVER (PARTITION BY CandidateId ORDER BY [Order]) AS [Order] FROM OrderedBelonging JOIN Belonging ON Belonging_Id = GUIDReference) OB ON OB.CandidateId = bg.CandidateId
	INNER JOIN OrderedBelonging OB ON OB.Belonging_Id = bg.GUIDReference AND OB.BelongingSection_Id=SA.Id
	INNER JOIN (
		SELECT B.CandidateId
			,B.GUIDReference
			,BelongingCode
			,B.State_Id
		FROM Belonging B
		INNER JOIN #GroupCandidates GC ON GC.CandidateId = B.CandidateId
			--INNER JOIN CollectiveMembership CM ON B.CandidateId IN (
			--             CM.Individual_Id
			--             ,CM.Group_Id
			--             )
			--WHERE CM.Group_Id = @Group_Id
		) AS B ON B.GUIDReference = OB.Belonging_Id
	INNER JOIN StateDefinition SD ON SD.Id = B.State_Id
	INNER JOIN stateModel SM ON SM.GUIDReference = SD.StateModel_Id
	INNER JOIN TransitionBehavior TB ON TB.GUIDReference = SD.StateDefinitionBehavior_Id
	WHERE BT.[Type] = 'IndividualBelongingType'

	--OrderedBelongingDtos,Group
	SELECT DISTINCT SA.Id AS SortAttributeId
		,'GroupBelongingType' AS BelongingType
		,OB.[Order]
		,B.CandidateId
		,B.GUIDReference AS Id
		,BT.Id AS BelongingTypeId
		,b.BelongingCode
		,SD.Id AS StateId
		,SD.Code
		,dbo.GetTranslationValue(SD.Label_Id, @pCultureCode) AS NAME
		,SM.GUIDReference AS StateModelId
		,dbo.GetTranslationValue(SM.Name_Id, @pCultureCode) AS StateModelName
		,CASE 
			WHEN TB.[Type] = 'FinalTransitionBehavior'
				THEN 1
			ELSE 0
			END AS IsLast
		,SD.TrafficLightBehavior AS DisplayBehavior
		,SD.InactiveBehavior AS Inactive
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN BelongingType BT ON BT.Id = SA.BelongingType_Id
	INNER JOIN belonging bg ON bg.[TypeId] = bt.id
	--INNER JOIN (SELECT Belonging_Id, CandidateId, ROW_NUMBER() OVER (PARTITION BY CandidateId ORDER BY [Order]) AS [Order] FROM OrderedBelonging JOIN Belonging ON Belonging_Id = GUIDReference) OB ON OB.CandidateId = bg.CandidateId
	INNER JOIN OrderedBelonging OB ON OB.Belonging_Id = bg.GUIDReference AND OB.BelongingSection_Id=SA.Id
	INNER JOIN (
		SELECT B.CandidateId
			,B.GUIDReference
			,BelongingCode
			,B.State_Id
		FROM Belonging B
		INNER JOIN #GroupCandidates GC ON GC.CandidateId = B.CandidateId
			--INNER JOIN CollectiveMembership CM ON B.CandidateId IN (
			--             CM.Individual_Id
			--             ,CM.Group_Id
			--             )
			--WHERE CM.Group_Id = @Group_Id
		) AS B ON B.GUIDReference = OB.Belonging_Id
	INNER JOIN StateDefinition SD ON SD.Id = B.State_Id
	INNER JOIN stateModel SM ON SM.GUIDReference = SD.StateModel_Id
	INNER JOIN TransitionBehavior TB ON TB.GUIDReference = SD.StateDefinitionBehavior_Id
	WHERE BT.[Type] = 'GroupBelongingType'

	--StateDefinitionDTO.Transitions
	SELECT DISTINCT B.GUIDReference AS BelongingId
		,ST.ToState_Id AS StateToId
		,dbo.GetTranslationValue(SD1.Label_Id, @pCultureCode) AS StateToName
		,SD1.Code AS StateToCode
	FROM #TEMP T
	INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId
	INNER JOIN BelongingType BT ON BT.Id = SA.BelongingType_Id
	INNER JOIN OrderedBelonging OB ON OB.BelongingSection_Id = SA.Id
	INNER JOIN (
		SELECT B.CandidateId
			,B.GUIDReference
			,BelongingCode
			,B.State_Id
		FROM Belonging B
		INNER JOIN CollectiveMembership CM ON B.CandidateId IN (
				CM.Individual_Id
				,CM.Group_Id
				)
		WHERE CM.Group_Id = @Group_Id
		) AS B ON B.GUIDReference = OB.Belonging_Id
	INNER JOIN StateDefinition SD ON SD.Id = B.State_Id
	--JOIN StateDefinitionsTransitions SDT ON SDT.StateDefinition_Id=SD.Id
	INNER JOIN StateTransition ST ON ST.FromState_Id = SD.Id
	INNER JOIN StateDefinition SD1 ON SD1.Id = ST.ToState_Id

	--AttributeValue DTO's
	--Boolean Attributes 1
	SELECT DISTINCT T.SortAttId AS SortAttributeId
		,AV.GUIDReference AS Id
		,AV.CandidateId
		,AV.RespondentId
		,'Boolean' AS DemographicType
		,T.Demographic_Id AS DemographicId
		--,boolAV.Value
		,CAST(CASE 
				WHEN AV.Value = '1'
					THEN 1
				WHEN AV.Value = '0'
					THEN 0
				END AS BIT) AS Value
	FROM #TEMP T
	INNER JOIN AttributeValue AV ON AV.DemographicId = T.Demographic_Id
		AND AV.CandidateId IS NOT NULL
	--INNER JOIN BooleanAttributeValue boolAV ON AV.GUIDReference = boolAV.GUIDReference
	INNER JOIN #GroupCandidates GC ON GC.CandidateId = AV.CandidateId
		AND (GC.IsAnonymized=0 OR T.MustAnonymize=0)
	WHERE av.CandidateId IS NOT NULL
		AND av.Discriminator = 'BooleanAttributeValue'
	
	UNION ALL
	
	SELECT DISTINCT T.SortAttId AS SortAttributeId
		,AV.GUIDReference AS Id
		,AV.CandidateId
		,AV.RespondentId
		,'Boolean' AS DemographicType
		,T.Demographic_Id AS DemographicId
		--,boolAV.Value
		,CAST(CASE 
				WHEN AV.Value = '1'
					THEN 1
				WHEN AV.Value = '0'
					THEN 0
				END AS BIT) AS Value
	FROM #TEMP T
	INNER JOIN AttributeValue AV ON AV.DemographicId = T.Demographic_Id
		AND AV.CandidateId IS NULL
	--INNER JOIN BooleanAttributeValue boolAV ON AV.GUIDReference = boolAV.GUIDReference
	INNER JOIN Respondent R ON Av.RespondentId = R.GUIDReference
	INNER JOIN Belonging B ON B.GUIDReference = R.GUIDReference
	INNER JOIN #GroupCandidates GC ON GC.CandidateId = B.CandidateId
		AND (GC.IsAnonymized=0 OR T.MustAnonymize=0)
	WHERE av.RespondentId IS NOT NULL
		AND av.Discriminator = 'BooleanAttributeValue'

	--Integer Attributes 
	SELECT DISTINCT T.SortAttId AS SortAttributeId
		,AV.GUIDReference AS Id
		,AV.CandidateId
		,T.Demographic_Id AS DemographicId
		,'Integer' AS DemographicType
		,AV.RespondentId
		--,intAV.Value
		,TRY_CAST(av.Value AS INT) AS Value
	FROM #TEMP T
	INNER JOIN AttributeValue AV ON AV.DemographicId = T.Demographic_Id
		AND AV.CandidateId IS NOT NULL
	--INNER JOIN IntAttributeValue intAV ON AV.GUIDReference = intAV.GUIDReference
	INNER JOIN #GroupCandidates GC ON GC.CandidateId = AV.CandidateId
		AND (GC.IsAnonymized=0 OR T.MustAnonymize=0)
	WHERE av.CandidateId IS NOT NULL
		AND av.Discriminator = 'IntAttributeValue'
	
	UNION ALL
	
	SELECT DISTINCT T.SortAttId AS SortAttributeId
		,AV.GUIDReference AS Id
		,AV.CandidateId
		,T.Demographic_Id AS DemographicId
		,'Integer' AS DemographicType
		,AV.RespondentId
		--,intAV.Value
		,TRY_CAST(av.Value AS INT) AS Value
	FROM #TEMP T
	INNER JOIN AttributeValue AV ON AV.DemographicId = T.Demographic_Id
		AND AV.CandidateId IS NULL
	--INNER JOIN IntAttributeValue intAV ON AV.GUIDReference = intAV.GUIDReference
	INNER JOIN Respondent R ON Av.RespondentId = R.GUIDReference
	INNER JOIN Belonging B ON B.GUIDReference = R.GUIDReference
	INNER JOIN #GroupCandidates GC ON GC.CandidateId = B.CandidateId
		AND (GC.IsAnonymized=0 OR T.MustAnonymize=0)
	WHERE av.RespondentId IS NOT NULL
		AND av.Discriminator = 'IntAttributeValue'

	--Float Attributes 3
	SELECT DISTINCT T.SortAttId AS SortAttributeId
		,AV.GUIDReference AS Id
		,AV.CandidateId
		,T.Demographic_Id AS DemographicId
		,'Float' AS DemographicType
		,AV.RespondentId
		--,floatAV.Value
		,TRY_CAST(REPLACE(AV.Value, ',', '.') AS DECIMAL(18, 2)) AS Value
	FROM #TEMP T
	INNER JOIN AttributeValue AV ON AV.DemographicId = T.Demographic_Id
		AND AV.CandidateId IS NOT NULL
	--INNER JOIN FloatAttributeValue floatAV ON AV.GUIDReference = floatAV.GUIDReference
	INNER JOIN #GroupCandidates GC ON GC.CandidateId = AV.CandidateId
		AND (GC.IsAnonymized=0 OR T.MustAnonymize=0)
	WHERE av.CandidateId IS NOT NULL
		AND av.Discriminator = 'FloatAttributeValue'
	
	UNION ALL
	
	SELECT DISTINCT T.SortAttId AS SortAttributeId
		,AV.GUIDReference AS Id
		,AV.CandidateId
		,T.Demographic_Id AS DemographicId
		,'Float' AS DemographicType
		,AV.RespondentId
		--,floatAV.Value
		,TRY_CAST(REPLACE(AV.Value, ',', '.') AS DECIMAL(18, 2)) AS Value
	FROM #TEMP T
	INNER JOIN AttributeValue AV ON AV.DemographicId = T.Demographic_Id
		AND AV.CandidateId IS NULL
	--INNER JOIN FloatAttributeValue floatAV ON AV.GUIDReference = floatAV.GUIDReference
	INNER JOIN Respondent R ON Av.RespondentId = R.GUIDReference
	INNER JOIN Belonging B ON B.GUIDReference = R.GUIDReference
	INNER JOIN #GroupCandidates GC ON GC.CandidateId = B.CandidateId
		AND (GC.IsAnonymized=0 OR T.MustAnonymize=0)
	WHERE av.RespondentId IS NOT NULL
		AND av.Discriminator = 'FloatAttributeValue'

	--Date Attributes 4
	SELECT DISTINCT T.SortAttId AS SortAttributeId
		,AV.GUIDReference AS Id
		,AV.CandidateId
		,T.Demographic_Id AS DemographicId
		,'Date' AS DemographicType
		,AV.RespondentId
		--,dateAV.Value
		,TRY_CAST(av.Value AS DATETIME) AS Value
	FROM #TEMP T
	INNER JOIN AttributeValue AV ON AV.DemographicId = T.Demographic_Id
		AND AV.CandidateId IS NOT NULL
	--INNER JOIN DateAttributeValue dateAV ON AV.GUIDReference = dateAV.GUIDReference
	INNER JOIN #GroupCandidates GC ON GC.CandidateId = AV.CandidateId
		AND (GC.IsAnonymized=0 OR T.MustAnonymize=0)
	WHERE av.CandidateId IS NOT NULL
		AND av.Discriminator = 'DateAttributeValue'
	
	UNION ALL
	
	SELECT DISTINCT T.SortAttId AS SortAttributeId
		,AV.GUIDReference AS Id
		,AV.CandidateId
		,T.Demographic_Id AS DemographicId
		,'Date' AS DemographicType
		,AV.RespondentId
		--,dateAV.Value
		,TRY_CAST(av.Value AS DATETIME) AS Value
	FROM #TEMP T
	INNER JOIN AttributeValue AV ON AV.DemographicId = T.Demographic_Id
		AND AV.CandidateId IS NULL
	--INNER JOIN DateAttributeValue dateAV ON AV.GUIDReference = dateAV.GUIDReference
	INNER JOIN Respondent R ON Av.RespondentId = R.GUIDReference
	INNER JOIN Belonging B ON B.GUIDReference = R.GUIDReference
	INNER JOIN #GroupCandidates GC ON GC.CandidateId = B.CandidateId
		AND (GC.IsAnonymized=0 OR T.MustAnonymize=0)
	WHERE av.RespondentId IS NOT NULL
		AND av.Discriminator = 'DateAttributeValue'

	--String Attributes 5
	SELECT DISTINCT T.SortAttId AS SortAttributeId
		,AV.GUIDReference AS Id
		,AV.CandidateId
		,T.Demographic_Id AS DemographicId
		,'String' AS DemographicType
		,AV.RespondentId
		--,strAV.Value
		,av.Value
	FROM #TEMP T
	INNER JOIN AttributeValue AV ON AV.DemographicId = T.Demographic_Id
		AND AV.CandidateId IS NOT NULL
	--INNER JOIN StringAttributeValue strAV ON AV.GUIDReference = strAV.GUIDReference
	INNER JOIN #GroupCandidates GC ON GC.CandidateId = AV.CandidateId
		AND (GC.IsAnonymized=0 OR T.MustAnonymize=0)
	WHERE av.CandidateId IS NOT NULL
		AND av.Discriminator = 'StringAttributeValue'
	
	UNION ALL
	
	SELECT DISTINCT T.SortAttId AS SortAttributeId
		,AV.GUIDReference AS Id
		,AV.CandidateId
		,T.Demographic_Id AS DemographicId
		,'String' AS DemographicType
		,AV.RespondentId
		--,strAV.Value
		,av.Value
	FROM #TEMP T
	INNER JOIN AttributeValue AV ON AV.DemographicId = T.Demographic_Id
		AND AV.CandidateId IS NULL
	--INNER JOIN StringAttributeValue strAV ON AV.GUIDReference = strAV.GUIDReference
	INNER JOIN Respondent R ON Av.RespondentId = R.GUIDReference
	INNER JOIN Belonging B ON B.GUIDReference = R.GUIDReference
	INNER JOIN #GroupCandidates GC ON GC.CandidateId = B.CandidateId
		AND (GC.IsAnonymized=0 OR T.MustAnonymize=0)
	WHERE av.RespondentId IS NOT NULL
		AND av.Discriminator = 'StringAttributeValue'

	------Enum Attributes 6
	SELECT DISTINCT [FreeText]
		,T.SortAttId AS SortAttributeId
		,AtValue.GUIDReference AS Id
		,AtValue.CandidateId
		,T.Demographic_Id AS DemographicId
		,'Enumeration' AS DemographicType
		,AtValue.RespondentId
		,AtValue.Defvalue AS Value
		,AtValue.IsActive
		,AtValue.IsFreeTextRequired
		,TranslationId
		,AtValue.[Key]
		,CultureCode
		,CultureName
		,Label
	FROM #TEMP T
	INNER JOIN Attribute A ON A.GUIDReference = T.Demographic_Id
	INNER JOIN (
		SELECT AV.CandidateId
			,AV.GUIDReference
			,ED.Value + ' - ' + dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Value
			,av.DemographicId
			,av.RespondentId
			,ED.EnumSet_Id
			,ED.Id AS EnumDefId
			,ED.Translation_Id AS TranslationId
			,dbo.GetTranslationValue(ED.Translation_Id, NULL) AS [Key]
			,@pCultureCode AS CultureCode
			,@pCultureName AS CultureName
			,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Label
			,ED.Value AS Defvalue
			,ED.IsActive
			,ED.IsFreeTextRequired
			,av.[FreeText]
			,gc.IsAnonymized
		FROM AttributeValue av
		INNER JOIN #GroupCandidates GC ON GC.CandidateId = AV.CandidateId
			AND av.Discriminator = 'EnumAttributeValue'
		--INNER JOIN CollectiveMembership CM ON AV.CandidateId IN (
		--             CM.Individual_Id
		--             ,CM.Group_Id
		--             )
		--INNER JOIN EnumAttributeValue enumAV ON AV.GUIDReference = enumAV.GUIDReference
		--INNER JOIN EnumDefinition ED ON enumAV.Value_Id = ED.Id
		LEFT JOIN EnumDefinition ED ON av.EnumDefinition_Id = ED.Id
		WHERE --CM.Group_Id = @Group_Id AND
			av.CandidateId IS NOT NULL
		
		UNION ALL
		
		SELECT AV.CandidateId
			,AV.GUIDReference
			,ED.Value + ' - ' + dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Value
			,av.DemographicId
			,av.RespondentId
			,ED.EnumSet_Id
			,ED.Id AS EnumDefId
			,ED.Translation_Id AS TranslationId
			,dbo.GetTranslationValue(ED.Translation_Id, NULL) AS [Key]
			,@pCultureCode AS CultureCode
			,@pCultureName AS CultureName
			,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Label
			,ED.Value AS Defvalue
			,ED.IsActive
			,ED.IsFreeTextRequired
			,av.[FreeText]
			,GC.IsAnonymized
		FROM AttributeValue av
		INNER JOIN Respondent R ON R.GUIDReference = av.RespondentId
		INNER JOIN Belonging B ON B.GUIDReference = R.GUIDReference
		INNER JOIN #GroupCandidates GC ON GC.CandidateId = B.CandidateId
			--INNER JOIN CollectiveMembership CM ON B.CandidateId IN (
			--             CM.Individual_Id
			--             ,CM.Group_Id
			--             )
			--INNER JOIN EnumAttributeValue enumAV ON AV.GUIDReference = enumAV.GUIDReference
			AND av.[Discriminator] = 'EnumAttributeValue'
		LEFT JOIN EnumDefinition ED ON av.EnumDefinition_Id = ED.Id
		WHERE --CM.Group_Id = @Group_Id AND
			av.RespondentId IS NOT NULL
		) AtValue ON AtValue.DemographicId = T.Demographic_Id
		AND (AtValue.IsAnonymized=0 OR T.MustAnonymize=0)
	WHERE A.[Type] = 'enum'

	DROP TABLE #TEMP

	DROP TABLE #GroupCandidates
END