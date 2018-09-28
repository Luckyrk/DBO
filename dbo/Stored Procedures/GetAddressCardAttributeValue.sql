CREATE procedure GetAddressCardAttributeValue @pDemographicId UNIQUEIDENTIFIER,@pOldAttributeValue nvarchar(200),@pNewAttributeValue nvarchar(200)
AS   
BEGIN   
 SET NOCOUNT ON 

  select top 1 TT.Value as oldAttributeValueDesc from EnumDefinition ED
  INNER JOIN Translation T ON T.TranslationId=ED.Translation_Id 
  INNER JOIN TranslationTerm TT ON TT.Translation_Id =T.TranslationId
  where Demographic_Id=@pDemographicId and ED.Value=@pOldAttributeValue

  select top 1 TT.Value as newAttributeValueDesc from EnumDefinition ED
  INNER JOIN Translation T ON T.TranslationId=ED.Translation_Id 
  INNER JOIN TranslationTerm TT ON TT.Translation_Id =T.TranslationId
  where Demographic_Id=@pDemographicId and ED.Value=@pNewAttributeValue
 END


