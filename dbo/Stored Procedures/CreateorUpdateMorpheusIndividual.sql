CREATE PROCEDURE [dbo].[CreateorUpdateMorpheusIndividual] (
	@pMorphuesFeed [MorpheusIndidvidualFeed] READONLY	
	,@pMessageID UNIQUEIDENTIFIER 
	,@pCountryISO2A NVARCHAR(4)
	,@pCultureCode INT
	)
AS
BEGIN --1
	SET XACT_ABORT ON;
	SET NOCOUNT ON;

	DECLARE @pMorphuesFeedInternal [MorpheusIndidvidualFeed]
	INSERT INTO @pMorphuesFeedInternal SELECT * FROM @pMorphuesFeed

	
	DECLARE @pCountryId UNIQUEIDENTIFIER
	SET @pCountryId = (SELECT CountryId FROM COUNTRY WHERE CountryISO2A = @pCountryISO2A)

	DECLARE @GetDate DATETIME
	
	IF (SELECT dbo.GetLocalDateTimeByCountryId(GETDATE(),@pCountryId)) IS NOT NULL
	BEGIN
		SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(GETDATE(),@pCountryId))
	END
	ELSE
	BEGIN
		SET @GetDate = GETDATE()
	END

	DECLARE @pUser NVARCHAR(200)
	SET @pUser = 'MorpheusUser'

	DECLARE @pSystemDate DATETIME
	SET @pSystemDate = getdate()


	DECLARE @groupIndividualIdSeqCount INT

		SET @groupIndividualIdSeqCount = (
				SELECT CC.IndividualBusinessIdDigits
				FROM CountryConfiguration CC
				INNER JOIN Country C ON CC.Id = C.Configuration_Id
				WHERE C.CountryId = @pCountryId
				)
	DECLARE @individualStatusGuid UNIQUEIDENTIFIER
		DECLARE @individualAssignedGuid UNIQUEIDENTIFIER
		DECLARE @individualNonParticipent UNIQUEIDENTIFIER
		DECLARE @individualParticipent UNIQUEIDENTIFIER
		DECLARE @individualDropOf UNIQUEIDENTIFIER = NULL

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
				WHERE Code = 'IndividualPreseted'
					AND Country_Id = @pCountryId
				)

		DECLARE @AliasContext_Id UNIQUEIDENTIFIER

		SET @AliasContext_Id = (
				SELECT NamedAliasContextId
				FROM NamedAliasContext
				WHERE Name = 'MorpheusIndividualContext'
					AND Country_Id = @pCountryId
				)
	
	IF OBJECT_ID('tempdb..#MorphuesFeedData') IS NOT NULL DROP TABLE #MorphuesFeedData
			CREATE TABLE #MorphuesFeedData (
				Rownumber INT Identity(1,1) NOT NULL
				,AppUserGUID NVARCHAR(300)  Collate Database_Default NULL
				,IndividualAlias NVARCHAR(300)  Collate Database_Default NULL
				,FirstName NVARCHAR(300) Collate Database_Default NULL 
				,LastName NVARCHAR(300) Collate Database_Default NULL
				,DateOfBirth DATETIME NULL
				,LeftHousehold NVARCHAR(100)   Collate Database_Default NULL
				,LeftHouseholdDate NVARCHAR(100)   Collate Database_Default NULL
				,Sex NVARCHAR(100)  Collate Database_Default NULL
				,IndividualGuid UNIQUEIDENTIFIER  NULL DEFAULT NEWID()
				,IndividualId VARCHAR(20)Collate Database_Default  NULL
				,GroupGuid UNIQUEIDENTIFIER  NULL --DEFAULT NEWID()
				,GroupSequence NVARCHAR(100) Collate Database_Default NULL
				,NextCollectiveSequence BIGINT  NULL
				,CollectiveMembershipId UNIQUEIDENTIFIER  NULL DEFAULT NEWID()
				,TitleGuid UNIQUEIDENTIFIER NULL
				,SexGuid UNIQUEIDENTIFIER NULL
				,IndividualRefererGuid UNIQUEIDENTIFIER NULL
				,GroupMembershipStateGuid UNIQUEIDENTIFIER NULL
				,PersonalIdentificationId BIGINT  NULL
				,RecordProcessed INT NULL
				,Title VARCHAR(100) NULL
				)
		
		BEGIN TRANSACTION
		BEGIN TRY

		DECLARE @GroupContextId UNIQUEIDENTIFIER
		DECLARE @IndividualContextId UNIQUEIDENTIFIER
		DECLARE @NonResisdent UNIQUEIDENTIFIER

		SET @GroupContextId = (SELECT NamedAliasContextId FROM NamedAliasContext WHERE Name = 'MorphesAppUserContext')
		SET @IndividualContextId = (SELECT NamedAliasContextId FROM NamedAliasContext WHERE Name = 'MorphesIndividualContext')
		SET @NonResisdent = (SELECT ID FROM StateDefinition WHERE Code='GroupMembershipNonResident' AND Country_Id=@pCountryId )

		DECLARE @InitlaFromStateGroupMembershipGuid UNIQUEIDENTIFIER					
					SET @InitlaFromStateGroupMembershipGuid  = (
								SELECT Id
								FROM StateDefinition
								WHERE Code = 'GroupMembershipPreSETed'
									AND Country_Id = @pCountryId
								)

		DECLARE @AppUserGUID NVARCHAR(100)

		IF EXISTS (SELECT 1
		FROM @pMorphuesFeedInternal FEED
			LEFT JOIN NAMEDALIAS NA ON NA.[KEY]=FEED.AppUserGUID AND NA.AliasContext_Id = @GroupContextId
			WHERE NA.[KEY] IS NULL)
		BEGIN

		SET @AppUserGUID= (SELECT FEED.AppUserGUID
		FROM @pMorphuesFeedInternal FEED
			LEFT JOIN NAMEDALIAS NA ON NA.[KEY]=FEED.AppUserGUID AND NA.AliasContext_Id = @GroupContextId
			WHERE NA.[KEY] IS NULL)

		INSERT INTO [MorpheusErrorLog] ([MessageId],[ErrorMessage])
				SELECT @pMessageID,'AppUserGUID NOT FOUND'+ @AppUserGUID

				DECLARE @Msg NVARCHAR(MAX)
				SET @Msg='AppUserGUID NOT FOUND'+ @AppUserGUID
			RAISERROR(@Msg,16,1)
		END
			

		/* missed row id concept */
		INSERT INTO #MorphuesFeedData (
			AppUserGUID 
			,IndividualAlias
			,FirstName
			,LastName
			,DateOfBirth
			,LeftHousehold
			,LeftHouseholdDate
			,Sex
			,IndividualGuid
			,IndividualId
			,GroupGuid
			,GroupSequence
			,CollectiveMembershipid
			,TitleGuid
			,SexGuid
			,IndividualRefererGuid
			,GroupMembershipStateGuid
			,PersonalIdentificationId
			,RecordProcessed
			,Title
			)
		SELECT FEED.AppUserGUID
			,FEED.IndividualGUID
			,FEED.FirstName
			,FEED.LastName
			,FEED.DateOfBirth
			,FEED.LeftHousehold
			,FEED.LeftHouseholdDate
			,FEED.Gender
			,NEWID()
			,NULL
			,C.GUIDReference
			,C.Sequence
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,0
			,Title
			FROM @pMorphuesFeedInternal FEED
			INNER JOIN NAMEDALIAS NA ON NA.[KEY]=FEED.AppUserGUID
			JOIN COLLECTIVE C ON C.GUIDReference=NA.Candidate_id
			WHERE NA.AliasContext_Id = @GroupContextId

			update #MorphuesFeedData set DateOfBirth = CASE WHEN DateOfBirth IS NOT NULL THEN DATEADD(day,0,DateOfBirth) ELSE DateOfBirth END
			select * from @pMorphuesFeedInternal
		
			DECLARE @FromStateGroupMembershipGuid UNIQUEIDENTIFIER
			SET @FromStateGroupMembershipGuid = (
					SELECT Id
					FROM StateDefinition
					WHERE Code = 'GroupMembershipResident'
						AND Country_Id = @pCountryId
					)
			-----UPDATE FEED TABLE COLUMNS------
			
			UPDATE MFD SET  MFD.RecordProcessed = 1
				FROM #MorphuesFeedData MFD 
				INNER JOIN NamedAlias NM ON NM.[Key] = MFD.IndividualAlias

			UPDATE MFD SET MFD.PersonalIdentificationId = PID.PersonalIdentificationId,MFD.IndividualGuid=I.GUIDReference,MFD.GroupMembershipStateGuid=CM.State_Id,MFD.CollectiveMembershipid = CM.CollectiveMembershipId
						FROM #MorphuesFeedData MFD
							INNER JOIN NAMEDALIAS NA ON NA.[KEY]=MFD.IndividualAlias
							INNER JOIN INDIVIDUAL I ON I.GUIDReference=NA.Candidate_id
							JOIN PERSONALIDENTIFICATION PID ON I.PersonalIdentificationId = PID.PersonalIdentificationId					
							JOIN COLLECTIVEMEMBERSHIP CM ON CM.Individual_Id = I.GUIDReference
						WHERE NA.AliasContext_Id = @IndividualContextId 

			UPDATE MFD SET MFD.SexGuid = I.GUIDReference, MFD.TitleGuid = IT.GUIDReference 
						FROM #MorphuesFeedData MFD
							INNER JOIN Translation t on t.KeyName = MFD.Sex
							INNER JOIN INDIVIDUALSEX I ON I.Translation_Id = t.TranslationId
							JOIN IndividualTitle IT ON IT.Sex_Id = I.GUIDReference
						WHERE t.KeyName = MFD.Sex AND IT.Sex_Id = I.GUIDReference


			UPDATE MFD SET MFD.TitleGuid = IT.GUIDReference 
						FROM #MorphuesFeedData MFD
							INNER JOIN Translation t on t.KeyName = MFD.Title COLLATE SQL_Latin1_General_CP1_CI_AI						
							JOIN IndividualTitle IT ON IT.Translation_Id =  t.TranslationId  AND IT.Country_Id =@pCountryId
						WHERE t.KeyName = MFD.Title COLLATE SQL_Latin1_General_CP1_CI_AI
			
			-----UPDATE GPS TABLES------			
			UPDATE PID SET PID.FirstOrderedName= MFD.FirstName, PID.LastOrderedName= MFD.LastName, PID.DateOfBirth= MFD.DateOfBirth,
							PID.TitleId = MFD.TitleGuid,
							PID.GPSUser=@pUser,
							PID.GPSUpdateTimestamp=@GetDate
			FROM #MorphuesFeedData MFD
			INNER JOIN PERSONALIDENTIFICATION PID ON PID.PersonalIdentificationId= MFD.PersonalIdentificationId
			WHERE PID.PersonalIdentificationId= MFD.PersonalIdentificationId
			


			UPDATE I SET I.Sex_Id = MFD.SexGuid,I.GPSUpdateTimestamp=@GetDate,I.GPSUser=@pUser
						FROM #MorphuesFeedData MFD
							INNER JOIN INDIVIDUAL I ON I.GUIDReference = MFD.IndividualGuid
							WHERE I.GUIDReference = MFD.IndividualGuid
							AND I.Sex_Id<>MFD.SexGuid

			UPDATE CM SET CM.State_Id = @NonResisdent,CM.GPSUpdateTimestamp=@GetDate,CM.GPSUser=@pUser
						FROM #MorphuesFeedData MFD
						INNER JOIN COLLECTIVEMEMBERSHIP CM ON CM.Individual_Id = MFD.IndividualGuid AND  MFD.GroupGuid = CM.Group_Id 
						WHERE UPPER( MFD.LeftHousehold) = 'TRUE' AND CM.State_Id <> @NonResisdent


			UPDATE CM SET CM.State_Id = @FromStateGroupMembershipGuid,CM.GPSUpdateTimestamp=@GetDate,CM.GPSUser=@pUser
						FROM #MorphuesFeedData MFD
						INNER JOIN COLLECTIVEMEMBERSHIP CM ON CM.Individual_Id = MFD.IndividualGuid AND  MFD.GroupGuid = CM.Group_Id 
						WHERE UPPER( MFD.LeftHousehold) = 'FALSE' AND CM.State_Id <> @FromStateGroupMembershipGuid

			UPDATE MFD SET MFD.GroupGuid = NM.Candidate_Id 
				FROM #MorphuesFeedData MFD 
				INNER JOIN NAMEDALIAS NM ON NM.[Key] = MFD.AppUserGUID 
		

		

			INSERT INTO StateDefinitionHistory (
									GUIDReference
									,GPSUser
									,CreationDate
									,GPSUpdateTimestamp
									,CreationTimeStamp
									,Comments
									,CollaborateInFuture
									,From_Id
									,To_Id
									,ReasonForchangeState_Id
									,Country_Id
									,GroupMembership_Id
									)
						SELECT NEWID()
									,@pUser
									,@GetDate
									,MFD.LeftHouseholdDate
									,@GetDate
									,NULL
									,0
									,MFD.GroupMembershipStateGuid
									,@NonResisdent
									,NULL
									,@pCountryId
									,MFD.CollectiveMembershipid
									FROM #MorphuesFeedData MFD
									WHERE UPPER(MFD.LeftHousehold) = 'TRUE'
									AND MFD.GroupMembershipStateGuid <> @NonResisdent

			-------UPDATE INDIVIDUAL AND GROUP GUID FRO NEW INDIVIDUALS-----------

			UPDATE MFD SET MFD.IndividualGuid = NEWID(), CollectiveMembershipId = NEWID() 
						from #MorphuesFeedData MFD
						WHERE MFD.RecordProcessed = 0

				SELECT * FROM #MorphuesFeedData
		
			------INSERT NEW INDIVIDUALS-------
			DECLARE @personalIdentificationId BIGINT

		SET @personalIdentificationId = (
					SELECT ISNULL(MAX(PersonalIdentIFicationId),0) FROM  PersonalIdentIFication
					)


			SET IDENTITY_INSERT PersonalIdentification ON

			declare @Sequence varchar(100) ;
			declare @MaxSequence varchar(100) ;
			select top 1  @Sequence = GroupSequence from  #MorphuesFeedData 			
			select @MaxSequence = max(substring(individualId, charIndex('-',individualId) + 1 ,2)) from individual where IndividualId like (@Sequence + '-%')
			set @MaxSequence = (@MaxSequence + 1);

			set @Sequence = @Sequence + '-' + CASE WHEN @MaxSequence < 10 THEN '0' + CAST(@MaxSequence AS CHAR(1)) ELSE @MaxSequence END

		
		

		-----INSERT INTO PERSONAL IDENTIFICATION---------
			INSERT INTO PersonalIdentification (
				PersonalIdentificationId,DateOfBirth,LastOrderedName,MiddleOrderedName,FirstOrderedName,TitleId
					,Country_Id,GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
			SELECT (@personalIdentificationId + MFD.Rownumber) as PersonalIdentificationId
					,MFD.DateOfBirth,MFD.LastName,NULL,MFD.FirstName,MFD.TitleGuid,@pCountryId
								,@pUser,@GetDate,@GetDate
				FROM #MorphuesFeedData MFD
								WHERE MFD.RecordProcessed = 0
								
				-----INSERT INTO CANDIDATE---------
					INSERT INTO Candidate (
										GUIDReference
										,ValidFromDate
										,EnrollmentDate
										,Comments
										,CandidateStatus
										,GeographicArea_Id
										,RewardsAccountGUID_Id
										,PreallocatedBatch_Id
										,GPSUser
										,CreationTimeStamp
										,GPSUpdateTimestamp
										,Country_Id
										)
									SELECT MFD.IndividualGuid
										,@GetDate
										,@GetDate
										,NULL
										,@individualStatusGuid
										,NULL
										,NULL
										,NULL
										,@pUser
										,@GetDate
										,@GetDate
										,@pCountryId
										FROM #MorphuesFeedData MFD
										WHERE MFD.RecordProcessed = 0
								
				-----INSERT INTO Individual---------
					INSERT INTO Individual (
										GUIDReference
										,PersonalIdentificationId
										,Sex_Id
										,Referer
										,Event_Id
										,CharitySubscription_Id
										,Participant
										,IndividualId
										,CATI3DCode
										,MainPostalAddress_Id
										,MainPhoneAddress_Id
										,MainEmailAddress_Id
										,CountryId
										,GPSUser
										,GPSUpdateTimestamp
										,CreationTimeStamp
										)
									SELECT MFD.IndividualGuid
										,(@personalIdentificationId + MFD.Rownumber)
										,MFD.SexGuid
										,NULL
										,NULL
										,NULL
										,1
										,@Sequence as IndividualId
										,NULL
										,NULL
										,NULL
										,NULL
										,@pCountryId
										,@pUser
										,@GetDate
										,@GetDate
									FROM #MorphuesFeedData MFD
									WHERE MFD.RecordProcessed = 0

					-----INSERT INTO CollectiveMembership---------
					INSERT INTO CollectiveMembership (
										CollectiveMembershipId
										,Sequence
										,SignUpDate
										,DeletedDate
										,GPSUser
										,GPSUpdateTimestamp
										,CreationTimeStamp
										,State_Id
										,Group_Id
										,Individual_Id
										,DiscriminatorType
										,Country_Id
										)
									SELECT MFD.CollectiveMembershipId
										,@MaxSequence
										,@GetDate
										,NULL
										,@pUser
										,@GetDate
										,@GetDate
										,CASE WHEN UPPER(MFD.LeftHousehold) = 'TRUE' THEN @NonResisdent ELSE @FromStateGroupMembershipGuid END
										,MFD.GroupGuid
										,MFD.IndividualGuid
										,'HouseHold'
										,@pCountryId
									FROM #MorphuesFeedData MFD
									WHERE MFD.RecordProcessed = 0

				-----INSERT INTO StateDefinitionHistory---------
					INSERT INTO StateDefinitionHistory (
										GUIDReference
										,GPSUser
										,CreationDate
										,GPSUpdateTimestamp
										,CreationTimeStamp
										,Comments
										,CollaborateInFuture
										,From_Id
										,To_Id
										,ReasonForchangeState_Id
										,Country_Id
										,Candidate_Id
										)
									SELECT NEWID()
										,@pUser
										,@GetDate
										,@GetDate
										,@GetDate
										,NULL
										,0
										,@FromStateIndividualGuid
										,C.CandidateStatus
										,NULL
										,@pCountryId
										,MFD.IndividualGuid
									FROM #MorphuesFeedData MFD
									INNER JOIN Candidate C ON MFD.IndividualGuid = C.GUIDReference
									WHERE MFD.RecordProcessed = 0


									INSERT INTO StateDefinitionHistory (
									GUIDReference
									,GPSUser
									,CreationDate
									,GPSUpdateTimestamp
									,CreationTimeStamp
									,Comments
									,CollaborateInFuture
									,From_Id
									,To_Id
									,ReasonForchangeState_Id
									,Country_Id
									,GroupMembership_Id
									)
						SELECT NEWID()
									,@pUser
									,@GetDate
									,@GetDate
									,@GetDate
									,NULL
									,0
									,@InitlaFromStateGroupMembershipGuid 
									,CASE WHEN UPPER(MFD.LeftHousehold) = 'TRUE' THEN @NonResisdent ELSE @FromStateGroupMembershipGuid END
									,NULL
									,@pCountryId
									,MFD.CollectiveMembershipid
									FROM #MorphuesFeedData MFD
									WHERE UPPER(MFD.LeftHousehold) = 'FALSE'
									
							--------INSERT INTO NAMEDALIAS-----

				INSERT INTO NamedAlias (NamedAliasId, [Key], AliasContext_Id, GPSUser, GPSUpdateTimestamp, CreationTimeStamp, [Guid], Incentive_Id, Candidate_Id, [Type])
					SELECT 
						NEWID() as NamedAliasId,
						MFD.IndividualAlias AS [Key],
						@IndividualContextId,
						@pUser as GPSUser,
						@GetDate as GPSUpdateTimestamp,
						@GetDate as CreationTimeStamp,
						NULL as [Guid],
						NULL as Incentive_Id,
						MFD.IndividualGuid,
						'CandidateAlias' as [Type]
					FROM #MorphuesFeedData MFD
					WHERE MFD.RecordProcessed = 0

					DECLARE @postalAddressTypeGuid UNIQUEIDENTIFIER
						SET @postalAddressTypeGuid = (
								SELECT Id
								FROM AddressType
								WHERE DiscriminatorType = 'PostalAddressType'
									AND IsDefault = 1
								)
					DECLARE @PostalAddressId UNIQUEIDENTIFIER

					SELECT TOP (1) @PostalAddressId=A.GUIDReference
					FROM #MorphuesFeedData MFD  
					INNER JOIN Collective C ON MFD.GroupGuid=C.GUIDReference
					INNER JOIN OrderedContactMechanism OCM ON OCM.Candidate_Id=C.GUIDReference
					INNER JOIN Address A ON OCM.Address_Id=A.GUIDReference AND AddressType='PostalAddress' AND [Type_Id]=@postalAddressTypeGuid

					INSERT INTO OrderedContactMechanism(Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Candidate_Id,Address_Id,Country_Id)
					SELECT NEWID(),1,@pUser,@GetDate,@GetDate,MFD.IndividualGuid,@PostalAddressId,@pCountryId
					FROM #MorphuesFeedData MFD
					WHERE MFD.RecordProcessed = 0 AND 
					NOT EXISTS
					(
					 SELECT 1
					 FROM OrderedContactMechanism OCM
					 WHERE OCM.Candidate_Id=MFD.IndividualGuid AND OCM.Address_Id=@PostalAddressId AND OCM.Country_Id=@pCountryId
					)

			INSERT INTO IncentiveAccount (IncentiveAccountId,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,Beneficiary_Id,[Type],Country_Id)
			SELECT MFD.IndividualGuid,@pUser ,@GetDate,@GetDate,null,'OwnAccount',@pCountryId FROM  #MorphuesFeedData MFD
					WHERE MFD.RecordProcessed = 0
					AND NOT EXISTS
					(
					 SELECT 1
					 FROM IncentiveAccount IA
					 WHERE IA.IncentiveAccountId=MFD.IndividualGuid 
					)



					SET IDENTITY_INSERT PersonalIdentification OFF

					COMMIT TRANSACTION

			END TRY
			BEGIN CATCH
				PRINT ERROR_MESSAGE()
				ROLLBACK TRANSACTION
				INSERT INTO MorpheusErrorLog ([MessageId],[ErrorMessage]) VALUES (@pMessageID,ERROR_MESSAGE())

				DECLARE @ERROR_MESSAGE NVARCHAR(MAX)
				SET @ERROR_MESSAGE=ERROR_MESSAGE()
				RAISERROR(@ERROR_MESSAGE,16,1)
			END CATCH
						
							
END
