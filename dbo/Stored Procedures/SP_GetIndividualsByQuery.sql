
-- Author:  Fernandez Matias  
-- Create date: 2014/11/11  
-- Description: Filters the IndividualIds that match the specified criteria.  
-- ver  user                      date        change   
-- 1.0  Fernandez Matias   2014/11/11  initial  
-- 1.1  Ramana                           2014-12-11    
-- 1.2  Jagadesh Dasari     2016-05-18   Search for Business ID 
-- 1.3  Gudla sai kiran    2017-05-11    Search for Alias  
-- =========================================================================

Create PROCEDURE [dbo].[SP_GetIndividualsByQuery] @OrigCountry UNIQUEIDENTIFIER
       ,@OrigBusinessId NVARCHAR(50) = ''
       ,@OrigEmail NVARCHAR(50) = ''
       ,@OrigPhone NVARCHAR(50) = ''
       ,@OrigPostCode NVARCHAR(50) = ''
       ,@OrigAddress NVARCHAR(50) = ''
       ,@OrigName NVARCHAR(50) = ''
       ,@OrgAlias NVARCHAR(50) = ''
       ,@OrigCultureCode INT = 2057
       ,@OrigOrderBy NVARCHAR(100) = NULL
       ,@OrigOrderType NVARCHAR(5) = NULL
       ,@OrigPageNumber INT = 1
       ,@OrigPageSize INT = 20
       ,@OrigIsExport BIT = 0
       ,@isPanelist BIT=0
       ,@Filters dbo.GridParametersTable READONLY
