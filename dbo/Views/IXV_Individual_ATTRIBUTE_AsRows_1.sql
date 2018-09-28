
CREATE VIEW [dbo].[IXV_Individual_ATTRIBUTE_AsRows]
	WITH SCHEMABINDING
AS
SELECT dbo.Country.CountryISO2A
	,Attribute.Country_Id
	,dbo.Individual.IndividualId
	,dbo.Attribute.[Key]
	,dbo.AttributeValue.GUIDReference
	,dbo.AttributeValue.GPSUser
	,dbo.AttributeValue.CreationTimeStamp
	,dbo.AttributeValue.GPSUpdateTimestamp
	,dbo.AttributeValue.Value
	,dbo.AttributeValue.ValueDesc
	,AttributeValue.DemographicId
	,dbo.Candidate.GUIDReference AS CandidateId
	,dbo.Attribute.Translation_Id
	,dbo.Attribute.[Type]
	,dbo.AttributeValue.EnumDefinition_Id
FROM dbo.Individual
INNER JOIN dbo.Candidate ON dbo.Individual.GUIDReference = dbo.Candidate.GUIDReference
INNER JOIN dbo.AttributeValue ON dbo.Candidate.GUIDReference = dbo.AttributeValue.CandidateId
	AND dbo.AttributeValue.RespondentId IS NULL
INNER JOIN dbo.Attribute ON dbo.AttributeValue.DemographicId = dbo.Attribute.GUIDReference
INNER JOIN dbo.Country ON dbo.Attribute.Country_Id = dbo.Country.CountryId

GO
CREATE UNIQUE CLUSTERED INDEX [IXV_RIAR_GUIDREF_PK]
    ON [dbo].[IXV_Individual_ATTRIBUTE_AsRows]([GUIDReference] ASC);

GO

CREATE NONCLUSTERED INDEX [IXV_RIAR_COUNTRYISO]
    ON [dbo].[IXV_Individual_ATTRIBUTE_AsRows]([CountryISO2A] ASC)
    INCLUDE([Key], [IndividualId], [GPSUser], [CreationTimeStamp], [GPSUpdateTimestamp], [Translation_Id], [Value], [ValueDesc], [Type]);


GO
CREATE NONCLUSTERED INDEX [IXV_RIAR_Translation_Id]
    ON [dbo].[IXV_Individual_ATTRIBUTE_AsRows]([Translation_Id] ASC);


GO
CREATE NONCLUSTERED INDEX [IXV_RIAR_DEMOGRAPHICID]
    ON [dbo].[IXV_Individual_ATTRIBUTE_AsRows]([DemographicId] ASC);


GO
CREATE NONCLUSTERED INDEX [IXV_RIAR_COUNTRYID]
    ON [dbo].[IXV_Individual_ATTRIBUTE_AsRows]([Country_Id] ASC);


