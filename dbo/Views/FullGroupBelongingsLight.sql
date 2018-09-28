CREATE VIEW FullGroupBelongingsLight
	AS

WITH EngTerms (Translation_Id, Value)  
AS 
(  
    SELECT tt.Translation_Id, CAST(Value AS NVARCHAR(255))
    FROM dbo.TranslationTerm tt
	WHERE CultureCode = 2057
)  
SELECT 
	DISTINCT C.CountryISO2A
	,statedefinition.Code as 'Status'
	,Collective.Sequence GroupId
	,IIF(ira.[Type] = 'Enum', ed.Value, IRA.VALUE) AS Value
	,TRANSTERM.Value AS BelongingName--CAST(TRANSTERM.Value AS NVARCHAR(255)) AS BelongingName
	,ATTRTERM.Value AS AttributeType--CAST(ATTRTERM.Value AS NVARCHAR(255)) AS AttributeType
	,ira.BelongingCode
	--,ira.[Key] as AttributeKey
	--,IIF(ira.[Type] = 'String', ira.value, NULL)	AS StringValue
	--,IIF(ira.[Type] = 'int', ira.value, NULL)		AS IntegerValue
	--,IIF(ira.[Type] = 'Enum', ira.value, NULL)		AS EnumValue
	--,IIF(ira.[Type] = 'Float', ira.value, NULL) AS FloatValue
	--,IIF(ira.[Type] = 'Date', FORMAT(TRY_PARSE(ira.value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss'), NULL) AS DateValue
	--,IIF(ira.[Type] = 'Boolean', ira.value, NULL) AS BooleanValue
	--,av.[FreeText]
	--,eddesc.Value as EnumDesc
	--,ira.GPSUser
	--,ira.GPSUpdateTimestamp
	--,ira.CreationTimeStamp
	--,ira.BelongingType
FROM COUNTRY C
JOIN Collective ON Collective.CountryId=C.CountryId
JOIN IXV_RESPONDENT_ATTRIBUTEVALUES(NOEXPAND) IRA ON IRA.Country_Id = C.CountryId AND IRA.CANDIDATEID = Collective.GUIDReference
JOIN dbo.belonging ON ira.candidateid = belonging.candidateid and Belonging.GUIDReference=ira.RESPONDENTID
JOIN dbo.statedefinition ON belonging.state_id = dbo.statedefinition.id 
JOIN dbo.AttributeValue AV ON IRA.GUIDREFERENCE = AV.GUIDReference
LEFT JOIN dbo.EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
LEFT JOIN EngTerms AS TRANSTERM ON TRANSTERM.Translation_Id=belongingtype_translation_id
LEFT JOIN EngTerms AS ATTRTERM ON ATTRTERM.Translation_Id=IRA.attribute_translation_id
--LEFT JOIN EngTerms AS eddesc ON eddesc.Translation_Id=ed.Translation_Id
