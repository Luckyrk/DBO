CREATE PROCEDURE [dbo].[DownloadCandidateAnonymizableInformation] (
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

		
		DELETE FROM @validation_result WHERE [Status] <> '';

		DECLARE @AnonymAV TABLE (Id UNIQUEIDENTIFIER);

		INSERT INTO @AnonymAV
		SELECT av.GUIDReference
		FROM @validation_result vi
		JOIN AttributeValue av ON vi.IndividualGuid=av.CandidateId OR vi.GroupGuid=av.CandidateId
		JOIN Attribute a ON a.GUIDReference=av.DemographicId AND a.MustAnonymize=1

		SELECT vi.GroupId, vi.IndividualId, t.KeyName as AttributeKey, av.Value
		FROM @AnonymAV aav
		JOIN AttributeValue av ON av.GUIDReference=aav.Id
		JOIN Attribute a ON a.GUIDReference=av.DemographicId AND a.MustAnonymize=1
		JOIN Translation t ON t.TranslationId=a.Translation_Id
		JOIN @validation_result vi ON vi.IndividualGuid=av.CandidateId OR vi.GroupGuid=av.CandidateId
		WHERE vi.IndividualGuid IS NOT NULL OR vi.GroupGuid IS NOT NULL
			
		SELECT vi.GroupId, vi.IndividualId, a.AddressType, AddressLine1, AddressLine2, AddressLine3, AddressLine4, PostCode
		FROM @validation_result vi
		JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=vi.IndividualGuid
		JOIN [Address] a ON a.GUIDReference=ocm.Address_Id

		SELECT vi.GroupId, vi.IndividualId, LastOrderedName, MiddleOrderedName, FirstOrderedName
		FROM Individual i
		JOIN @validation_result vi ON vi.IndividualGuid=i.GUIDReference
		JOIN PersonalIdentification pii ON pii.PersonalIdentificationId=i.PersonalIdentificationId
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


--select * from individual i
--JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=i.GUIDReference
--JOIN [Address] a ON a.GUIDReference=ocm.Address_Id