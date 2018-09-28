
CREATE VIEW [dbo].[IX_FullGroupAttributeAsRows]
	WITH SCHEMABINDING
AS
SELECT ATTRIBUTEVALUE.GUIDREFERENCE
	,Country.CountryISO2A
	,ATTRIBUTE.[Key]
	,ATTRIBUTE.[Type]
	,DEMOGRAPHICID
	,RESPONDENTID
	,VALUE
	,VALUEDESC
	,ATTRIBUTE.Translation_Id AS attribute_translation_id
	,Candidate.GUIDReference AS CANDIDATEID
	,ATTRIBUTEVALUE.GPSUser
	,ATTRIBUTEVALUE.GPSUpdateTimestamp
	,ATTRIBUTEVALUE.CreationTimeStamp
	,Collective.Sequence
	,dbo.AttributeValue.EnumDefinition_Id
FROM DBO.ATTRIBUTEVALUE
INNER JOIN DBO.ATTRIBUTE ON ATTRIBUTEVALUE.DemographicId = ATTRIBUTE.GUIDReference
	AND respondentid IS NULL
INNER JOIN dbo.AttributeScope ON Attribute.Scope_Id = AttributeScope.GUIDReference
INNER JOIN dbo.Collective ON AttributeValue.CandidateId = Collective.GUIDReference
INNER JOIN dbo.Candidate ON dbo.Collective.GUIDReference = dbo.Candidate.GUIDReference
INNER JOIN dbo.Country ON Country.CountryId = Attribute.Country_Id
GO
CREATE UNIQUE CLUSTERED INDEX [IX_FullGroupAttributeAsRows_PK]
    ON [dbo].[IX_FullGroupAttributeAsRows]([GUIDREFERENCE] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_FullGroupAttributeAsRows_Cntry_Key]
    ON [dbo].[IX_FullGroupAttributeAsRows]([CountryISO2A] ASC, [Key] ASC, [Type] ASC);
GO
CREATE NONCLUSTERED INDEX [<IDX_CountryISO2A_Type_Sequence, sysname,>]
ON [dbo].[IX_FullGroupAttributeAsRows] ([CountryISO2A],[Type],[Sequence])
INCLUDE ([Key],[attribute_translation_id],[EnumDefinition_Id])
GO




