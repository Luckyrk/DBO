CREATE VIEW [dbo].[IXV_RESPONDENT_ATTRIBUTEVALUES]
	WITH SCHEMABINDING
AS
SELECT 
	ATTRIBUTEVALUE.GUIDREFERENCE
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
	,ATTRIBUTEVALUE.GPSUser
	,ATTRIBUTEVALUE.GPSUpdateTimestamp
	,ATTRIBUTEVALUE.CreationTimeStamp
	,Attribute.[Key]
FROM dbo.Candidate
JOIN dbo.Belonging ON dbo.Belonging.CandidateId = dbo.Candidate.GUIDReference AND dbo.Belonging.[Type] = 'GroupBelonging'
JOIN dbo.BelongingType ON dbo.BelongingType.Id = dbo.Belonging.TypeId
JOIN dbo.Respondent ON dbo.Respondent.GUIDReference = dbo.Belonging.GUIDReference
JOIN dbo.AttributeValue ON dbo.AttributeValue.RespondentId = dbo.Respondent.GUIDReference AND dbo.AttributeValue.CandidateId IS NULL
JOIN dbo.Attribute ON dbo.AttributeValue.DemographicId = dbo.Attribute.GUIDReference

GO
CREATE UNIQUE CLUSTERED INDEX [IXV_RA_GUIDREF_PK]
    ON [dbo].[IXV_RESPONDENT_ATTRIBUTEVALUES]([GUIDREFERENCE] ASC);
Go
CREATE NONCLUSTERED INDEX [IXV_RA_RESPONDENTID]
    ON [dbo].[IXV_RESPONDENT_ATTRIBUTEVALUES]([RESPONDENTID] ASC);


GO
CREATE NONCLUSTERED INDEX [IXV_RA_DEMOGRAPHICID]
    ON [dbo].[IXV_RESPONDENT_ATTRIBUTEVALUES]([DEMOGRAPHICID] ASC);


GO
CREATE NONCLUSTERED INDEX [IXV_RA_COUNTRYID]
    ON [dbo].[IXV_RESPONDENT_ATTRIBUTEVALUES]([Country_Id] ASC);


GO


