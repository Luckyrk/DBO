CREATE PROCEDURE [dbo].[GetCreateBelonging] @pindividualId UNIQUEIDENTIFIER
       ,@pbelongingTypeId UNIQUEIDENTIFIER, @pCultureCode INT = 2057
AS
BEGIN
BEGIN TRY 
       DECLARE @pCultureName VARCHAR(100) = 'en-GB'
       DECLARE @DefaultGuid UNIQUEIDENTIFIER = '00000000-0000-0000-0000-000000000000'
       --SELECT * FROM BelongingType
       DECLARE @Group_Id UNIQUEIDENTIFIER

       SELECT @Group_Id = Group_Id
       FROM CollectiveMemberShip
       WHERE Individual_Id = @pindividualId

       CREATE TABLE #TEMP (
              AttributeConfigurationId UNIQUEIDENTIFIER
              ,AttributeId UNIQUEIDENTIFIER
  ,AttrOrder INT
              )

       INSERT INTO #TEMP
       SELECT AC.AttributeConfigurationId
  ,AC.AttributeId ,AC.[Order]
       FROM AttributeConfiguration AC
       INNER JOIN Attribute A ON A.GuidReference = AC.AttributeId
       WHERE BelongingTypeId = @pbelongingTypeId
	   		AND A.Active = 1

       --EnumAttributeDto 
       SELECT DISTINCT A.GuidReference AS Id
              ,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS NAME
   ,T.AttrOrder
              ,[Key] AS Code --,
              ,IsCalculated
              ,Calculation_Id AS BusinessRuleId
              ,Category_Id AS CategoryId
              ,'' AS ScopeType
              ,0 AS ShowScopeInfo
              ,0 AS DemographicType
              ,IsReadOnly
              ,A.Translation_Id AS TranslationId
              ,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
              ,@pCultureCode AS CultureCode
              ,@pCultureName AS CultureName
              ,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       WHERE A.[Type] = 'Enum'

       --INNER JOIN EnumDefinition ED ON ED.Demographic_Id = A.GUIDReference
       --WHERE ED.IsActive = 1
       --StringAttribute
       SELECT DISTINCT A.GuidReference AS Id
              ,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS NAME
  ,T.AttrOrder
              ,[Key] AS Code --,
              ,MinLength
              ,MaxLength
              ,IsCalculated
              ,Calculation_Id AS BusinessRuleId
              ,Category_Id AS CategoryId
              ,'' AS ScopeType
              ,0 AS ShowScopeInfo
              ,3 AS DemographicType
              ,IsReadOnly
              ,A.Translation_Id AS TranslationId
              ,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
              ,@pCultureCode AS CultureCode
              ,@pCultureName AS CultureName
              ,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       WHERE A.[Type] = 'String'

       --BoolAttribute
       SELECT DISTINCT A.GuidReference AS Id
              ,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS NAME
  ,T.AttrOrder
              ,[Key] AS Code --,
              ,IsCalculated
              ,Calculation_Id AS BusinessRuleId
              ,Category_Id AS CategoryId
              ,'' AS ScopeType
              ,0 AS ShowScopeInfo
              ,4 AS DemographicType
              ,IsReadOnly
              ,A.Translation_Id AS TranslationId
              ,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
              ,@pCultureCode AS CultureCode
              ,@pCultureName AS CultureName
              ,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       WHERE A.[Type] = 'Boolean'

       --DateAttribute
       SELECT DISTINCT A.GuidReference AS Id
              ,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS NAME
  ,T.AttrOrder
              ,[Key] AS Code --,
              ,DateFrom
              ,DateTo
              ,Today
              ,IsCalculated
              ,Calculation_Id AS BusinessRuleId
              ,Category_Id AS CategoryId
              ,'' AS ScopeType
              ,0 AS ShowScopeInfo
              ,3 AS DemographicType
              ,IsReadOnly
              ,A.Translation_Id AS TranslationId
              ,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
              ,@pCultureCode AS CultureCode
              ,@pCultureName AS CultureName
              ,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       WHERE A.[Type] = 'Date'

       --FloatAttribute
       SELECT DISTINCT A.GuidReference AS Id
              ,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS NAME
  ,T.AttrOrder
              ,[Key] AS Code --,
              ,[From]
              ,[To]
              ,IsCalculated
              ,Calculation_Id AS BusinessRuleId
              ,Category_Id AS CategoryId
              ,'' AS ScopeType
              ,0 AS ShowScopeInfo
              ,3 AS DemographicType
              ,IsReadOnly
              ,A.Translation_Id AS TranslationId
              ,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
              ,@pCultureCode AS CultureCode
              ,@pCultureName AS CultureName
              ,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       WHERE A.[Type] = 'Float'

       --IntAttribute
       SELECT DISTINCT A.GuidReference AS Id
              ,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS NAME
  ,T.AttrOrder
              ,[Key] AS Code --,
              ,[From]
              ,[To]
              ,IsCalculated
              ,Calculation_Id AS BusinessRuleId
              ,Category_Id AS CategoryId
              ,'' AS ScopeType
              ,0 AS ShowScopeInfo
              ,3 AS DemographicType
              ,IsReadOnly
              ,A.Translation_Id AS TranslationId
              ,dbo.GetTranslationValue(A.Translation_Id, NULL) AS [Key]
              ,@pCultureCode AS CultureCode
              ,@pCultureName AS CultureName
              ,dbo.GetTranslationValue(A.Translation_Id, @pCultureCode) AS Label
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       WHERE A.[Type] = 'Int'

         --Actual DefinitionDtos
       SELECT DISTINCT --SA.Id AS SortAttributeId
              A.GUIDReference AS AttributeId
              ,ED.Id
              ,ISNULL(ED.EnumSet_Id, @DefaultGuid) AS EnumValueSetId
              ,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS NAME
              ,ED.Value
              ,ED.IsActive
              ,IsSelected
              ,IsFreeTextRequired
              ,ED.Translation_Id AS TranslationId
              ,dbo.GetTranslationValue(ED.Translation_Id, NULL) AS [Key]
              ,@pCultureCode AS CultureCode
              ,@pCultureName AS CultureName
              ,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Label
       FROM #TEMP T
		INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
	   INNER JOIN EnumSet ES ON ES.Id = A.EnumSetId
       INNER JOIN EnumDefinition ED ON ED.EnumSet_Id = ES.Id
       WHERE ED.IsActive = 1
              AND A.EnumSetId IS NOT NULL       
	
       UNION
       
       SELECT DISTINCT --SA.Id AS SortAttId
              A.GUIDReference AS AttributeId
              ,ED.Id
              ,ISNULL(ED.EnumSet_Id, @DefaultGuid) AS EnumValueSetId
              ,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS NAME
              ,ED.Value
              ,ED.IsActive
              ,IsSelected
              ,IsFreeTextRequired
              ,ED.Translation_Id AS TranslationId
              ,dbo.GetTranslationValue(ED.Translation_Id, NULL) AS [Key]
              ,@pCultureCode AS CultureCode
              ,@pCultureName AS CultureName
              ,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Label
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       INNER JOIN EnumDefinition ED ON ED.Demographic_Id = A.GUIDReference
       WHERE ED.IsActive = 1
              AND A.EnumSetId IS NULL

       --EnumsetDTO
       SELECT DISTINCT --SA.Id AS SortAttId,
              ES.ID AS Id
              ,A.GUIDReference AS AttributeId
              ,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS NAME
              ,ED.Translation_Id
              ,dbo.GetTranslationValue(ED.Translation_Id, NULL) AS [Key]
              ,@pCultureCode AS CultureCode
              ,@pCultureName AS CultureName
              ,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Label
      
	   FROM #TEMP T
		INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
	   INNER JOIN EnumSet ES ON ES.Id = A.EnumSetId
       INNER JOIN EnumDefinition ED ON ED.EnumSet_Id = ES.Id
       WHERE ED.IsActive = 1
              --AND A.GUIDReference='115033F9-35B6-4184-BD06-1CA3E0214487'
              --AND F.GUIDReference=@pFormId
              AND A.EnumSetId IS NOT NULL

       --EnumsetDTO.Definitions
       SELECT DISTINCT --SA.Id AS SortAttId,
              ES.ID AS EnumSetId
              ,ED.Id
              ,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS NAME
              ,ED.Value
              ,ED.IsActive
              ,ED.Translation_Id AS TranslationId
              ,dbo.GetTranslationValue(ED.Translation_Id, NULL) AS [Key]
              ,@pCultureCode AS CultureCode
              ,@pCultureName AS CultureName
              ,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Label
              ,IsFreeTextRequired
              ,IsSelected
              ,ISNULL(ED.EnumSet_Id, @DefaultGuid) AS EnumValueSetId
       FROM #TEMP T

       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
        INNER JOIN EnumSet ES ON ES.Id = A.EnumSetId
       INNER JOIN EnumDefinition ED ON ED.EnumSet_Id = ES.Id
       WHERE ED.IsActive = 1
              AND A.EnumSetId IS NOT NULL

       ----Boolean Attributes 1
       SELECT DISTINCT AtValue.GUIDReference AS Id
              ,AtValue.CandidateId
              ,AtValue.RespondentId
              ,'Boolean' AS DemographicType
              ,T.AttributeId AS DemographicId
              ,AtValue.Value
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       LEFT JOIN (
              SELECT AV.CandidateId
                     ,AV.GUIDReference
			--,boolAV.Value
			,av.Value
                     ,av.DemographicId
                     ,av.RespondentId
              FROM AttributeValue av
              INNER JOIN CollectiveMembership CM ON AV.CandidateId IN (
                           CM.Individual_Id
                           ,CM.Group_Id
                           )
		--INNER JOIN BooleanAttributeValue boolAV ON AV.GUIDReference = boolAV.GUIDReference
		AND av.[Discriminator] = 'BooleanAttributeValue'
              WHERE CM.Group_Id = @Group_Id
              ) AtValue ON AtValue.DemographicId = T.AttributeId
       WHERE A.[Type] = 'Boolean'

       --Integer Attributes 2
       SELECT DISTINCT AtValue.GUIDReference AS Id
              ,AtValue.CandidateId
              ,T.AttributeId AS DemographicId
              ,'Integer' AS DemographicType
              ,AtValue.RespondentId
              ,AtValue.Value
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       LEFT JOIN (
              SELECT AV.CandidateId
                     ,AV.GUIDReference
			--,intAV.Value
			,av.Value
                     ,av.DemographicId
                     ,av.RespondentId
              FROM AttributeValue av
              INNER JOIN CollectiveMembership CM ON AV.CandidateId IN (
                           CM.Individual_Id
                           ,CM.Group_Id
                           )
		--INNER JOIN IntAttributeValue intAV ON AV.GUIDReference = intAV.GUIDReference
		AND av.[Discriminator] = 'IntAttributeValue'
              WHERE CM.Group_Id = @Group_Id
              ) AtValue ON AtValue.DemographicId = T.AttributeId
       WHERE A.[Type] = 'Int'

       ----Float Attributes 3
       SELECT DISTINCT AtValue.GUIDReference AS Id
              ,AtValue.CandidateId
              ,T.AttributeId AS DemographicId
              ,'Float' AS DemographicType
              ,AtValue.RespondentId
              ,AtValue.Value
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       LEFT JOIN (
              SELECT AV.CandidateId
                     ,AV.GUIDReference
			--,floatAV.Value
			,av.Value
                     ,av.DemographicId
                     ,av.RespondentId
              FROM AttributeValue av
              INNER JOIN CollectiveMembership CM ON AV.CandidateId IN (
                           CM.Individual_Id
                           ,CM.Group_Id
                           )
		--INNER JOIN FloatAttributeValue floatAV ON AV.GUIDReference = floatAV.GUIDReference
              WHERE CM.Group_Id = @Group_Id
		AND av.Discriminator='floatattributevalue' 
              ) AtValue ON AtValue.DemographicId = T.AttributeId
       WHERE A.[Type] = 'float'

       ----Date Attributes 4
       SELECT DISTINCT AtValue.GUIDReference AS Id
              ,AtValue.CandidateId
              ,T.AttributeId AS DemographicId
              ,'Date' AS DemographicType
              ,AtValue.RespondentId
              ,AtValue.Value
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       LEFT JOIN (
              SELECT AV.CandidateId
                     ,AV.GUIDReference
			--,dateAV.Value
			,av.Value
                     ,av.DemographicId
                     ,av.RespondentId
              FROM AttributeValue av
              INNER JOIN CollectiveMembership CM ON AV.CandidateId IN (
                           CM.Individual_Id
                           ,CM.Group_Id
                           )
		--INNER JOIN DateAttributeValue dateAV ON AV.GUIDReference = dateAV.GUIDReference
              WHERE CM.Group_Id = @Group_Id
		AND av.Discriminator='DateAttributeValue'
              ) AtValue ON AtValue.DemographicId = T.AttributeId
       WHERE A.[Type] = 'Date'

       ----String Attributes 5
       SELECT DISTINCT AtValue.GUIDReference AS Id
              ,AtValue.CandidateId
              ,T.AttributeId AS DemographicId
              ,'String' AS DemographicType
              ,AtValue.RespondentId
              ,AtValue.Value
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       LEFT JOIN (
              SELECT AV.CandidateId
                     ,AV.GUIDReference
			--,dateAV.Value
			,av.Value
                     ,av.DemographicId
                     ,av.RespondentId
              FROM AttributeValue av
              INNER JOIN CollectiveMembership CM ON AV.CandidateId IN (
                           CM.Individual_Id
                           ,CM.Group_Id
                           )
		--INNER JOIN StringAttributeValue dateAV ON AV.GUIDReference = dateAV.GUIDReference
              WHERE CM.Group_Id = @Group_Id
		AND av.Discriminator='StringAttributeValue'
              ) AtValue ON AtValue.DemographicId = T.AttributeId
       WHERE A.[Type] = 'String'

       --Enum Attributes 6
       SELECT DISTINCT AtValue.GUIDReference AS Id
              ,AtValue.CandidateId
              ,T.AttributeId AS DemographicId
              ,'Enumeration' AS DemographicType
              ,AtValue.RespondentId
              ,AtValue.Defvalue AS Value
              ,AtValue.IsActive
              ,AtValue.IsFreeTextRequired
              ,TranslationId
              ,AtValue.[Key]
              ,CultureCode
              ,CultureName
              ,Label
       FROM #TEMP T
       INNER JOIN Attribute A ON A.GUIDReference = T.AttributeId
       LEFT JOIN (
              SELECT AV.CandidateId
                     ,AV.GUIDReference
                     ,ED.Value + ' - ' + dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Value
                     ,av.DemographicId
                     ,av.RespondentId
                     ,ED.EnumSet_Id
                     ,ED.Id AS EnumDefId
                     ,ED.Translation_Id AS TranslationId
                     ,dbo.GetTranslationValue(ED.Translation_Id, NULL) AS [Key]
                     ,@pCultureCode AS CultureCode
                     ,@pCultureName AS CultureName
                     ,dbo.GetTranslationValue(ED.Translation_Id, @pCultureCode) AS Label
                     ,ED.Value AS Defvalue
                     ,ED.IsActive
                     ,ED.IsFreeTextRequired
              FROM AttributeValue av
              INNER JOIN CollectiveMembership CM ON AV.CandidateId IN (
                           CM.Individual_Id
                           ,CM.Group_Id
                           )
		--INNER JOIN EnumAttributeValue enumAV ON AV.GUIDReference = enumAV.GUIDReference
		--INNER JOIN EnumDefinition ED ON enumAV.Value_Id = ED.Id
		INNER JOIN EnumDefinition ED ON av.EnumDefinition_Id = ED.Id
		INNER JOIN Attribute at ON av.DemographicId = at.GUIDReference
              WHERE CM.Group_Id = @Group_Id
		AND av.Discriminator='EnumAttributeValue'
              ) AtValue ON AtValue.DemographicId = T.AttributeId
       WHERE A.[Type] = 'enum'
END TRY
BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH
END
