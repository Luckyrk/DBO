CREATE PROCEDURE [dbo].[Getviewanswerformfromdemographicscardresult_merge] 
@pCountryID    UNIQUEIDENTIFIER, 
@pindividualId UNIQUEIDENTIFIER, 
@pFormId       UNIQUEIDENTIFIER, 
@pCultureCode  INT, 
@pCultureName  NVARCHAR(10) 
AS 
  BEGIN 
      SET nocount ON; 

      --SELECT * FROM ATtributeScope 
      --individualid, individualbusinessid,groupid,groupsequenceid, 
      DECLARE @Group_Id      UNIQUEIDENTIFIER, 
              @GroupSequence VARCHAR(10), 
              @businessID    VARCHAR(10), 
              @DefaultGuid   UNIQUEIDENTIFIER = 
              '00000000-0000-0000-0000-000000000000' 

      SELECT @Group_Id = group_id 
      FROM   collectivemembership 
      WHERE  individual_id = @pindividualId 

      SELECT @businessID = individualid 
      FROM   individual I 
      WHERE  I.guidreference = @pindividualId 

      SELECT @GroupSequence = sequence 
      FROM   collective 
      WHERE  guidreference = @Group_Id 

      --MERDED Form,FormPages,ColumnDtos,PageSectionDtos 
      SELECT F.guidreference   AS FormId, 
             FTT.value         AS FormNAME, 
             F.translation_id  AS FormTranslationId, 
             FTT.keyname       AS FormKey, 
             FTT.value         AS FormLabel, 
             FP.number         AS PageNumber, 
             FP.translation_id AS PageTranslationId, 
             FPTT.keyname      AS PageKey, 
             FPTT.value        AS PageLabel, 
             FP.id             AS PageId, 
             PC.pagecolumnid   AS PageColumnId, 
             PC.columnnumber   AS ColumnNumber, 
             PC.pagecolumnid   AS PageColumnId, 
             PS.id             PageSectionId, 
             PSTT.value        AS PageSectionNAME, 
             PS.[order]        PageSectionOrder, 
             PS.orientation    PageSectionOrientation, 
             PS.translation_id AS PageSectionTranslationId, 
             PSTT.keyname      AS PageSectionKey, 
             @pCultureCode     AS CultureCode, 
             @pCultureName     AS CultureName, 
             PSTT.value        AS PageSectionLabel 
      FROM   formpage FP 
             INNER JOIN form F 
                     ON F.guidreference = FP.form_id 
             INNER JOIN pagecolumn PC 
                     ON FP.id = PC.page_id 
             INNER JOIN pagesection PS 
                     ON PS.column_id = PC.pagecolumnid 
             CROSS apply dbo.[Gettranslationvalue_tbl](F.translation_id, 
                         @pCultureCode 
                         ) FTT 
             CROSS apply dbo.[Gettranslationvalue_tbl](FP.translation_id, 
                         @pCultureCode) FPTT 
             CROSS apply dbo.[Gettranslationvalue_tbl](PS.translation_id, 
                         @pCultureCode) PSTT 
      WHERE  F.guidreference = @pFormId 
      ORDER  BY FP.number, 
                PC.columnnumber, 
                PS.[order] 

      --Attributesection (sort attribute) 
      CREATE TABLE #temp 
        ( 
           sectionid       UNIQUEIDENTIFIER, 
           orientation     INT, 
           sortattid       UNIQUEIDENTIFIER, 
           [sortorder]     INT, 
           sortcompulsory  BIT, 
           demographic_id  UNIQUEIDENTIFIER, 
           scopetype       NVARCHAR(100), 
           pageorientation INT, 
           attributename   NVARCHAR(400) 
        ) 

      INSERT INTO #temp 
      SELECT PS.id AS SectionID, 
             PS.orientation, 
             SA.id, 
             SA.[order], 
             SA.compulsory, 
             SA.demographic_id, 
             ATS.[type], 
             PS.orientation, 
             TT.value 
      FROM   formpage FP 
             INNER JOIN form F 
                     ON F.guidreference = FP.form_id 
             INNER JOIN pagecolumn PC 
                     ON FP.id = PC.page_id 
             INNER JOIN pagesection PS 
                     ON PS.column_id = PC.pagecolumnid 
             INNER JOIN sortattribute SA 
                     ON SA.pagesection_id = PS.id 
             INNER JOIN attribute A 
                     ON A.guidreference = SA.demographic_id 
             INNER JOIN attributescope ATS 
                     ON ATS.guidreference = A.scope_id 
             CROSS apply dbo.[Gettranslationvalue_tbl](A.translation_id, 
                         @pCultureCode 
                         ) TT 
      WHERE  F.guidreference = @pFormId 
             AND A.active = 1 
             AND ATS.type IN ( 'Individual', 'HouseHold' ) 
      UNION 
      SELECT PS.id AS SectionID, 
             PS.orientation, 
             SA.id, 
             SA.[order], 
             SA.compulsory, 
             AC.attributeid, 
             ATS.[type], 
             PS.orientation, 
             TT.value 
      FROM   formpage FP 
             INNER JOIN form F 
                     ON F.guidreference = FP.form_id 
             INNER JOIN pagecolumn PC 
                     ON FP.id = PC.page_id 
             INNER JOIN pagesection PS 
                     ON PS.column_id = PC.pagecolumnid 
             INNER JOIN sortattribute SA 
                     ON SA.pagesection_id = PS.id 
             INNER JOIN attributeconfiguration AC 
                     ON AC.belongingtypeid = SA.belongingtype_id 
             INNER JOIN attribute A 
                     ON A.guidreference = AC.attributeid 
             INNER JOIN attributescope ATS 
                     ON ATS.guidreference = A.scope_id 
             CROSS apply dbo.[Gettranslationvalue_tbl](A.translation_id, 
                         @pCultureCode 
                         ) TT 
      WHERE  F.guidreference = @pFormId 
             AND A.active = 1 
             AND ATS.type IN ( 'GroupBelongingType', 'IndividualBelongingType' ) 

      -- Group and Individuals in group 
      CREATE TABLE #groupcandidates 
        ( 
           candidateid UNIQUEIDENTIFIER 
        ) 

      INSERT INTO #groupcandidates 
      SELECT @Group_Id 
      UNION ALL 
      SELECT CM.individual_id 
      FROM   collectivemembership CM 
      WHERE  CM.group_id = @Group_Id 

      --AttributeSectionDTO (Sort attribute collection) 
      SELECT T.sectionid      AS PageSectionId, 
             T.sortattid      AS Id, 
             T.sortorder      AS [Order], 
             T.sortcompulsory AS Compulsory, 
             scopetype 
      FROM   #temp T 
      WHERE  scopetype IN ( 'Individual', 'HouseHold' ) 

      SELECT CM.individual_id AS IndividualId, 
             I.individualid   AS IndividualBusinessId, 
             CM.group_id      AS GroupId, 
             CASE 
               WHEN CM.individual_id = C.groupcontact_id THEN 1 
               ELSE 0 
             END              AS IsGroupContact, 
             C.sequence       AS Groupsequence 
      FROM   collectivemembership CM 
             INNER JOIN individual I 
                     ON I.guidreference = CM.individual_id 
             INNER JOIN collective C 
                     ON C.guidreference = CM.group_id 
             INNER JOIN statedefinition SD 
                     ON SD.id = CM.state_id 
      WHERE  CM.group_id = @Group_Id 
             AND SD.inactivebehavior <> 1 

      --MERGED 
      --SELECT DISTINCT SA.Id AS SortAttributeId 
      --     ,A.GuidReference AS Id 
      --     ,CASE  
      --            WHEN A.ShortCode IS NOT NULL 
      --                   THEN A.ShortCode 
      --            ELSE TT.Value 
      --            END AS NAME 
      --     ,[Key] AS Code 
      --     ,MinLength -- StringAttribute 
      --     ,MaxLength --StringAttribute 
      --     ,DateFrom  --DateAttribute 
      --     ,DateTo    --DateAttribute 
      --     ,[From]    --FloatAttribute,intAttribute 
      --     ,[To]      --FloatAttribute,intAttribute 
      --     ,IsCalculated 
      --     ,Calculation_Id AS BusinessRuleId 
      --     ,Category_Id AS CategoryId 
      --     ,ScopeType 
      --     ,0 AS ShowScopeInfo 
      --     ,0 AS DemographicType 
      --     ,IsReadOnly 
      --     ,A.Translation_Id AS TranslationId 
      --     ,TT.Keyname AS [Key] 
      --     ,@pCultureCode AS CultureCode 
      --     ,@pCultureName AS CultureName 
      --     ,TT.Value AS Label 
      --FROM #TEMP T 
      --INNER JOIN SortAttribute SA ON SA.Id = T.SortAttId 
      --INNER JOIN Attribute A ON A.GUIDReference = T.Demographic_Id 
      --CROSS APPLY dbo.[GetTranslationValue_tbl](A.Translation_Id, @pCultureCode) TT 
      --WHERE A.[Type] IN ('Enum','String','Boolean','Date','Float','Int') 
      --     AND a.Active = 1 
      --Actual DefinitionDtos 
      SELECT DISTINCT --SA.Id AS SortAttributeId 
      A.guidreference                          AS AttributeId, 
      ED.id, 
      TT.value                                 AS NAME, 
      ED.value, 
      ED.isactive, 
      isfreetextrequired, 
      isselected, 
      Isnull(ED.enumvalueset_id, @DefaultGuid) AS EnumValueSetId, 
      ED.translation_id                        AS TranslationId, 
      TT.keyname                               AS [Key], 
      @pCultureCode                            AS CultureCode, 
      @pCultureName                            AS CultureName, 
      TT.value                                 AS Label 
      FROM   #temp T 
             INNER JOIN sortattribute SA 
                     ON SA.id = T.sortattid 
             INNER JOIN attribute A 
                     ON A.guidreference = T.demographic_id --SA.Demographic_Id 
             INNER JOIN enumset ES 
                     ON ES.id = A.enumsetid 
             INNER JOIN enumdefinition ED 
                     ON ED.enumset_id = ES.id 
             CROSS apply dbo.[Gettranslationvalue_tbl](ED.translation_id, 
                         @pCultureCode) TT 
      WHERE  ED.isactive = 1 
             AND A.active = 1 
             AND A.enumsetid IS NOT NULL 
      UNION 
      SELECT DISTINCT --SA.Id AS SortAttId 
      A.guidreference                          AS AttributeId, 
      ED.id, 
      TT.value                                 AS NAME, 
      ED.value, 
      ED.isactive, 
      isfreetextrequired, 
      isselected, 
      Isnull(ED.enumvalueset_id, @DefaultGuid) AS EnumValueSetId, 
      ED.translation_id                        AS TranslationId, 
      TT.keyname                               AS [Key], 
      @pCultureCode                            AS CultureCode, 
      @pCultureName                            AS CultureName, 
      TT.value                                 AS Label 
      FROM   #temp T 
             INNER JOIN sortattribute SA 
                     ON SA.id = T.sortattid 
             INNER JOIN attribute A 
                     ON A.guidreference = T.demographic_id --SA.Demographic_Id 
             INNER JOIN enumdefinition ED 
                     ON ED.demographic_id = A.guidreference 
             CROSS apply dbo.[Gettranslationvalue_tbl](ED.translation_id, 
                         @pCultureCode) TT 
      WHERE  ED.isactive = 1 
             AND A.active = 1 
             AND A.enumsetid IS NULL 

      --EnumsetDTO 
      SELECT DISTINCT SA.id           AS SortAttId, 
                      ES.id           AS Id, 
                      A.guidreference AS AttributeId, 
                      TT.value        AS NAME, 
                      ES.translation_id, 
                      TT.keyname      AS [Key], 
                      @pCultureCode   AS CultureCode, 
                      @pCultureName   AS CultureName, 
                      TT.value        AS Label 
      FROM   #temp T 
             INNER JOIN sortattribute SA 
                     ON SA.id = T.sortattid 
             INNER JOIN attribute A 
                     ON A.guidreference = SA.demographic_id 
             INNER JOIN enumset ES 
                     ON ES.id = A.enumsetid 
             CROSS apply dbo.[Gettranslationvalue_tbl](ES.translation_id, 
                         @pCultureCode) TT 

      --EnumsetDTO.Definitions 
      SELECT DISTINCT ES.id                                    AS EnumSetId, 
                      ED.id, 
                      TT.value                                 AS NAME, 
                      ED.value, 
                      ED.isactive, 
                      ED.translation_id                        AS TranslationId, 
                      TT.keyname                               AS [Key], 
                      @pCultureCode                            AS CultureCode, 
                      @pCultureName                            AS CultureName, 
                      TT.value                                 AS Label, 
                      isfreetextrequired, 
                      isselected, 
                      Isnull(ED.enumvalueset_id, @DefaultGuid) AS EnumValueSetId 
      FROM   #temp T 
             INNER JOIN sortattribute SA 
                     ON SA.id = T.sortattid 
             INNER JOIN attribute A 
                     ON A.guidreference = SA.demographic_id 
             INNER JOIN enumset ES 
                     ON ES.id = A.enumsetid 
             INNER JOIN enumdefinition ED 
                     ON ED.enumset_id = ES.id 
             CROSS apply dbo.[Gettranslationvalue_tbl](ED.translation_id, 
                         @pCultureCode) TT 

      --ValueGroupings 
      SELECT DISTINCT DVG.guidreference AS GroupingId, 
                      TT.value          AS Demographic, 
                      A.guidreference   AS AttributeId, 
                      TT2.value         AS GroupingName, 
                      DVG.[type]        AS DemographicType, 
                      A.translation_id  AS Id, 
                      TT.keyname        AS [Key], 
                      @pCultureCode     AS CultureCode, 
                      @pCultureName     AS CultureName, 
                      TT.value          AS Label 
      FROM   #temp T 
             INNER JOIN sortattribute SA 
                     ON SA.id = T.sortattid 
             INNER JOIN attribute A 
                     ON A.guidreference = SA.demographic_id 
             INNER JOIN demographicvaluegrouping DVG 
                     ON DVG.demographic_id = A.guidreference 
             CROSS apply dbo.[Gettranslationvalue_tbl](A.translation_id, 
                         @pCultureCode 
                         ) TT 
             CROSS apply dbo.[Gettranslationvalue_tbl](DVG.label_id, 
                         @pCultureCode 
                         ) 
                         TT2 

      --Intervales 
      SELECT DISTINCT DV.guidreference  AS Id, 
                      DVG.guidreference AS DemographicGroupingId, 
                      TT3.value         AS IntervalDescription, 
                      TT3.value         AS IntervalDescriptionKey, 
                      CASE 
                        WHEN DVG.[type] = 'Decimal' THEN 'Float' 
                        WHEN DVG.[type] = 'Int' THEN 'Integer' 
                        ELSE DVG.[type] 
                      END               AS DemographicType, 
                      DV.label_id       AS TranslationId, 
                      TT.value          AS Demographic, 
                      A.guidreference   AS AttributeId, 
                      TT2.value         AS GroupingName, 
                      A.translation_id  AS TranslationId, 
                      TT.keyname        AS [Key], 
                      @pCultureCode     AS CultureCode, 
                      TT.value          AS Label, 
                      A.[from]          AS [From], 
                      A.[to]            AS [To], 
                      DVI.startint      AS FromInteger, 
                      DVI.endint        AS ToInteger, 
                      DVI.startdate     AS FromDate, 
                      DVI.enddate       AS ToDate, 
                      A.datefrom        AS MinDate, 
                      A.dateto          AS MaxDate, 
                      DVI.startdecimal  AS FromDecimal, 
                      DVI.enddecimal    AS ToDecimal, 
                      A.[from]          AS MinDecimal, 
                      A.[to]            AS MaxDecimal 
      --,IsFreeTextRequired,IsSelected,ISNULL(ED.EnumSet_Id,@DefaultGuid) AS EnumValueSetId 
      FROM   sortattribute SA --ON SA.PageSection_Id=PS.Id 
             INNER JOIN attribute A 
                     ON A.guidreference = SA.demographic_id 
             CROSS apply dbo.[Gettranslationvalue_tbl](A.translation_id, 
                         @pCultureCode 
                         ) TT 
             INNER JOIN demographicvaluegrouping DVG 
                     ON DVG.demographic_id = A.guidreference 
             CROSS apply dbo.[Gettranslationvalue_tbl](DVG.label_id, 
                         @pCultureCode 
                         ) 
                         TT2 
             INNER JOIN demographicvalue DV 
                     ON DV.demographicvaluegrouping_id = DVG.guidreference 
             CROSS apply dbo.[Gettranslationvalue_tbl](DV.label_id, 
                         @pCultureCode) 
                         TT3 
             LEFT JOIN demographicvalueinterval DVI 
                    ON DVI.guidreference = DV.guidreference 
      WHERE  DVG.[type] <> 'Enum' 
             AND A.active = 1 

      --Belonging section 
      SELECT DISTINCT sectionid         AS PageSectionId, 
                      SA.id, 
                      BT.id             AS BelongingTypeId, 
                      TT.value          AS NAME, 
                      BT.translation_id AS TranslationId, 
                      TT.keyname        AS [Key], 
                      @pCultureCode     AS CultureCode, 
                      @pCultureName     AS CultureName, 
                      TT.value          AS Label, 
                      CASE 
                        WHEN BT.[type] = 'GroupBelongingType' THEN 0 
                        WHEN BT.[type] = 'IndividualBelongingType' THEN 1 
                      END               AS BelongingTypeScope, 
                      SA.[order] 
      FROM   #temp T 
             INNER JOIN sortattribute SA 
                     ON SA.id = T.sortattid 
             INNER JOIN belongingtype BT 
                     ON BT.id = SA.belongingtype_id 
             CROSS apply dbo.[Gettranslationvalue_tbl](BT.translation_id, 
                         @pCultureCode) TT 

      ---BelongingSection AttributeConfigurationDTO 
      SELECT SA.id                       AS SortAttributeID, 
             AC.attributeconfigurationid AS Id, 
             AC.belongingtypeid, 
             AC.[order], 
             T.attributename, 
             AC.attributeid, 
             AC.isrequired 
      FROM   #temp T 
             INNER JOIN sortattribute SA 
                     ON SA.id = T.sortattid 
             INNER JOIN attributeconfiguration AC 
                     ON sa.belongingtype_id = AC.belongingtypeid 
                        AND AC.attributeid = T.demographic_id 

  /* 
    Kept UNION ALL between OrderedBelongingDtos,Individual and OrderedBelongingDtos,Group results
  */ 
      --OrderedBelongingDtos,Individual  
      SELECT DISTINCT SA.id                     AS SortAttributeId, 
                      'IndividualBelongingType' AS BelongingType, 
                      OB.[order], 
                      B.candidateid, 
                      B.guidreference           AS Id, 
                      BT.id                     AS BelongingTypeId, 
                      b.belongingcode, 
                      SD.id                     AS StateId, 
                      SD.code, 
                      TT.value                  AS NAME, 
                      SM.guidreference          AS StateModelId, 
                      TT2.value                 AS StateModelName, 
                      CASE 
                        WHEN TB.[type] = 'FinalTransitionBehavior' THEN 1 
                        ELSE 0 
                      END                       AS IsLast, 
                      SD.trafficlightbehavior   AS DisplayBehavior, 
                      SD.inactivebehavior       AS Inactive 
      FROM   #temp T 
             INNER JOIN sortattribute SA 
                     ON SA.id = T.sortattid 
             INNER JOIN belongingtype BT 
                     ON BT.id = SA.belongingtype_id 
             INNER JOIN belonging bg 
                     ON bg.[typeid] = bt.id 
             INNER JOIN orderedbelonging OB 
                     ON OB.belonging_id = bg.guidreference 
             INNER JOIN (SELECT B.candidateid, 
                                B.guidreference, 
                                belongingcode, 
                                B.state_id 
                         FROM   belonging B 
                                INNER JOIN #groupcandidates GC 
                                        ON GC.candidateid = B.candidateid) AS B 
                     ON B.guidreference = OB.belonging_id 
             INNER JOIN statedefinition SD 
                     ON SD.id = B.state_id 
             CROSS apply dbo.[Gettranslationvalue_tbl](SD.label_id, 
                         @pCultureCode) 
                         TT 
             INNER JOIN statemodel SM 
                     ON SM.guidreference = SD.statemodel_id 
             CROSS apply dbo.[Gettranslationvalue_tbl](SM.name_id, @pCultureCode 
                         ) 
                         TT2 
             INNER JOIN transitionbehavior TB 
                     ON TB.guidreference = SD.statedefinitionbehavior_id 
      WHERE  BT.[type] = 'IndividualBelongingType' 
      UNION ALL 
      --OrderedBelongingDtos,Group 
      SELECT DISTINCT SA.id                   AS SortAttributeId, 
                      'GroupBelongingType'    AS BelongingType, 
                      OB.[order], 
                      B.candidateid, 
                      B.guidreference         AS Id, 
                      BT.id                   AS BelongingTypeId, 
                      b.belongingcode, 
                      SD.id                   AS StateId, 
                      SD.code, 
                      TT.value                AS NAME, 
                      SM.guidreference        AS StateModelId, 
                      TT2.value               AS StateModelName, 
                      CASE 
                        WHEN TB.[type] = 'FinalTransitionBehavior' THEN 1 
                        ELSE 0 
                      END                     AS IsLast, 
                      SD.trafficlightbehavior AS DisplayBehavior, 
                      SD.inactivebehavior     AS Inactive 
      FROM   #temp T 
             INNER JOIN sortattribute SA 
                     ON SA.id = T.sortattid 
             INNER JOIN belongingtype BT 
                     ON BT.id = SA.belongingtype_id 
             INNER JOIN belonging bg 
                     ON bg.[typeid] = bt.id 
             INNER JOIN orderedbelonging OB 
                     ON OB.belonging_id = bg.guidreference 
             INNER JOIN (SELECT B.candidateid, 
                                B.guidreference, 
                                belongingcode, 
                                B.state_id 
                         FROM   belonging B 
                                INNER JOIN #groupcandidates GC 
                                        ON GC.candidateid = B.candidateid) AS B 
                     ON B.guidreference = OB.belonging_id 
             INNER JOIN statedefinition SD 
                     ON SD.id = B.state_id 
             CROSS apply dbo.[Gettranslationvalue_tbl](SD.label_id, 
                         @pCultureCode) 
                         TT 
             INNER JOIN statemodel SM 
                     ON SM.guidreference = SD.statemodel_id 
             CROSS apply dbo.[Gettranslationvalue_tbl](SM.name_id, @pCultureCode 
                         ) 
                         TT2 
             INNER JOIN transitionbehavior TB 
                     ON TB.guidreference = SD.statedefinitionbehavior_id 
      WHERE  BT.[type] = 'GroupBelongingType' 

      --StateDefinitionDTO.Transitions 
      SELECT DISTINCT B.guidreference AS BelongingId, 
                      ST.tostate_id   AS StateToId, 
                      TT.value        AS StateToName, 
                      SD1.code        AS StateToCode 
      FROM   #temp T 
             INNER JOIN sortattribute SA 
                     ON SA.id = T.sortattid 
             INNER JOIN belongingtype BT 
                     ON BT.id = SA.belongingtype_id 
             INNER JOIN orderedbelonging OB 
                     ON OB.belongingsection_id = SA.id 
             INNER JOIN (SELECT B.candidateid, 
                                B.guidreference, 
                                belongingcode, 
                                B.state_id 
                         FROM   belonging B 
                                INNER JOIN collectivemembership CM 
                                        ON B.candidateid IN ( 
                                           CM.individual_id, CM.group_id ) 
                         WHERE  CM.group_id = @Group_Id) AS B 
                     ON B.guidreference = OB.belonging_id 
             INNER JOIN statedefinition SD 
                     ON SD.id = B.state_id 
             --JOIN StateDefinitionsTransitions SDT ON SDT.StateDefinition_Id=SD.Id 
             INNER JOIN statetransition ST 
                     ON ST.fromstate_id = SD.id 
             INNER JOIN statedefinition SD1 
                     ON SD1.id = ST.tostate_id 
             CROSS apply dbo.[Gettranslationvalue_tbl](SD1.label_id, 
                         @pCultureCode 
                         ) TT 

      --AttributeValue DTO's 
      --MERGED 
      SELECT DISTINCT T.sortattid      AS SortAttributeId, 
                      T.demographic_id AS DemographicId, 
                      CASE 
                        WHEN A.shortcode IS NOT NULL THEN A.shortcode 
                        ELSE '' --TT.Value 
                      END              AS NAME, 
                      [key]            AS Code, 
                      minlength -- StringAttribute 
                      , 
                      maxlength --StringAttribute 
                      , 
                      datefrom --DateAttribute 
                      , 
                      dateto --DateAttribute 
                      , 
                      [from] --FloatAttribute,intAttribute 
                      , 
                      [to] --FloatAttribute,intAttribute 
                      , 
                      iscalculated, 
                      calculation_id   AS BusinessRuleId, 
                      category_id      AS CategoryId, 
                      scopetype, 
                      0                AS ShowScopeInfo, 
                      0                AS DemographicType, 
                      isreadonly, 
                      A.translation_id AS TranslationId 
                      --,TT.Keyname AS [Key] 
                      , 
                      @pCultureCode    AS CultureCode, 
                      @pCultureName    AS CultureName 
                      --,TT.Value AS Label 
                      , 
                      AV.id, 
                      AV.candidateid, 
                      demographictype, 
                      AV.respondentid, 
                      AV.value 
      FROM   #temp T 
             INNER JOIN attribute A 
                     ON A.guidreference = T.demographic_id 
             --CROSS APPLY dbo.[GetTranslationValue_tbl](A.Translation_Id, @pCultureCode) TT 
             LEFT JOIN (SELECT A.demographicid, 
                               A.guidreference AS Id, 
                               A.candidateid, 
                               CASE 
                                 WHEN a.discriminator = 'BooleanAttributeValue' 
                               THEN 
                                 'Boolean' 
                                 WHEN a.discriminator = 'IntAttributeValue' THEN 
                                 'Integer' 
                                 WHEN a.discriminator = 'FloatAttributeValue' 
                               THEN 
                                 'Float' 
                                 WHEN a.discriminator = 'DateAttributeValue' 
                               THEN 
                                 'Date' 
                                 WHEN a.discriminator = 'StringAttributeValue' 
                               THEN 
                                 'String' 
                               END             AS DemographicType, 
                               A.respondentid, 
                               A.value 
                        FROM   attributevalue a 
                               INNER JOIN #groupcandidates GC 
                                       ON GC.candidateid = A.candidateid 
                        WHERE  a.candidateid IS NOT NULL 
                               AND a.discriminator IN ( 'BooleanAttributeValue', 
                                                        'IntAttributeValue', 
                                                        'FloatAttributeValue', 
                                                        'DateAttributeValue', 
                                   'StringAttributeValue' 
                                                      )) 
                       AV 
                    ON AV.demographicid = T.demographic_id 
					WHERE T.scopetype IN ('Individual','HouseHold')
      UNION ALL 
      SELECT DISTINCT T.sortattid      AS SortAttributeId, 
                      T.demographic_id AS DemographicId, 
                      CASE 
                        WHEN A.shortcode IS NOT NULL THEN A.shortcode 
                        ELSE '' -- TT.Value 
                      END              AS NAME, 
                      [key]            AS Code, 
                      minlength -- StringAttribute 
                      , 
                      maxlength --StringAttribute 
                      , 
                      datefrom --DateAttribute 
                      , 
                      dateto --DateAttribute 
                      , 
                      [from] --FloatAttribute,intAttribute 
                      , 
                      [to] --FloatAttribute,intAttribute 
                      , 
                      iscalculated, 
                      calculation_id   AS BusinessRuleId, 
                      category_id      AS CategoryId, 
                      scopetype, 
                      0                AS ShowScopeInfo, 
                      0                AS DemographicType, 
                      isreadonly, 
                      A.translation_id AS TranslationId 
                      --,TT.Keyname AS [Key] 
                      , 
                      @pCultureCode    AS CultureCode, 
                      @pCultureName    AS CultureName 
                      --,TT.Value AS Label 
                      , 
                      AV.id, 
                      AV.candidateid, 
                      AV.demographictype, 
                      AV.respondentid, 
                      AV.value 
      FROM   #temp T 
             INNER JOIN attribute A 
                     ON A.guidreference = T.demographic_id 
             --CROSS APPLY dbo.[GetTranslationValue_tbl](A.Translation_Id, @pCultureCode) TT 
             LEFT JOIN (SELECT A.demographicid, 
                               A.guidreference AS Id, 
                               A.candidateid, 
                               CASE 
                                 WHEN a.discriminator = 'BooleanAttributeValue' 
                               THEN 
                                 'Boolean' 
                                 WHEN a.discriminator = 'IntAttributeValue' THEN 
                                 'Integer' 
                                 WHEN a.discriminator = 'FloatAttributeValue' 
                               THEN 
                                 'Float' 
                                 WHEN a.discriminator = 'DateAttributeValue' 
                               THEN 
                                 'Date' 
                                 WHEN a.discriminator = 'StringAttributeValue' 
                               THEN 
                                 'String' 
                               END             AS DemographicType, 
                               A.respondentid, 
                               A.value 
                        FROM   attributevalue a 
                               INNER JOIN respondent R 
                                       ON A.respondentid = R.guidreference 
                               INNER JOIN belonging B 
                                       ON B.guidreference = R.guidreference 
                               INNER JOIN #groupcandidates GC 
                                       ON GC.candidateid = B.candidateid 
                        WHERE  a.respondentid IS NOT NULL 
                               AND a.discriminator IN ( 'BooleanAttributeValue', 
                                                        'IntAttributeValue', 
                                                        'FloatAttributeValue', 
                                                        'DateAttributeValue', 
                                   'StringAttributeValue' 
                                                      )) 
                       AV 
                    ON AV.demographicid = T.demographic_id 
				WHERE	T.scopetype IN ('GroupBelongingType','IndividualBelongingType')

      ------Enum Attributes 6 
      SELECT DISTINCT [freetext], 
                      T.sortattid           AS SortAttributeId, 
					 T.demographic_id AS DemographicId, 
					   CASE 
                        WHEN A.shortcode IS NOT NULL THEN A.shortcode 
                        ELSE '' --TT.Value 
                      END              AS NAME, 
                      A.[key]            AS Code, 
					  IsCalculated, 
                      calculation_id   AS BusinessRuleId, 
                      category_id      AS CategoryId, 
                      scopetype, 
                      0                AS ShowScopeInfo, 
                      0                AS DemographicType, 
                      IsReadOnly, 
                      A.translation_id AS TranslationId 
                      --,TT.Keyname AS [Key] 
                      , 
                      @pCultureCode    AS CultureCode, 
                      @pCultureName    AS CultureName ,
                      AtValue.guidreference AS Id, 
                      AtValue.candidateid, 
                      'Enumeration'         AS DemographicType, 
                      AtValue.respondentid, 
                      AtValue.defvalue      AS Value, 
                      AtValue.isactive, 
                      AtValue.isfreetextrequired, 
                      translationid, 
                      AtValue.[key], 
                      CultureCode, 
                      CultureName, 
                      Label 
      FROM   #temp T 
             INNER JOIN attribute A 
                     ON A.guidreference = T.demographic_id 
             INNER JOIN (SELECT AV.candidateid, 
                                AV.guidreference, 
                                ED.value + ' - ' + TT.value AS Value, 
                                av.demographicid, 
                                av.respondentid, 
                                ED.enumset_id, 
                                ED.id                       AS EnumDefId, 
                                ED.translation_id           AS TranslationId, 
                                TT.keyname                  AS [Key], 
                                @pCultureCode               AS CultureCode, 
                                @pCultureName               AS CultureName, 
                                TT.value                    AS Label, 
                                ED.value                    AS Defvalue, 
                                ED.isactive, 
                                ED.isfreetextrequired, 
                                av.[freetext] 
                         FROM   attributevalue av 
                                INNER JOIN #groupcandidates GC 
                                        ON GC.candidateid = AV.candidateid 
                                           AND av.discriminator = 
                                               'EnumAttributeValue' 
                                LEFT JOIN enumdefinition ED 
                                       ON av.enumdefinition_id = ED.id 
                                OUTER apply 
                                [Gettranslationvalue_tbl](ED.translation_id, 
                                @pCultureCode) 
                                TT 
                         WHERE  av.candidateid IS NOT NULL 
                         UNION ALL 
                         SELECT AV.candidateid, 
                                AV.guidreference, 
                                ED.value + ' - ' + TT.value AS Value, 
                                av.demographicid, 
                                av.respondentid, 
                                ED.enumset_id, 
                                ED.id                       AS EnumDefId, 
                                ED.translation_id           AS TranslationId, 
                                TT.keyname                  AS [Key], 
                                @pCultureCode               AS CultureCode, 
                                @pCultureName               AS CultureName, 
                                TT.value                    AS Label, 
                                ED.value                    AS Defvalue, 
                                ED.isactive, 
                                ED.isfreetextrequired, 
                                av.[freetext] 
                         FROM   attributevalue av 
                                INNER JOIN respondent R 
                                        ON R.guidreference = av.respondentid 
                                INNER JOIN belonging B 
                                        ON B.guidreference = R.guidreference 
                                INNER JOIN #groupcandidates GC 
                                        ON GC.candidateid = B.candidateid 
                                           AND av.[discriminator] = 
                                               'EnumAttributeValue' 
                                LEFT JOIN enumdefinition ED 
                                       ON av.enumdefinition_id = ED.id 
                                OUTER apply 
                                [Gettranslationvalue_tbl](ED.translation_id, 
                                @pCultureCode) 
                                TT 
                         WHERE  av.respondentid IS NOT NULL) AtValue 
                     ON AtValue.demographicid = T.demographic_id 
      WHERE  A.[type] = 'enum' 

      DROP TABLE #temp 

      DROP TABLE #groupcandidates 
  END 

go 