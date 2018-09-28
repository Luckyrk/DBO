--exec GetDemographicAttributeValue '630a9db1-78e3-cbf2-d5b6-08d11b00476f','44d130c5-d07a-4368-9552-009875ff45a7',3

--EXEC GetDemographicAttributeValue '8C009AA7-FD3D-C79A-6D36-08D11B00469E','44D130C5-D07A-4368-9552-009875FF45A7','1'

CREATE procedure GetDemographicAttributeValue @pCandidateId UNIQUEIDENTIFIER, @pDemographicId UNIQUEIDENTIFIER,@pAttributeValue nvarchar(200)

AS      

BEGIN      

 SET NOCOUNT ON  

select distinct AV.Value AS OldDemographicValue, AV.ValueDesc AS OldDemographicValueDesc, A.[Key] AS CouncilTaxCode from AttributeValue AV 

INNER JOIN Attribute A ON A.GUIDReference=AV.DemographicId

--INNER JOIN Translation T ON T.KeyName=AV.ValueDesc

INNER JOIN TranslationTerm TT ON TT.Value =AV.ValueDesc

 where AV.CandidateId=@pCandidateId AND A.GUIDReference=@pDemographicId AND AV.ValueDesc IS NOT NULL


 select top 1 TT.Value as NewDemographicValue from EnumDefinition ED

  INNER JOIN Translation T ON T.TranslationId=ED.Translation_Id 

  INNER JOIN TranslationTerm TT ON TT.Translation_Id =T.TranslationId

  where Demographic_Id=@pDemographicId and ED.Value=@pAttributeValue

 END
