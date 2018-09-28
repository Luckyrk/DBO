CREATE PROCEDURE [dbo].[MorpheusAppUserInsert](
		 @pMorpheusAppUserType as MorpheusAppUserType READONLY
		,@pDemographicData as MorpheusDemographicType READONLY		
		,@pMessageID UNIQUEIDENTIFIER 
		,@pCountryCode VARCHAR(2)
		,@pCultureCode INT
	)
	AS
	BEGIN
	BEGIN TRY
	SET XACT_ABORT ON;
	SET NOCOUNT ON;
			PRINT 'MorpheusAppUserInsert PROCESS STARTED'
	
			DECLARE @GetDate				DATETIME
			DECLARE @postalAddressId		UNIQUEIDENTIFIER	=	NEWID()
			DECLARE @plectronicAddressGuid	UNIQUEIDENTIFIER	=	NEWID()
			DECLARE @phonelAddressId		UNIQUEIDENTIFIER	=	NEWID()
			DECLARE @mobilephonelAddressId	UNIQUEIDENTIFIER	=	NEWID()
			DECLARE @individualId			UNIQUEIDENTIFIER	=	NEWID()
			DECLARE @pCountryId				UNIQUEIDENTIFIER
			DECLARE @GroupId				UNIQUEIDENTIFIER

			SELECT @pCountryId = CountryId FROM Country WHERE CountryISO2A = @pCountryCode

			IF (SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(),@pCountryId)) IS NOT NULL
			BEGIN
				SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(GETDATE(),@pCountryId))
			END
			ELSE
			BEGIN
				SET @GetDate = GETDATE()
			END

			DECLARE @pUser NVARCHAR(100)='MorpheusUser'

			DECLARE @MorphesAppUserContext AS NVARCHAR(MAX) ='MorphesAppUserContext'
			DECLARE @MorphesIndividualContextKey AS NVARCHAR(MAX) ='MorphesIndividualContext'

			DECLARE @postalAddressTypeGuid UNIQUEIDENTIFIER
						SET @postalAddressTypeGuid = (
								SELECT Id
								FROM AddressType
								WHERE DiscriminatorType = 'PostalAddressType'
									AND IsDefault = 1
								)

			DECLARE @emailAddressTypeGuid UNIQUEIDENTIFIER
						SET @emailAddressTypeGuid = (
								SELECT Id
								FROM AddressType
								WHERE DiscriminatorType = 'ElectronicAddressType'
									AND IsDefault = 1
								)

			DECLARE @homeAddressTypeGuid UNIQUEIDENTIFIER
			SET @homeAddressTypeGuid = (
					SELECT Id
					FROM AddressType AT
					INNER JOIN Translation T ON AT.Description_Id = T.TranslationId
					WHERE AT.DiscriminatorType = 'PhoneAddressType'
						AND T.KeyName = 'HomePhoneType'
					)

			DECLARE @workAddressTypeGuid UNIQUEIDENTIFIER
			SET @workAddressTypeGuid = (
					SELECT Id
					FROM AddressType AT
					INNER JOIN Translation T ON AT.Description_Id = T.TranslationId
					WHERE AT.DiscriminatorType = 'PhoneAddressType'
						AND T.KeyName = 'WorkPhoneType'
					)

			DECLARE @mobileAddressTypeGuid UNIQUEIDENTIFIER
						SET @mobileAddressTypeGuid = (
								SELECT Id
								FROM AddressType AT
								INNER JOIN Translation T ON AT.Description_Id = T.TranslationId
								WHERE AT.DiscriminatorType = 'PhoneAddressType'
									AND T.KeyName = 'MobilePhoneType'
								)


			IF EXISTS (
			SELECT 1 FROM 
			NamedAlias NA 
			INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NAC.NamedAliasContextId
			INNER JOIN @pMorpheusAppUserType TEMP ON TEMP.AppUserGUID = NA.[Key]
			WHERE NAC.[Name]=@MorphesAppUserContext
			)
			BEGIN

				
					BEGIN TRY
						

						DECLARE @CandidateId UNIQUEIDENTIFIER
						
						DECLARE @NewGroupContactId UNIQUEIDENTIFIER=NULL
						DECLARE @IndividualIDofMainShopper UNIQUEIDENTIFIER =NULL
						DECLARE @IndividualIDofChiefIncomeEarner UNIQUEIDENTIFIER =NULL						
						DECLARE @GpsUser NVARCHAR(MAX)='MorpheusUser'

						


						DECLARE @DiscriminatorPostalAddressType NVARCHAR(300)='PostalAddressType'
						DECLARE @DiscriminatorAddressPostalTypeDesc NVARCHAR(300)='PostalAddress'
						DECLARE @DiscriminatorAddressPostalTypeTransKey NVARCHAR(300)='HomeAddressType'
						DECLARE @DiscriminatorAddressPostalTypeTransID UNIQUEIDENTIFIER
						SET @DiscriminatorAddressPostalTypeTransID=(SELECT TranslationId FROM Translation WHERE KeyName=@DiscriminatorAddressPostalTypeTransKey)

						DECLARE @DiscriminatorPhoneAddressType NVARCHAR(300)='PhoneAddressType'
						DECLARE @DiscriminatorAddressPhoneTypeDesc NVARCHAR(300)='PhoneAddress'
						DECLARE @DiscriminatorAddressHomePhoneTypeTransKey NVARCHAR(300)='HomePhoneType'
						DECLARE @DiscriminatorAddressHomePhoneTypeTransID UNIQUEIDENTIFIER
						SET @DiscriminatorAddressHomePhoneTypeTransID=(SELECT TranslationId FROM Translation WHERE KeyName=@DiscriminatorAddressHomePhoneTypeTransKey)

						DECLARE @DiscriminatorAddressHomeMobileTypeTransKey NVARCHAR(300)='MobilePhoneType'
						DECLARE @DiscriminatorAddressHomeMobileTypeTransID UNIQUEIDENTIFIER
						SET @DiscriminatorAddressHomeMobileTypeTransID=(SELECT TranslationId FROM Translation WHERE KeyName=@DiscriminatorAddressHomeMobileTypeTransKey)

						DECLARE @DiscriminatorElectronicAddressType NVARCHAR(300)='ElectronicAddressType'
						DECLARE @DiscriminatorElectronicAddressDesc NVARCHAR(300)='ElectronicAddress'
						DECLARE @DiscriminatorAddressPersonalElectronicAddressTransKey NVARCHAR(300)='PersonalEmailAddressType'
						DECLARE @DiscriminatorAddressPersonalElectronicAddressTransId UNIQUEIDENTIFIER
						SET @DiscriminatorAddressPersonalElectronicAddressTransId=(SELECT TranslationId FROM Translation WHERE KeyName=@DiscriminatorAddressPersonalElectronicAddressTransKey)

						SELECT @GroupId=C.GUIDReference
						FROM NamedAlias NA 
						INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
						INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
						INNER JOIN @pMorpheusAppUserType MAU ON MAU.AppUserGUID=NA.[Key]
						WHERE NAC.[Name]=@MorphesAppUserContext

						SELECT @NewGroupContactId=NA.Candidate_Id
						FROM NamedAlias NA 
						INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
						INNER JOIN @pMorpheusAppUserType MAU ON MAU.IndividualIDofAppUser=NA.[Key]
						WHERE NAC.[Name]=@MorphesIndividualContextKey

						SELECT @IndividualIDofMainShopper=NA.Candidate_Id
						FROM NamedAlias NA 
						INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
						INNER JOIN @pMorpheusAppUserType MAU ON MAU.IndividualIDofMainShopper=NA.[Key]
						WHERE NAC.[Name]=@MorphesIndividualContextKey

						SELECT @IndividualIDofChiefIncomeEarner=NA.Candidate_Id
						FROM NamedAlias NA 
						INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
						INNER JOIN @pMorpheusAppUserType MAU ON MAU.IndividualIDofChiefIncomeEarner=NA.[Key]
						WHERE NAC.[Name]=@MorphesIndividualContextKey

					BEGIN TRANSACTION
						-- HousHold Home AddressLine1
						
						UPDATE A SET A.AddressLine1=MAU.AddressLine1,A.GPSUpdateTimestamp=@GetDate,A.GPSUser=@GpsUser
						FROM NamedAlias NA 
						INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
						INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
						INNER JOIN @pMorpheusAppUserType MAU ON MAU.AppUserGUID=NA.[Key]
						INNER JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=C.GUIDReference
						INNER JOIN [Address] A ON A.GUIDReference=ocm.Address_Id AND [AddressType]=@DiscriminatorAddressPostalTypeDesc
						INNER JOIN [AddressType] AT ON AT.DiscriminatorType=@DiscriminatorPostalAddressType AND AT.[Description_Id]=@DiscriminatorAddressPostalTypeTransID AND AT.Id=A.[Type_Id]
						WHERE NAC.[Name]=@MorphesAppUserContext AND ISNULL(A.AddressLine1,'')<>MAU.AddressLine1 AND MAU.AddressLine1 IS NOT NULL AND LEN(MAU.AddressLine1)>0

						-- HousHold Home AddressLine2
						UPDATE A SET A.AddressLine2=MAU.AddressLine2,A.GPSUpdateTimestamp=@GetDate,A.GPSUser=@GpsUser
						FROM NamedAlias NA 
						INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
						INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
						INNER JOIN @pMorpheusAppUserType MAU ON MAU.AppUserGUID=NA.[Key]
						INNER JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=C.GUIDReference
						INNER JOIN [Address] A ON A.GUIDReference=ocm.Address_Id AND [AddressType]=@DiscriminatorAddressPostalTypeDesc
						INNER JOIN [AddressType] AT ON AT.DiscriminatorType=@DiscriminatorPostalAddressType AND AT.[Description_Id]=@DiscriminatorAddressPostalTypeTransID AND AT.Id=A.[Type_Id]
						WHERE NAC.[Name]=@MorphesAppUserContext AND ISNULL(A.AddressLine2,'')<>MAU.AddressLine2 AND MAU.AddressLine2 IS NOT NULL AND  LEN(MAU.AddressLine2)>0

						-- HousHold Home AddressLine3
						UPDATE A SET A.AddressLine3=MAU.AddressLine3,A.GPSUpdateTimestamp=@GetDate,A.GPSUser=@GpsUser
						FROM NamedAlias NA 
						INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
						INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
						INNER JOIN @pMorpheusAppUserType MAU ON MAU.AppUserGUID=NA.[Key]
						INNER JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=C.GUIDReference
						INNER JOIN [Address] A ON A.GUIDReference=ocm.Address_Id AND [AddressType]=@DiscriminatorAddressPostalTypeDesc
						INNER JOIN [AddressType] AT ON AT.DiscriminatorType=@DiscriminatorPostalAddressType AND AT.[Description_Id]=@DiscriminatorAddressPostalTypeTransID AND AT.Id=A.[Type_Id]
						WHERE NAC.[Name]=@MorphesAppUserContext AND ISNULL(A.AddressLine3,'')<>MAU.AddressLine3 AND MAU.AddressLine3 IS NOT NULL AND LEN(MAU.AddressLine3)>0

						-- HousHold Home AddressLine4
						UPDATE A SET A.AddressLine4=MAU.AddressLine4,A.GPSUpdateTimestamp=@GetDate,A.GPSUser=@GpsUser
						FROM NamedAlias NA 
						INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
						INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
						INNER JOIN @pMorpheusAppUserType MAU ON MAU.AppUserGUID=NA.[Key]
						INNER JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=C.GUIDReference
						INNER JOIN [Address] A ON A.GUIDReference=ocm.Address_Id AND [AddressType]=@DiscriminatorAddressPostalTypeDesc
						INNER JOIN [AddressType] AT ON AT.DiscriminatorType=@DiscriminatorPostalAddressType AND AT.[Description_Id]=@DiscriminatorAddressPostalTypeTransID AND AT.Id=A.[Type_Id]
						WHERE NAC.[Name]=@MorphesAppUserContext AND ISNULL(A.AddressLine4,'')<>MAU.AddressLine4 AND MAU.AddressLine4 IS NOT NULL AND LEN(MAU.AddressLine4)>0

						-- HousHold Home Address Postcode
						UPDATE A SET A.Postcode=MAU.Postcode,A.GPSUpdateTimestamp=@GetDate,A.GPSUser=@GpsUser
						FROM NamedAlias NA 
						INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
						INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
						INNER JOIN @pMorpheusAppUserType MAU ON MAU.AppUserGUID=NA.[Key]
						INNER JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=C.GUIDReference
						INNER JOIN [Address] A ON A.GUIDReference=ocm.Address_Id AND [AddressType]=@DiscriminatorAddressPostalTypeDesc
						INNER JOIN [AddressType] AT ON AT.DiscriminatorType=@DiscriminatorPostalAddressType AND AT.[Description_Id]=@DiscriminatorAddressPostalTypeTransID AND AT.Id=A.[Type_Id]
						WHERE NAC.[Name]=@MorphesAppUserContext AND ISNULL(A.Postcode,'')<>MAU.Postcode AND MAU.Postcode IS NOT NULL AND LEN(MAU.Postcode)>0

						-- Home Phone Address of House Hold
						IF EXISTS (
							SELECT 1
							FROM NamedAlias NA 
							INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
							INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
							INNER JOIN @pMorpheusAppUserType MAU ON MAU.AppUserGUID=NA.[Key]
							INNER JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=C.GUIDReference
							INNER JOIN [Address] A ON A.GUIDReference=ocm.Address_Id AND [AddressType]=@DiscriminatorAddressPhoneTypeDesc
							INNER JOIN [AddressType] AT ON AT.DiscriminatorType=@DiscriminatorPhoneAddressType AND AT.[Description_Id]=@DiscriminatorAddressHomePhoneTypeTransID AND AT.Id=A.[Type_Id]
							WHERE NAC.[Name]=@MorphesAppUserContext
						)
						BEGIN 
							UPDATE A SET A.AddressLine1=MAU.PhoneNumberHome,A.GPSUpdateTimestamp=@GetDate,A.GPSUser=@GpsUser
							FROM NamedAlias NA 
							INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
							INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
							INNER JOIN @pMorpheusAppUserType MAU ON MAU.AppUserGUID=NA.[Key]
							INNER JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=C.GUIDReference
							INNER JOIN [Address] A ON A.GUIDReference=ocm.Address_Id AND [AddressType]=@DiscriminatorAddressPhoneTypeDesc
							INNER JOIN [AddressType] AT ON AT.DiscriminatorType=@DiscriminatorPhoneAddressType AND AT.[Description_Id]=@DiscriminatorAddressHomePhoneTypeTransID AND AT.Id=A.[Type_Id]
							WHERE NAC.[Name]=@MorphesAppUserContext AND (ISNULL(A.AddressLine1,'')<>MAU.PhoneNumberHome) AND MAU.PhoneNumberHome IS NOT NULL AND LEN(MAU.PhoneNumberHome)>0
						END
						ELSE 
						BEGIN
							IF EXISTS(SELECT 1 FROM @pMorpheusAppUserType tp WHERE tp.PhoneNumberHome IS NOT NULL AND LEN(tp.PhoneNumberHome)>0)
							BEGIN
								SET @phonelAddressId=NEWID()
								INSERT INTO [Address] (GUIDReference,AddressLine1,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,[Type_Id],AddressType,Country_Id)
								SELECT @phonelAddressId,tp.PhoneNumberHome,@pUser,@GetDate,@GetDate,@homeAddressTypeGuid,'PhoneAddress',@pCountryId				
								FROM @pMorpheusAppUserType tp
								WHERE tp.PhoneNumberHome IS NOT NULL AND LEN(tp.PhoneNumberHome)>0

								INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
								SELECT NEWID(),1,@puser,@GetDate,@GetDate,@GroupId,@phonelAddressId,@pCountryId
								WHERE NOT EXISTS (
										SELECT 1
										FROM OrderedContactMechanism C
										WHERE C.Candidate_Id = @GroupId
										AND Address_Id = @phonelAddressId
										)

								INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
								SELECT NEWID(),1,@puser,@GetDate,@GetDate,CMP.Individual_Id,@phonelAddressId,@pCountryId
								FROM CollectiveMembership CMP 
								INNER JOIN Collective C ON CMP.Group_Id=C.GUIDReference AND C.GroupContact_Id=CMP.Individual_Id
								WHERE CMP.Group_Id=@GroupId AND CMP.Country_Id=@pCountryId
								AND NOT EXISTS (
										SELECT 1
										FROM OrderedContactMechanism C
										WHERE C.Candidate_Id = CMP.Individual_Id
										AND Address_Id = @phonelAddressId
										)
							END

						END


						-- Mobile Phone Address of House Hold
						IF EXISTS (
							SELECT 1
							FROM NamedAlias NA 
							INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
							INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
							INNER JOIN @pMorpheusAppUserType MAU ON MAU.AppUserGUID=NA.[Key]
							INNER JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=C.GUIDReference
							INNER JOIN [Address] A ON A.GUIDReference=ocm.Address_Id AND [AddressType]=@DiscriminatorAddressPhoneTypeDesc
							INNER JOIN [AddressType] AT ON AT.DiscriminatorType=@DiscriminatorPhoneAddressType AND AT.[Description_Id]=@DiscriminatorAddressHomeMobileTypeTransID AND AT.Id=A.[Type_Id]
							WHERE NAC.[Name]=@MorphesAppUserContext
						)
						BEGIN 
							UPDATE A SET A.AddressLine1=MAU.PhoneNumberMobile,A.GPSUpdateTimestamp=@GetDate,A.GPSUser=@GpsUser
							FROM NamedAlias NA 
							INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
							INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
							INNER JOIN @pMorpheusAppUserType MAU ON MAU.AppUserGUID=NA.[Key]
							INNER JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=C.GUIDReference
							INNER JOIN [Address] A ON A.GUIDReference=ocm.Address_Id AND [AddressType]=@DiscriminatorAddressPhoneTypeDesc
							INNER JOIN [AddressType] AT ON AT.DiscriminatorType=@DiscriminatorPhoneAddressType AND AT.[Description_Id]=@DiscriminatorAddressHomeMobileTypeTransID AND AT.Id=A.[Type_Id]
							WHERE NAC.[Name]=@MorphesAppUserContext AND (ISNULL(A.AddressLine1,'')<>MAU.PhoneNumberMobile) AND MAU.PhoneNumberMobile IS NOT NULL AND LEN(MAU.PhoneNumberMobile)>0
						END
						ELSE
						BEGIN
							IF EXISTS(SELECT 1 FROM @pMorpheusAppUserType tp WHERE tp.PhoneNumberMobile IS NOT NULL AND LEN(tp.PhoneNumberMobile)>0)
							BEGIN

								SET @mobilephonelAddressId=NEWID()
								INSERT INTO [Address] (GUIDReference,AddressLine1,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,[Type_Id],AddressType,Country_Id)
								SELECT @mobilephonelAddressId,tp.PhoneNumberMobile,@pUser,@GetDate,@GetDate,@mobileAddressTypeGuid,'PhoneAddress',@pCountryId				
								FROM @pMorpheusAppUserType tp
								WHERE tp.PhoneNumberMobile IS NOT NULL AND LEN(tp.PhoneNumberMobile)>0

							
								INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
								SELECT NEWID(),2,@puser,@GetDate,@GetDate,@GroupId,@mobilephonelAddressId,@pCountryId
									WHERE NOT EXISTS (
											SELECT 1
											FROM OrderedContactMechanism C
											WHERE C.Candidate_Id = @GroupId
											AND Address_Id = @mobilephonelAddressId
											)

								INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
								SELECT NEWID(),1,@puser,@GetDate,@GetDate,CMP.Individual_Id,@mobilephonelAddressId,@pCountryId 
								FROM CollectiveMembership CMP 
								INNER JOIN Collective C ON CMP.Group_Id=C.GUIDReference AND C.GroupContact_Id=CMP.Individual_Id
								WHERE CMP.Group_Id=@GroupId AND CMP.Country_Id=@pCountryId
									AND NOT EXISTS (
											SELECT 1
											FROM OrderedContactMechanism C
											WHERE C.Candidate_Id = CMP.Individual_Id
											AND Address_Id = @mobilephonelAddressId
											)
							END
						END

						-- Personal Email Address of House Hold
						IF EXISTS (
							SELECT 1
							FROM NamedAlias NA 
							INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
							INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
							INNER JOIN @pMorpheusAppUserType MAU ON MAU.AppUserGUID=NA.[Key]
							INNER JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=C.GUIDReference
							INNER JOIN [Address] A ON A.GUIDReference=ocm.Address_Id AND [AddressType]=@DiscriminatorElectronicAddressDesc
							INNER JOIN [AddressType] AT ON AT.DiscriminatorType=@DiscriminatorElectronicAddressType AND AT.[Description_Id]=@DiscriminatorAddressPersonalElectronicAddressTransId AND AT.Id=A.[Type_Id]
							WHERE NAC.[Name]=@MorphesAppUserContext
						)
						BEGIN
							UPDATE A SET A.AddressLine1=MAU.Email,A.GPSUpdateTimestamp=@GetDate,A.GPSUser=@GpsUser
							FROM NamedAlias NA 
							INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
							INNER JOIN Collective C ON NA.Candidate_Id=C.GUIDReference
							INNER JOIN @pMorpheusAppUserType MAU ON MAU.AppUserGUID=NA.[Key]
							INNER JOIN OrderedContactMechanism ocm ON ocm.Candidate_Id=C.GUIDReference
							INNER JOIN [Address] A ON A.GUIDReference=ocm.Address_Id AND [AddressType]=@DiscriminatorElectronicAddressDesc
							INNER JOIN [AddressType] AT ON AT.DiscriminatorType=@DiscriminatorElectronicAddressType AND AT.[Description_Id]=@DiscriminatorAddressPersonalElectronicAddressTransId AND AT.Id=A.[Type_Id]
							WHERE NAC.[Name]=@MorphesAppUserContext AND ISNULL(A.AddressLine1,'')<>MAU.Email AND MAU.Email IS NOT NULL AND LEN(MAU.Email)>0
						END
						ELSE
						BEGIN
							IF EXISTS (SELECT 1 FROM @pMorpheusAppUserType FEED WHERE FEED.Email IS NOT NULL AND LEN(FEED.Email)>0)
							BEGIN
								INSERT INTO Address (GUIDReference,AddressLine1,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,AddressLine2,AddressLine3,AddressLine4,PostCode,[Type_Id]
										,AddressType,Country_Id)
								SELECT @plectronicAddressGuid,FEED.Email,@pUser,@GetDate,@GetDate,NULL,NULL,NULL,NULL,@emailAddressTypeGuid,'ElectronicAddress',@pCountryId
									FROM @pMorpheusAppUserType FEED
									WHERE FEED.Email IS NOT NULL AND LEN(FEED.Email)>0

								INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
								SELECT NEWID(),1,@puser,@GetDate,@GetDate,@GroupId,@plectronicAddressGuid,@pCountryId 
									FROM @pMorpheusAppUserType FEED
									WHERE FEED.Email IS NOT NULL AND LEN(FEED.Email)>0
										AND NOT EXISTS (
											SELECT 1
											FROM OrderedContactMechanism C
											WHERE C.Candidate_Id = @GroupId AND Address_Id = @plectronicAddressGuid
											)
									
								INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
								SELECT NEWID(),1,@puser,@GetDate,@GetDate,CMP.Individual_Id,@plectronicAddressGuid,@pCountryId 
								FROM CollectiveMembership CMP 
								INNER JOIN Collective C ON CMP.Group_Id=C.GUIDReference AND C.GroupContact_Id=CMP.Individual_Id
								WHERE CMP.Group_Id=@GroupId AND CMP.Country_Id=@pCountryId
									AND NOT EXISTS (
											SELECT 1
											FROM OrderedContactMechanism C
											WHERE C.Candidate_Id = CMP.Individual_Id
											AND Address_Id = @plectronicAddressGuid
											)
							END
						END

						-- Group Contact  Update
						IF NOT EXISTS (SELECT 1 FROM Collective WHERE GUIDReference=@GroupId AND GroupContact_Id=@NewGroupContactId) 
						--AND NOT EXISTS(SELECT 1 FROM CollectiveGroupContactHistory CGH WHERE Group_Id=@GroupId AND Individual_Id=@NewGroupContactId) 
						AND (@NewGroupContactId IS NOT NULL)
						AND EXISTS (SELECT 1 FROM CollectiveMembership WHERE Group_Id=@GroupId AND Individual_Id=@NewGroupContactId)
						BEGIN
							UPDATE TOP (1) CollectiveGroupContactHistory SET DateTo=@GetDate,GPSUpdateTimestamp=@GetDate,GPSUser=@GpsUser WHERE Group_Id=@GroupId

							INSERT INTO CollectiveGroupContactHistory (Id,DateFrom,DateTo,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,Group_Id,Individual_Id,Country_Id)
							 VALUES(NEWID(),@GetDate,NULL,@GetDate,@GpsUser,@GetDate,@GroupId,@NewGroupContactId,@pCountryId)

							UPDATE Collective SET GroupContact_Id=@NewGroupContactId,GPSUpdateTimestamp=@GetDate,GPSUser=@GpsUser WHERE GUIDReference=@GroupId AND CountryId=@pCountryId
						END


						DECLARE @MainShopperRoleId UNIQUEIDENTIFIER
						DECLARE @NewDynamicRoleAssignmentId UNIQUEIDENTIFIER

						SELECT @MainShopperRoleId=DR.DynamicRoleId FROM Translation T 
						INNER JOIN DynamicRole DR ON T.TranslationId=Dr.Translation_Id
						INNER JOIN Country c ON c.CountryId=dr.Country_Id
						WHERE KeyName='MainShopperRoleName' AND c.CountryISO2A='MH'


						IF NOT EXISTS (SELECT 1 FROM DynamicRoleAssignment WHERE DynamicRole_Id=@MainShopperRoleId AND Candidate_Id=@IndividualIDofMainShopper AND Group_Id=@GroupId) 
						AND (@IndividualIDofMainShopper IS NOT NULL)
						AND EXISTS (SELECT 1 FROM CollectiveMembership WHERE Group_Id=@GroupId AND Individual_Id=@IndividualIDofMainShopper)
						BEGIN
						  IF EXISTS (SELECT 1 FROM DynamicRoleAssignment WHERE DynamicRole_Id=@MainShopperRoleId  AND Group_Id=@GroupId)
						  BEGIN
							 UPDATE  DynamicRoleAssignmentHistory SET DateTo=@GetDate,GPSUpdateTimestamp=@GetDate,GPSUser=@GpsUser
							 WHERE GUIDReference =(
							 SELECT TOP(1) DRAH.GUIDReference
							 FROM DynamicRoleAssignment DRA 
							 INNER JOIN DynamicRoleAssignmentHistory DRAH ON DRA.DynamicRoleAssignmentId=DRAH.DynamicRoleAssignment_Id 
							 WHERE DRA.DynamicRole_Id=@MainShopperRoleId  AND DRA.Group_Id=@GroupId
							 ORDER BY DRAH.DateFrom DESC)

							 SELECT @NewDynamicRoleAssignmentId=DynamicRoleAssignmentId FROM DynamicRoleAssignment WHERE DynamicRole_Id=@MainShopperRoleId AND Group_Id=@GroupId
							 UPDATE DynamicRoleAssignment SET Candidate_Id=@IndividualIDofMainShopper,GPSUpdateTimestamp=@GetDate,GPSUser=@GpsUser WHERE DynamicRole_Id=@MainShopperRoleId AND Group_Id=@GroupId

							 INSERT INTO DynamicRoleAssignmentHistory(GUIDReference,DateFrom,DateTo,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,DynamicRoleAssignment_Id,DynamicRole_Id,Candidate_Id)
							 SELECT NEWID(),@GetDate,NULL,@GetDate,@GpsUser,@GetDate,@NewDynamicRoleAssignmentId,@MainShopperRoleId,@IndividualIDofMainShopper

						  END
						  ELSE 
						  BEGIN
							 SET @NewDynamicRoleAssignmentId=NEWID()

							 INSERT INTO DynamicRoleAssignment(DynamicRoleAssignmentId,DynamicRole_Id,Candidate_Id,Panelist_Id,Group_Id,GPSUser,CreationTimeStamp,GPSUpdateTimestamp,Country_Id)
							 SELECT @NewDynamicRoleAssignmentId,@MainShopperRoleId,@IndividualIDofMainShopper,NULL,@GroupId,@GpsUser,@GetDate,@GetDate,@pCountryId

							 INSERT INTO DynamicRoleAssignmentHistory(GUIDReference,DateFrom,DateTo,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,DynamicRoleAssignment_Id,DynamicRole_Id,Candidate_Id)
							 SELECT NEWID(),@GetDate,NULL,@GetDate,@GpsUser,@GetDate,@NewDynamicRoleAssignmentId,@MainShopperRoleId,@IndividualIDofMainShopper
						  END
						END
						  DECLARE @ChiefIncomeEarnerRoleNameRoleId UNIQUEIDENTIFIER

						SELECT @ChiefIncomeEarnerRoleNameRoleId=DR.DynamicRoleId FROM Translation T 
						INNER JOIN DynamicRole DR ON T.TranslationId=Dr.Translation_Id
						INNER JOIN Country c ON c.CountryId=dr.Country_Id
						WHERE KeyName='ChiefIncomeEarnerRoleName' AND c.CountryISO2A='MH'


						IF NOT EXISTS (SELECT 1 FROM DynamicRoleAssignment WHERE DynamicRole_Id=@ChiefIncomeEarnerRoleNameRoleId AND Candidate_Id=@IndividualIDofChiefIncomeEarner AND Group_Id=@GroupId) 
								AND (@IndividualIDofChiefIncomeEarner IS NOT NULL)
								AND (@ChiefIncomeEarnerRoleNameRoleId IS NOT NULL)
								AND EXISTS (SELECT 1 FROM CollectiveMembership WHERE Group_Id=@GroupId AND Individual_Id=@IndividualIDofChiefIncomeEarner)
						BEGIN
						  IF EXISTS (SELECT 1 FROM DynamicRoleAssignment WHERE DynamicRole_Id=@ChiefIncomeEarnerRoleNameRoleId  AND Group_Id=@GroupId)
						  BEGIN
							 UPDATE  DynamicRoleAssignmentHistory SET DateTo=@GetDate,GPSUpdateTimestamp=@GetDate,GPSUser=@GpsUser 
							 WHERE GUIDReference =(
							 SELECT TOP(1) DRAH.GUIDReference
							 FROM DynamicRoleAssignment DRA 
							 INNER JOIN DynamicRoleAssignmentHistory DRAH ON DRA.DynamicRoleAssignmentId=DRAH.DynamicRoleAssignment_Id 
							 WHERE DRA.DynamicRole_Id=@ChiefIncomeEarnerRoleNameRoleId  AND DRA.Group_Id=@GroupId
							 ORDER BY DRAH.DateFrom DESC)

							 SELECT @NewDynamicRoleAssignmentId=DynamicRoleAssignmentId FROM DynamicRoleAssignment WHERE DynamicRole_Id=@ChiefIncomeEarnerRoleNameRoleId AND Group_Id=@GroupId
							 UPDATE DynamicRoleAssignment SET Candidate_Id=@IndividualIDofChiefIncomeEarner,GPSUpdateTimestamp=@GetDate,GPSUser=@GpsUser WHERE DynamicRole_Id=@ChiefIncomeEarnerRoleNameRoleId AND Group_Id=@GroupId

							 INSERT INTO DynamicRoleAssignmentHistory(GUIDReference,DateFrom,DateTo,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,DynamicRoleAssignment_Id,DynamicRole_Id,Candidate_Id)
							 SELECT NEWID(),@GetDate,NULL,@GetDate,@GpsUser,@GetDate,@NewDynamicRoleAssignmentId,@ChiefIncomeEarnerRoleNameRoleId,@IndividualIDofChiefIncomeEarner
						  END
						  ELSE 
						  BEGIN
							 SET @NewDynamicRoleAssignmentId=NEWID()

							 INSERT INTO DynamicRoleAssignment(DynamicRoleAssignmentId,DynamicRole_Id,Candidate_Id,Panelist_Id,Group_Id,GPSUser,CreationTimeStamp,GPSUpdateTimestamp,Country_Id)
							 SELECT @NewDynamicRoleAssignmentId,@ChiefIncomeEarnerRoleNameRoleId,@IndividualIDofChiefIncomeEarner,NULL,@GroupId,@GpsUser,@GetDate,@GetDate,@pCountryId

							 INSERT INTO DynamicRoleAssignmentHistory(GUIDReference,DateFrom,DateTo,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,DynamicRoleAssignment_Id,DynamicRole_Id,Candidate_Id)
							 SELECT NEWID(),@GetDate,NULL,@GetDate,@GpsUser,@GetDate,@NewDynamicRoleAssignmentId,@ChiefIncomeEarnerRoleNameRoleId,@IndividualIDofChiefIncomeEarner
						  END
						END

						 DECLARE @MorpheusLevelTest AS TABLE 
						 (
							 AppUserGUID	NVARCHAR (300),
							 AttributeKey	NVARCHAR (300),
							 AttributeName  NVARCHAR (MAX),
							 AttributeValue  NVARCHAR (MAX),
							 CandidateId     UNIQUEIDENTIFIER,
							 AttributeId     UNIQUEIDENTIFIER,
							 DemographicType NVARCHAR (300)
						 )

						IF EXISTS (
							 SELECT 1
							 FROM @pDemographicData D 
							 LEFT JOIN Attribute A ON A.[Key]=D.AttributeKey AND A.Country_Id=@pCountryId
							 WHERE A.[Key] IS NULL 
						)
						BEGIN
							DECLARE @AttributeKeyError NVARCHAR(MAX)
							 SET @AttributeKeyError='Invalid Attribute '+(SELECT TOP (1) D.AttributeKey
							 FROM @pDemographicData D 
							 LEFT JOIN Attribute A ON A.[Key]=D.AttributeKey AND A.Country_Id=@pCountryId
							 WHERE A.[Key] IS NULL)

							 RAISERROR(@AttributeKeyError,16,1)
						END

						 INSERT INTO @MorpheusLevelTest(AppUserGUID,AttributeKey,AttributeName,AttributeValue,CandidateId,AttributeId,DemographicType)
						 SELECT D.AppUserGUID,D.AttributeKey,D.AttributeName,
						 (CASE WHEN A.[Type] = 'Boolean' THEN 
													(CASE UPPER(D.AttributeValue)
														WHEN 'YES' THEN '1'
														WHEN 'NO'  THEN '0'
														WHEN 'TRUE' THEN '1'
														WHEN 'FALSE' THEN '0' 
													ELSE D.AttributeValue END)
								ELSE D.AttributeValue
								END),
						 NA.Candidate_Id,A.GUIDReference,A.[Type]
						 FROM NamedAlias NA 
						 INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NamedAliasContextId
						 INNER JOIN @pDemographicData D ON NA.[Key]=D.AppUserGUID
						 INNER JOIN Attribute A ON A.[Key]=D.AttributeKey
						 WHERE NAC.[Name]=@MorphesAppUserContext

						IF EXISTS (SELECT 1
						FROM  @MorpheusLevelTest D 
						INNER JOIN AttributeValue AV ON D.AttributeId=AV.DemographicId AND AV.CandidateId=D.CandidateId
						LEFT OUTER JOIN dbo.EnumDefinition ED ON ED.Demographic_Id = D.AttributeId AND ED.Value = D.AttributeValue COLLATE SQL_Latin1_General_CP1_CI_AI
						WHERE DemographicType = 'Enum' AND ED.Demographic_Id IS NULL)
						BEGIN
							INSERT INTO [MorpheusErrorLog] ([MessageId],[ErrorMessage])
							SELECT @pMessageID,'Enum definition not found for attribute key:'+ D.AttributeKey
							FROM  @MorpheusLevelTest D 
							INNER JOIN AttributeValue AV ON D.AttributeId=AV.DemographicId AND AV.CandidateId=D.CandidateId
							LEFT OUTER JOIN dbo.EnumDefinition ED ON ED.Demographic_Id = D.AttributeId AND ED.Value = D.AttributeValue COLLATE SQL_Latin1_General_CP1_CI_AI
							WHERE DemographicType = 'Enum' AND ED.Demographic_Id IS NULL

							RAISERROR('Enum definition not found for attribute key:',16,1)
						END

						--IF EXISTS( SELECT 1 FROM [MorpheusErrorLog] WHERE [MessageId]=@pMessageID)
						--BEGIN
						--	ROLLBACK TRANSACTION
						--	RETURN;
						--END


						UPDATE AV SET AV.Value= CASE WHEN DemographicType = 'Boolean'
									THEN 
										CASE UPPER(D.AttributeValue)
										WHEN 'YES'
											THEN '1'
										WHEN 'NO'
											THEN '0'
										WHEN 'TRUE'
											THEN '1'
										WHEN 'FALSE'
											THEN '0'
										ELSE D.AttributeValue
								END
								ELSE D.AttributeValue
							END,AV.GPSUpdateTimestamp=@GetDate,AV.GPSUser=@GpsUser
						FROM  @MorpheusLevelTest D 					
						INNER JOIN AttributeValue AV ON D.AttributeId=AV.DemographicId AND AV.CandidateId=D.CandidateId 
						WHERE DemographicType <> 'Enum'

						UPDATE AV SET AV.Value= D.AttributeValue,AV.GPSUpdateTimestamp=@GetDate,AV.EnumDefinition_Id=ED.Id
						FROM  @MorpheusLevelTest D 
						INNER JOIN AttributeValue AV ON D.AttributeId=AV.DemographicId AND AV.CandidateId=D.CandidateId
						INNER JOIN dbo.EnumDefinition ED ON ED.Demographic_Id = D.AttributeId AND ED.Value = D.AttributeValue COLLATE SQL_Latin1_General_CP1_CI_AI
						WHERE DemographicType = 'Enum'


						 INSERT INTO AttributeValue
						 (
						 GUIDReference,DemographicId,CandidateId,RespondentId,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Address_Id,[Value],
						 [ValueDesc],Country_Id,[FreeText],[Discriminator],[EnumDefinition_Id]
						 ) 					
						 SELECT NEWID(),D.AttributeId,D.CandidateId,NULL,@GPSUser,@GetDate,@GetDate,NULL,D.AttributeValue,NULL,@pCountryId,NULL,
													(
													CASE WHEN D.DemographicType = 'String' THEN 'StringAttributeValue'
														 WHEN D.DemographicType = 'Int' THEN 'IntAttributeValue'
														 WHEN DemographicType = 'Float' THEN 'FloatAttributeValue'
														 WHEN LOWER(DemographicType) IN ('date','datetime') THEN 'DateAttributeValue'
														 WHEN DemographicType = 'Boolean' THEN 'BooleanAttributeValue'
														 WHEN DemographicType = 'Enum' THEN 'EnumAttributeValue'
													END) AS [Discriminator]
													,CASE 
														WHEN DemographicType <> 'Enum' THEN NULL
														WHEN DemographicType = 'Enum'
														THEN ( SELECT ed.ID FROM dbo.EnumDefinition ED 
														WHERE ED.Demographic_Id = D.AttributeId
														AND ED.Value = d.AttributeValue COLLATE SQL_Latin1_General_CP1_CI_AI) END [EnumDefinition_Id]
						 FROM @MorpheusLevelTest D 
						 WHERE NOT EXISTS
						 (
						  SELECT 1 FROM AttributeValue AV 
						  WHERE D.AttributeId=AV.DemographicId AND AV.CandidateId=D.CandidateId 
						 )

						COMMIT TRANSACTION

					END TRY
					BEGIN CATCH
						PRINT 'ERROR'
						PRINT CAST( ERROR_LINE() AS VARCHAR(100))
						PRINT ERROR_MESSAGE()
						ROLLBACK TRANSACTION
						INSERT INTO MorpheusErrorLog ([MessageId],[ErrorMessage]) VALUES (@pMessageID,ERROR_MESSAGE())
						DECLARE @ERROR_MSG NVARCHAR(MAX)
						SET @ERROR_MSG=ERROR_MESSAGE()
						RAISERROR(@ERROR_MSG,16,1)
					END CATCH
				
			END
			ELSE
			BEGIN
				BEGIN TRANSACTION
					BEGIN TRY
						DECLARE @indNamedAliasContextId UNIQUEIDENTIFIER
						DECLARE @AliasKeyForErrorMsg NVARCHAR(200)
						DECLARE @ShortCodeErrorMsg NVARCHAR(200)
						SET @indNamedAliasContextId=(SELECT NamedAliasContextId from NamedAliasContext where Name='MorphesIndividualContext')

						IF EXISTS (SELECT [IndividualIDofAppUser] FROM @pMorpheusAppUserType WHERE [IndividualIDofAppUser] IS NOT NULL AND LEN([IndividualIDofAppUser])>0) 
						AND
						EXISTS (
						SELECT 1 FROM 
						NamedAlias NA 
						INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NAC.NamedAliasContextId
						INNER JOIN @pMorpheusAppUserType TEMP ON TEMP.[IndividualIDofAppUser] = NA.[Key]
						WHERE NAC.[NamedAliasContextId]=@indNamedAliasContextId
						)
						BEGIN
						   SELECT @AliasKeyForErrorMsg='Alias is already exists '+[IndividualIDofAppUser] FROM @pMorpheusAppUserType WHERE [IndividualIDofAppUser] IS NOT NULL AND LEN([IndividualIDofAppUser])>0
						   RAISERROR (@AliasKeyForErrorMsg, 16, 1)
						END

						IF EXISTS (SELECT [IndividualIDofMainShopper]  FROM @pMorpheusAppUserType WHERE [IndividualIDofMainShopper] IS NOT NULL AND LEN([IndividualIDofMainShopper])>0)
						AND
						EXISTS (
						SELECT 1 FROM 
						NamedAlias NA 
						INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NAC.NamedAliasContextId
						INNER JOIN @pMorpheusAppUserType TEMP ON TEMP.[IndividualIDofMainShopper] = NA.[Key]
						WHERE NAC.[NamedAliasContextId]=@indNamedAliasContextId
						)
						BEGIN
						   SELECT @AliasKeyForErrorMsg='Alias is already exists '+[IndividualIDofMainShopper]  FROM @pMorpheusAppUserType WHERE [IndividualIDofMainShopper] IS NOT NULL AND LEN([IndividualIDofMainShopper])>0
						   RAISERROR (@AliasKeyForErrorMsg, 16, 1)
						END

						IF EXISTS (SELECT [IndividualIDofChiefIncomeEarner] AS RoleType FROM @pMorpheusAppUserType WHERE [IndividualIDofChiefIncomeEarner] IS NOT NULL AND LEN([IndividualIDofChiefIncomeEarner])>0)
						AND
						EXISTS (
						SELECT 1 FROM 
						NamedAlias NA 
						INNER JOIN NamedAliasContext NAC ON NA.AliasContext_Id=NAC.NamedAliasContextId
						INNER JOIN @pMorpheusAppUserType TEMP ON TEMP.[IndividualIDofChiefIncomeEarner] = NA.[Key]
						WHERE NAC.[NamedAliasContextId]=@indNamedAliasContextId
						)
						BEGIN
						   SELECT @AliasKeyForErrorMsg='Alias is already exists '+[IndividualIDofChiefIncomeEarner] FROM @pMorpheusAppUserType WHERE [IndividualIDofChiefIncomeEarner] IS NOT NULL AND LEN([IndividualIDofChiefIncomeEarner])>0
						   RAISERROR (@AliasKeyForErrorMsg, 16, 1)
						END

						IF EXISTS (SELECT 1 FROM @pMorpheusAppUserType WHERE [ShortCode] IS NULL OR LEN([ShortCode])=0 OR ISNUMERIC([ShortCode])=0) 
						BEGIN
						   SELECT @ShortCodeErrorMsg='Invalid ShortCode :'+[ShortCode] FROM @pMorpheusAppUserType WHERE [ShortCode] IS NULL OR LEN([ShortCode])=0 OR ISNUMERIC([ShortCode])=0
						   RAISERROR (@ShortCodeErrorMsg, 16, 1)
						END

						
						IF EXISTS (SELECT ShortCode FROM @pMorpheusAppUserType UT INNER JOIN Collective C ON C.[Sequence]=CAST(UT.ShortCode AS INT) WHERE UT.[ShortCode] IS NOT NULL ) 
						BEGIN
						   SELECT @ShortCodeErrorMsg='ShortCode is already exists '+[ShortCode] FROM @pMorpheusAppUserType WHERE [ShortCode] IS NOT NULL
						   RAISERROR (@ShortCodeErrorMsg, 16, 1)
						END

						DECLARE @groupStatusGuid			UNIQUEIDENTIFIER
						DECLARE @groupAssignedStatusGuid	UNIQUEIDENTIFIER
						DECLARE @groupParticipantStatusGuid UNIQUEIDENTIFIER
						DECLARE @groupTerminatedStatusGuid	UNIQUEIDENTIFIER

						SET @groupAssignedStatusGuid = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'GroupAssigned'
									AND Country_Id = @pCountryId
								)
			
						SET @groupParticipantStatusGuid = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'GroupParticipant'
									AND Country_Id = @pCountryId
								)

						SET @groupTerminatedStatusGuid = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'GroupTerminated'
									AND Country_Id = @pCountryId
								)

						SET @groupStatusGuid = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'GroupCandidate'
									AND Country_Id = @pCountryId
								)

						DECLARE @existingroupStatusGuid		UNIQUEIDENTIFIER

						SET @existingroupStatusGuid = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'GroupPreSETed'
									AND Country_Id = @pCountryId
								)

						DECLARE @individualStatusGuid		UNIQUEIDENTIFIER
						DECLARE @individualAssignedGuid		UNIQUEIDENTIFIER
						DECLARE @individualNonParticipent	UNIQUEIDENTIFIER
						DECLARE @individualParticipent		UNIQUEIDENTIFIER
						DECLARE @individualDropOf			UNIQUEIDENTIFIER = NULL

						SET @individualDropOf = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'IndividualTerminated'
									AND Country_Id = @pCountryId
								)

						SET @individualStatusGuid = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'IndividualCandidate'
									AND Country_Id = @pCountryId
								)

						SET @individualAssignedGuid = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'IndividualAssigned'
									AND Country_Id = @pCountryId
								)

						SET @individualNonParticipent = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'IndividualNonParticipant'
									AND Country_Id = @pCountryId
								)

						SET @individualParticipent = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'IndividualParticipant'
									AND Country_Id = @pCountryId
								)

						DECLARE @FromStateIndividualGuid UNIQUEIDENTIFIER
						SET @FromStateIndividualGuid = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'IndividualPreSETed'
									AND Country_Id = @pCountryId
								)
					
						

						

						DECLARE @TitleId UNIQUEIDENTIFIER
						SET @TitleId  = (SELECT 
									Guidreference 
									FROM IndividualTitle 
									WHERE Code = 0 and Country_Id = @pCountryId
									)

						

						DECLARE @PersonalIdentificationId BIGINT

						SET @PersonalIdentificationId = (
								SELECT ISNULL(MAX(PersonalIdentificationId),0) FROM  PersonalIdentification
								)
						
						


						IF OBJECT_ID('tempdb..#Individuals') IS NOT NULL DROP TABLE #Individuals
						CREATE TABLE #Individuals
						(
							RowIndex INT IDENTITY(1,1),
							RoleType VARCHAR(100),
							RoleFlag CHAR(10),
							RoleName VARCHAR(100),
							IndividualId UNIQUEIDENTIFIER,
							Collectivemembershipid UNIQUEIDENTIFIER,
							BusinessId VARCHAR(100),
							PersonalIdentificationId BIGINT,
							IndividualIDofAppUser UNIQUEIDENTIFIER
						)

						IF OBJECT_ID('tempdb..#Roles') IS NOT NULL DROP TABLE Roles

						CREATE TABLE #Roles
						(
							RowIndex INT IDENTITY(1,1),
							IndividualId UNIQUEIDENTIFIER,
							RoleType VARCHAR(100),
							RoleFlag CHAR(10),
							RoleName VARCHAR(100),
						)
						INSERT INTO #Roles (RoleType,RoleFlag,RoleName)
						SELECT RoleType, roleflag,RoleName FROM
						(
							SELECT [IndividualIDofAppUser] AS RoleType,'G' as roleflag,'MainContactRoleName' as RoleName FROM @pMorpheusAppUserType
								UNION
							SELECT [IndividualIDofMainShopper] AS RoleType,'M' as roleflag,'MainShopperRoleName' as RoleName FROM @pMorpheusAppUserType
								UNION
							SELECT [IndividualIDofChiefIncomeEarner] AS RoleType,'C'as roleflag,'ChiefIncomeEarnerRoleName' as RoleName FROM @pMorpheusAppUserType
						)
						AS RoleTable


						

						INSERT INTO #Individuals (RoleType,IndividualId,Collectivemembershipid,PersonalIdentificationId,IndividualIDofAppUser)
						SELECT RoleType,NEWID(),NEWID(),@PersonalIdentificationId, IndividualIDofAppUser FROM
						(
							SELECT [IndividualIDofAppUser] AS RoleType,IndividualIDofAppUser FROM @pMorpheusAppUserType WHERE [IndividualIDofAppUser] IS NOT NULL AND LEN([IndividualIDofAppUser])>0
								UNION
							SELECT [IndividualIDofMainShopper] AS RoleType,IndividualIDofAppUser FROM @pMorpheusAppUserType WHERE [IndividualIDofMainShopper] IS NOT NULL AND LEN([IndividualIDofMainShopper])>0
								UNION
							SELECT [IndividualIDofChiefIncomeEarner] AS RoleType,IndividualIDofAppUser FROM @pMorpheusAppUserType WHERE [IndividualIDofChiefIncomeEarner] IS NOT NULL AND LEN([IndividualIDofChiefIncomeEarner])>0
						)
						AS RoleTable

						UPDATE tmp SET tmp.IndividualId = IND.IndividualId FROM #Roles tmp INNER JOIN #Individuals IND ON IND.RoleType = tmp.RoleType

						UPDATE #Individuals SET PersonalIdentificationId = (PersonalIdentificationId + RowIndex);

						/********PERSONAL IDENTIFICATION START*********/
			
						SET IDENTITY_INSERT PersonalIdentification ON

						INSERT INTO PersonalIdentification (
						PersonalIdentificationId,DateOfBirth,LastOrderedName,MiddleOrderedName,FirstOrderedName,TitleId,Country_Id,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
						SELECT PersonalIdentificationId,ISNULL(MAU.DateOfBirth,'1-1-1990'),'preallocated',null,ISNULL(MAU.Name,'preallocated'),@TitleId,@pCountryId,'GPS',@GetDate,@GetDate 
						FROM #Individuals i 
						JOIN @pMorpheusAppUserType MAU ON MAU.IndividualIDofAppUser = i.IndividualIDofAppUser

						SET IDENTITY_INSERT PersonalIdentification OFF
						/********PERSONAL IDENTIFICATION END*********/
		

    					DECLARE @GroupAlias NVARCHAR(100)=(SELECT AppUserGUID from @pMorpheusAppUserType)						
						DECLARE @GroupSequence	NVARCHAR(500)=(SELECT TOP (1) ShortCode from @pMorpheusAppUserType)

						IF EXISTS (SELECT * from NamedAlias where [Key]=@GroupAlias)
						BEGIN
							SET @GroupId=(SELECT TOP 1 Candidate_Id from NamedAlias where [Key]=@GroupAlias)
						END
						ELSE
						BEGIN
							SET @GroupId=NEWID()
						END


						

			
						/********CANDIDATE INSERT WITH INDIVIDUAL ID AND GROUP ID*********/

						INSERT INTO Candidate (GUIDReference,ValidFromDate,EnrollmentDate,Comments,CandidateStatus,GeographicArea_Id,RewardsAccountGUID_Id,PreallocatedBatch_Id
							,GPSUser,CreationTimeStamp,GPSUpdateTimestamp,Country_Id)
						SELECT IndividualId,@GetDate,@GetDate,NULL,@individualStatusGuid,null,NULL,NULL,@pUser,@GetDate,@GetDate,@pCountryId 
							FROM #Individuals 				

						INSERT INTO Candidate (GUIDReference,ValidFromDate,EnrollmentDate,Comments,CandidateStatus,GeographicArea_Id,RewardsAccountGUID_Id,PreallocatedBatch_Id,GPSUser
								,CreationTimeStamp,GPSUpdateTimestamp,Country_Id)
						SELECT @GroupId,@GetDate,@GetDate,NULL,@groupStatusGuid,null,NULL,NULL,@pUser,@GetDate,@GetDate,@pCountryId
							WHERE NOT EXISTS (SELECT 1 FROM Candidate C WHERE C.GUIDReference = @GroupId)

						/********CANDIDATE INSERT WITH INDIVIDUAL ID AND GROUP ID*********/


						/********GROUP POSTAL ADDRESS INSERT *********/
				
						INSERT INTO Address (GUIDReference,AddressLine1,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,AddressLine2,AddressLine3,AddressLine4,PostCode
								,[Type_Id],AddressType,Country_Id)
						SELECT @postalAddressId,FEED.AddressLine1,@pUser,@GetDate,@GetDate,FEED.AddressLine2,FEED.AddressLine3,FEED.AddressLine4,FEED.PostCode,@postalAddressTypeGuid
								,'PostalAddress',@pCountryId FROM @pMorpheusAppUserType FEED

						INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
						SELECT NEWID(),1,@puser,@GetDate,@GetDate,@GroupId,@postalAddressId,@pCountryId
							WHERE  NOT EXISTS (
									SELECT 1
									FROM OrderedContactMechanism C
									WHERE C.Candidate_Id = @GroupId
									)


						INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
						SELECT NEWID(),1,@puser,@GetDate,@GetDate,I.IndividualId,@postalAddressId,@pCountryId FROM #Individuals  I 
						

						/********GROUP POSTAL ADDRESS INSERT *********/


						/********GROUP EMAIL ADDRESS INSERT *********/
						IF EXISTS (SELECT 1 FROM @pMorpheusAppUserType FEED WHERE FEED.Email IS NOT NULL AND LEN(FEED.Email)>0)
						BEGIN
						INSERT INTO Address (GUIDReference,AddressLine1,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,AddressLine2,AddressLine3,AddressLine4,PostCode,[Type_Id]
								,AddressType,Country_Id)
						SELECT @plectronicAddressGuid,FEED.Email,@pUser,@GetDate,@GetDate,NULL,NULL,NULL,NULL,@emailAddressTypeGuid,'ElectronicAddress',@pCountryId
							FROM @pMorpheusAppUserType FEED
							WHERE FEED.Email IS NOT NULL AND LEN(FEED.Email)>0

						INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
						SELECT NEWID(),1,@puser,@GetDate,@GetDate,@GroupId,@plectronicAddressGuid,@pCountryId 
							FROM @pMorpheusAppUserType FEED
							WHERE FEED.Email IS NOT NULL AND LEN(FEED.Email)>0
								AND NOT EXISTS (
									SELECT 1
									FROM OrderedContactMechanism C
									WHERE C.Candidate_Id = @GroupId AND Address_Id = @plectronicAddressGuid
									)
									
						INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
						SELECT NEWID(),1,@puser,@GetDate,@GetDate,I.IndividualId,@plectronicAddressGuid,@pCountryId FROM #Individuals I INNER JOIN #Roles R ON R.RoleType = I.RoleType where R.RoleFlag = 'G'						
							AND NOT EXISTS (
									SELECT 1
									FROM OrderedContactMechanism C
									WHERE C.Candidate_Id = (SELECT I.IndividualId FROM #Individuals I INNER JOIN #Roles R ON R.RoleType = I.RoleType where R.RoleFlag = 'G') 
									AND Address_Id = @plectronicAddressGuid
									)
						END

						/********GROUP EMAIL ADDRESS INSERT *********/


						/********GROUP HOME PHONE ADDRESS INSERT *********/	
			
						INSERT INTO [Address] (GUIDReference,AddressLine1,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,[Type_Id],AddressType,Country_Id)
						SELECT @phonelAddressId,tp.PhoneNumberHome,@pUser,@GetDate,@GetDate,@homeAddressTypeGuid,'PhoneAddress',@pCountryId				
						FROM @pMorpheusAppUserType tp
						WHERE tp.PhoneNumberHome IS NOT NULL AND LEN(tp.PhoneNumberHome)>0

						IF EXISTS(SELECT 1 FROM @pMorpheusAppUserType tp WHERE tp.PhoneNumberHome IS NOT NULL AND LEN(tp.PhoneNumberHome)>0)
						BEGIN
							INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
							SELECT NEWID(),1,@puser,@GetDate,@GetDate,@GroupId,@phonelAddressId,@pCountryId
								WHERE NOT EXISTS (
										SELECT 1
										FROM OrderedContactMechanism C
										WHERE C.Candidate_Id = @GroupId
										AND Address_Id = @phonelAddressId
										)

							INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
							SELECT NEWID(),1,@puser,@GetDate,@GetDate,I.IndividualId,@phonelAddressId,@pCountryId FROM #Individuals I INNER JOIN #Roles R ON R.RoleType = I.RoleType where R.RoleFlag = 'G'
								AND NOT EXISTS (
										SELECT 1
										FROM OrderedContactMechanism C
										WHERE C.Candidate_Id = (SELECT I.IndividualId FROM #Individuals I INNER JOIN #Roles R ON R.RoleType = I.RoleType where R.RoleFlag = 'G')
										AND Address_Id = @phonelAddressId
										)
						END

						/********GROUP HOME PHONE ADDRESS INSERT *********/	

						/********GROUP MOBILE PHONE ADDRESS INSERT *********/	

						INSERT INTO [Address] (GUIDReference,AddressLine1,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,[Type_Id],AddressType,Country_Id)
						SELECT @mobilephonelAddressId,tp.PhoneNumberMobile,@pUser,@GetDate,@GetDate,@mobileAddressTypeGuid,'PhoneAddress',@pCountryId				
						FROM @pMorpheusAppUserType tp
						WHERE tp.PhoneNumberMobile IS NOT NULL AND LEN(tp.PhoneNumberMobile)>0

						IF EXISTS(SELECT 1 FROM @pMorpheusAppUserType tp WHERE tp.PhoneNumberMobile IS NOT NULL AND LEN(tp.PhoneNumberMobile)>0)
						BEGIN
							INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
							SELECT NEWID(),2,@puser,@GetDate,@GetDate,@GroupId,@mobilephonelAddressId,@pCountryId
								WHERE NOT EXISTS (
										SELECT 1
										FROM OrderedContactMechanism C
										WHERE C.Candidate_Id = @GroupId
										AND Address_Id = @mobilephonelAddressId
										)

							INSERT INTO OrderedContactMechanism (Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
							SELECT NEWID(),1,@puser,@GetDate,@GetDate,I.IndividualId,@mobilephonelAddressId,@pCountryId FROM #Individuals I INNER JOIN #Roles R ON R.RoleType = I.RoleType where R.RoleFlag = 'G'
								AND NOT EXISTS (
										SELECT 1
										FROM OrderedContactMechanism C
										WHERE C.Candidate_Id = (SELECT I.IndividualId FROM #Individuals I INNER JOIN #Roles R ON R.RoleType = I.RoleType where R.RoleFlag = 'G')
										AND Address_Id = @mobilephonelAddressId
										)
						END
						/********GROUP MOBILE PHONE ADDRESS INSERT *********/	



						DECLARE @sexId UNIQUEIDENTIFIER
						DECLARE @pGENDer nvarchar(30) = (SELECT TOP 1 Gender FROM @pMorpheusAppUserType)
						IF (@pGENDer IS NULL) SET @pGENDer='Male'
						SET @sexId=(SELECT I.GUIDReference from Individualsex I inner join translation T on I.Translation_Id=T.TranslationId where T.KeyName= @pGENDer and I.Country_Id =@pCountryId)
						DECLARE @BusinessId NVARCHAR(300)

			
						/********CALCULATING GROUP SEQUENCE*********/	

						--IF NOT EXISTS (SELECT * from Collective where GUIDReference =@GroupId)
						--BEGIN
						--	SET @GroupSequence=(SELECT ISNULL(MAX(Sequence), 0)+1 from Collective)
						--END
						--ELSE
						--BEGIN
						--	SET @GroupSequence=(SELECT Sequence from Collective where GUIDReference =@GroupId)
						--END
						
						--SET @GroupSequence= CASE WHEN CAST(@GroupSequence AS INT) > 10000 THEN @GroupSequence ELSE  '10000'+ @GroupSequence END
						
						DECLARE @collecivesequence INT
						IF  EXISTS (SELECT Sequence FROM CollectiveMembership where Group_Id =@GroupId)
						BEGIN
							SET @collecivesequence=(SELECT ISNULL(MAX(Sequence), 0)+1 FROM CollectiveMembership where Group_Id =@GroupId)
							SET @collecivesequence=@collecivesequence+1
							IF @collecivesequence<9
							BEGIN
								SET @BusinessId=@GroupSequence+'-'+'0'+ CAST(@collecivesequence AS NVARCHAR(100))
							END
							ELSE
							BEGIN
								SET @BusinessId=@GroupSequence+ CAST(@collecivesequence AS nvarchar(100))
							END
						END
						ELSE
						BEGIN
							SET @BusinessId=@GroupSequence+'-'+'0'+ CAST(1 AS nvarchar(100))
						END

					PRINT 'BUSINESS'
					print @BusinessId
					print @collecivesequence

					UPDATE #Individuals SET BusinessId = @GroupSequence +'-'+'0' + CAST(RowIndex AS VARCHAR(10));
					


					/********CALCULATING GROUP SEQUENCE*********/	

		 
					/********INDIVIDUAL CREATION*********/	
					PRINT 'Individual Creation'

					INSERT INTO Individual (GUIDReference,PersonalIdentificationId,Sex_Id,Referer,Event_Id,CharitySubscription_Id,Participant,IndividualId,CATI3DCode
						,MainPostalAddress_Id,MainPhoneAddress_Id,MainEmailAddress_Id,CountryId,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
					SELECT IndividualId,PersonalIdentificationId,@sexId,null,NULL,NULL,1,BusinessId,NULL,@postalAddressId ,
							CASE WHEN @phonelAddressId  IS NOT NULL 
							AND EXISTS(SELECT 1 FROM @pMorpheusAppUserType tp WHERE tp.PhoneNumberHome IS NOT NULL AND LEN(tp.PhoneNumberHome)>0)
									THEN @phonelAddressId 
								ELSE NULL
							END
							,CASE 
								WHEN @plectronicAddressGuid  IS NOT NULL 
								AND EXISTS (
										SELECT 1
										FROM OrderedContactMechanism C
										WHERE C.Candidate_Id = @GroupId AND Address_Id = @plectronicAddressGuid
									)
									THEN @plectronicAddressGuid 
								ELSE NULL
							END
						,@pCountryId,@pUser,@GetDate,@GetDate
					from #Individuals


					UPDATE COLLECTIVE SET GroupContact_Id = (SELECT I.IndividualId FROM #Individuals I INNER JOIN #Roles R ON R.RoleType = I.RoleType where R.RoleFlag = 'G') WHERE GUIDReference = @GroupId

						SELECT @individualId

						PRINT 'Individual Creation' 

						/********INDIVIDUAL CREATION*********/	

						DECLARE @collectiveTranslationId UNIQUEIDENTIFIER
						DECLARE @individualDescriptotId UNIQUEIDENTIFIER
						DECLARE @GroupcontactId nvarchar(200)

						SET @collectiveTranslationId = (
								SELECT TranslationId
								FROM Translation
								WHERE KeyName = 'MorpheusIndAliasStrategyTypeDescriptor'
								)


					/*******INCENTIVE ACCOUNT*************/

					INSERT INTO IncentiveAccount (IncentiveAccountId,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Beneficiary_Id,[Type],Country_Id)
					SELECT IndividualId,@pUser ,@GetDate,@GetDate,null,'OwnAccount',@pCountryId FROM #Individuals

					/*******INCENTIVE ACCOUNT*************/

					/********NAMED ALIAS CREATION*********/	

					DECLARE @aliasIndKey nvarchar(500)
					DECLARE @indcontextId UNIQUEIDENTIFIER
					SET @indcontextId=(SELECT NamedAliasContextId from NamedAliasContext where Name='MorphesIndividualContext')
					SET @aliasIndKey=(SELECT AppUserGUID  from @pMorpheusAppUserType) 

					INSERT INTO NamedAlias (NamedAliasId, [Key], AliasContext_Id, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, [Guid], Incentive_Id, Candidate_Id, [Type])
					SELECT NEWID() as NamedAliasId,RoleType,@indcontextId,@pUser as GPSUser,@GetDate as GPSUpdateTimestamp,@GetDate as CreationTimeStamp,
								NULL as [Guid],NULL as Incentive_Id,IndividualId,'CandidateAlias' as [Type]
								FROM #Individuals 
					

				/********NAMED ALIAS CREATION*********/	

				/********COLLECTIVE CREATION*********/	
				print @GroupSequence
					SET @GroupcontactId=(SELECT IndividualIDofAppUser from @pMorpheusAppUserType)
					SET @collectiveTranslationId = (
							SELECT TranslationId
								FROM Translation
								WHERE KeyName = 'HouseHoldGroup'
								)

					INSERT INTO Collective (GUIDReference,TypeTranslation_Id,Sequence,DiscriminatorType,GroupContact_Id,IsDuplicate,CountryId,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
					SELECT @GroupId,@collectiveTranslationId,@GroupSequence,'HouseHold',null,0,@pCountryId,@pUser,@GetDate,@GetDate
							   WHERE NOT EXISTS (
									SELECT 1
									FROM Collective C
									WHERE C.GUIDReference = @GroupId
									)



					UPDATE COLLECTIVE SET GroupContact_Id = (SELECT I.IndividualId FROM #Individuals I INNER JOIN #Roles R ON R.RoleType = I.RoleType where R.RoleFlag = 'G') WHERE GUIDReference = @GroupId

					/********COLLECTIVE CREATION*********/	

					DECLARE @FromStateGroupMembershipGuid UNIQUEIDENTIFIER
					DECLARE @collectivemembershipid UNIQUEIDENTIFIER=newid()
					SET @FromStateGroupMembershipGuid = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'GroupMembershipPreSETed'
									AND Country_Id = @pCountryId
								)

					DECLARE @PanelistDefaultStateId UNIQUEIDENTIFIER
					SELECT @PanelistDefaultStateId = (
								SELECT TOP 1 st.ToState_Id
								FROM statedefinition sd
								INNER JOIN StateDefinitionsTransitions SDT ON SDT.StateDefinition_Id = SD.Id
								INNER JOIN StateTransition st ON st.Id = sdt.AvailableTransition_Id
									AND sd.Country_Id = @pCountryId
								WHERE sd.code = 'PanelistPreSETedState'
								ORDER BY st.[Priority]
								)	



					DECLARE @defaultGroupMembershipStatusId UNIQUEIDENTIFIER
					SET @defaultGroupMembershipStatusId = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'GroupMembershipResident'
									AND Country_Id = @pCountryId
								)

					/********COLLECTIVE MEMBERSHIP CREATION*********/	

					INSERT INTO CollectiveMembership (CollectiveMembershipId,Sequence,SignUpDate,DeletedDate,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,State_Id,Group_Id,Individual_Id
								,DiscriminatorType,Country_Id)
					SELECT Collectivemembershipid
								,(SELECT (ISNULL(MAX(Sequence), 0) + RowIndex) from CollectiveMembership where Group_Id=@GroupId)
								,ISNULL(MAU.JoinDate, @GetDate),NULL,@pUser,@GetDate,@GetDate,@defaultGroupMembershipStatusId,@GroupId,IndividualId,'HouseHold',@pCountryId 
								FROM #Individuals i 
								JOIN @pMorpheusAppUserType MAU ON i.IndividualIDofAppUser = MAU.IndividualIDofAppUser

						/********STATE DEFINITION HISTORY CREATION*********/	

						INSERT INTO StateDefinitionHistory (GUIDReference,GPSUser,CreationDate,GPSUpdateTimestamp,CreationTimeStamp,Comments,CollaborateInFuture,From_Id,To_Id
									,ReasonForchangeState_Id,Country_Id,GroupMembership_Id)
						SELECT NEWID(),@pUser,@GetDate,@GetDate,@GetDate,NULL,0,@FromStateGroupMembershipGuid,@defaultGroupMembershipStatusId,NULL,@pCountryId,Collectivemembershipid
							FROM #Individuals
		
						/********STATE DEFINITION HISTORY CREATION*********/	

					/********COLLECTIVE MEMBERSHIP CREATION*********/	


					DECLARE @PanelistPreSETedStateId UNIQUEIDENTIFIER
					DECLARE @PanelistDropoutStateId AS UNIQUEIDENTIFIER
					DECLARE @PanelistRefusalStateId AS UNIQUEIDENTIFIER
					DECLARE @PanelistLiveStateId as UNIQUEIDENTIFIER

					SELECT @PanelistLiveStateId = Id
						FROM StateDefinition
						WHERE Code = 'PanelistLiveState'
							AND Country_Id = @pCountryId

					SELECT @PanelistDropoutStateId = Id
						FROM StateDefinition
						WHERE Code = 'PanelistDroppedOffState'
							AND Country_Id = @pCountryId

					SELECT @PanelistRefusalStateId = Id
						FROM StateDefinition
						WHERE Code = 'PanelistRefusalState'
							AND Country_Id = @pCountryId

					SELECT @PanelistDefaultStateId = (
								SELECT TOP 1 st.ToState_Id
								FROM statedefinition sd
								INNER JOIN StateDefinitionsTransitions SDT ON SDT.StateDefinition_Id = SD.Id
								INNER JOIN StateTransition st ON st.Id = sdt.AvailableTransition_Id
									AND sd.Country_Id = @pCountryId
								WHERE sd.code = 'PanelistPreSETedState'
								ORDER BY st.[Priority]
								)

					SELECT @PanelistPreSETedStateId = Id
						FROM StateDefinition
						WHERE Code = 'PanelistPreSETedState'
							AND Country_Id = @pCountryId

					DECLARE @panelistId UNIQUEIDENTIFIER =	NEWID()
					DECLARE @panelguId UNIQUEIDENTIFIER
					SET @panelguId=(SELECT GUIDReference from Panel where Name='Morpheus')


					/********PANELIST CREATION*********/	
		
					IF EXISTS (SELECT 1 FROM #Individuals I INNER JOIN #Roles R ON R.RoleType = I.RoleType where R.RoleFlag = 'G')
					BEGIN

						INSERT INTO Panelist (GUIDReference,CreationDate,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Panel_Id,RewardsAccount_Id,PanelMember_Id,CollaborationMethodology_Id,State_Id,IncentiveLevel_Id,ExpectedKit_Id
									,ChangeReason_Id,Country_Id)
						SELECT @panelistId,@GetDate,@pUser,@GetDate,@GetDate,@panelguId,NULL,@GroupId
									,(SELECT top 1 GUIDReference from CollaborationMethodology )
									,@PanelistLiveStateId,null,NULL,null,@pCountryId
		 						FROM #Individuals I INNER JOIN #Roles R ON R.RoleType = I.RoleType where R.RoleFlag = 'G'

						INSERT INTO StateDefinitionHistory (GUIDReference,GPSUser,CreationDate,GPSUpdateTimestamp,CreationTimeStamp,Comments,CollaborateInFuture,From_Id
									,To_Id,ReasonForchangeState_Id,Country_Id,Panelist_Id)
						SELECT NEWID(),@pUser,@GetDate,@GetDate,@GetDate,NULL,0,@PanelistPreSETedStateId,@PanelistLiveStateId,NULL,@pCountryId,@panelistId
								FROM IncentiveLevel IL where  IL.Panel_Id = @panelguId AND IL.[Description] = 'DEFAULT' AND IL.Country_Id = @pCountryId

					END

					/********PANELIST CREATION*********/	

		


					/********NAMED ALIAS CREATION*********/	
		
					DECLARE @aliasGroupKey nvarchar(500)
					DECLARE @contextId UNIQUEIDENTIFIER
					SET @contextId=(SELECT NamedAliasContextId from NamedAliasContext where Name='MorphesAppUserContext')
					SET @aliasGroupKey=(SELECT AppUserGUID  from @pMorpheusAppUserType) 

					INSERT INTO NamedAlias (NamedAliasId, [Key], AliasContext_Id, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, [Guid], Incentive_Id, Candidate_Id, [Type])
					SELECT NEWID() as NamedAliasId,@aliasGroupKey,@contextId,@pUser as GPSUser,@GetDate as GPSUpdateTimestamp,@GetDate as CreationTimeStamp,
								NULL as [Guid],NULL as Incentive_Id,@GroupId,'CandidateAlias' as [Type]
						WHERE NOT EXISTS (
									SELECT 1
									FROM NamedAlias C
									WHERE [Key] = @aliasGroupKey AND [AliasContext_Id]=@contextId
									)
			
					/********NAMED ALIAS CREATION*********/		


					/********COLLABORATION METHODOLOGY CREATION*********/		

		
					INSERT INTO CollaborationMethodologyHistory(GUIDReference,GPSUpdateTimestamp,CreationTimeStamp,[Date],GPSUser,Comments,Panelist_Id,OldCollaborationMethodology_Id,
								NewCollaborationMethodology_Id,Country_Id,CollaborationMethodologyChangeReason_Id)
					SELECT NEWID(),@GetDate,@GetDate,@GetDate,@pUser,null,@panelistId,NULL,(SELECT top 1 GUIDReference from CollaborationMethodology),@pCountryId,null

					/********COLLABORATION METHODOLOGY CREATION*********/	
		
			
					/********DYNAMIC ROLES CREATION*********/	

					CREATE TABLE #DyniamicRoles (
						DynamicRoleId UNIQUEIDENTIFIER
						,GroupId UNIQUEIDENTIFIER
						,IndividualId UNIQUEIDENTIFIER
						)

		
					INSERT INTO #DyniamicRoles (DynamicRoleId,GroupId,IndividualId)
					SELECT DR.DynamicRoleId,@GroupId,IndividualId FROM  					
							DynamicRole DR inner join Translation T ON DR.Translation_Id = T.TranslationId
							INNER JOIN  #Roles I ON I.RoleName = T.KeyName COLLATE SQL_Latin1_General_CP1_CI_AS
							AND DR.Country_Id = @pCountryId
										

					INSERT INTO DynamicRoleAssignment (DynamicRoleAssignmentId,DynamicRole_Id,Candidate_Id,Group_Id,CreationTimeStamp,GPSUpdateTimestamp,GPSUser,Country_Id)
					SELECT NEWID(),DR.DynamicRoleId,DR.IndividualId,DR.GroupId,@GetDate,@GetDate,@pUser,@pCountryId 
						FROM #DyniamicRoles DR
						WHERE NOT EXISTS (
							SELECT 1
							FROM DynamicRoleAssignment DRA
							WHERE DR.GroupId = DRA.Group_Id
								AND DR.DynamicRoleId = DRA.DynamicRole_Id
							)

					INSERT INTO DynamicRoleAssignmentHistory (GUIDReference,DateFrom,CreationTimeStamp,GPSUser,GPSUpdateTimestamp,DynamicRoleAssignment_Id,DynamicRole_Id,Candidate_Id)
					SELECT NEWID(),@GetDate,@GetDate,@pUser,@GetDate,DRA.DynamicRoleAssignmentId,DRA.DynamicRole_Id,DRA.Candidate_Id 
						FROM DynamicRoleAssignment DRA
						INNER JOIN #DyniamicRoles TDR ON TDR.GroupId = DRA.Group_Id
							AND TDR.DynamicRoleId = DRA.DynamicRole_Id
							AND TDR.IndividualId = DRA.Candidate_Id


					/********DYNAMIC ROLES CREATION*********/	


					/********DEMOGRAPHICS CREATION*********/	

					IF OBJECT_ID('tempdb..#Demographics') IS NOT NULL DROP TABLE #Demographics
					CREATE TABLE #Demographics (
						DemographicId UNIQUEIDENTIFIER
						,IndividualId UNIQUEIDENTIFIER
						,DemographicValue NVARCHAR(MAX)
						,DemographicType VARCHAR(10)
						,DemographicName NVARCHAR(MAX)
						,Rownumber INT
						,AttributeValueId UNIQUEIDENTIFIER DEFAULT NEWID()
						,FromRange DECIMAL(18, 2)
						,ToRange DECIMAL(18, 2)
						,MinimumLength INT
						,MaximumLength INT
						,DateFrom DATETIME
						,DateTo DATETIME
						,Today BIT
						,AttributeScope varchar(100)
						)


					INSERT INTO #Demographics (DemographicId,IndividualId,DemographicValue,DemographicType,DemographicName,Rownumber,FromRange,ToRange,MinimumLength,MaximumLength,DateFrom
						,DateTo,Today,AttributeScope)
					SELECT A.GUIDReference,@GroupId,demo.[AttributeValue],A.[Type],demo.[AttributeName],null,A.[From],A.[To],A.[MinLength],A.[MaxLength],A.[DateFrom],A.[DateTo],A.Today,null
						FROM  @pDemographicData demo
						INNER JOIN Attribute A ON A.[Key] = demo.[AttributeKey]
							AND Country_Id = @pCountryId
						WHERE demo.[AttributeValue] IS NOT NULL
							AND demo.[AttributeValue] <> ''


					INSERT INTO AttributeValue (GUIDReference,DemographicId,CandidateId,RespondentId,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Address_Id,[Value],[ValueDesc]
							,[EnumDefinition_Id],[FreeText],[Discriminator]	,Country_Id)
					SELECT NEWID(),d.DemographicId,@groupId,NULL,@pUser,@GetDate,@GetDate,NULL
							,CASE 
								WHEN DemographicType = 'String'
									THEN DemographicValue
								WHEN DemographicType = 'Int'
									THEN DemographicValue
								WHEN DemographicType = 'Float'
									THEN DemographicValue
								WHEN LOWER(DemographicType) IN ('date','datetime')
									THEN CONVERT (VARCHAR(30), CONVERT(DATETIME,DemographicValue),20)
								WHEN DemographicType = 'Boolean'
									THEN CASE UPPER(DemographicValue)
								WHEN 'YES'
									THEN '1'
								WHEN 'NO'
									THEN '0'
								WHEN 'TRUE'
									THEN '1'
								WHEN 'FALSE'
									THEN '0'
								ELSE DemographicValue
								END
							END
							,NULL
							,CASE 
								WHEN DemographicType = 'Enum'
									THEN ( SELECT ed.ID FROM dbo.EnumDefinition ED 
								WHERE ED.Demographic_Id = d.DemographicId
											AND ED.Value = d.DemographicValue COLLATE SQL_Latin1_General_CP1_CI_AI) 
							 END [EnumDefinition_Id]
							,NULL
							,CASE 
								WHEN DemographicType = 'String'
									THEN 'StringAttributeValue'
								WHEN DemographicType = 'Int'
									THEN 'IntAttributeValue'
								WHEN DemographicType = 'Float'
									THEN 'FloatAttributeValue'
								WHEN LOWER(DemographicType) IN ('date','datetime')
									THEN 'DateAttributeValue'
								WHEN DemographicType = 'Boolean'
									THEN 'BooleanAttributeValue'
								WHEN DemographicType = 'Enum'
									THEN 'EnumAttributeValue'
							END AS [Discriminator]
									,@pCountryId
						FROM #Demographics d
			
					/********DEMOGRAPHICS CREATION*********/	


					PRINT 'MorpheusAppUserInsert PROCESS END'
					COMMIT TRANSACTION

					END TRY
					BEGIN CATCH						
						PRINT 'ERROR'
						PRINT ERROR_MESSAGE()
						PRINT ERROR_LINE()
						ROLLBACK TRANSACTION
						INSERT INTO MorpheusErrorLog ([MessageId],[ErrorMessage]) VALUES (@pMessageID,ERROR_MESSAGE())
						DECLARE @ERROR_MESSAGE NVARCHAR(MAX)
						SET @ERROR_MESSAGE=ERROR_MESSAGE()
						RAISERROR(@ERROR_MESSAGE,16,1)
					END CATCH
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