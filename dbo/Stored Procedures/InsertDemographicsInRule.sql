CREATE PROCEDURE [dbo].[InsertDemographicValueInRule] 
	@pCountryId UNIQUEIDENTIFIER, 
	@pAttributeId UNIQUEIDENTIFIER, 
	@pAttributeValue NVARCHAR(1000), 
	@pScope VARCHAR(50), 
	@pScopeReferenceId VARCHAR(60), 
	@pUser NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON

	SET XACT_ABORT ON

		DECLARE @attributeDataType AS NVARCHAR(50), 
		    @candidateGuid UNIQUEIDENTIFIER, 	
			 @attributeValueGuid UNIQUEIDENTIFIER, 	    
		    @enumDefinitionId UNIQUEIDENTIFIER,
		    @InvalidEnumValue NVARCHAR(200) = 'Invalid Enum value provided';

	DECLARE @GetDate DATETIME 

	SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryId))

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

	BEGIN TRANSACTION
	BEGIN TRY
		IF NOT EXISTS (
				SELECT 1
				FROM AttributeValue
				WHERE DemographicId = @pAttributeId
					AND CandidateId = @candidateGuid
				)
		BEGIN
						
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
	
		COMMIT TRANSACTION

	END TRY

	BEGIN CATCH
		declare @error nvarchar(max)= (SELECT ERROR_MESSAGE())
		RAISERROR(@error,16,1)
		Rollback Transaction
	END CATCH
	
END
