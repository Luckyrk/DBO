
CREATE VIEW [dbo].[IXV_RESPONDENT_IndividualBelonging_ATTRIBUTEVALUES]
	WITH SCHEMABINDING
AS
SELECT ATTRIBUTEVALUE.GUIDREFERENCE
	,ATTRIBUTE.Country_Id
	,ATTRIBUTE.Type
	,DEMOGRAPHICID
	,RESPONDENTID
	,VALUE
	,ATTRIBUTE.Translation_Id AS attribute_translation_id
	,Candidate.GUIDReference AS CANDIDATEID
	,Belonging.BelongingCode
	,Belonging.Type AS BelongingType
	,BelongingType.Translation_Id AS belongingtype_translation_id
	,Belonging.GPSUser AS BelongingGPSUser
	,ATTRIBUTEVALUE.GPSUser
	,ATTRIBUTEVALUE.GPSUpdateTimestamp
	,ATTRIBUTEVALUE.CreationTimeStamp
	,Attribute.[Key]
FROM DBO.ATTRIBUTEVALUE
INNER JOIN DBO.ATTRIBUTE ON ATTRIBUTEVALUE.DemographicId = ATTRIBUTE.GUIDReference
INNER JOIN dbo.Respondent ON AttributeValue.RespondentId = Respondent.GUIDReference
	AND ATTRIBUTEVALUE.CANDIDATEID IS NULL
INNER JOIN dbo.Belonging ON Respondent.GUIDReference = Belonging.GUIDReference
INNER JOIN dbo.BelongingType ON BelongingType.Id = Belonging.TypeId
	AND Belonging.Type = 'IndividualBelonging'
INNER JOIN dbo.Candidate ON dbo.Belonging.CandidateId = dbo.Candidate.GUIDReference
join dbo.StateDefinition on dbo.StateDefinition.Id=dbo.Belonging.State_Id 
GO
CREATE UNIQUE CLUSTERED INDEX [IXV_RIA_GUIDREF_PK]
    ON [dbo].[IXV_RESPONDENT_IndividualBelonging_ATTRIBUTEVALUES]([GUIDREFERENCE] ASC);
GO
CREATE NONCLUSTERED INDEX [IXV_RIA_RESPONDENTID]
    ON [dbo].[IXV_RESPONDENT_IndividualBelonging_ATTRIBUTEVALUES]([RESPONDENTID] ASC);


GO
CREATE NONCLUSTERED INDEX [IXV_RIA_DEMOGRAPHICID]
    ON [dbo].[IXV_RESPONDENT_IndividualBelonging_ATTRIBUTEVALUES]([DEMOGRAPHICID] ASC);


GO
CREATE NONCLUSTERED INDEX [IXV_RIA_COUNTRYID]
    ON [dbo].[IXV_RESPONDENT_IndividualBelonging_ATTRIBUTEVALUES]([Country_Id] ASC);


GO


