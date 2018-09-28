CREATE PROCEDURE CreateBelongings
(
  @pBelongingTypeId UNIQUEIDENTIFIER
 ,@pBusinessId NVARCHAR(1000)
 ,@pGpsUser NVARCHAR(500)
 ,@pCountryCode VARCHAR(50)
 ,@pAttributes BelongingDemographicKeyValues readonly
)
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;
BEGIN TRY
	DECLARE @CountryId UNIQUEIDENTIFIER 
	DECLARE @StateDefinitionId UNIQUEIDENTIFIER
	DECLARE @BelongingCode BIGINT
	DECLARE @BelongingID UNIQUEIDENTIFIER
	DECLARE @BelongingSectionID UNIQUEIDENTIFIER
	DECLARE @BelongingType NVARCHAR(500)
	DECLARE @BusinessId UNIQUEIDENTIFIER 
	DECLARE @GetDate DATETIME

	
	SELECT @CountryId=CountryId FROM Country WHERE CountryISO2A=@pCountryCode

	IF CHARINDEX('-', @pBusinessId)=0
	BEGIN
	 SELECT @BusinessId=GUIDReference FROM Collective WHERE Sequence=CAST(@pBusinessId AS BIGINT) AND CountryId=@CountryId
	END
	ELSE
	BEGIN
	 SELECT @BusinessId=GUIDReference FROM Individual WHERE IndividualId=@pBusinessId AND CountryId=@CountryId
	END

	SELECT @StateDefinitionId=Id FROM StateDefinition WHERE code='BelongingActive' AND Country_Id=@CountryId
	SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryId))

	BEGIN TRANSACTION
	BEGIN TRY

		SELECT @BelongingType=[Type] FROM BelongingType WHERE Id=@pBelongingTypeId

		SELECT @BelongingSectionID=Id FROM SortAttribute WHERE BelongingType_Id=@pBelongingTypeId

		IF @BusinessId IS NULL OR NOT EXISTS (SELECT @BusinessId)
			RAISERROR ('Invalid BusinessId', 16, 1);
		
		DECLARE @BelongingDemoErrorMsg NVARCHAR(MAX)

		IF EXISTS (
		SELECT 1
		FROM @pAttributes D 
			LEFT OUTER JOIN Attribute A ON D.[Key]=A.[Key] COLLATE SQL_Latin1_General_CP1_CI_AI AND A.Country_Id=@CountryId 
			WHERE A.[Key] IS NULL)
		BEGIN
		

		SELECT @BelongingDemoErrorMsg=STUFF((
							SELECT ', ' + at.[Key]
							FROM @pAttributes at
							LEFT OUTER JOIN Attribute e ON at.[Key]=e.[Key] COLLATE SQL_Latin1_General_CP1_CI_AI AND e.Country_Id=@CountryId 
							WHERE e.[Key] IS NULL 
							FOR XML PATH('')
							), 1, 2, '')
		SET @BelongingDemoErrorMsg='Invalid attribute keys '+@BelongingDemoErrorMsg
		RAISERROR (@BelongingDemoErrorMsg, 16, 1)

		END

		IF EXISTS (SELECT 1
		FROM @pAttributes D 
		INNER JOIN Attribute A ON D.[Key]=A.[Key] AND A.Country_Id=@CountryId
		LEFT JOIN dbo.EnumDefinition ED ON D.[Value]=ED.Value
		WHERE A.[Type] = 'Enum' AND ED.Value IS NULL )
		BEGIN

			SELECT @BelongingDemoErrorMsg=STUFF((
								SELECT ', ' + D.[Key]
								FROM @pAttributes D 
								INNER JOIN Attribute A ON D.[Key]=A.[Key] AND A.Country_Id=@CountryId
								LEFT JOIN dbo.EnumDefinition ED ON D.[Value]=ED.Value
								WHERE A.[Type] = 'Enum' AND ED.Value IS NULL 
								), 1, 2, '')

			SET @BelongingDemoErrorMsg='Invalid enum attribute values'+@BelongingDemoErrorMsg
			RAISERROR (@BelongingDemoErrorMsg, 16, 1)
		END

		SELECT @BelongingCode=MAX(ISNULL(BelongingCode,0))+1
		FROM Belonging B 
		WHERE B.TypeId=@pBelongingTypeId AND CandidateId=@BusinessId

		IF @BelongingCode IS NULL
		   SET @BelongingCode=1
		
		SET @BelongingID=NEWID()
		INSERT INTO Respondent(GUIDReference,DiscriminatorType,CountryID,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
		SELECT @BelongingID,'Belonging',@CountryId,@pGpsUser,@GetDate,@GetDate

		INSERT INTO Belonging(GUIDReference,CandidateId,TypeId,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,State_Id,BelongingCode,[Type])
		SELECT 
		@BelongingID as GUIDReference,
		@BusinessId as CandidateId,
		@pBelongingTypeId as TypeId,
		@pGpsUser as GPSUser,
		@GetDate as GPSUpdateTimestamp,
		@GetDate as CreationTimeStamp,
		@StateDefinitionId,
		@BelongingCode,
		(CASE WHEN @BelongingType='IndividualBelongingType' THEN'IndividualBelonging' ELSE 'GroupBelonging' END)

		INSERT INTO [OrderedBelonging](Id,BelongingSection_Id,Belonging_Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
		SELECT NEWID(),@BelongingSectionID,@BelongingID,(ISNULL(Max([Order]),0)+1),@pGpsUser,@GetDate,@GetDate
		FROM OrderedBelonging OB 
		WHERE OB.BelongingSection_Id=@BelongingSectionID

		INSERT INTO AttributeValue (
				GUIDReference
				,DemographicId
				,CandidateId
				,RespondentId
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				,Address_Id
				,[Value]
				,[ValueDesc]
				,[EnumDefinition_Id]
				,[FreeText]
				,[Discriminator]	
				,Country_Id			
				)
			SELECT NEWID() as GUIDReference
				,A.GUIDReference as DemographicId
				,NULL as  CandidateId
				,@BelongingID as RespondentId
				,@pGpsUser as GPSUser
				,@GetDate as GPSUpdateTimestamp
				,@GetDate as CreationTimeStamp
				,NULL as Address_Id
				,(CASE WHEN A.[Type] = 'String' THEN D.[Value]
					  WHEN A.[Type] = 'Int'  THEN D.[Value]
					  WHEN A.[Type] = 'Float' THEN D.[Value]
					  WHEN LOWER(A.[Type]) IN ('date','datetime') THEN CONVERT (VARCHAR(30), CONVERT(DATETIME,D.[Value]),20)
					  WHEN A.[Type] = 'Boolean' THEN (CASE D.[Value] WHEN 'Yes' THEN '1' WHEN 'No' THEN '0' WHEN 'TRUE' THEN '1' WHEN 'FALSE' THEN '0' ELSE D.[Value] END)
					  WHEN A.[Type] = 'Enum' THEN ( SELECT ed.Value FROM dbo.EnumDefinition ED WHERE ED.Demographic_Id = A.GUIDReference AND ED.Value = D.[Value] COLLATE SQL_Latin1_General_CP1_CI_AI)
					END) [Value]
				,(CASE WHEN A.[Type] ='Enum' THEN (SELECT dbo.GetTranslationValue(ed.Translation_Id,2057) FROM dbo.EnumDefinition ED WHERE ED.Demographic_Id = A.GUIDReference AND ED.Value = D.[Value] COLLATE SQL_Latin1_General_CP1_CI_AI) ELSE NULL END) as [ValueDesc]
				,CASE WHEN A.[Type] = 'Enum' THEN ( SELECT ed.ID FROM dbo.EnumDefinition ED WHERE ED.Demographic_Id = A.GUIDReference AND ED.Value = D.[Value] COLLATE SQL_Latin1_General_CP1_CI_AI) END [EnumDefinition_Id]
				,NULL as [FreeText]
				,(CASE WHEN A.[Type] = 'String' THEN 'StringAttributeValue'
					  WHEN A.[Type] = 'Int' THEN 'IntAttributeValue'
					  WHEN A.[Type] = 'Float' THEN 'FloatAttributeValue'
					  WHEN LOWER(A.[Type]) IN ('date','datetime') THEN 'DateAttributeValue'
					  WHEN A.[Type] = 'Boolean' THEN 'BooleanAttributeValue'
					  WHEN A.[Type] = 'Enum' THEN 'EnumAttributeValue'
				  END) AS [Discriminator]
				,@CountryId as Country_Id
		FROM @pAttributes D 
		INNER JOIN Attribute A ON D.[Key]=A.[Key] AND A.Country_Id=@CountryId

		COMMIT TRANSACTION

		SELECT 'S' as Code

	END TRY
	BEGIN CATCH
		DECLARE @ERROR_MESSAGE NVARCHAR(MAX)
		PRINT ERROR_MESSAGE()
		SET @ERROR_MESSAGE=ERROR_MESSAGE() 
		PRINT CAST(ERROR_LINE() AS NVARCHAR(MAX))
		ROLLBACK TRANSACTION
		SELECT @ERROR_MESSAGE as Code
	END CATCH 
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