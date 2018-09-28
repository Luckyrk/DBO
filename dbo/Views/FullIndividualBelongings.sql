
CREATE VIEW [dbo].[FullIndividualBelongings]
AS
SELECT dbo.Country.CountryISO2A
	,dbo.Collective.Sequence GroupId
	,dbo.Individual.IndividualId
	,IRI.BelongingCode
	,IRI.BelongingType AS BelongingType
	,sd.Code as [Status]
	,iri.[Key] as AttributeKey
	,CAST(TRANSTERM.Value AS NVARCHAR(255)) AS BelongingName
	,CAST(ATTRTERM.Value AS NVARCHAR(255)) AS AttributeType
	,(CASE WHEN  IRI.[Type]='String' THEN  CAST (IRI.Value AS NVARCHAR(255)) ELSE NULL END) AS StringValue
	,(CASE WHEN  IRI.[Type]='Int' THEN  CAST (IRI.Value AS NVARCHAR(255)) ELSE NULL END) IntegerValue
	,(CASE WHEN  IRI.[Type]='Enum' THEN  CAST (ED.Value AS NVARCHAR(255)) ELSE NULL END) AS EnumValue
	,(CASE WHEN  IRI.[Type]='Float' THEN  CAST (IRI.Value AS NVARCHAR(255)) ELSE NULL END) AS  FloatValue
	,(CASE WHEN  IRI.[Type]='Date' THEN  CAST (FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss') AS NVARCHAR(255)) ELSE NULL END) AS DateValue
	,(CASE WHEN  IRI.[Type]='Boolean' THEN  CAST (IRI.Value AS NVARCHAR(255)) ELSE NULL END) AS  BooleanValue
	,av.[FreeText]
	,IRI.GPSUser
	,IRI.GPSUpdateTimestamp
	,IRI.CreationTimeStamp

FROM [IXV_RESPONDENT_IndividualBelonging_ATTRIBUTEVALUES](NOEXPAND) IRI
JOIN dbo.AttributeValue AV ON IRI.GUIDREFERENCE = AV.GUIDReference
LEFT JOIN dbo.EnumDefinition ED on ED.Id = AV.EnumDefinition_Id
INNER JOIN dbo.Country ON IRI.Country_Id = dbo.Country.CountryId
LEFT JOIN dbo.Collective ON IRI.CANDIDATEID = dbo.Collective.[GUIDReference]
LEFT JOIN dbo.Individual ON IRI.CANDIDATEID = dbo.Individual.[GUIDReference]
join dbo.Belonging b on iri.RESPONDENTID=b.GUIDReference
join StateDefinition sd on sd.Id=b.State_Id
INNER JOIN dbo.Translation AS TRANSTYPE ON TRANSTYPE.TranslationId = IRI.belongingtype_translation_id
LEFT JOIN (SELECT *
	FROM dbo.TranslationTerm
	WHERE CultureCode = 2057
	) AS TRANSTERM ON TRANSTYPE.TranslationId = TRANSTERM.Translation_Id
INNER JOIN dbo.Translation AS TRANSATTR ON TRANSATTR.TranslationId = IRI.attribute_translation_id
LEFT JOIN (SELECT *
	FROM dbo.TranslationTerm
	WHERE CultureCode = 2057
	) AS ATTRTERM ON TRANSATTR.TranslationId = ATTRTERM.Translation_Id

GO