AS
BEGIN
       SET NOCOUNT ON;

       DECLARE @Country UNIQUEIDENTIFIER = @OrigCountry;
       DECLARE @BusinessId NVARCHAR(50) = @OrigBusinessId
       DECLARE @Email NVARCHAR(50) = @OrigEmail
       DECLARE @Phone NVARCHAR(50) = @OrigPhone
       DECLARE @PostCode NVARCHAR(50) = @OrigPostCode
       DECLARE @Address NVARCHAR(50) = @OrigAddress
       DECLARE @Name NVARCHAR(50) = @OrigName
       DECLARE @Alias NVARCHAR(50)= @OrgAlias
       DECLARE @CultureCode INT = @OrigCultureCode
       DECLARE @OrderBy NVARCHAR(100) = @OrigOrderBy
       DECLARE @OrderType NVARCHAR(5) = @OrigOrderType
       DECLARE @PageNumber INT = @OrigPageNumber
       DECLARE @PageSize INT = @OrigPageSize
       DECLARE @IsExport BIT = @OrigIsExport
       DECLARE @OFFSETRows INT = 0

       IF (@IsExport = 0)
              SET @OFFSETRows = (@PageSize * (@PageNumber - 1))
       ELSE
              SET @PageSize = 15000

       DECLARE @IsLessThan VARCHAR(50) = 'IsLessThan'
              ,@IsLessThanOrEqualTo VARCHAR(50) = 'IsLessThanOrEqualTo'
              ,@IsEqualTo VARCHAR(50) = 'IsEqualTo'
              ,@IsNotEqualTo VARCHAR(50) = 'IsNotEqualTo'
              ,@IsGreaterThanOrEqualTo VARCHAR(50) = 'IsGreaterThanOrEqualTo'
              ,@IsGreaterThan VARCHAR(50) = 'IsGreaterThan'
              ,@StartsWith VARCHAR(50) = 'StartsWith'
              ,@EndsWith VARCHAR(50) = 'EndsWith'
              ,@Contains VARCHAR(50) = 'Contains'
              ,@IsContainedIn VARCHAR(50) = 'IsContainedIn'
              ,@DoesNotContain VARCHAR(50) = 'DoesNotContain'
       DECLARE @FilterBusinessId NVARCHAR(100);
       DECLARE @FilterName NVARCHAR(100);
       DECLARE @FilterPhone NVARCHAR(100);
       DECLARE @FilterGroupContact NVARCHAR(100);
       DECLARE @FilterEmail NVARCHAR(100);
       DECLARE @FilterGeographicArea NVARCHAR(100);
       DECLARE @FilterAlias NVARCHAR(100);
       DECLARE @OperatorBusinessId NVARCHAR(100);
       DECLARE @OperatorName NVARCHAR(100);
       DECLARE @OperatorPhone NVARCHAR(100);
       DECLARE @OperatorGroupContact NVARCHAR(100);
       DECLARE @OperatorEmail NVARCHAR(100);
       DECLARE @OperatorGeographicArea NVARCHAR(100);
       DECLARE @OperatorAlias NVARCHAR(100);
       DECLARE @FilterLocal AS GridParametersTable;
       DECLARE @CountryConfigurationId UNIQUEIDENTIFIER = (SELECT Configuration_Id FROM Country WHERE CountryId = @OrigCountry)
       DECLARE @IsCountryConfigurable BIT = (SELECT [Required] FROM FieldConfiguration WHERE [Key]='IsCountryRequired' AND CountryConfiguration_Id = @CountryConfigurationId)  
       --DECLARE @GroupBusinessIdDigits INT = (SELECT GroupBusinessIdDigits FROM CountryConfiguration WHERE Id = @CountryConfigurationId)
       DECLARE @SampleIndividualId NVARCHAR(50) = (SELECT TOP 1 IndividualId FROM Individual WHERE IndividualId IS NOT NULL)
       DECLARE @GroupBusinessIdDigits INT = (SELECT LEN(items) FROM dbo.Split(@SampleIndividualId,'-') WHERE id = 1)

       INSERT INTO @FilterLocal
       SELECT *
       FROM @Filters

       SELECT @FilterBusinessId = ParameterValue
              ,@OperatorBusinessId = Opertor
       FROM @FilterLocal
       WHERE ParameterName = 'BusinessId';

       SELECT @FilterName = ParameterValue
              ,@OperatorName = Opertor
       FROM @FilterLocal
       WHERE ParameterName = 'Name';

       SELECT @FilterPhone = ParameterValue
              ,@OperatorPhone = Opertor
       FROM @FilterLocal
       WHERE ParameterName = 'Phone';

       SELECT @FilterGroupContact = ParameterValue
              ,@OperatorGroupContact = Opertor
       FROM @FilterLocal
       WHERE ParameterName = 'GroupContact';

       SELECT @FilterEmail = ParameterValue
              ,@OperatorEmail = Opertor
       FROM @FilterLocal
       WHERE ParameterName = 'EmailAddress';

       SELECT @FilterGeographicArea = ParameterValue
              ,@OperatorGeographicArea = Opertor
       FROM @FilterLocal
       WHERE ParameterName = 'GeographicArea';

       SELECT @FilterAlias = ParameterValue
              ,@OperatorAlias = Opertor
       FROM @FilterLocal
       WHERE ParameterName = 'Alias';

       IF OBJECT_ID('tempdb..#FilteredIds') IS NOT NULL
              TRUNCATE TABLE #FilteredIds
       ELSE
              CREATE TABLE #FilteredIds (GUIDReference UNIQUEIDENTIFIER PRIMARY KEY (GUIDReference))

       --DECLARE @FilteredIds TABLE (GUIDReference uniqueidentifier PRIMARY KEY (GUIDReference))  
       IF (@BusinessId <> '')
       BEGIN
              DECLARE @LocalBusinessId NVARCHAR(50)
              IF(@IsCountryConfigurable = 1)
                     BEGIN
                     DECLARE @ModifiedBusinessId VARCHAR(50) = REPLACE(LTRIM(REPLACE(@BusinessId,'0',' ')),' ','0')
                     DECLARE @BusinessIdPreFix VARCHAR(50) = (SELECT items FROM dbo.Split(@ModifiedBusinessId,'-') WHERE id = 1) 
                           ,@BusinessIdPostFix VARCHAR(50) = (SELECT items FROM dbo.Split(@ModifiedBusinessId,'-') WHERE id = 2)
                           ,@BusinessIdCount INT, @IdLengthDiff INT 

                           SET @IdLengthDiff = @GroupBusinessIdDigits - LEN(@BusinessIdPreFix)

                     IF((@IdLengthDiff > 0) AND (LEN(@ModifiedBusinessId) > 1))
                           BEGIN
                                  SET @ModifiedBusinessId = (SELECT RIGHT('00000000000000'+ISNULL(@BusinessIdPreFix,''),@GroupBusinessIdDigits))

                                  IF(LEN(@BusinessIdPostFix) > 0)
                                  BEGIN
                                         SET @ModifiedBusinessId = CONCAT (@ModifiedBusinessId,CONCAT ('-',@BusinessIdPostFix));
                                  END

                                  IF(@BusinessIdPostFix IS NOT NULL)
                                  BEGIN
                                         INSERT #FilteredIds (GUIDReference)
                                         SELECT DISTINCT ind.GUIDReference
                                         FROM Individual ind
                                         INNER JOIN Candidate c ON c.GUIDReference = ind.GUIDReference
                                         INNER JOIN CollectiveMembership cm ON cm.Individual_Id=ind.GUIDReference
                                         WHERE c.Country_Id = @Country
                                                AND (
                                                       @ModifiedBusinessId <> ''
                                                       AND REPLACE(LTRIM(REPLACE(ind.IndividualId,'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(@ModifiedBusinessId,'0',' ')),' ','0')
                                                       )
                                  END
                                  ELSE
                                  BEGIN
                                         INSERT #FilteredIds (GUIDReference)
                                         SELECT DISTINCT ind.GUIDReference
                                         FROM Individual ind
                                         INNER JOIN Candidate c ON c.GUIDReference = ind.GUIDReference
                                         INNER JOIN CollectiveMembership cm ON cm.Individual_Id=ind.GUIDReference
                                         WHERE c.Country_Id = @Country
                                                AND (
                                                       @ModifiedBusinessId <> ''
                                                       AND REPLACE(LTRIM(REPLACE(LEFT(ind.IndividualId,CHARINDEX('-',ind.IndividualId)-1),'0',' ')),' ','0') = REPLACE(LTRIM(REPLACE(@ModifiedBusinessId,'0',' ')),' ','0')
                                                       )
                                  END
                                  
                                  SET @BusinessIdCount = (SELECT COUNT(*) FROM #FilteredIds)

                                  IF(@BusinessIdCount < 1)
                                         BEGIN
                                         SET @LocalBusinessId = CONCAT (
                                                REPLACE(LTRIM(REPLACE(@BusinessId,'0',' ')),' ','0')
                                                ,'%'
                                                );

                                         INSERT #FilteredIds (GUIDReference)
                                         SELECT DISTINCT ind.GUIDReference
                                         FROM Individual ind
                                         INNER JOIN Candidate c ON c.GUIDReference = ind.GUIDReference
                                         INNER JOIN CollectiveMembership cm ON cm.Individual_Id=ind.GUIDReference
                                         WHERE c.Country_Id = @Country
                                                AND (
                                                       @LocalBusinessId <> ''
                                                       AND REPLACE(LTRIM(REPLACE(ind.IndividualId,'0',' ')),' ','0') LIKE @LocalBusinessId
                                                       )
                                  END
                           END
                     ELSE
                           BEGIN
                                  SET @LocalBusinessId = CONCAT (
                                         @BusinessId
                                         ,'%'
                                         );

                                  INSERT #FilteredIds (GUIDReference)
                                  SELECT DISTINCT ind.GUIDReference
                                  FROM Individual ind
                                  INNER JOIN Candidate c ON c.GUIDReference = ind.GUIDReference
                                  INNER JOIN CollectiveMembership cm ON cm.Individual_Id=ind.GUIDReference
                                  WHERE c.Country_Id = @Country
                                         AND (
                                                @LocalBusinessId <> ''
                                                AND ind.IndividualId LIKE @LocalBusinessId
                                                )
                           END                  
                     END
              ELSE
                     BEGIN
                           SET @LocalBusinessId = CONCAT (
                                         @BusinessId
                                         ,'%'
                                         );

                           INSERT #FilteredIds (GUIDReference)
                           SELECT DISTINCT ind.GUIDReference
                           FROM Individual ind
                           INNER JOIN Candidate c ON c.GUIDReference = ind.GUIDReference
                           INNER JOIN CollectiveMembership cm ON cm.Individual_Id=ind.GUIDReference
                           WHERE c.Country_Id = @Country
                                  AND (
                                         @LocalBusinessId <> ''
                                         AND ind.IndividualId LIKE @LocalBusinessId
                                         )
                     END
       END
       ELSE IF (@Name <> '')
       BEGIN
              DECLARE @Name1 NVARCHAR(50)
                     ,@Name2 NVARCHAR(50)
                     ,@Name3 NVARCHAR(50)
              DECLARE @NameCount INT

              SET @Name = LTRIM(RTRIM(@Name))
              SET @Name = (
                           SELECT dbo.replacedoublespacewithSingle(@Name)
                           )
              SET @NameCount = (
                           SELECT COUNT(0)
                           FROM dbo.Split(@Name, ' ')
                           )

              IF (@NameCount >= 1)
                     SET @Name1 = (
                                  SELECT items
                                  FROM dbo.Split(@Name, ' ')
                                  WHERE Id = 1
                                  )

              IF (@NameCount >= 2)
                     SET @Name2 = (
                                  SELECT items
                                  FROM dbo.Split(@Name, ' ')
                                  WHERE Id = 2
                                  )

              IF (@NameCount = 3)
                     SET @Name3 = (
                                  SELECT items
                                  FROM dbo.Split(@Name, ' ')
                                  WHERE Id = 3
                                  )

              IF (@NameCount > 3) --If name having morethan 3 names like 'Test user kantar account' then name3 we are taking as 'kantaraccount'  
                     SET @Name3 = (
                                  SELECT *
                                  FROM (
                                         SELECT items + ''
                                         FROM dbo.Split(@Name, ' ')
                                         WHERE Id > 2
                                         FOR XML PATH('')
                                         ) X(C)
                                  )
              SET @Name1 = ISNULL(@Name1, @Name)
              SET @Name2 = ISNULL(@Name2, @Name1)
              SET @Name3 = ISNULL(@Name3, @Name1)

              INSERT #FilteredIds (GUIDReference)
              SELECT DISTINCT ind.GUIDReference
              FROM Individual ind
              INNER JOIN Candidate c ON c.GUIDReference = ind.GUIDReference
              INNER JOIN PersonalIdentification pid ON ind.PersonalIdentificationId = pid.PersonalIdentificationId
              INNER JOIN CollectiveMembership cm ON cm.Individual_Id=ind.GUIDReference
              WHERE c.Country_Id = @Country
                     AND (
                           (
                                  pid.LastOrderedName LIKE '%' + @name1 + '%'
                                  OR pid.MiddleOrderedName LIKE '%' + @name1 + '%'
                                  OR pid.FirstOrderedName LIKE '%' + @name1 + '%'
                                  )
                           OR (
                                  @name2 IS NULL
                                  OR pid.LastOrderedName LIKE '%' + @name2 + '%'
                                  OR pid.MiddleOrderedName LIKE '%' + @name2 + '%'
                                  OR pid.FirstOrderedName LIKE '%' + @name2 + '%'
                                  )
                           OR (
                                  @name3 IS NULL
                                  OR pid.LastOrderedName LIKE '%' + @name3 + '%'
                                  OR pid.MiddleOrderedName LIKE '%' + @name3 + '%'
                                  OR pid.FirstOrderedName LIKE '%' + @name3 + '%'
                                  )
                           )
       END
       ELSE IF (@Email <> '')
       BEGIN
              DECLARE @LocalEmail NVARCHAR(50) = CONCAT (
                           @Email
                           ,'%'
                           );

              INSERT #FilteredIds (GUIDReference)
              SELECT DISTINCT ind.GUIDReference
              FROM Individual ind
              INNER JOIN Candidate c ON c.GUIDReference = ind.GUIDReference
              INNER JOIN CollectiveMembership cm ON cm.Individual_Id=ind.GUIDReference
              INNER JOIN OrderedContactMechanism OCM ON OCM.Candidate_Id=c.GUIDReference
              INNER JOIN [Address] ad ON ad.GUIDReference = OCM.Address_Id
                     AND ad.AddressType = 'ElectronicAddress'
              WHERE c.Country_Id = @Country
                     AND (
                           @LocalEmail IS NULL
                           OR ad.AddressLine1 LIKE @LocalEmail
                           )
       END
       ELSE IF (@Phone <> '')
       BEGIN
              DECLARE @LocalPhone NVARCHAR(50) = CONCAT (
                           @Phone
                           ,'%'
                           );

              INSERT #FilteredIds (GUIDReference)
              SELECT DISTINCT ind.GUIDReference
              FROM Individual ind
              INNER JOIN Candidate c ON c.GUIDReference = ind.GUIDReference
              INNER JOIN CollectiveMembership cm ON cm.Individual_Id=ind.GUIDReference
              Inner Join OrderedContactMechanism oc on oc.Candidate_Id=c.GUIDReference
              INNER JOIN [Address] ad ON ad.GUIDReference = oc.Address_Id
                     AND ad.AddressType = 'PhoneAddress'
              WHERE c.Country_Id = @Country
                     AND (
                           @LocalPhone IS NULL
                           OR ad.AddressLine1 LIKE @LocalPhone
                           )
       END
       ELSE IF (@PostCode <> '')
       BEGIN
              DECLARE @LocalPostCode NVARCHAR(50) = CONCAT (
                           @PostCode
                           ,'%'
                           );

              INSERT #FilteredIds (GUIDReference)
              SELECT DISTINCT ind.GUIDReference
              FROM Individual ind
              INNER JOIN Candidate c ON c.GUIDReference = ind.GUIDReference
              INNER JOIN CollectiveMembership cm ON cm.Individual_Id=ind.GUIDReference
              INNER JOIN OrderedContactMechanism OCM ON OCM.Candidate_Id=c.GUIDReference
              INNER JOIN [Address] ad ON ad.GUIDReference = OCM.Address_Id
                     AND ad.AddressType = 'PostalAddress'
              WHERE c.Country_Id = @Country
                     AND (
                           @LocalPostCode IS NULL
                           OR ad.PostCode LIKE @LocalPostCode
                           )
       END
       ELSE IF (@Address <> '')
       BEGIN
              DECLARE @LocalAddress NVARCHAR(50) = CONCAT (
                           '%'
                           ,@Address
                           ,'%'
                           );

              INSERT #FilteredIds (GUIDReference)
              SELECT DISTINCT ind.GUIDReference
              FROM Individual ind
              INNER JOIN Candidate c ON c.GUIDReference = ind.GUIDReference
              INNER JOIN OrderedContactMechanism OCM ON OCM.Candidate_Id=c.GUIDReference
              INNER JOIN [Address] ad ON ad.GUIDReference = OCM.Address_Id
                     AND ad.AddressType = 'PostalAddress'
              WHERE c.Country_Id = @Country
                     AND (
                           @LocalAddress IS NULL
                           OR ad.AddressLine1 LIKE @LocalAddress
                           )
       END
       ELSE IF(@Alias <> '')
       BEGIN
    DECLARE @LocalAlias NVARCHAR(50) = CONCAT (
                           '%'
                           ,@Alias
                           ,'%'
                           );

              INSERT #FilteredIds (GUIDReference)
              SELECT    DISTINCT
                 dbo.Individual.Guidreference FROM         
           dbo.Individual INNER JOIN
           dbo.Candidate CAN ON dbo.Individual.GUIDReference = CAN.GUIDReference INNER JOIN
           dbo.Country ON CAN.Country_ID = dbo.Country.CountryId    
                 inner JOIN dbo.NamedAlias as NA on NA.Candidate_Id = CAN.GUIDReference
                 inner JOIN dbo.NamedAliasContext as NAC on NA.AliasContext_Id = NAC.NamedAliasContextId
                 
              WHERE Country.CountryId = @Country
                     AND (
                           @LocalAlias IS NULL
                           OR NA.[KEY] LIKE @LocalAlias
                           )
       END

       IF (@OperatorBusinessId IS NOT NULL)
       BEGIN
              DELETE ids
              FROM #FilteredIds ids
              INNER JOIN Individual ind ON ind.GUIDReference = ids.GUIDReference
              WHERE NOT (
                           (
                                  @OperatorBusinessId = @IsEqualTo
                                  AND ind.IndividualId = @FilterBusinessId
                                  )
                           OR (
                                  @OperatorBusinessId = @Contains
                                  AND ind.IndividualId LIKE '%' + @FilterBusinessId + '%'
                                  )
                           OR (
                                  @OperatorBusinessId = @DoesNotContain
                                  AND ind.IndividualId NOT LIKE '%' + @FilterBusinessId + '%'
                                  )
                           OR (
                                  @OperatorBusinessId = @StartsWith
                                  AND ind.IndividualId LIKE @FilterBusinessId + '%'
                                  )
                           OR (
                                  @OperatorBusinessId = @EndsWith
                                  AND ind.IndividualId LIKE '%' + @FilterBusinessId
                                  )
                           )

              DELETE
              FROM @FilterLocal
              WHERE ParameterName = 'BusinessId';
       END

       IF (@OperatorEmail IS NOT NULL)
       BEGIN
              DELETE ids
              FROM #FilteredIds ids
              INNER JOIN Individual ind ON ind.GUIDReference = ids.GUIDReference
              LEFT JOIN [Address] ad ON ad.GUIDReference = ind.MainEmailAddress_Id
                     AND ad.AddressType = 'ElectronicAddress'
              WHERE NOT (
                           (
                                  @OperatorEmail = @IsEqualTo
                                  AND ISNULL(ad.AddressLine1, '') = @FilterEmail
                                  )
                           OR (
                                  @OperatorEmail = @Contains
                                  AND ISNULL(ad.AddressLine1, '') LIKE '%' + @FilterEmail + '%'
                                  )
                           OR (
                                  @OperatorEmail = @DoesNotContain
                                  AND ISNULL(ad.AddressLine1, '') NOT LIKE '%' + @FilterEmail + '%'
                                  )
                           OR (
                                  @OperatorEmail = @StartsWith
                                  AND ISNULL(ad.AddressLine1, '') LIKE @FilterEmail + '%'
                                  )
                           OR (
                                  @OperatorEmail = @EndsWith
                                  AND ISNULL(ad.AddressLine1, '') LIKE '%' + @FilterEmail
                                  )
                           )

              DELETE
              FROM @FilterLocal
              WHERE ParameterName = 'Email';
       END

       IF (@OperatorPhone IS NOT NULL)
       BEGIN
              DELETE ids
              FROM #FilteredIds ids
              INNER JOIN Individual ind ON ind.GUIDReference = ids.GUIDReference
              LEFT JOIN [Address] ad ON ad.GUIDReference = ind.MainPhoneAddress_Id
                     AND ad.AddressType = 'PhoneAddress'
              WHERE NOT (
                           (
                                  @OperatorPhone = @IsEqualTo
                                  AND ISNULL(ad.AddressLine1, '') = @FilterPhone
                                  )
                           OR (
                                  @OperatorPhone = @Contains
                                  AND ISNULL(ad.AddressLine1, '') LIKE '%' + @FilterPhone + '%'
                                  )
                           OR (
                                  @OperatorPhone = @DoesNotContain
                                  AND ISNULL(ad.AddressLine1, '') NOT LIKE '%' + @FilterPhone + '%'
                                  )
                           OR (
                                  @OperatorPhone = @StartsWith
                                  AND ISNULL(ad.AddressLine1, '') LIKE @FilterPhone + '%'
                                  )
                           OR (
                                  @OperatorPhone = @EndsWith
                                  AND ISNULL(ad.AddressLine1, '') LIKE '%' + @FilterPhone
                                  )
                           )

              DELETE
              FROM @FilterLocal
              WHERE ParameterName = 'Phone';
       END

       IF (@OperatorGeographicArea IS NOT NULL)
       BEGIN
              DELETE ids
              FROM #FilteredIds ids
              INNER JOIN Candidate can ON ids.GUIDReference = can.GUIDReference
              LEFT JOIN GeographicArea ga ON ga.GUIDReference = can.GeographicArea_Id
              WHERE NOT (
                           (
                                  @OperatorGeographicArea = @IsEqualTo
                                  AND ga.Code = @FilterGeographicArea
                                  )
                           OR (
                                  @OperatorGeographicArea = @Contains
                                  AND ga.Code LIKE '%' + @FilterGeographicArea + '%'
                                  )
                           OR (
                                  @OperatorGeographicArea = @DoesNotContain
                                  AND ga.Code NOT LIKE '%' + @FilterGeographicArea + '%'
                                  )
                           OR (
                                  @OperatorGeographicArea = @StartsWith
                                  AND ga.Code LIKE @FilterGeographicArea + '%'
                                  )
                           OR (
                                  @OperatorGeographicArea = @EndsWith
                                  AND ga.Code LIKE '%' + @FilterGeographicArea
                                  )
                           )

              DELETE
              FROM @FilterLocal
              WHERE ParameterName = 'GeographicArea';
       END

       IF (@OperatorGroupContact IS NOT NULL)
       BEGIN
              IF (@FilterGroupContact = 'False')
              BEGIN
                     SET @FilterGroupContact = 0
              END
              ELSE
                     SET @FilterGroupContact = 1

              DELETE ids
              FROM #FilteredIds ids
              INNER JOIN CollectiveMembership cm ON cm.Individual_Id = ids.GUIDReference
              INNER JOIN Collective c ON c.GUIDReference = cm.Group_Id
              WHERE NOT (
                           (
                                  @OperatorGroupContact = @IsEqualTo
                                  AND IIF(c.GroupContact_Id = ids.GUIDReference, 1, 0) = @FilterGroupContact
                                  )
                           OR (
                                  @OperatorGroupContact = @Contains
                                  AND IIF(c.GroupContact_Id = ids.GUIDReference, 1, 0) LIKE '%' + @FilterGroupContact + '%'
                                  )
                           OR (
                                  @OperatorGroupContact = @DoesNotContain
                                  AND IIF(c.GroupContact_Id = ids.GUIDReference, 1, 0) NOT LIKE '%' + @FilterGroupContact + '%'
                                  )
                           OR (
                                  @OperatorGroupContact = @StartsWith
                                  AND IIF(c.GroupContact_Id = ids.GUIDReference, 1, 0) LIKE @FilterGroupContact + '%'
                                  )
                           OR (
                                  @OperatorGroupContact = @EndsWith
                                  AND IIF(c.GroupContact_Id = ids.GUIDReference, 1, 0) LIKE '%' + @FilterGroupContact
                                  )
                           )

              DELETE
              FROM @FilterLocal
              WHERE ParameterName = 'GroupContact';
       END

       IF (@OperatorName IS NOT NULL)
       BEGIN
              DELETE ids
              FROM #FilteredIds ids
              INNER JOIN Individual ind ON ids.GUIDReference = ind.GUIDReference
              INNER JOIN PersonalIdentification pid ON ind.PersonalIdentificationId = pid.PersonalIdentificationId
              WHERE NOT (
                           (
                                  @OperatorName = @IsEqualTo
                                  AND CONCAT (
                                         pid.FirstOrderedName
                                         ,' '
                                         ,pid.LastOrderedName
                                         ) = @FilterName
                                  )
                           OR (
                                  @OperatorName = @Contains
                                  AND CONCAT (
                                         pid.FirstOrderedName
                                         ,' '
                                         ,pid.LastOrderedName
                                         ) LIKE '%' + @FilterName + '%'
                                  )
                           OR (
                                  @OperatorName = @DoesNotContain
                                  AND CONCAT (
                                         pid.FirstOrderedName
                                         ,' '
                                         ,pid.LastOrderedName
                                         ) NOT LIKE '%' + @FilterName + '%'
                                  )
                           OR (
                                  @OperatorName = @StartsWith
                                  AND CONCAT (
                                         pid.FirstOrderedName
                                         ,' '
                                         ,pid.LastOrderedName
                                         ) LIKE @FilterName + '%'
                                  )
                           OR (
                                  @OperatorName = @EndsWith
                                  AND CONCAT (
                                         pid.FirstOrderedName
                                         ,' '
                                         ,pid.LastOrderedName
                                         ) LIKE '%' + @FilterName
                                  )
                           )

              DELETE
              FROM @FilterLocal
              WHERE ParameterName = 'Name';
       END

  

	   IF (@OperatorAlias IS NOT NULL)
       BEGIN
	   CREATE TABLE #AliasFilteredIds (GUIDReference UNIQUEIDENTIFIER PRIMARY KEY (GUIDReference))
	   Insert #AliasFilteredIds (GUIDReference) 
             SELECT DISTINCT NA.Candidate_Id as GUIDReference
              FROM  #FilteredIds ids
              Inner JOIN dbo.NamedAlias as NA on NA.Candidate_Id = ids.GUIDReference
              WHERE   NA.Candidate_Id  in  (
						SELECT  NA2.Candidate_Id 
						FROM  #FilteredIds ids2
						Inner JOIN dbo.NamedAlias as NA2 on NA2.Candidate_Id = ids2.GUIDReference
                        ) AND   
						(
                           (
                                  @OperatorAlias = @IsEqualTo
								  AND ISNULL(NA.[KEY], '') =@FilterAlias
                                  
                                  )
                           OR (
                                  @OperatorAlias = @Contains
                                 AND ISNULL(NA.[KEY], '') LIKE '%' + @FilterAlias + '%'
                                  )
                           OR (
                                  @OperatorAlias = @DoesNotContain
                                  AND ISNULL(NA.[KEY], '') NOT LIKE '%' + @FilterAlias + '%'
                                  )
                           OR (
                                  @OperatorAlias = @StartsWith
                                  AND ISNULL(NA.[KEY], '') LIKE @FilterAlias + '%'
                                  )
                           OR (
                                  @OperatorAlias = @EndsWith
                                  AND ISNULL(NA.[KEY], '') LIKE '%' + @FilterAlias
                                  )
                           )

              DELETE
              FROM @FilterLocal
              WHERE ParameterName = 'Alias';

			  Delete from #FilteredIds
			  insert #FilteredIds (GUIDReference) 
			  SELECT GUIDReference FROM #AliasFilteredIds

			  Drop Table #AliasFilteredIds
       END

       IF (
                     (
                           SELECT COUNT(1)
                           FROM #FilteredIds
                           ) <= 1 AND (@isPanelist=0) AND (ISNULL(@OrigBusinessId,'')= '' AND ISNULL(@OrigEmail,'') = '' AND ISNULL(@OrigPhone,'') = '' AND ISNULL(@OrigPostCode,'')=''
                     AND ISNULL(@OrigAddress,'')= '' AND ISNULL(@OrigName,'')= '')
                     )
       BEGIN
              -- ONLY 1 ROW; THEN JUST RETURN THE ID TO FETCH THE INDIVIDUAL PAGE    
              IF (@IsExport = 0)
                     SELECT COUNT(1) AS TotalRows
                     FROM #FilteredIds

              SELECT i.IndividualId AS BusinessId
                     ,i.GUIDReference AS Id
              FROM #FilteredIds ind
              INNER JOIN Individual i ON i.GUIDReference = ind.GUIDReference
       END
       ELSE
       BEGIN
              -- MORE THAN 1 ROW; JOIN WITH THE DETAILS TO GET THE FILL THE GRID  
              IF OBJECT_ID('tempdb..#TempResult') IS NOT NULL
                     TRUNCATE TABLE #TempResult

              IF OBJECT_ID('tempdb..#FilteredIdsTrimmed') IS NOT NULL
                     TRUNCATE TABLE #FilteredIdsTrimmed
              ELSE
                     CREATE TABLE #FilteredIdsTrimmed (
                           GUIDReference UNIQUEIDENTIFIER PRIMARY KEY (GUIDReference)
                           ,GPSUpdateTimestamp DATETIME
                           )

              IF (
                           (
                                  SELECT COUNT(1)
                                  FROM @FilterLocal
                                  ) > 0
                           )
              BEGIN
                     INSERT INTO #FilteredIdsTrimmed (GUIDReference)
                     SELECT *
                     FROM #FilteredIds ids
					
              END
              ELSE
              BEGIN
			
                     INSERT INTO #FilteredIdsTrimmed
                     SELECT ids.*
                           ,GPSUpdateTimestamp
                     FROM #FilteredIds ids
                     INNER JOIN Candidate can ON can.GUIDReference = ids.GUIDReference
                     ORDER BY GPSUpdateTimestamp ASC
					
					 OFFSET @OFFSETRows ROWS
                     FETCH NEXT @PageSize ROWS ONLY

                    SET @OFFSETRows = 0;
              END

              SELECT indInfo.*
              INTO #TempResult
              FROM #FilteredIdsTrimmed _ind
              CROSS APPLY ufnGetIndividualSearchInformation(_ind.GUIDReference, @Country, @CultureCode) AS indInfo

              IF (@IsExport = 0)
                     SELECT COUNT(0) AS TotalRows
                     FROM #FilteredIds



              SELECT *
              FROM #TempResult				   
              ORDER BY CASE 
                           WHEN @OrderType = 'ASC'
                                  AND @OrderBy = 'BusinessId'
                                  THEN BusinessId
                           END ASC
                     ,CASE 
                           WHEN @OrderType = 'DESC'
                                  AND @OrderBy = 'BusinessId'
                                  THEN BusinessId
                           END DESC
                     ,CASE 
                           WHEN @OrderType = 'ASC'
                                  AND @OrderBy = 'Name'
                                  THEN Name
                           END ASC
                     ,CASE 
                           WHEN @OrderType = 'DESC'
                                  AND @OrderBy = 'Name'
                                  THEN Name
                           END DESC
                     ,CASE 
                           WHEN @OrderType = 'ASC'
                                  AND @OrderBy = 'Phone'
                                  THEN Phone
                           END ASC
                     ,CASE 
                           WHEN @OrderType = 'DESC'
                                  AND @OrderBy = 'Phone'
                                  THEN Phone
                           END DESC
                     ,CASE 
                           WHEN @OrderType = 'ASC'
                                  AND @OrderBy = 'GeographicArea'
                                  THEN GeographicArea
                           END ASC
                     ,CASE 
                           WHEN @OrderType = 'DESC'
                                  AND @OrderBy = 'GeographicArea'
                                  THEN GeographicArea
                           END DESC
                     ,CASE 
                           WHEN @OrderType = 'ASC'
                                  AND @OrderBy = 'Email'
                                  THEN EmailAddress
                           END ASC
                     ,CASE 
                           WHEN @OrderType = 'DESC'
                                  AND @OrderBy = 'Email'
                                  THEN EmailAddress
                           END DESC
                     ,CASE 
                           WHEN @OrderType = 'ASC'
                                  AND @OrderBy = 'GroupContact'
                                  THEN GroupContact
                           END ASC
                     ,CASE 
                           WHEN @OrderType = 'DESC'
                                  AND @OrderBy = 'GroupContact'
                                  THEN GroupContact
                           END DESC
                     ,CASE 
                           WHEN @OrderType = 'ASC'
                                  AND @OrderBy = 'Alias'
                                  THEN Alias
                           END ASC
                     ,CASE 
                           WHEN @OrderType = 'DESC'
                                  AND @OrderBy = 'Alias'
                                  THEN Alias
                           END DESC
                     ,CASE 
                           WHEN @OrderType = 'ASC'
                                  AND @OrderBy = ''
                                  THEN GPSUpdateTimestamp
                           END ASC
                     ,CASE 
                           WHEN @OrderType = 'DESC'
                                  AND @OrderBy = ''
                                  THEN GPSUpdateTimestamp
                           END DESC

	
			   OFFSET @OFFSETRows ROWS

              FETCH NEXT @PageSize ROWS ONLY
			  OPTION (RECOMPILE)
       END
END




