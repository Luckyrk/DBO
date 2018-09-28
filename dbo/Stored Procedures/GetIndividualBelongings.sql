CREATE PROCEDURE [dbo].[GetIndividualBelongings](
 @pIndividualId  UNIQUEIDENTIFIER,
 @pCountryISO2A VARCHAR(10),
 @pCultureCode INT)

AS
BEGIN

DECLARE @countryId uniqueidentifier,
		@DefaultGuid UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
SET @countryId = (SELECT CountryId FROM Country WHERE CountryISO2A = @pCountryISO2A)

DECLARE @GroupId UNIQUEIDENTIFIER = (SELECT TOP 1 CM.Group_Id
	FROM Individual I
	JOIN CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
	JOIN StateDefinition SD ON CM.State_Id = SD.Id
	WHERE i.GUIDReference = @pIndividualId
	ORDER BY SD.InactiveBehavior ASC, CM.GPSUpdateTimestamp DESC)

IF OBJECT_ID('tempdb..#BelongingIds') IS NOT NULL DROP TABLE #BelongingIds
SELECT b.GUIDReference as BelongingId,dbo.GetTranslationValue(bt.Translation_Id,2057) as BelongingType,bt.Id as BelongingTypeId,b.BelongingCode
INTO #BelongingIds
FROM BelongingTypeConfiguration BTC
INNER JOIN ConfigurationSet CS ON BTC.ConfigurationSetId = CS.ConfigurationSetId
INNER JOIN BelongingType BT ON BT.Id = BTC.BelongingTypeId
INNER JOIN Belonging B ON B.TypeId = BT.Id
WHERE B.CandidateId IN (
                                @pIndividualId
                                ,@GroupID
                                )
AND cs.Type = 'Individual'
ORDER BY b.BelongingCode

SELECT * FROM #BelongingIds

SELECT b.GUIDReference as BelongingId,T.BelongingType,T.BelongingTypeId,b.BelongingCode
,tt.Value as StateName,sd.Id as StateId, sd.TrafficLightBehavior as DisplayBehavior
FROM #BelongingIds T
JOIN Belonging B ON B.GUIDReference = T.BelongingId
--JOIN SortAttribute SA ON SA.BelongingType_Id = T.BelongingTypeId
JOIN StateDefinition sd on sd.Id=B.State_Id	
JOIN TranslationTerm tt on tt.Translation_Id=sd.Label_Id and tt.CultureCode = @pCultureCode


SELECT DISTINCT b.GUIDReference as BelongingId,T.BelongingType,T.BelongingTypeId,b.BelongingCode
,a.GUIDReference as AttributeId,att.Value as Name,ac.IsRequired as [Required],ac.[Order],
a.ShortCode,ac.UseShortCode
FROM #BelongingIds T
JOIN Belonging B ON B.GUIDReference = T.BelongingId
JOIN SortAttribute SA ON SA.BelongingType_Id = T.BelongingTypeId
JOIN OrderedBelonging OB ON OB.Belonging_Id = T.BelongingId AND OB.BelongingSection_Id = SA.Id
JOIN AttributeConfiguration ac on ac.BelongingTypeId= T.BelongingTypeId
JOIN Attribute a on a.GUIDReference = ac.AttributeId AND a.Active = 1
JOIN TranslationTerm att on att.Translation_Id=a.Translation_Id and att.CultureCode=@pCultureCode
ORDER BY ac.[Order]



IF OBJECT_ID('tempdb..#tmphold') IS NOT NULL DROP TABLE #tmphold
SELECT DISTINCT
	A.[Type] AS [aType],
	A.GUIDReference AS aId,
	A.[Key] AS aNAME,
	@pCountryISO2A AS aCountryCode,
	Case When A.ShortCode is not null Then A.ShortCode Else dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) End as [aKey],
	IIF(AC.UseShortCode=1 AND A.ShortCode IS NOT NULL, A.ShortCode, dbo.GetTranslationValue(A.Translation_Id, @pCultureCode)) AS aShowName,
	AC.[Order] AS [acOrder],
	AC.[IsRequired] AS [acIsRequired],
	A.[GUIDReference] AS [aGUIDReference],
	A.[IsCalculated] AS aIsCalculated,
	A.[IsReadOnly] AS [aIsReadOnly],
	A.[GPSUser] AS [aGPSUser],
	A.[GPSUpdateTimestamp] AS [aGPSUpdateTimestamp],
	A.[CreationTimeStamp] AS [aCreationTimeStamp],
	A.[DateFrom] AS [aDateFrom],
	A.[DateTo] AS [aDateTo],
	A.[Today] AS [aToday],
	A.[From] AS [aFrom],
	A.[To] AS [aTo],
	A.[MinLength] AS [aMinLength],
	A.[MaxLength] AS [aMaxLength],
	A.[Calculation_Id] AS [aCalculation_Id],
	A.[Translation_Id] AS [aTranslation_Id],
	A.[Country_Id] AS [aCountry_Id],
	A.[Scope_Id] AS [aScopeId],
	AtS.[Type] AS [aScopeType],
	A.[Category_Id] AS aCategoryId,
	A.[TypeDescriptor_Id] AS [aTypeDescriptor_Id],
	A.EnumSetId AS aEnumSetId,
	A.ShortCode AS aShortCode
INTO #tmphold
FROM #BelongingIds T
JOIN Belonging B ON B.GUIDReference = T.BelongingId
JOIN AttributeConfiguration ac on ac.BelongingTypeId=T.BelongingTypeId
JOIN Attribute a on a.GUIDReference = ac.AttributeId 
INNER JOIN AttributeScope Ats ON a.[Scope_Id] = Ats.GUIDReference	
JOIN AttributeValue av on av.DemographicId=ac.AttributeId and av.RespondentId=b.GUIDReference
--where i.GUIDReference = @pIndividualId  and ac.Discriminator='BelongingType' AND A.Active = 1 AND Ats.[Type] IN ('IndividualBelongingType','GroupBelongingType')
	
