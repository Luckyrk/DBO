CREATE PROCEDURE [dbo].[GetDemographicsInfo] 
	@pScope VARCHAR(50)
	,@pScopeReferenceId UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
AS
BEGIN
	DECLARE @CandidateGuid UNIQUEIDENTIFIER
	DECLARE @CollectiveGuid UNIQUEIDENTIFIER

	DECLARE @CountryCode NVARCHAR(10)
	DECLARE @CountryGuid UNIQUEIDENTIFIER
		,@DefaultGuid UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
	DECLARE @GeographicAreaId UNIQUEIDENTIFIER


	IF (@pScope = 'INDIVIDUAL')
	BEGIN
		SET @CandidateGuid = @pScopeReferenceId
	END
	ELSE IF (
			@pScope = 'GROUP'
			OR @pScope = 'PANEL'
			)
	BEGIN
		SET @candidateGuid = (
				SELECT TOP 1 Group_Id
				FROM CollectiveMembership
				WHERE Individual_Id = @pScopeReferenceId
				ORDER BY SignUpDate DESC
				)
		SELECT @GeographicAreaId = GeographicArea_Id FROM Candidate WHERE GUIDReference = @candidateGuid
	END

	SET @CountryCode = (
			SELECT CountryISO2A
			FROM Country
			WHERE CountryId = @pCountryId
			)
	SET @CountryGuid = @pCountryId;

	CREATE TABLE #tmphold (
		aType NVARCHAR(400)
		,aId UNIQUEIDENTIFIER
		,aName NVARCHAR(400)
		,aOrder INT
		,aShortCode NVARCHAR(6)
		,aMustAnonymize BIT
		,aTimeDisplay BIT
		)

	INSERT INTO #tmphold
	SELECT A.[Type] AS [Type]
		,A.guidreference AS Id
		--,Case When A.ShortCode is not null Then A.ShortCode Else dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) End AS NAME
		,IIF(UseShortCode=1 AND A.ShortCode IS NOT NULL, A.ShortCode, dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)) AS NAME
		,ac.[Order]
		,A.ShortCode
		,A.MustAnonymize
		,A.TimeDisplay
	FROM attribute A
	INNER JOIN AttributeScope S ON S.GuidReference = A.[Scope_Id] 
	INNER JOIN AttributeConfiguration ac ON a.guidreference = ac.attributeid
	INNER JOIN configurationset cs ON cs.ConfigurationSetId = ac.ConfigurationSetId
	WHERE cs.[type] = @pScope
		AND A.Country_Id = @pCountryId and A.Active =1 and ac.Discriminator='ConfigurationSet'
		AND S.[Type] IN ((SELECT items from dbo.Split( CASE WHEN @pScope = 'INDIVIDUAL' THEN 'INDIVIDUAL' 
							WHEN @pScope = 'GROUP' THEN 'Household,GeographicArea'
							ELSE 'Panel'
							END,',')))
	ORDER BY ac.[Order] ASC 

	SELECT a.NAME
		,CASE 
			WHEN a.[Type] = 'Boolean'
				THEN CAST((
							CASE WHEN AtValueBool.Value='0' THEN 'False'
								WHEN AtValueBool.Value='1' THEN 'True'
								ELSE NULL
							END
							) AS VARCHAR(1000))
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
			END AS Value
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
			END AS DemographicType,
			a.MustAnonymize,
			a.TimeDisplay
	FROM (
	SELECT aType AS [Type]
			,aId AS Id
			,aName AS NAME
			,aOrder as aOrder
			,aMustAnonymize as MustAnonymize
			,aTimeDisplay as TimeDisplay
		FROM #tmphold
	) a
	LEFT JOIN (
		SELECT AV.CandidateId
			,AV.GUIDReference
			,av.Value
			,av.DemographicId
		FROM AttributeValue av
		WHERE AV.CandidateId = @CandidateGuid OR AV.RespondentId = @GeographicAreaId
		AND av.[Discriminator] = 'BooleanAttributeValue'
		) AtValueBool ON AtValueBool.DemographicId = a.Id
		AND a.[Type] = 'Boolean'
	LEFT JOIN (
		SELECT AV.CandidateId
			,AV.GUIDReference
			,av.Value
			,av.DemographicId
		FROM AttributeValue av
		WHERE AV.CandidateId = @CandidateGuid OR AV.RespondentId = @GeographicAreaId
		AND av.[Discriminator] = 'IntAttributeValue'
		) AtValueInt ON AtValueInt.DemographicId = a.Id
		AND a.[Type] = 'Int'
	LEFT JOIN (
		SELECT AV.CandidateId
			,AV.GUIDReference
			,av.Value
			,av.DemographicId
		FROM AttributeValue av
		WHERE AV.CandidateId = @CandidateGuid OR AV.RespondentId = @GeographicAreaId
		AND av.[Discriminator] = 'FloatAttributeValue'
		) AtValueFloat ON AtValueFloat.DemographicId = a.Id
		AND a.[Type] = 'float'
	LEFT JOIN (
		SELECT AV.CandidateId
			,AV.GUIDReference
			,av.Value
			,av.DemographicId
		FROM AttributeValue av
		WHERE AV.CandidateId = @CandidateGuid OR AV.RespondentId = @GeographicAreaId
		AND av.[Discriminator] = 'DateAttributeValue'
		) AtValueDate ON AtValueDate.DemographicId = a.Id
		AND a.[Type] = 'Date'
	LEFT JOIN (
		SELECT AV.CandidateId
			,AV.GUIDReference
			,av.Value
			,av.DemographicId
		FROM AttributeValue av
		WHERE AV.CandidateId = @CandidateGuid OR AV.RespondentId = @GeographicAreaId
		AND av.[Discriminator] = 'StringAttributeValue'
		) AtValueString ON AtValueString.DemographicId = a.Id
		AND a.[Type] = 'string'
	LEFT JOIN (
		SELECT AV.CandidateId
			,AV.GUIDReference
			,(ED.Value +' - ' + dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode))  As Value
			,av.DemographicId
			,ED.EnumSet_Id
		FROM AttributeValue av
		INNER JOIN EnumDefinition ED ON av.[EnumDefinition_Id] = ED.Id
		WHERE AV.CandidateId = @CandidateGuid OR AV.RespondentId = @GeographicAreaId
		AND av.[Discriminator] = 'EnumAttributeValue'
		) AtValueEnum ON AtValueEnum.DemographicId = a.Id
		AND a.[Type] = 'enum'
	WHERE a.[Type] IN (
			'Int'
			,'float'
			,'Date'
			,'string'
			,'enum'
			,'Boolean'
			)
	ORDER BY [aOrder] ASC

	---- ---Forms  8
	IF (@pScope = 'INDIVIDUAL')
	BEGIN
	SELECT DISTINCT F.GUIDReference AS Id,
		(dbo.GetTranslationValue(Translation_Id, @pCultureCode)) AS NAME,
		F.GPSUpdateTimestamp AS CreationTimeStamp
	FROM Form F
	LEFT JOIN FormPanel FP ON F.GUIDReference = FP.Form_Id
	LEFT JOIN CollectiveMembership CM ON CM.Individual_Id = @CandidateGuid
	LEFT JOIN Panelist P ON FP.Panel_Id = P.Panel_Id AND (P.PanelMember_Id = CM.Individual_Id OR P.PanelMember_Id = CM.Group_Id)
	WHERE F.Country_Id = @pCountryId AND FP.Panel_Id IS NULL OR P.GUIDReference IS NOT NULL

		EXEC GetPanelistUrlInfo @pScopeReferenceId
			,@pCountryId
	END
END