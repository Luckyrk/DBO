CREATE PROCEDURE [dbo].[SaveDemographicValue] 
	@pCountryId UNIQUEIDENTIFIER, 
	@pAttributeId UNIQUEIDENTIFIER, 
	@pAttributeValue NVARCHAR(1000), 
	@pScope VARCHAR(50), 
	@pScopeReferenceId VARCHAR(60), 
	@pUser NVARCHAR(100)
AS
BEGIN
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @InvalidCountry NVARCHAR(200) = 'Invalid Country';
	DECLARE @InvalidAttribute NVARCHAR(200) = 'Invalid Attribute';
	DECLARE @InvalidScope NVARCHAR(200) = 'Invalid Scope';
	DECLARE @InvalidIndividual NVARCHAR(200) = 'Invalid Individual Id';
	DECLARE @DuplicateIndividuals NVARCHAR(200) = 'Duplicate individuals exist for the individual ' + @pScopeReferenceId;
	DECLARE @InvalidGroup NVARCHAR(200) = 'Invalid Group';
	DECLARE @DuplicateGroups NVARCHAR(200) = 'Duplicate individuals exist for the group ' + @pScopeReferenceId;
	DECLARE @InvalidEnumValue NVARCHAR(200) = 'Invalid Enum value provided';
	DECLARE @GetDate DATETIME
	SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryId))
	Declare @enumDefinitionId UNIQUEIDENTIFIER
	BEGIN TRY
		IF NOT EXISTS (
				SELECT 1
				FROM Country
				WHERE CountryId = @pCountryId
				)
		BEGIN
			RAISERROR (@InvalidCountry, 16, 1);
		END

		IF NOT EXISTS (
				SELECT 1
				FROM Attribute
				WHERE GUIDReference = @pAttributeId AND Active =1
				)
		BEGIN
			RAISERROR (@InvalidAttribute, 16, 1);
		END

		IF NOT EXISTS (
				SELECT 1
				WHERE Upper(@pScope) IN (
						'INDIVIDUAL',
						'HOUSEHOLD'
						)
				)
		BEGIN
			RAISERROR (@InvalidScope, 16, 1);
		END

		IF Upper(@pScope) = 'INDIVIDUAL'
		BEGIN
			DECLARE @individualCount INT = (
					SELECT Count(1)
					FROM Individual I
					INNER JOIN Candidate C ON C.GUIDReference = I.GUIDReference
					WHERE IndividualId = @pScopeReferenceId
						AND c.Country_Id = @pCountryId
					)

			IF @individualCount = 0
			BEGIN
				RAISERROR (@InvalidIndividual, 16, 1);
			END
			ELSE IF @individualCount > 1
			BEGIN
				RAISERROR (@DuplicateIndividuals, 16, 1);
			END
		END

		IF Upper(@pScope) = 'HOUSEHOLD'
		BEGIN
			DECLARE @GroupCount INT = (
					SELECT Count(1)
					FROM Collective Coll
					INNER JOIN Candidate c ON c.GUIDReference = Coll.GUIDReference
					WHERE Coll.Sequence = @pScopeReferenceId
						AND c.Country_Id = @pCountryId
					)

			IF @GroupCount = 0
			BEGIN
				RAISERROR (@InvalidGroup, 16, 1);
			END
			ELSE IF @GroupCount > 1
			BEGIN
				RAISERROR (@DuplicateGroups, 16, 1);
			END
		END
	

	DECLARE @attributeDataType AS NVARCHAR(50), @candidateGuid UNIQUEIDENTIFIER, @attributeValueGuid UNIQUEIDENTIFIER, @attributeValueNotExists BIT = 0

	SET @candidateGuid = (
			CASE 
				WHEN Upper(@pScope) = 'INDIVIDUAL'
					THEN (
							SELECT I.GUIDReference
							FROM Individual I
							INNER JOIN Candidate C ON C.GUIDReference = I.GUIDReference
							WHERE IndividualId = @pScopeReferenceId
								AND c.Country_Id = @pCountryId
							)
				WHEN Upper(@pScope) = 'HOUSEHOLD'
					THEN (
							SELECT Coll.GUIDReference
							FROM Collective Coll
							INNER JOIN Candidate c ON c.GUIDReference = Coll.GUIDReference
							WHERE Coll.Sequence = @pScopeReferenceId
								AND c.Country_Id = @pCountryId
							)
				END
			)
	SET @attributeDataType = (
			SELECT [Type]
			FROM Attribute
			WHERE GUIDReference = @pAttributeId
			)
	SET XACT_ABORT ON

	BEGIN TRANSACTION
	IF(@attributeDataType = 'ENUM')
	BEGIN
	SET @enumDefinitionId = (
				SELECT Id
				FROM EnumDefinition ED
				WHERE Demographic_Id = @pAttributeId
					AND Value = @pAttributeValue
				)

		IF @enumDefinitionId IS NULL
		BEGIN
			RAISERROR (@InvalidEnumValue, 16, 1);
		END
	END
	IF NOT EXISTS (
			SELECT 1
			FROM AttributeValue
			WHERE DemographicId = @pAttributeId
				AND CandidateId = @candidateGuid
			)
	BEGIN
		--Setting this flag for inserts bydefault flag is 0 
		SET @attributeValueNotExists = 1
		SET @attributeValueGuid = NEWID()

			INSERT INTO AttributeValue (
						GUIDReference, 
						DemographicId, 
						CandidateId, 
						RespondentId, 
						[Value],
						[ValueDesc],
						[EnumDefinition_Id],
						[FreeText],
						[Discriminator],
						GPSUser, 
						GPSUpdateTimestamp, 
						CreationTimeStamp, 
						Address_Id, 
						Country_Id)
			VALUES (
						@attributeValueGuid, 
						@pAttributeId, 
						@candidateGuid, 
						NULL, 
						@pAttributeValue,
						NULL,
						case when @attributeDataType = 'ENUM' then @enumDefinitionId ELSE null end,
						NULL,
						case when @attributeDataType = 'BOOLEAN' then 'BooleanAttributeValue'
								when @attributeDataType = 'INT' then 'IntAttributeValue'
								when @attributeDataType = 'STRING' then 'StringAttributeValue'
								when @attributeDataType = 'FLOAT' then 'FloatAttributeValue'
								when @attributeDataType = 'DATE' then 'DateAttributeValue'
								when @attributeDataType = 'ENUM' then 'EnumAttributeValue' end,
						@pUser, 
						@GetDate, 
						@GetDate, 
						NULL, 
						@pCountryId
				)
	END
	ELSE
	BEGIN
		SET @attributeValueGuid = (
				SELECT GUIDReference
				FROM AttributeValue
				WHERE DemographicId = @pAttributeId
					AND CandidateId = @candidateGuid
				)
	

	IF Upper(@attributeDataType) = 'BOOLEAN'
	BEGIN
		UPDATE AttributeValue
		SET [Value] = CONVERT(BIT, @pAttributeValue)
		,[ValueDesc] = NULL
		,[EnumDefinition_Id] = NULL
		,[FreeText] = NULL
		,[Discriminator] = 'BooleanAttributeValue'
		,GPSUpdateTimestamp=@GetDate
		,GPSUser=@pUser
		WHERE GUIDReference = @attributeValueGuid

	END
	ELSE IF Upper(@attributeDataType) = 'INT'
	BEGIN
		UPDATE AttributeValue
		SET [Value] = CONVERT(INT, @pAttributeValue)
		,[ValueDesc] = NULL
		,[EnumDefinition_Id] = NULL
		,[FreeText] = NULL
		,[Discriminator] = 'IntAttributeValue'
		,GPSUpdateTimestamp=@GetDate
		,GPSUser=@pUser
		WHERE GUIDReference = @attributeValueGuid

	END
	ELSE IF Upper(@attributeDataType) = 'STRING'
	BEGIN
		UPDATE AttributeValue
		SET [Value] = @pAttributeValue
		,[ValueDesc] = NULL
		,[EnumDefinition_Id] = NULL
		,[FreeText] = NULL
		,[Discriminator] = 'StringAttributeValue'
		,GPSUpdateTimestamp=@GetDate
		,GPSUser=@pUser
		WHERE GUIDReference = @attributeValueGuid
	END
	ELSE IF Upper(@attributeDataType) = 'FLOAT'
	BEGIN
		UPDATE AttributeValue
		SET [Value] = CONVERT(FLOAT, @pAttributeValue)
		,[ValueDesc] = NULL
		,[EnumDefinition_Id] = NULL
		,[FreeText] = NULL
		,[Discriminator] = 'FloatAttributeValue'
		,GPSUpdateTimestamp=@GetDate
		,GPSUser=@pUser
		WHERE GUIDReference = @attributeValueGuid
	END
	ELSE IF (Upper(@attributeDataType) = 'DATE')
	BEGIN
		UPDATE AttributeValue
		SET [Value] = Convert(DATETIME, @pAttributeValue)
		,[ValueDesc] = NULL
		,[EnumDefinition_Id] = NULL
		,[FreeText] = NULL
		,[Discriminator] = 'DateAttributeValue'
		,GPSUpdateTimestamp=@GetDate
		,GPSUser=@pUser
		WHERE GUIDReference = @attributeValueGuid
	END
	ELSE
	BEGIN
		IF Upper(@attributeDataType) = 'ENUM'
			

		SET @enumDefinitionId = (
				SELECT Id
				FROM EnumDefinition ED
				WHERE Demographic_Id = @pAttributeId
					AND Value = @pAttributeValue
				)

		IF @enumDefinitionId IS NULL
		BEGIN
			RAISERROR (@InvalidEnumValue, 16, 1);
		END

		UPDATE AttributeValue
		SET [Value] = NULL
		,[ValueDesc] = NULL
		,[EnumDefinition_Id] = @enumDefinitionId
		,[FreeText] = NULL
		,[Discriminator] = 'EnumAttributeValue'
		,GPSUpdateTimestamp=@GetDate
		,GPSUser=@pUser
		WHERE GUIDReference = @attributeValueGuid
	END
END
	UPDATE AttributeValue
	SET GPSUser = @pUser
	,GPSUpdateTimestamp = @GetDate
	WHERE GUIDReference = @attributeValueGuid

	COMMIT TRANSACTION
	END TRY

	BEGIN CATCH
		declare @error nvarchar(max)= (SELECT ERROR_MESSAGE())
		RAISERROR(@error,16,1)
		Rollback Transaction
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
