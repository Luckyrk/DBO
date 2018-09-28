CREATE PROCEDURE [dbo].[AnonymizeCandidates] (
	 @pHouseholdCodes StringIdTableType READONLY
	,@pIndividualCodes StringIdTableType READONLY	
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT = 2057
	,@pUser NVARCHAR(200) = ''
	,@pAutomaticProcess BIT = 0
	)
AS
BEGIN
BEGIN TRY
	DECLARE @GetDate DATETIME=dbo.GetLocalDateTimeByCountryId(GETDATE(),@pCountryId)
	DECLARE @validation_result TABLE(
		GroupId NVARCHAR(200) NULL,
		IndividualId NVARCHAR(200) NULL,
		[Status] NVARCHAR(200) NULL,
		IndividualGuid UNIQUEIDENTIFIER,
		GroupGuid UNIQUEIDENTIFIER)
	
	DECLARE @internalHouseholdCodes StringIdTableType
	DECLARE @internalIndividualCodes StringIdTableType

	INSERT INTO @internalHouseholdCodes SELECT * FROM @pHouseholdCodes WHERE ISNULL(Id, '') <> ''
	INSERT INTO @internalIndividualCodes SELECT * FROM @pIndividualCodes WHERE ISNULL(Id, '') <> ''

	INSERT @validation_result
	EXEC sp_executesql N';EXEC ValidateAnonymization @0, @1, @2, @3',N'@0 [dbo].[StringIdTableType] READONLY,@1 [dbo].[StringIdTableType] READONLY,@2 nvarchar(40),@3 int',
		@0 = @internalHouseholdCodes, @1 = @internalIndividualCodes, @2 = @pCountryId, @3 = @pCultureCode

	IF EXISTS (SELECT 1 FROM @validation_result WHERE [Status] <> '' AND @pAutomaticProcess = 0)
	BEGIN
		SELECT * FROM @validation_result;
	END
	ELSE
	BEGIN
		
		DELETE FROM @validation_result WHERE [Status] <> '';

		DECLARE @AnonymAV TABLE (Id UNIQUEIDENTIFIER);
		DECLARE @AnonymCE TABLE (Id UNIQUEIDENTIFIER);
		DECLARE @AnonymAT TABLE (Id UNIQUEIDENTIFIER);
		DECLARE @AnonymDocCE TABLE (Id BIGINT);
		DECLARE @AnonymDocAT TABLE (Id BIGINT);
		DECLARE @AnonymER TABLE (Id UNIQUEIDENTIFIER);
				
		INSERT INTO @AnonymAV
		SELECT av.GUIDReference
		FROM @validation_result vi
		JOIN AttributeValue av ON vi.IndividualGuid=av.CandidateId OR vi.GroupGuid=av.CandidateId
		JOIN Attribute a ON a.GUIDReference=av.DemographicId AND a.MustAnonymize=1
			
		UPDATE av SET Value=null, ValueDesc=null, [FreeText]='', EnumDefinition_Id=null
		FROM AttributeValue av
		JOIN @AnonymAV aav ON aav.Id=av.GUIDReference
		
		
		
		--SELECT * 
		UPDATE a SET
			AddressLine1 = CONCAT(i.IndividualId, '_ADRESSE'),
			AddressLine2 = CONCAT(i.IndividualId, '_ADRESSE'),
			AddressLine3 = CONCAT(i.IndividualId, '_ADRESSE'),
			AddressLine4 = CONCAT(i.IndividualId, '_ADRESSE'),
			PostCode=''
		FROM @validation_result i
		JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=i.IndividualGuid
		JOIN [Address] a ON a.GUIDReference=ocm.Address_Id
		JOIN AddressType at ON at.Id=a.Type_Id
		JOIN Translation t ON t.TranslationId=at.Description_Id
		WHERE a.AddressType = 'PostalAddress' AND (t.KeyName <> 'HomeAddressType' OR i.GroupGuid IS NOT NULL)

		UPDATE a SET
			AddressLine1 = CONCAT(i.IndividualId, '_EMAIL'),
			AddressLine2 = '',
			AddressLine3 = '',
			AddressLine4 = '',
			PostCode=''
		FROM @validation_result i
		JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=i.IndividualGuid
		JOIN [Address] a ON a.GUIDReference=ocm.Address_Id
		WHERE a.AddressType = 'ElectronicAddress'

		UPDATE a SET
			AddressLine1 = '0',
			AddressLine2 = '0',
			AddressLine3 = '0',
			AddressLine4 = '0',
			PostCode=''
		FROM @validation_result i
		JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=i.IndividualGuid
		JOIN [Address] a ON a.GUIDReference=ocm.Address_Id		
		JOIN AddressType at ON at.Id=a.Type_Id
		JOIN Translation t ON t.TranslationId=at.Description_Id
		WHERE a.AddressType = 'PhoneAddress' AND (t.KeyName <> 'HomePhoneType' OR i.GroupGuid IS NOT NULL)

		UPDATE pii SET 
			LastOrderedName = CONCAT(i.IndividualId, '_NOM'),
			MiddleOrderedName = CONCAT(i.IndividualId, '_NOM'),
			FirstOrderedName = CONCAT(i.IndividualId, '_PRENOM'),
			TitleId=NULL
		FROM Individual i
		JOIN @validation_result ii ON ii.IndividualGuid=i.GUIDReference
		JOIN PersonalIdentification pii ON pii.PersonalIdentificationId=i.PersonalIdentificationId

		DECLARE @internalHouseholdId StringIdTableType
		DECLARE @internalIndividualId StringIdTableType

		INSERT INTO @internalHouseholdId SELECT DISTINCT CONCAT(GroupGUID, '') FROM @validation_result
		INSERT INTO @internalIndividualId SELECT DISTINCT CONCAT(IndividualGUID, '') FROM @validation_result

		UPDATE i SET i.IsAnonymized=1,i.GPSUpdateTimestamp=@GetDate FROM
		Individual i
		JOIN @validation_result ii ON ii.IndividualGuid=i.GUIDReference


		INSERT INTO @AnonymCE
		SELECT ce.GUIDReference
		FROM @validation_result i
		JOIN CommunicationEvent ce ON ce.Candidate_Id=i.IndividualGuid OR ce.Candidate_Id=i.GroupGuid

		INSERT INTO @AnonymAT
		SELECT at.GUIDReference
		FROM @validation_result i
		JOIN ActionTask at ON at.Candidate_Id=i.IndividualGuid OR at.Candidate_Id=i.GroupGuid

		INSERT INTO @AnonymDocCE
		SELECT d.DocumentId
		FROM @AnonymCE i
		JOIN DocumentCommunicationEventAssociation d ON d.CommunicationEventId =  i.Id

		INSERT INTO @AnonymER
		SELECT er.MorpheusEReceiptsId
		FROM @validation_result i
		JOIN MorpheusEReceipts er ON er.CandidateId = i.IndividualGuid OR er.CandidateId = i.GroupGuid

		DELETE d
		FROM @AnonymCE i
		JOIN DocumentCommunicationEventAssociation d ON d.CommunicationEventId =  i.Id

		DELETE ed
		FROM @AnonymDocCE i
		JOIN EmailDocument ed ON ed.DocumentId = i.Id

		DELETE td
		FROM @AnonymDocCE i
		JOIN TextDocument td ON td.DocumentId = i.Id

		/*change for anonymize  */
		DELETE dp
		FROM @AnonymDocCE i
		JOIN DocumentPanelistAssociation dp ON dp.DocumentId = i.Id
		/*change for anonymize  */

		DELETE d
		FROM @AnonymDocCE i
		JOIN DocumentActionTaskAssociation	d ON d.DocumentId =  i.Id

		DELETE d
		FROM @AnonymDocCE i
		JOIN Document d ON d.DocumentId = i.Id

	
		INSERT INTO @AnonymDocAT
		SELECT d.DocumentId
		FROM @AnonymAT i
		JOIN DocumentActionTaskAssociation	d ON d.ActionTaskId =  i.Id

		DELETE d
		FROM @AnonymAT i
		JOIN DocumentActionTaskAssociation	d ON d.ActionTaskId =  i.Id

		DELETE ed
		FROM @AnonymDocAT i
		JOIN EmailDocument ed ON ed.DocumentId = i.Id

		DELETE td
		FROM @AnonymDocAT i
		JOIN TextDocument td ON td.DocumentId = i.Id

		/*change for anonymize  */
		DELETE dp
		FROM @AnonymDocAT i
		JOIN DocumentPanelistAssociation dp ON dp.DocumentId = i.Id
		/*change for anonymize  */

		DELETE d
		FROM @AnonymDocAT i
		JOIN Document d ON d.DocumentId = i.Id

		DELETE cer
		FROM @AnonymCE i
		JOIN CommunicationEventReason cer ON cer.Communication_Id=i.Id

		DELETE ce
		FROM @AnonymCE i
		JOIN CommunicationEvent ce ON ce.GUIDReference = i.Id
	
		DELETE at
		FROM @AnonymAT i
		JOIN ActionTask at ON at.GUIDReference=i.Id

		DELETE mh
		FROM @AnonymER i
		JOIN MorpheusEReceiptsHistory mh ON mh.MorpheusEReceiptsId = i.Id

		DELETE er
		FROM @AnonymER i
		JOIN MorpheusEReceipts er ON er.MorpheusEReceiptsId = i.Id

		IF EXISTS (SELECT 1 FROM sysobjects 
					WHERE  id = object_id(N'AnonymizeCandidatesHistory') AND OBJECTPROPERTY(id, N'IsProcedure') = 1 )
		BEGIN
			EXEC sp_executesql N';EXEC AnonymizeCandidatesHistory @0, @1',N'@0 [dbo].[StringIdTableType] READONLY,@1 [dbo].[StringIdTableType] READONLY',
						@0 = @internalHouseholdId, @1 = @internalIndividualId						 
		END

		SELECT * FROM @validation_result
	END
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
