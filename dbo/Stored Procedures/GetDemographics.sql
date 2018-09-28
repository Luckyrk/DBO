CREATE PROCEDURE [dbo].[GetDemographics]
	@pScope VARCHAR(50),
	@pScopeReferenceId UNIQUEIDENTIFIER,
	@pCountryId UNIQUEIDENTIFIER,
	@pCultureCode INT
AS
BEGIN

	DECLARE @CandidateGuid UNIQUEIDENTIFIER
	DECLARE @CountryCode NVARCHAR(10)
	DECLARE @CountryGuid UNIQUEIDENTIFIER,
		@DefaultGuid UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
	
	DECLARE @IsAddress BIT = IIF(@pScope = 'PostalAddress', 1, 0);
	
	IF (@pScope = 'INDIVIDUAL' OR @pScope = 'PostalAddress')
	BEGIN
		SET @CandidateGuid = @pScopeReferenceId
	END
	ELSE IF (@pScope = 'GROUP' OR @pScope = 'PANEL')
	BEGIN
		SET @candidateGuid = (
				SELECT TOP 1 Group_Id
				FROM CollectiveMembership
				WHERE Individual_Id = @pScopeReferenceId
				ORDER BY CreationTimeStamp DESC
				)
	END

	SET @CountryCode = (
			SELECT CountryISO2A
			FROM Country
			WHERE CountryId = @pCountryId
			)
	SET @CountryGuid = @pCountryId;

	CREATE TABLE #tmphold (
		aType NVARCHAR(400),
		aId UNIQUEIDENTIFIER,
		aName NVARCHAR(400),
		aCountryCode NVARCHAR(4),
		aKey NVARCHAR(400),
		aShowName NVARCHAR(400),
		acOrder INT,
		acIsRequired BIT,
		aGUIDReference UNIQUEIDENTIFIER,
		aIsCalculated BIT,
		aIsReadOnly BIT,
		aGPSUser NVARCHAR(100),
		aGPSUpdateTimestamp DATETIME,
		aCreationTimeStamp DATETIME,
		aDateFrom DATETIME,
		aDateTo DATETIME,
		aToday BIT,
		aFrom DECIMAL(18, 2),
		aTo DECIMAL(18, 2),
		aMinLength INT,
		aMaxLength INT,
		aCalculation_Id UNIQUEIDENTIFIER,
		aTranslation_Id UNIQUEIDENTIFIER,
		aCountry_Id UNIQUEIDENTIFIER,
		aScopeId UNIQUEIDENTIFIER,
		aScopeType NVARCHAR(100),
		aCategoryId UNIQUEIDENTIFIER,
		aTypeDescriptor_Id UNIQUEIDENTIFIER,
		aEnumSetID UNIQUEIDENTIFIER,
		aShortCode NVARCHAR(6),
		aTimeDisplay BIT
		)

	INSERT INTO #tmphold
	SELECT A.[Type] AS [Type],
		A.GUIDReference AS Id,
		A.[Key] AS NAME,
		@CountryCode AS CountryCode,
		Case When A.ShortCode is not null Then A.ShortCode Else dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) End as [Key],
		IIF(AC.UseShortCode=1 AND A.ShortCode IS NOT NULL, A.ShortCode, dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)) AS ShowName,
		AC.[Order] AS [AttrOrder],
		AC.[IsRequired] AS [IsRequired],
		A.[GUIDReference] AS [GUIDReference],
		A.[IsCalculated] AS [IsCalculated],
		A.[IsReadOnly] AS [IsReadOnly],
		A.[GPSUser] AS [GPSUser],
		A.[GPSUpdateTimestamp] AS [GPSUpdateTimestamp],
		A.[CreationTimeStamp] AS [CreationTimeStamp],
		A.[DateFrom] AS [DateFrom],
		A.[DateTo] AS [DateTo],
		A.[Today] AS [Today],
		A.[From] AS [From],
		A.[To] AS [To],
		A.[MinLength] AS [MinLength],
		A.[MaxLength] AS [MaxLength],
		A.[Calculation_Id] AS BusinessRuleId,
		A.[Translation_Id] AS [Translation_Id],
		A.[Country_Id] AS [Country_Id],
		A.[Scope_Id] AS [ScopeId],
		AtS.[Type] AS [ScopeType],
		A.[Category_Id] AS CategoryId,
		A.[TypeDescriptor_Id] AS [TypeDescriptor_Id],
		A.EnumSetId,
		A.ShortCode,
		A.TimeDisplay
	FROM Attribute A
	INNER JOIN AttributeConfiguration ac ON a.GUIDReference = ac.AttributeId
	INNER JOIN ConfigurationSet cs ON cs.ConfigurationSetId = ac.ConfigurationSetId
	INNER JOIN AttributeScope Ats ON a.[Scope_Id] = Ats.GUIDReference	
	WHERE cs.[Type] = @pScope AND A.Country_Id = @pCountryId and ac.Discriminator='ConfigurationSet'
	AND A.Active =1

		--Boolean Attributes 1
	SELECT
	    aType AS [Type],
		aGUIDReference AS Id,
		AtValue.GUIDReference,
		aKey AS NAME,
		aShowName AS ShowName,
		'Boolean' AS DemographicType,
		aCountryCode AS CountryCode,
		acOrder AS [AttrOrder],
		aKey AS [Key],
		AtValue.CANDIDATEID,
		acIsRequired AS [IsRequired],
		aGUIDReference AS [GUIDReference],
		aIsCalculated AS [IsCalculated],
		aIsReadOnly AS [IsReadOnly],
		aGPSUser AS [GPSUser],
		aGPSUpdateTimestamp AS [GPSUpdateTimestamp],
		aCreationTimeStamp AS [CreationTimeStamp],
		aDateFrom AS [DateFrom],
		aDateTo AS [DateTo],
		aToday AS [Today],
		aFrom AS [From],
		aTo AS [To],
		aMinLength AS [MinLength],
		aMaxLength AS [MaxLength],
		aCalculation_Id AS BusinessRuleId,
		aTranslation_Id AS [Translation_Id],
		aCountry_Id AS [Country_Id],
		aScopeId AS [ScopeId],
		aScopeType AS [ScopeType],
		aCategoryId AS CategoryId,
		aTypeDescriptor_Id AS [TypeDescriptor_Id],	
			CAST(CASE WHEN AtValue.Value='1' THEN 1 
		WHEN AtValue.Value='0' then 0 END AS BIT) AS BoolValue	
	FROM #tmphold a
	LEFT JOIN (
		SELECT AV.CandidateId,
			AV.GUIDReference,
			av.Value,
			av.DemographicId
		FROM AttributeValue av
		WHERE
			(@IsAddress = 0 AND AV.CandidateId = @CandidateGuid) OR
			(@IsAddress = 1 AND AV.Address_Id = @CandidateGuid)
			AND av.Discriminator='BooleanAttributeValue'
		) AtValue ON AtValue.DemographicId = a.aGUIDReference
	WHERE aType = 'Boolean'

	--Integer Attributes 2
	SELECT aType AS [Type],
		aGUIDReference AS Id,
		AtValue.GUIDReference,
		aKey AS NAME,
		aShowName AS ShowName,
		'Integer' AS DemographicType,
		aCountryCode AS CountryCode,
		acOrder AS [AttrOrder],
		aKey AS [Key],
		AtValue.CANDIDATEID,
		acIsRequired AS [IsRequired],
		aGUIDReference AS [GUIDReference],
		aIsCalculated AS [IsCalculated],
		aIsReadOnly AS [IsReadOnly],
		aGPSUser AS [GPSUser],
		aGPSUpdateTimestamp AS [GPSUpdateTimestamp],
		aCreationTimeStamp AS [CreationTimeStamp],
		aDateFrom AS [DateFrom],
		aDateTo AS [DateTo],
		aToday AS [Today],
		aFrom AS [From],
		aTo AS [To],
		aMinLength AS [MinLength],
		aMaxLength AS [MaxLength],
		aCalculation_Id AS BusinessRuleId,
		aTranslation_Id AS [Translation_Id],
		aCountry_Id AS [Country_Id],
		aScopeId AS [ScopeId],
		aScopeType AS [ScopeType],
		aCategoryId AS CategoryId,
		aTypeDescriptor_Id AS [TypeDescriptor_Id],
		CAST(AtValue.Value AS INT) AS IntValue
	FROM #tmphold a
	LEFT JOIN (
		SELECT AV.CandidateId,
			AV.GUIDReference ,
			av.Value,
			av.DemographicId
		FROM AttributeValue  av
		WHERE 
			(@IsAddress = 0 AND AV.CandidateId = @CandidateGuid) OR
			(@IsAddress = 1 AND AV.Address_Id = @CandidateGuid)
			AND av.Discriminator='IntAttributeValue'
		) AtValue ON AtValue.DemographicId = a.aGUIDReference
	WHERE aType = 'Int'

	--Float Attributes 3
	SELECT aType AS [Type],
		aGUIDReference AS Id,
		AtValue.GUIDReference,
		aKey AS NAME,
		aShowName AS ShowName,
		'Float' AS DemographicType,
		aCountryCode AS CountryCode,
		acOrder AS [AttrOrder],
		aKey AS [Key],
		AtValue.CANDIDATEID,
		acIsRequired AS [IsRequired],
		aGUIDReference AS [GUIDReference],
		aIsCalculated AS [IsCalculated],
		aIsReadOnly AS [IsReadOnly],
		aGPSUser AS [GPSUser],
		aGPSUpdateTimestamp AS [GPSUpdateTimestamp],
		aCreationTimeStamp AS [CreationTimeStamp],
		aDateFrom AS [DateFrom],
		aDateTo AS [DateTo],
		aToday AS [Today],
		aFrom AS [From],
		aTo AS [To],
		aMinLength AS [MinLength],
		aMaxLength AS [MaxLength],
		aCalculation_Id AS BusinessRuleId,
		aTranslation_Id AS [Translation_Id],
		aCountry_Id AS [Country_Id],
		aScopeId AS [ScopeId],
		aScopeType AS [ScopeType],
		aCategoryId AS CategoryId,
		aTypeDescriptor_Id AS [TypeDescriptor_Id],
		CAST(REPLACE(Value, ',', '.') AS DECIMAL(18,2)) AS FloatValue
	FROM #tmphold a
	LEFT JOIN (
		SELECT AV.CandidateId,
			AV.GUIDReference,
			av.Value,
			av.DemographicId
		FROM AttributeValue av
		WHERE 
			(@IsAddress = 0 AND AV.CandidateId = @CandidateGuid) OR
			(@IsAddress = 1 AND AV.Address_Id = @CandidateGuid)
			AND av.Discriminator='FloatAttributeValue'
		) AtValue ON AtValue.DemographicId = a.aGUIDReference
	WHERE aType = 'float'

	--Date Attributes 4
	SELECT aType AS [Type],
		aGUIDReference AS Id,
		AtValue.GUIDReference,
		aKey AS NAME,
		aShowName AS ShowName,
		'Date' AS DemographicType,
		aCountryCode AS CountryCode,
		acOrder AS [AttrOrder],
		aKey AS [Key],
		AtValue.CANDIDATEID,
		acIsRequired AS [IsRequired],
		aGUIDReference AS [GUIDReference],
		aIsCalculated AS [IsCalculated],
		aIsReadOnly AS [IsReadOnly],
		aGPSUser AS [GPSUser],
		aGPSUpdateTimestamp AS [GPSUpdateTimestamp],
		aCreationTimeStamp AS [CreationTimeStamp],
		aDateFrom AS [DateFrom],
		aDateTo AS [DateTo],
		aToday AS [Today],
		aFrom AS [From],
		aTo AS [To],
		aMinLength AS [MinLength],
		aMaxLength AS [MaxLength],
		aCalculation_Id AS BusinessRuleId,
		aTranslation_Id AS [Translation_Id],
		aCountry_Id AS [Country_Id],
		aScopeId AS [ScopeId],
		aScopeType AS [ScopeType],
		aCategoryId AS CategoryId,
		aTypeDescriptor_Id AS [TypeDescriptor_Id],
		cast
		(AtValue.Value as datetime) AS DateValue,
		aTimeDisplay as TimeDisplay
	FROM #tmphold a
	LEFT JOIN (
		SELECT AV.CandidateId,
			AV.GUIDReference,
			av.Value,
			av.DemographicId
		FROM AttributeValue av
		WHERE 
			(@IsAddress = 0 AND AV.CandidateId = @CandidateGuid) OR
			(@IsAddress = 1 AND AV.Address_Id = @CandidateGuid)
			AND av.Discriminator='DateAttributeValue'
		) AtValue ON AtValue.DemographicId = a.aGUIDReference
	WHERE aType = 'Date'

	--String Attributes 5
	SELECT aType AS [Type],
		aGUIDReference AS Id,
		AtValue.GUIDReference,
		aKey AS NAME,
		aShowName AS ShowName,
		'String' AS DemographicType,
		aCountryCode AS CountryCode,
		acOrder AS [AttrOrder],
		aKey AS [Key],
		AtValue.CANDIDATEID,
		acIsRequired AS [IsRequired],
		aGUIDReference AS [GUIDReference],
		aIsCalculated AS [IsCalculated],
		aIsReadOnly AS [IsReadOnly],
		aGPSUser AS [GPSUser],
		aGPSUpdateTimestamp AS [GPSUpdateTimestamp],
		aCreationTimeStamp AS [CreationTimeStamp],
		aDateFrom AS [DateFrom],
		aDateTo AS [DateTo],
		aToday AS [Today],
		aFrom AS [From],
		aTo AS [To],
		aMinLength AS [MinLength],
		aMaxLength AS [MaxLength],
		aCalculation_Id AS BusinessRuleId,
		aTranslation_Id AS [Translation_Id],
		aCountry_Id AS [Country_Id],
		aScopeId AS [ScopeId],
		aScopeType AS [ScopeType],
		aCategoryId AS CategoryId,
		aTypeDescriptor_Id AS [TypeDescriptor_Id],
		AtValue.Value AS StringValue
	FROM #tmphold a
	LEFT JOIN (
		SELECT AV.CandidateId,
			AV.GUIDReference,
			av.value,
			av.DemographicId
		FROM AttributeValue av
		WHERE
			(@IsAddress = 0 AND AV.CandidateId = @CandidateGuid) OR
			(@IsAddress = 1 AND AV.Address_Id = @CandidateGuid)
			AND av.Discriminator='StringAttributeValue'
		) AtValue ON AtValue.DemographicId = a.aGUIDReference
	WHERE aType = 'string'

	--Enum Attributes 6
	DECLARE @tmpEnum TABLE (
		[Type] NVARCHAR(256),
		Id UNIQUEIDENTIFIER,
		Guidreference UNIQUEIDENTIFIER,
		NAME NVARCHAR(400),
		ShowName NVARCHAR(400),
		DemographicType NVARCHAR(400),
		CountryCode NVARCHAR(10),
		EnumSetId UNIQUEIDENTIFIER,
		[Key] NVARCHAR(400),
		CANDIDATEID UNIQUEIDENTIFIER,
		[Order] NVARCHAR(400),
		[IsRequired] BIT,
		[AGUIDReference] UNIQUEIDENTIFIER,
		[IsCalculated] BIT,
		[IsReadOnly] BIT,
		[GPSUser] NVARCHAR(100),
		[GPSUpdateTimestamp] DATETIME,
		[CreationTimeStamp] DATETIME,
		[DateFrom] DATETIME,
		[DateTo] DATETIME,
		[Today] DATETIME,
		[From] DECIMAL,
		[To] DECIMAL,
		[MinLength] INT,
		[MaxLength] INT,
		BusinessRuleId UNIQUEIDENTIFIER,
		[Translation_Id] UNIQUEIDENTIFIER,
		[Country_Id] UNIQUEIDENTIFIER,
		[ScopeId] UNIQUEIDENTIFIER,
		[ScopeType] NVARCHAR(100),
		CategoryId UNIQUEIDENTIFIER,
		[TypeDescriptor_Id] UNIQUEIDENTIFIER,
		value NVARCHAR(400),
		[FreeText] NVARCHAR(300)
		)

	INSERT INTO @tmpEnum
	SELECT aType AS [Type],
		aGUIDReference A,
		AtValue.GUIDReference,
		aKey AS NAME,
		aShowName AS ShowName,
		'Enumeration' AS DemographicType,
		aCountryCode AS CountryCode,
		aEnumSetID,
		aKey AS [Key],
		AtValue.CANDIDATEID,
		acOrder AS [AttrOrder],
		acIsRequired AS [IsRequired],
		aGUIDReference AS [GUIDReference],
		aIsCalculated AS [IsCalculated],
		aIsReadOnly AS [IsReadOnly],
		aGPSUser AS [GPSUser],
		aGPSUpdateTimestamp AS [GPSUpdateTimestamp],
		aCreationTimeStamp AS [CreationTimeStamp],
		aDateFrom AS [DateFrom],
		aDateTo AS [DateTo],
		aToday AS [Today],
		aFrom AS [From],
		aTo AS [To],
		aMinLength AS [MinLength],
		aMaxLength AS [MaxLength],
		aCalculation_Id AS BusinessRuleId,
		aTranslation_Id AS [Translation_Id],
		aCountry_Id AS [Country_Id],
		aScopeId AS [ScopeId],
		aScopeType AS [ScopeType],
		aCategoryId AS CategoryId,
		aTypeDescriptor_Id AS [TypeDescriptor_Id],
		AtValue.Value AS value,
		AtValue.[FreeText]
	FROM #tmphold a
	LEFT JOIN (
		SELECT AV.CandidateId,
			AV.GUIDReference,
			ED.Value,
			av.DemographicId,
			ED.EnumSet_Id,
			av.[FreeText]
		FROM AttributeValue av
		INNER JOIN EnumDefinition ED ON av.EnumDefinition_Id = ED.Id
		WHERE
			(@IsAddress = 0 AND AV.CandidateId = @CandidateGuid) OR
			(@IsAddress = 1 AND AV.Address_Id = @CandidateGuid)
			AND av.Discriminator='EnumAttributeValue'
		) AtValue ON AtValue.DemographicId = a.aGUIDReference
	WHERE aType = 'enum'

	SELECT [Type],
		Id,
		Guidreference,
		NAME,
		ShowName,
		DemographicType,
		CountryCode,
		[Order] as AttrOrder,
		[Key],
		CANDIDATEID,
		[IsRequired],
		[AGUIDReference] AS Guidreference,
		[IsCalculated],
		[IsReadOnly],
		[GPSUser],
		[GPSUpdateTimestamp],
		[CreationTimeStamp],
		[DateFrom],
		[DateTo],
		[Today],
		[From],
		[To],
		[MinLength],
		[MaxLength],
		BusinessRuleId,
		[Translation_Id],
		[Country_Id],
		[ScopeId],
		[ScopeType],
		CategoryId,
		[TypeDescriptor_Id],
		value as StringValue,
		[FreeText]
	FROM @tmpEnum

	-- Enum Definitions ----7
	SELECT ED.Id,
		ISNULL(ED.EnumValueSet_Id, @DefaultGuid) AS EnumValueSetId,
		dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS NAME,
		ed.Value,
		ed.IsActive,
		ed.IsSelected,
		ed.IsFreeTextRequired,
		ed.Demographic_Id AS DemographicId
	FROM EnumDefinition ED
	INNER JOIN @tmpEnum TEMP ON ed.Demographic_Id = TEMP.Id
	WHERE ED.IsActive = 1
	
	UNION
	
	SELECT ED.Id,
		ISNULL(ED.EnumValueSet_Id, @DefaultGuid) AS EnumValueSetId,
		dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS NAME,
		ed.Value,
		ed.IsActive,
		ed.IsSelected,
		ed.IsFreeTextRequired,
		TEMP.Id AS DemographicId
	FROM EnumDefinition ED
	INNER JOIN @tmpEnum TEMP ON ed.EnumSet_Id = TEMP.EnumSetId
	WHERE ED.IsActive = 1
	ORDER BY DemographicId,ed.Value

	---- ---Forms  8
	SELECT DISTINCT Form.GUIDReference AS Id,
		(dbo.GetTranslationValue(Translation_Id, @pCultureCode)) AS NAME,
		Form.GPSUpdateTimestamp AS CreationTimeStamp
	FROM Form
	LEFT JOIN FormPanel fp ON Form.GUIDReference = fp.Form_Id
	WHERE Form.Country_Id = @pCountryId

 DROP TABLE #tmphold
END