--Boolean Attributes 1
SELECT DISTINCT
	    aType AS [Type],
		AtValue.GUIDReference AS Id,
		aGUIDReference AS GUIDReference,
		AtValue.RespondentId,
		aGUIDReference AS DemographicId,
		aKey AS NAME,
		aShowName AS ShowName,
		'Boolean' AS DemographicType,
		aCountryCode AS CountryCode,
		acOrder AS [AttrOrder],
		aKey AS [Key],
		AtValue.CANDIDATEID,
		--AtValue.RespondentId,
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
			av.DemographicId,
			av.RespondentId
		FROM AttributeValue av
		WHERE
			AV.CandidateId = @pIndividualId OR AV.RespondentId IN (SELECT BelongingId FROM #BelongingIds) AND av.Discriminator='BooleanAttributeValue'
		) AtValue ON AtValue.DemographicId = a.aGUIDReference
	WHERE aType = 'Boolean'


--Integer Attributes 2
SELECT aType AS [Type],
		AtValue.GUIDReference AS Id,
		aGUIDReference AS GUIDReference,
		AtValue.RespondentId,
		aGUIDReference AS DemographicId,
		aKey AS NAME,
		aShowName AS ShowName,
		'Integer' AS DemographicType,
		aCountryCode AS CountryCode,
		acOrder AS [AttrOrder],
		aKey AS [Key],
		AtValue.CANDIDATEID,
		--AtValue.RespondentId,
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
			av.DemographicId,
			av.RespondentId
		FROM AttributeValue  av
		WHERE 
			AV.CandidateId = @pIndividualId OR AV.RespondentId IN (SELECT BelongingId FROM #BelongingIds) AND av.Discriminator='IntAttributeValue'
		) AtValue ON AtValue.DemographicId = a.aGUIDReference
	WHERE aType = 'Int'

	--Float Attributes 3
SELECT aType AS [Type],
		AtValue.GUIDReference AS Id,
		aGUIDReference AS GUIDReference,
		AtValue.RespondentId,
		aGUIDReference AS DemographicId,
		aKey AS NAME,
		aShowName AS ShowName,
		'Float' AS DemographicType,
		aCountryCode AS CountryCode,
		acOrder AS [AttrOrder],
		aKey AS [Key],
		AtValue.CANDIDATEID,
		--AtValue.RespondentId,
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
			av.DemographicId,
			av.RespondentId
		FROM AttributeValue av
		WHERE 
			AV.CandidateId = @pIndividualId OR AV.RespondentId IN (SELECT BelongingId FROM #BelongingIds) AND av.Discriminator='FloatAttributeValue'
		) AtValue ON AtValue.DemographicId = a.aGUIDReference
	WHERE aType = 'float'

	--Date Attributes 4
SELECT aType AS [Type],
		AtValue.GUIDReference AS Id,
		aGUIDReference AS GUIDReference,
		AtValue.RespondentId,
		aGUIDReference AS DemographicId,
		aKey AS NAME,
		aShowName AS ShowName,
		'Date' AS DemographicType,
		aCountryCode AS CountryCode,
		acOrder AS [AttrOrder],
		aKey AS [Key],
		AtValue.CANDIDATEID,
		--AtValue.RespondentId,
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
		(AtValue.Value as datetime) AS DateValue
	FROM #tmphold a
	LEFT JOIN (
		SELECT AV.CandidateId,
			AV.GUIDReference,
			av.Value,
			av.DemographicId,
			av.RespondentId
		FROM AttributeValue av
		WHERE 
			AV.CandidateId = @pIndividualId OR AV.RespondentId IN (SELECT BelongingId FROM #BelongingIds) AND av.Discriminator='DateAttributeValue'
		) AtValue ON AtValue.DemographicId = a.aGUIDReference
	WHERE aType = 'Date'

	--String Attributes 5
SELECT aType AS [Type],
		AtValue.GUIDReference AS Id,
		aGUIDReference AS GUIDReference,
		AtValue.RespondentId,
		aGUIDReference AS DemographicId,
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
			av.DemographicId,
			av.RespondentId
		FROM AttributeValue av
		WHERE
			AV.CandidateId = @pIndividualId OR AV.RespondentId IN (SELECT BelongingId FROM #BelongingIds) AND av.Discriminator='StringAttributeValue'
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
		RespondentId UNIQUEIDENTIFIER,
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
		AtValue.GUIDReference AS Id,
		aGUIDReference AS GUIDReference,
		aKey AS NAME,
		aShowName AS ShowName,
		'Enumeration' AS DemographicType,
		aCountryCode AS CountryCode,
		aEnumSetID,
		aKey AS [Key],
		AtValue.CANDIDATEID,
		AtValue.RespondentId,
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
			av.RespondentId,
			ED.EnumSet_Id,
			av.[FreeText]
		FROM AttributeValue av
		INNER JOIN EnumDefinition ED ON av.EnumDefinition_Id = ED.Id
		WHERE
			AV.CandidateId = @pIndividualId OR AV.RespondentId IN (SELECT BelongingId FROM #BelongingIds) AND av.Discriminator='EnumAttributeValue'
		) AtValue ON AtValue.DemographicId = a.aGUIDReference
	WHERE aType = 'enum'

	SELECT [Type],
		Id,
		Guidreference,
		RespondentId,
		GUIDReference as DemographicId,
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
	INNER JOIN @tmpEnum TEMP ON ed.Demographic_Id = TEMP.GuidReference
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

	DROP TABLE #tmphold
	DROP TABLE #BelongingIds
END
