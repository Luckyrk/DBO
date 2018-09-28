/**************************************************************
Created By    :      Satish
Created On    :      8-Aug-2016
Reason        :      [PBI-41292] - Insert/update demographics in Belongings using Business Rules (bug 41228).


***************************************************************/

GO

CREATE PROCEDURE [dbo].[UpdateBelongingAtrribute] 
          @pBusinessId VARCHAR(100)
		 ,@pBelongingType VARCHAR(100)
         ,@pBelongingCode VARCHAR(100)
         ,@pAttributeKey VARCHAR(100)
         ,@pAttributeValue VARCHAR(100)
         ,@pCountryCode VARCHAR(10)
         ,@pCultureCode INT = 2057
AS
BEGIN

       SET NOCOUNT ON

       BEGIN TRY

              SET XACT_ABORT ON
              BEGIN TRANSACTION

              DECLARE @Type                            VARCHAR(100) = ''
              DECLARE @GPSUser                         VARCHAR(100) = ''
              DECLARE @BlgType                         VARCHAR(100) = ''
              DECLARE @ValueDesc                       VARCHAR(100) = ''
              DECLARE @Discriminator                   VARCHAR(100) =''
              DECLARE @BelongingTranslationID UNIQUEIDENTIFIER = NULL;
              DECLARE @StateID                         UNIQUEIDENTIFIER = NULL;
              DECLARE @BelongingTypeId          UNIQUEIDENTIFIER = NULL;
              DECLARE @BelongingCodeId          UNIQUEIDENTIFIER = NULL;
              DECLARE @CountryID                       UNIQUEIDENTIFIER = NULL;
              DECLARE @AttributeId              UNIQUEIDENTIFIER = NULL;
              DECLARE @AttributeValueId         UNIQUEIDENTIFIER = NULL;
              DECLARE @EnumId                                 UNIQUEIDENTIFIER = NULL;
              DECLARE @CandidateId              UNIQUEIDENTIFIER = NULL;

              
              DECLARE @GetDate DATETIME
              SET @GetDate = (select dbo.GetLocalDateTime(GETDATE(),@pCountryCode))

              SELECT TOP 1 @CountryID =  CountryId FROM Country WHERE CountryISO2A = @pCountryCode       
              IF @CountryID IS NOT NULL 
              BEGIN
                     SELECT TOP 1 @BelongingTranslationID = Translation_Id FROM TRANSLATIONTERM WHERE VALUE = @pBelongingType AND CultureCode = @pCultureCode
                     IF @BelongingTranslationID IS NOT NULL   
                     BEGIN
                           SELECT TOP 1 @BelongingTypeId = Id FROM belongingType WHERE Translation_id = @BelongingTranslationID
                           SELECT TOP 1 @Type = [Type] FROM belongingType WHERE Translation_id = @BelongingTranslationID
                           IF @BelongingTypeId IS NOT NULL   
                           BEGIN
                                  
                                  IF LOWER(@Type) = LOWER('groupbelongingtype' )
                                  BEGIN
                                         SET @BlgType = 'GroupBelonging'                        
                                         SELECT TOP 1 @CandidateId = CM.Group_Id  FROM Collective C INNER JOIN Collectivemembership CM ON C.Guidreference = CM.Group_Id 
                                                INNER JOIN INDIVIDUAL I ON I.Guidreference = CM.Individual_Id 
                                                WHERE I.IndividualId = @pBusinessId
                                  END
                                  ELSE
                                  BEGIN
                                         SET @BlgType ='IndividualBelonging'
                                         SELECT TOP 1 @CandidateId = Guidreference FROM Individual WHERE IndividualId = @pBusinessId AND CountryId = @CountryID
                                  END


                                  IF LTRIM(RTRIM(@pBelongingCode)) != ''
                                  BEGIN
                                         SELECT TOP 1 @BelongingCodeId = Guidreference FROM belonging WHERE BelongingCode = @pBelongingCode AND TypeId = @BelongingTypeId AND CandidateId= @CandidateId
                                         IF @BelongingCodeId IS NULL 
                                         BEGIN                                    
                                                DECLARE @BelongingCodeError VARCHAR(MAX) = 'Belonging Code is not found : ' + CONVERT(VARCHAR(50), @pBelongingCode);
                                                RAISERROR (@BelongingCodeError, 16, 1);
                                         END
                                  END
                                  
                                  IF LTRIM(RTRIM(@pAttributeKey)) != ''
                                  BEGIN
                                         SELECT TOP 1 @AttributeId = Guidreference,@Discriminator = [Type] FROM Attribute WHERE [Key] = @pAttributeKey AND Country_id = @CountryID

                                         DECLARE @FromValue VARCHAR(MAX) = ''
                                         DECLARE @ToValue VARCHAR(MAX) = ''

						IF LEN(LTRIM(RTRIM( @pAttributeValue ))) > 0 
						BEGIN

                                         IF LOWER(@Discriminator) = 'int'
                                         BEGIN
                                                
                                                DECLARE @IntValidation VARCHAR(MAX) = ''
                                                IF CONVERT(INT, ISNUMERIC(@pAttributeValue)) = 0
                                                BEGIN
                                                       SET @IntValidation = 'Enter only Numric Value ' + CONVERT(VARCHAR(50), @pAttributeValue) ;
                                                       RAISERROR (@IntValidation, 16, 1);
                                                END

                                                SELECT TOP 1 @FromValue = [From], @ToValue = [To]  FROM Attribute WHERE [Key] = @pAttributeKey AND Country_id = @CountryID

                                                IF (FLOOR(@pAttributeValue) < FLOOR(ISNULL(@FromValue,0)))
                                                BEGIN
                                                       SET @IntValidation = 'Value of Attributte ' + CONVERT(VARCHAR(50), @pAttributeValue) + ' Is Smaller than From limit of ' + CONVERT(VARCHAR(50), @FromValue) ; 
                                                       RAISERROR (@IntValidation, 16, 1);
                                                END
                                                ELSE IF (FLOOR(@pAttributeValue) > FLOOR(ISNULL(@ToValue,0) ))
                                                BEGIN
                                                       SET @IntValidation = 'Value of Attributte ' + CONVERT(VARCHAR(50), @pAttributeValue) + ' Is Greater than To limit of ' + CONVERT(VARCHAR(50), @ToValue) ;   
                                                       RAISERROR (@IntValidation, 16, 1);
                                                END
                                                
                                                
                                         END
                                         IF LOWER(@Discriminator) = 'date'
                                         BEGIN
                                                
                                                DECLARE @Today VARCHAR(10) = '0';
                                                DECLARE @DateValidation VARCHAR(MAX) = ''
                                                IF CONVERT(INT, ISDATE(@pAttributeValue)) = 0
                                                BEGIN
                                                       SET @DateValidation = 'Enter only Date ' + CONVERT(VARCHAR(50), @pAttributeValue) ;
                                                       RAISERROR (@DateValidation, 16, 1);
                                                END

                                                SELECT TOP 1 @FromValue = DateFrom, @ToValue = DateTo ,@Today = Today FROM Attribute WHERE [Key] = @pAttributeKey AND Country_id = @CountryID

                                                IF  ((@Today = '1') AND (CONVERT(DATETIME,CONVERT(VARCHAR(10),@pAttributeValue,111)) > CONVERT(DATETIME,CONVERT(VARCHAR(10),@GetDate,111))))
                                                BEGIN
                                                       SET @DateValidation = 'Value of Attributte ' + CONVERT(VARCHAR(50), @pAttributeValue) + ' Is Greater than Today ' ; 
                                                       RAISERROR (@DateValidation, 16, 1);
                                                END
                                                
                                                IF (CONVERT(DATETIME, @pAttributeValue ) < CONVERT(DATETIME, @FromValue))
                                                BEGIN
                                                       SET @DateValidation = 'Value of Attributte ' + CONVERT(VARCHAR(50), @pAttributeValue) + ' Is Smaller than From limit of ' + CONVERT(VARCHAR(50), @FromValue) ; 
                                                       RAISERROR (@DateValidation, 16, 1);
                                                END
                                                ELSE IF ((@ToValue IS NOT NULL) AND (CONVERT(DATETIME, @pAttributeValue ) > CONVERT(DATETIME, @ToValue)))
                                                BEGIN
                                                       SET @DateValidation = 'Value of Attributte ' + CONVERT(VARCHAR(50), @pAttributeValue) + ' Is Greater than To limit of  ' + CONVERT(VARCHAR(50), @ToValue) ;
                                                       RAISERROR (@DateValidation, 16, 1);
                                                END

                                         END
                                         IF LOWER(@Discriminator) = 'boolean'
                                         BEGIN
                                                DECLARE @BooleanValidation VARCHAR(MAX) = 'Enter Valid Boolean Value : ' + CONVERT(VARCHAR(50), @pAttributeValue);

                                                IF (LTRIM(RTRIM(@pAttributeValue)) != '0' AND LTRIM(RTRIM(@pAttributeValue)) != '1' AND LOWER(LTRIM(RTRIM(@pAttributeValue))) != 'yes' AND
                                                       LOWER(LTRIM(RTRIM(@pAttributeValue))) != 'no' AND LOWER(LTRIM(RTRIM(@pAttributeValue))) != 'true' AND LOWER(LTRIM(RTRIM(@pAttributeValue))) != 'false')
                                                BEGIN
                                                       RAISERROR (@BooleanValidation, 16, 1);
                                                END
                                                IF LOWER(LTRIM(RTRIM(@pAttributeValue))) = 'yes'
                                                BEGIN
                                                       SET @pAttributeValue = '1'
                                                END
                                                IF LOWER(LTRIM(RTRIM(@pAttributeValue))) = 'no'
                                                BEGIN
                                                       SET @pAttributeValue = '0'
                                                END
                                                IF LOWER(LTRIM(RTRIM(@pAttributeValue))) = 'true'
                                                BEGIN
                                                       SET @pAttributeValue = '1'
                                                END
                                                IF LOWER(LTRIM(RTRIM(@pAttributeValue))) = 'false'
                                                BEGIN
                                                       SET @pAttributeValue = '0'
                                                END
                                         END
                                         
                                         IF LOWER(@Discriminator) = 'float'
                                         BEGIN
                                                DECLARE @FloatValidation VARCHAR(MAX) = ''
                                                IF CONVERT(INT, ISNUMERIC (@pAttributeValue)) = 0
                                                BEGIN
                                                       SET @FloatValidation = 'Enter only Numric Value ' + CONVERT(VARCHAR(50), @pAttributeValue) ;
                                                       RAISERROR (@FloatValidation, 16, 1);
                                                END

                                                SELECT TOP 1 @FromValue = [From], @ToValue = [To]  FROM Attribute WHERE [Key] = @pAttributeKey AND Country_id = @CountryID
                                                
                                                IF (CONVERT(FLOAT, @pAttributeValue ) < CONVERT(FLOAT, ISNULL(@FromValue,0)))
                                                BEGIN
                                                       SET @FloatValidation = 'Value of Attributte ' + CONVERT(VARCHAR(50), @pAttributeValue) + ' Is Smaller than From limit of ' + CONVERT(VARCHAR(50), @FromValue) ; 
                                                       RAISERROR (@FloatValidation, 16, 1);
                                                END
                                                ELSE IF  (CONVERT(FLOAT, @pAttributeValue ) > CONVERT(FLOAT, ISNULL(@ToValue,0) ))
                                                BEGIN
                                                       SET @FloatValidation = 'Value of Attributte ' + CONVERT(VARCHAR(50), @pAttributeValue) + ' Is Greater than To limit of ' + CONVERT(VARCHAR(50), @ToValue) ;   
                                                       RAISERROR (@FloatValidation, 16, 1);
                                                END

                                         END
                                         IF LOWER(@Discriminator) = 'string'
                                         BEGIN                                    
                                                DECLARE @StringValidation VARCHAR(MAX) = ''

                                                SELECT TOP 1 @FromValue = MinLength, @ToValue = [MaxLength]  FROM Attribute WHERE [Key] = @pAttributeKey AND Country_id = @CountryID
                                                
                                                IF (CONVERT(INT,LEN(@pAttributeValue) ) < CONVERT(INT, ISNULL(@FromValue,0)))
                                                BEGIN
                                                       SET @StringValidation = 'Length of Attributte ' + CONVERT(VARCHAR(50), @pAttributeValue) + ' Is Smaller than From limit of ' + CONVERT(VARCHAR(50), @FromValue) ; 
                                                       RAISERROR (@StringValidation, 16, 1);
                                                END
                                                ELSE IF  (CONVERT(INT, LEN(@pAttributeValue) ) > CONVERT(INT, ISNULL(@ToValue,0) ))
                                                BEGIN
                                                       SET @StringValidation = 'Length of Attributte ' + CONVERT(VARCHAR(50), @pAttributeValue) + ' Is Greater than To limit of ' + CONVERT(VARCHAR(50), @ToValue) ;   
                                                       RAISERROR (@StringValidation, 16, 1);
                                                END
                                         END

                                         IF LOWER(@Discriminator) = 'enum'
                                         BEGIN
                                                SELECT TOP 1 @EnumId = Id,@ValueDesc = T.Value FROM EnumDefinition E INNER JOIN TranslationTerm T 
                                                ON E.Translation_Id = T.Translation_Id WHERE E.VALUE = @pAttributeValue AND E.Demographic_Id = @AttributeId 
                                                AND T.CultureCode = @pCultureCode

												  IF @EnumId IS NULL 
												BEGIN
													DECLARE @EnumValidation VARCHAR(MAX) = ''
													SET @EnumValidation = CONVERT(VARCHAR(100), 'Enter only Valid Enum Value ') + CONVERT(VARCHAR(50), @pAttributeValue);
													RAISERROR (@EnumValidation, 16, 1);
												END
                                         END

                        END       

                                         SET @Discriminator = @Discriminator + 'AttributeValue'

                                         IF @AttributeId IS NOT NULL 
                                         BEGIN
                                                
                                                SELECT TOP 1 @StateID = Id FROM Statedefinition WHERE Code = 'BelongingActive' AND Country_Id = @CountryID

                                                IF NOT EXISTS (SELECT 1 FROM attributeconfiguration WHERE BelongingTypeId = @BelongingTypeId AND AttributeId = @AttributeId )
                                                BEGIN
                                                       DECLARE @AttributeKeyError VARCHAR(MAX) = 'Attribute Key is not found to that Belonging : ' + CONVERT(VARCHAR(50), @pAttributeKey);
                                                       RAISERROR (@AttributeKeyError, 16, 1);
                                                END

                                                IF LEN(LTRIM(RTRIM(@pBelongingCode))) = 0 
                                                BEGIN
                                                       DECLARE @BlgCode INT  = 0;
                                                       DECLARE @BlgId UNIQUEIDENTIFIER = NewID();

                                                       INSERT INTO belonging (GUIDReference,CandidateId,TypeId,BelongingCode,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,State_Id,[Type])
                                                       SELECT @BlgId,NULL,@BelongingTypeId,@BlgCode,@GPSUser,@GetDate,@GetDate,@StateID,@BlgType

                                                       INSERT INTO attributeValue (GUIDReference,DemographicId,CandidateId,RespondentId,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Address_Id,
                                                       Value,ValueDesc,Country_Id,[FreeText],Discriminator,EnumDefinition_Id)
                                                       SELECT NEWID(),@AttributeId,@CandidateId,@BlgId,@GPSUser,@GetDate,@GetDate,NULL,@pAttributeValue,@ValueDesc,@CountryID,NULL,@Discriminator,@EnumId

                                                END
                                                ELSE
                                                BEGIN
                                                       IF EXISTS (SELECT 1 FROM attributeValue WHERE RespondentId = @BelongingCodeId AND DemographicId = @AttributeId)
                                                       BEGIN
                                                              UPDATE attributeValue SET Value = @pAttributeValue,ValueDesc=@ValueDesc,EnumDefinition_Id =  @EnumId
                                                              WHERE RespondentId = @BelongingCodeId AND DemographicId = @AttributeId
                                                       END
                                                       ELSE
                                                       BEGIN

                                                              INSERT INTO attributeValue (GUIDReference,DemographicId,CandidateId,RespondentId,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Address_Id,
                                                              Value,ValueDesc,Country_Id,[FreeText],Discriminator,EnumDefinition_Id)
                                                              SELECT NEWID(),@AttributeId,NULL,@BelongingCodeId,@GPSUser,@GetDate,@GetDate,NULL,@pAttributeValue,@ValueDesc,@CountryID,NULL,@Discriminator,@EnumId

                                                       END
                                                END


                                         END
                                         ELSE
                                         BEGIN
                                                DECLARE @AttributeIdError VARCHAR(MAX) = 'Attribute Key is not found : ' + CONVERT(VARCHAR(50), @pAttributeKey);
                                                RAISERROR (@AttributeIdError, 16, 1);
                                         END
                                  END
                                  ELSE
									BEGIN
										DECLARE @AttributeError VARCHAR(MAX) = 'Attribute Key is required ' ;
										RAISERROR (@AttributeError, 16, 1);
					END
                           END
                           ELSE
                           BEGIN
                                  DECLARE @BelongingTypeIdError VARCHAR(MAX) = 'Belonging Type is not found : ' + CONVERT(VARCHAR(50), @pBelongingType);
                                  RAISERROR (@BelongingTypeIdError, 16, 1);
                           END

                     END
                     ELSE
                     BEGIN
                           DECLARE @BelongingTranslationIDError VARCHAR(MAX) = 'Belonging Type is not found : ' + CONVERT(VARCHAR(50), @pBelongingType);
                           RAISERROR (@BelongingTranslationIDError, 16, 1);
                     END
              END    
              ELSE
              BEGIN
                     DECLARE @CountryError VARCHAR(MAX) = 'Country is not found for Country Code  : ' + CONVERT(VARCHAR(50), @pCountryCode);
                     RAISERROR (@CountryError, 16, 1);               
              END

              COMMIT TRANSACTION
              SET XACT_ABORT OFF

       END TRY
       BEGIN CATCH

              DECLARE @ErrorNumber INT = ERROR_NUMBER();
              DECLARE @ErrorLine INT = ERROR_LINE();
              DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
              DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
              DECLARE @ErrorState INT = ERROR_STATE();
              RAISERROR (
                           @ErrorMessage
                           ,@ErrorSeverity
                           ,@ErrorState
                           );
              ROLLBACK TRANSACTION
       END CATCH
  
END

