CREATE PROCEDURE [dbo].[GetSelectedPanelCardDemographics] @pPanelId UNIQUEIDENTIFIER

	,@pScopeReferenceId UNIQUEIDENTIFIER

	,@pCountryId UNIQUEIDENTIFIER

	,@pCultureCode INT

AS

BEGIN

	CREATE TABLE #tmphold (

		aType NVARCHAR(400)

		,aId UNIQUEIDENTIFIER

		,aName NVARCHAR(400)

		,aOrder INT

		,MustAnonymize BIT
		,TimeDisplay BIT
		)

DECLARE @groupid uniqueidentifier=(select top 1 group_id from collectivemembership where Individual_Id=@pScopeReferenceId )

	INSERT INTO #tmphold

	SELECT A.[Type] AS [Type]

		,A.GUIDReference AS Id

		,IIF(AC.UseShortCode=1 AND A.ShortCode IS NOT NULL, A.ShortCode, dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)) AS NAME

		,[Order]

		,a.MustAnonymize
		,a.TimeDisplay

	FROM Attribute A

	INNER JOIN AttributeConfiguration ac ON a.GUIDReference = ac.AttributeId

	INNER JOIN ConfigurationSet cs ON cs.ConfigurationSetId = ac.ConfigurationSetId

	WHERE cs.[Type] = 'PANEL'

		AND A.Country_Id = @pCountryId

		AND cs.PanelId = @pPanelId

		AND A.Active=1

	SELECT a.NAME

		,CASE 

			WHEN a.[Type] = 'Boolean'

				THEN CAST(

				(CASE WHEN AtValueBool.Value=0 THEN 'False'

					WHEN AtValueBool.Value=1 THEN 'True'

					ELSE NULL

				END)

				 AS VARCHAR(1000))

			WHEN a.[Type] = 'Int'

				THEN CAST(AtValueInt.Value AS NVARCHAR(1000))

			WHEN a.[Type] = 'float'

				THEN CAST(AtValueFloat.Value AS NVARCHAR(1000))

			WHEN a.[Type] = 'date'

				THEN CAST(FORMAT(Convert(DateTime, AtValueDate.Value), 'dd/MM/yyyy HH:mm') AS NVARCHAR(1000))

			WHEN a.[Type] = 'string'

				THEN CAST(AtValueString.Value AS NVARCHAR(1000))

			WHEN a.[Type] = 'enum'

				THEN CAST(AtValueEnum.Value AS NVARCHAR(1000))				

			END 		

		AS Value

		,CASE 

			WHEN a.[Type] = 'Boolean'

				THEN 'Boolean'

			WHEN a.[Type] = 'Int'

				THEN 'Integer'

			WHEN a.[Type] = 'float'

				THEN 'Float'

			WHEN a.[Type] = 'date'

				THEN 'Date'

			WHEN a.[Type] = 'string'

				THEN 'String'

			WHEN a.[Type] = 'enum'

				THEN 'Enumeration'				

			END 		

		 AS DemographicType,

		 a.MustAnonymize,
		 a.TimeDisplay

	FROM (

		SELECT aType AS [Type]

			,aId AS Id

			,aName AS NAME

			,aOrder
			,MustAnonymize
			,TimeDisplay
		FROM #tmphold

		) a

	LEFT JOIN (

		SELECT AV.CandidateId

			,AV.GUIDReference

			,av.Value

			,av.DemographicId

		FROM AttributeValue av

		--INNER JOIN BooleanAttributeValue boolAV ON AV.GUIDReference = boolAV.GUIDReference

		WHERE (AV.CandidateId = @pScopeReferenceId or Av.CandidateId=@groupid)
		AND av.Discriminator='BooleanAttributeValue'

		) AtValueBool ON AtValueBool.DemographicId = a.Id

		AND a.[Type] = 'Boolean'

	LEFT JOIN (

		SELECT AV.CandidateId

			,AV.GUIDReference

			,av.Value

			,av.DemographicId

		FROM AttributeValue av

		--INNER JOIN IntAttributeValue intAV ON AV.GUIDReference = intAV.GUIDReference

		WHERE (AV.CandidateId = @pScopeReferenceId or Av.CandidateId=@groupid)
		AND av.Discriminator='IntAttributeValue'

		) AtValueInt ON AtValueInt.DemographicId = a.Id

		AND a.[Type] = 'Int'

	LEFT JOIN (

		SELECT AV.CandidateId

			,AV.GUIDReference

			,av.Value

			,av.DemographicId

		FROM AttributeValue av

		--INNER JOIN FloatAttributeValue floatAV ON AV.GUIDReference = floatAV.GUIDReference

		WHERE (AV.CandidateId = @pScopeReferenceId or Av.CandidateId=@groupid)
		AND av.Discriminator='FloatAttributeValue'

		) AtValueFloat ON AtValueFloat.DemographicId = a.Id

		AND a.[Type] = 'float'

	LEFT JOIN (

		SELECT AV.CandidateId

			,AV.GUIDReference

			,av.Value

			,av.DemographicId

		FROM AttributeValue av

		--INNER JOIN DateAttributeValue dateAV ON AV.GUIDReference = dateAV.GUIDReference

		WHERE (AV.CandidateId = @pScopeReferenceId or Av.CandidateId=@groupid)
		AND av.Discriminator='DateAttributeValue'

		) AtValueDate ON AtValueDate.DemographicId = a.Id

		AND a.[Type] = 'Date'

	LEFT JOIN (

		SELECT AV.CandidateId

			,AV.GUIDReference

			,av.Value

			,av.DemographicId

		FROM AttributeValue av

		--INNER JOIN StringAttributeValue dateAV ON AV.GUIDReference = dateAV.GUIDReference

		WHERE (AV.CandidateId = @pScopeReferenceId or Av.CandidateId=@groupid)
		AND av.Discriminator='StringAttributeValue'

		) AtValueString ON AtValueString.DemographicId = a.Id

		AND a.[Type] = 'string'

	LEFT JOIN (

		SELECT AV.CandidateId

			,AV.GUIDReference

			,(ED.Value + ' - ' + dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode)) AS Value

			,av.DemographicId

			,ED.EnumSet_Id

		FROM AttributeValue av

		--INNER JOIN EnumAttributeValue enumAV ON AV.GUIDReference = enumAV.GUIDReference

		INNER JOIN EnumDefinition ED ON av.EnumDefinition_Id = ED.Id

		WHERE (AV.CandidateId = @pScopeReferenceId or Av.CandidateId=@groupid)
		AND av.Discriminator='EnumAttributeValue'
		) AtValueEnum ON AtValueEnum.DemographicId = a.Id

		AND a.[Type] = 'enum'

		LEFT JOIN Individual I ON i.GUIDReference=@pScopeReferenceId

	WHERE a.[Type] IN (

			'Int'

			,'float'

			,'Date'

			,'string'

			,'enum'

			,'Boolean'

			)
		AND (a.MustAnonymize = 0 OR ISNULL(i.IsAnonymized, 0) = 0)

	ORDER BY aOrder

END