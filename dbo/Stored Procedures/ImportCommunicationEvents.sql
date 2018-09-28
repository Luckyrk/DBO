CREATE PROCEDURE [dbo].[ImportCommunicationEvents]
	 @CountryCode AS VARCHAR(3) = ''
	,@FileName AS VARCHAR(200) =''
	,@ImportType VARCHAR(100) = 'CommunicationEvents'
	,@JobId UNIQUEIDENTIFIER
	,@InsertedRows AS BIGINT OUTPUT
AS

/***********************************************************
Created By : Suresh P
Updates:
6-Jan-2016: Changes Related to 37504
11-May-2016 : Made Dropout Logic specific to UK/IE.
26-Jun-2016 : Logic changed for BusinessId to accept individualid also for HH PanelType.
01-Aug-2016  : check for existing issues and stop importing
04-Aug-2016 : updated @ValidIndividuals query
16-Dec-2016 : Updated logic to allow import when panelcode is null.
12-Jan 2017 : Updated Allowing non-main contacts for Spain
13-Jan 2017 : Updated unique constraint from code. Shwoing warning msgs for Spain
13-Jan 2017 : Allowed dropout paneists for UK/IE as part of bug-43251
11-May-2017 : 44184 ES - Communications SSIS import issues - Performance issues fixing.
15-May-2017 : Morpheus - eliminating Dynamic roles implementation, instead GroupContact is considered

EXEC [ImportCommunicationEvents] 'ES' , 'test1.csv', 'CommunicationEvents', NEWID() , 0
***********************************************************/
BEGIN
BEGIN TRY
	DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@CountryCode))

	DECLARE @GPSUser VARCHAR(20) = 'ImportUser'
	DECLARE @ImportDate DATETIME = @Getdate
	DECLARE @CountryId   AS UNIQUEIDENTIFIER
	                          
	DECLARE @AuditId AS BIGINT
	DECLARE @CallLength VARCHAR(100) = '00:00:00.0000000'
	DECLARE @IsErrorOccured AS BIT = 0
	DECLARE @ErrorSource VARCHAR(500) = 'CommunicationEvents'
	
	BEGIN TRY
		PRINT 'STARTED'

		SELECT @CountryId = CountryId
		FROM Country
		WHERE CountryISO2A = @CountryCode

		--	select * from SSIS.ImportCommunicationEvents 

		-- DELETE Empty rows
	DELETE FROM SSIS.ImportCommunicationEvents
	Where ISNULL(BusinessId,'') = ''
	and  ISNULL(CommunicationReasonCode,'') = ''
	and  ISNULL(ContactMechanismType,'') = ''
	and  ISNULL(CreationDate,'') = ''
	and  ISNULL(Incoming,'') = ''
	and  ISNULL(Comment,'') = ''
	and  ISNULL([State],'') = ''
	and  ISNULL(CallLength,'') = ''
	and ISNULL(PanelId,'')=''
		
UPDATE SSIS.ImportCommunicationEvents SET
CreationDate = (CASE RTRIM(LTRIM(CreationDate)) WHEN '' THEN NULL ELSE CreationDate END )
, CallLength = (case when ltrim(CallLength) = '' then 0 else ltrim(CallLength) end)
, PanelId = (CASE WHEN PanelId ='' then NULL else PanelId end)
where CountryCode=@CountryCode
	
		-- Log Audit Summary 				
		INSERT INTO [FileImportAuditSummary] (
			 CountryCode,PanelID,PanelName,[Filename]
			,FileImportDate,GPSUser,TotalRows,PassedRows,[Status]
			,Comments,ImportType, JobId)
		VALUES ( @CountryCode,NULL,NULL,@FileName,@ImportDate,@GPSUser,0,0
				,'Processing',NULL,@ImportType, @JobId)

		SET @AuditId = @@Identity

		DECLARE @ValidIndividuals AS TABLE (
			BusinessID VARCHAR(20)
			,CandidateId UNIQUEIDENTIFIER
			,CollaborationMethodology_GUID UNIQUEIDENTIFIER
			,CollectiveId  VARCHAR(20)
			,PanelistState  VARCHAR(100)
			,PanelId VARCHAR(20)
			,PanelType VARCHAR(20)
			,PanelGuid UNIQUEIDENTIFIER
			)


	    DECLARE @RoleName VARCHAR(50) = (CASE WHEN @CountryCode in ('GB', 'IE','ES') THEN 'MainContactRoleName' ELSE 'MainShopperRoleName'  END )

		INSERT INTO @ValidIndividuals (
			 BusinessID
			,CandidateId
			,CollaborationMethodology_GUID
			,CollectiveId
			,PanelistState
			,PanelId
			,PanelType
			,PanelGuid
			)

		SELECT  I.IndividualId AS BusinessId, I.GUIDReference AS CandidateId					
			,pl.CollaborationMethodology_Id, C.Sequence as CollectiveId
			,ltrim(rtrim(SD.Code)) , P.PanelCode
			, P.[Type]
			,P.GUIDReference
			FROM Panelist pl				
			INNER JOIN CollectiveMembership cm ON cm.Group_Id = pl.PanelMember_Id
			Inner JOIN Collective C ON C.GUIDReference = cm.Group_Id
			INNER JOIN Individual I ON i.GUIDReference = cm.Individual_Id
			INNER JOIN (select DRA.Candidate_Id ,DR.Code, T.KeyName, DRA.Panelist_Id
				from  dbo.DynamicRoleAssignment DRA
				Join dbo.DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id and DR.Country_Id = DRA.Country_ID
				Join dbo.Translation T ON T.TranslationId = DR.Translation_Id
				Where DRA.Country_Id = @CountryId
				and KeyName = @RoleName ) rol ON rol.Candidate_Id = I.GUIDReference  -- MainContactRoleName
				 AND rol.Panelist_Id = pl.GUIDReference
			INNER JOIN StateDefinition SD ON pl.State_Id = SD.Id and SD.Country_Id = @CountryId
			INNER JOIN Panel P ON P.GUIDReference=pl.Panel_Id	
			WHERE Pl.Country_Id= @CountryId

	UNION ALL

			SELECT  I.IndividualId AS BusinessId, I.GUIDReference AS CandidateId					
			,pl.CollaborationMethodology_Id, NULL as CollectiveId
			,SD.Code, P.PanelCode, P.[Type]
				,P.GUIDReference
			FROM Panelist pl
			INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id
			
			INNER JOIN (select DRA.Candidate_Id ,DR.Code, T.KeyName , DRA.Panelist_Id
				from  dbo.DynamicRoleAssignment DRA
				Join dbo.DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id and DR.Country_Id = DRA.Country_ID
				Join dbo.Translation T ON T.TranslationId = DR.Translation_Id
				Where DRA.Country_Id = @CountryId and KeyName = @RoleName ) rol 
			ON rol.Candidate_Id = I.GUIDReference  -- Main Contact
			 AND rol.Panelist_Id = pl.GUIDReference 
			 
			INNER JOIN StateDefinition SD ON pl.State_Id = SD.Id and SD.Country_Id = @CountryId
			LEFT JOIN Panel P ON P.GUIDReference=pl.Panel_Id 
			WHERE Pl.Country_Id= @CountryId
			AND @CountryCode NOT IN ('ES') -- ***  
	UNION ALL		
			SELECT  I.IndividualId AS BusinessId, I.GUIDReference AS CandidateId					
			,pl.CollaborationMethodology_Id, NULL as CollectiveId
			,SD.Code, P.PanelCode, P.[Type]
				,P.GUIDReference
			FROM Panelist pl
			INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id
			
			/*INNER JOIN (select DRA.Candidate_Id ,DR.Code, T.KeyName , DRA.Panelist_Id
				from  dbo.DynamicRoleAssignment DRA
				Join dbo.DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id and DR.Country_Id = DRA.Country_ID
				Join dbo.Translation T ON T.TranslationId = DR.Translation_Id
				Where DRA.Country_Id = @CountryId and KeyName = @RoleName ) rol 
			ON rol.Candidate_Id = I.GUIDReference  -- Main Contact
			 AND rol.Panelist_Id = pl.GUIDReference */
			 
			INNER JOIN StateDefinition SD ON pl.State_Id = SD.Id and SD.Country_Id = @CountryId
			INNER JOIN Panel P ON P.GUIDReference = pl.Panel_Id 
			WHERE Pl.Country_Id= @CountryId
			AND @CountryCode IN ('ES') -- *** 
	UNION ALL
		SELECT  I.IndividualId AS BusinessId,
		  C.GroupContact_Id  AS CandidateId					
		,pl.CollaborationMethodology_Id, C.Sequence as CollectiveId
		,SD.Code, P.PanelCode, P.[Type]
		,P.GUIDReference
		 FROM Collective C
		INNER JOIN  CollectiveMembership CM ON CM.Group_Id = C.GUIDReference
			LEFT JOIN Individual ind ON  ind.GUIDReference = C.GroupContact_Id
		INNER JOIN Individual I ON I.GUIDReference =  CM.Individual_Id
		INNER JOIN  Panelist pl ON pl.PanelMember_Id = C.GUIDReference 
		INNER JOIN StateDefinition SD ON pl.State_Id = SD.Id  AND SD.Country_Id = @CountryId
		INNER JOIN Panel P ON P.GUIDReference = pl.Panel_Id 
		WHERE Pl.Country_Id= @CountryId
		AND @CountryCode IN ('MH') -- *** 


 --select * from @ValidIndividuals
 --order by BusinessID
			---------------------------

			DECLARE @StagingCommunications AS TABLE
			(
				Id	uniqueidentifier
				,BusinessId	varchar(20)
				,CommunicationReasonCode	varchar(20)
				,ContactMechanismType	varchar(50)
				,CreationDate	varchar(50)
				,Incoming	varchar(50)
				,Comment	varchar(max)
				,[State]	varchar(50)
				,CallLength varchar(10)
				,PanelCode Varchar(50)
				,CountryCode Varchar(10)
				,CallLengthTime Time
				,PanelistId uniqueidentifier
				,ContactMechanism_Id uniqueidentifier
				,ReasonType_Id uniqueidentifier
				,Panel_Id uniqueidentifier
			)

			print '@StagingCommunications'
			
			
			INSERT INTO @StagingCommunications
			SELECT   distinct
				 IA.Id
				,IA.BusinessId
				,IA.CommunicationReasonCode
				,IA.ContactMechanismType
				,IA.CreationDate
				,IA.Incoming
				,IA.Comment
				,IA.[state]
				,IA.CallLength
				,IA.PanelId
				,IA.CountryCode

				,NULL as CallLengthTime
				,VI.CandidateId
				,NULL as ContactMechanism_Id
				,NULL AS ReasonType_Id
				,(Case when IA.PanelId IS NOT NULL THEN VI.PanelGuid END) as panel_Id
			FROM SSIS.ImportCommunicationEvents IA
			INNER JOIN @ValidIndividuals VI ON  IA.BusinessId in (VI.BusinessId   ) 
			and (IA.PanelId IS NULL OR VI.PanelId = IA.PanelId ) 
			
			union  all

			SELECT    distinct
				 IA.Id
				,IA.BusinessId
				,IA.CommunicationReasonCode
				,IA.ContactMechanismType
				,IA.CreationDate
				,IA.Incoming
				,IA.Comment
				,IA.[state]
				,IA.CallLength
				,IA.PanelId
				,IA.CountryCode

				,NULL as CallLengthTime
				,VI.CandidateId
				,NULL as ContactMechanism_Id
				,NULL AS ReasonType_Id
				,(Case when IA.PanelId IS NOT NULL THEN VI.PanelGuid END) as panel_Id
			FROM SSIS.ImportCommunicationEvents IA
			INNER JOIN @ValidIndividuals VI ON  IA.BusinessId in (VI.CollectiveId) 
			and (IA.PanelId IS NULL OR VI.PanelId = IA.PanelId ) 

			UPDATE IA
			SET ContactMechanism_Id  = CT.GUIDReference
			,IA.CallLengthTime = (CASE When CT.[Types] in ('Phone', 'PersonalCall') 
								THEN CAST(CONVERT(varchar, DATEADD(ms, ( ISNULL(CallLength,0) % 86400 ) * 1000, 0), 114) AS TIME) 
								ELSE @CallLength  END)  
			 FROM @StagingCommunications IA
			INNER JOIN ContactMechanismType CT 
			ON CT.ContactMechanismCode = IA.ContactMechanismType and CT.Country_Id =  @CountryId

			
			UPDATE IA
			SET ReasonType_Id  = CRT.GUIDReference
			FROM @StagingCommunications IA
			INNER JOIN CommunicationEventReasonType CRT
			ON CRT.CommEventReasonCode = IA.CommunicationReasonCode AND CRT.Country_Id=@CountryId
			
			--UPDATE IA
			--SET  IA.Panel_Id  =  P.GUIDReference
			--FROM @StagingCommunications IA
			--INNER Join Panel P ON P.PanelCode = IA.PanelCode and P.Country_Id = @CountryId 
			--WHERE IA.PanelCode IS NOT NULL

----------------------------------------------------------
-- GET RECENT CommunicationEvents from Target
	DECLARE @MinCommunicationDate as DATETIME
	DECLARE @MaxCommunicationDate as DATETIME

	SELECT  @MinCommunicationDate = MIN(CreationDate) , @MaxCommunicationDate = MAX(CreationDate) 
	FROM SSIS.ImportCommunicationEvents

	DECLARE @CommunicationEvents AS TABLE
	(
		 CommunicationEventID uniqueidentifier
		,CommunicationEventReasonID uniqueidentifier
		,CreationDate datetime
		,Incoming bit
		,[STATE]  int
		,CallLength Time
		,ContactMechanism_Id uniqueidentifier
		,Country_Id uniqueidentifier
		,Candidate_Id uniqueidentifier
		,Comment		nvarchar(1000)
		,ReasonType_Id  uniqueidentifier
		,panel_id	 uniqueidentifier

		--	UNIQUE CLUSTERED ( Country_Id, Candidate_Id, CreationDate, ContactMechanism_Id, ReasonType_Id, panel_id )
	)

	INSERT INTO @CommunicationEvents
	(	CommunicationEventID 
		,CommunicationEventReasonID 
		,CreationDate 
		,Incoming 
		,[STATE]  
		,CallLength 
		,ContactMechanism_Id 
		,Country_Id 
		,Candidate_Id 
		,Comment		
		,ReasonType_Id  
		,panel_id	
	)

	SELECT  CE.GUIDReference, CER.GUIDReference , CE.CreationDate , CE.Incoming, CE.[State] , 
	CE.CallLength, CE.ContactMechanism_Id, CE.Country_Id, CE.Candidate_Id, CER.Comment, CER.ReasonType_Id, CER.panel_id
	FROM CommunicationEvent CE 
	INNER JOIN CommunicationEventReason CER ON CER.Communication_Id = CE.GUIDReference
	Where CE.CreationDate between @MinCommunicationDate and @MaxCommunicationDate
	AND CE.Country_Id = @CountryId	AND CER.Country_Id = @CountryId  

	-------------------------------------------------------------


		----------------------------------------
		print ' Validations'
		----------------------------------------
		-- check if already error exists
		IF EXISTS (SELECT * FROM [dbo].[FileImportErrorLog] 
				WHERE  JobId = @JobId)	
		BEGIN
				UPDATE [dbo].[FileImportErrorLog] 
				SET ErrorDate = @Getdate
				WHERE  JobId = @JobId

			SET @IsErrorOccured = 1
		END

		-------- Duplicate communications check
      
	  
	            ---Duplicate  check within data file
				print 'dup within file'
	  INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode,ImportType,[FileName]
			,PanelCode,ErrorSource,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,@ErrorSource
			,'0'
			,'Error: Duplicate Communication Events within the file (please Re-import). BusinessId - ' + ISNULL(V2.BusinessId, '') + ' , Communication Reason - ' + ISNULL(V2.CommunicationReasonCode, '') 
			+ ', ContactMechanism Code - ' + ISNULL(V2.ContactMechanismType, '') + ', PanelId - ' + ISNULL(V2.PanelId, '') 
			+ ', Communication Date - ' + ISNULL(V2.CreationDate, '') + ''

			,@ImportDate
			,@JobId
			FROM 
			(
				SELECT IA.BusinessId,CommunicationReasonCode , ContactMechanismType, IA.PanelId, CreationDate, count(1) cnt
				FROM  SSIS.ImportCommunicationEvents IA
				where IA.CountryCode=@CountryCode
				GROUP BY IA.BusinessId,CommunicationReasonCode , ContactMechanismType, IA.PanelId, CreationDate
				HAVING count(1) > 1

				)V2
				
		IF (@@ROWCOUNT > 0)
			SET @IsErrorOccured = 1

		
-- IA.BusinessId,CommunicationReasonCode , ContactMechanismType, IA.PanelId, CreationDate
			
			------Duplicate check with data base
			 
	print 'dup in target table'
	INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode,ImportType,[FileName]
			,PanelCode,ErrorSource,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
		SELECT DISTINCT  @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,@ErrorSource
			,'0'
			,'Warning: Duplicate Communication Events (system ignored). BusinessId - ' + ISNULL(V2.BusinessId, '') + ' , Communication Reason - ' + ISNULL(V2.CommunicationReasonCode, '') 
			+ ', ContactMechanism Code - ' + ISNULL(V2.ContactMechanismType, '') + ', PanelId - ' + ISNULL(V2.PanelId, '') 
			+ ', Communication Date - ' + ISNULL(V2.CreationDate, '') + ''

			,@ImportDate
			,@JobId
			FROM 
			(
				SELECT IA.BusinessId, IA.CommunicationReasonCode , ContactMechanismType, IA.PanelCode as PanelId, IA.CreationDate
				FROM  @StagingCommunications IA
				INNER JOIN  @CommunicationEvents CE 
				ON CE.Candidate_Id = IA.PanelistId
				AND CE.CreationDate =  CONVERT(DATETIME, IA.CreationDate)
				AND CE.ContactMechanism_Id  = IA.ContactMechanism_Id
				AND CE.ReasonType_Id =  IA.ReasonType_Id
				AND (IA.PanelCode IS NULL OR CE.panel_id = IA.Panel_Id)
				AND CE.Country_Id = @CountryId
				AND IA.CountryCode = @CountryCode

			) V2
						
		--	select * from SSIS.ImportCommunicationEvents 
		-- not an error.
		---------
		print 'validate businessid'
		INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode,ImportType,[FileName]
			,PanelCode,ErrorSource,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
		--SELECT @CountryCode
		--	,@ImportType
		--	,@FileName
		--	,NULL
		--	,@ErrorSource
		--	,'0'
		--	,'Error: Invalid BusinessId for:  BusinessId - ' + ISNULL(IA.BusinessId, '') + ' , CommunicationReason - ' + ISNULL(IA.CommunicationReasonCode, '') + ', ContactMechanism Code - ' + ISNULL(IA.ContactMechanismType, '') + ', Comment - ' + ISNULL(Comment, '') + ''
		--	,@ImportDate
		--	,@JobId
		--FROM SSIS.ImportCommunicationEvents IA
		--LEFT JOIN @ValidIndividuals VI ON IA.BusinessId in (VI.BusinessId, VI.CollectiveId )
		--WHERE VI.BusinessID IS NULL
		--AND IA.CountryCode=@CountryCode

		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,@ErrorSource
			,'0'
			,'Error: Invalid BusinessId for:  BusinessId - ' + ISNULL(IA.BusinessId, '') + ' , CommunicationReason - ' + ISNULL(IA.CommunicationReasonCode, '') + ', ContactMechanism Code - ' + ISNULL(IA.ContactMechanismType, '') + ', Comment - ' + ISNULL(Comment, '') + ''
			,@ImportDate
			,@JobId
		FROM SSIS.ImportCommunicationEvents IA
		LEFT JOIN 
		(
			SELECT VI.BusinessId  AS BusinessId
			from @ValidIndividuals VI
			--WHERE VI.CollectiveId IS NULL 

			UNION ALL 

			SELECT VI.CollectiveId  AS BusinessId
			from @ValidIndividuals VI
			WHERE VI.CollectiveId IS NOT NULL 

		) V ON  V.BusinessId  = IA.BusinessId

		WHERE V.BusinessID IS NULL
		AND IA.CountryCode=@CountryCode
		  
		
		UNION ALL 

			select @CountryCode, @ImportType,  @FileName , IA.PanelId,
			@ErrorSource, '0', 'Error: No ' + @RoleName + ' in this group.  BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , CommunicationReason - ' + ISNULL(IA.CommunicationReasonCode, '') + ', ContactMechanism Code - ' + ISNULL(IA.ContactMechanismType, '') + ', Comment - ' + ISNULL(Comment, '') + ''
			,@ImportDate ,@JobId
			from  dbo.DynamicRoleAssignment DRA
			INNER JOIN  dbo.DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id and DR.Country_Id = DRA.Country_ID AND DRA.Country_Id = @CountryId
			INNER JOIN  dbo.Translation T ON T.TranslationId = DR.Translation_Id  and KeyName = @RoleName
			INNER JOIN CollectiveMembership cm ON DRA.Candidate_Id = cm.Individual_Id 
			Inner JOIN Collective C ON C.GUIDReference = cm.Group_Id   
			INNER JOIN Individual I ON i.GUIDReference = cm.Individual_Id and I.CountryId = @CountryId
			RIGHT JOIN  SSIS.ImportCommunicationEvents IA  ON  (convert(varchar(20),C.sequence) = IA.BusinessId  OR IA.BusinessId = i.IndividualId)
			Where DRA.Candidate_Id IS NULL
			AND @CountryCode NOT IN ('ES', 'MH') -- *** 
			AND IA.CountryCode=@CountryCode
 

		IF (@@ROWCOUNT > 0)
			SET @IsErrorOccured = 1				
		ELSE
			PRINT'VALID BUSINESS ID'
 
 print 'validate comm reason'
-- ERROR : 2. InValid CommunicationEvent Reason
		INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode
			,ImportType
			,[FileName]
			,PanelCode
			,ErrorSource
			,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,@ErrorSource
			,'0'			
			,'Error: Invalid CommunicationEvent Reason for:  BusinessId - ' + ISNULL(IA.BusinessId, '') + 
			' , CommunicationReason - ' + ISNULL(IA.CommunicationReasonCode, '') + ', ContactMechanism Code - ' 
			+ ISNULL(IA.ContactMechanismType, '') + ', Comment - ' + ISNULL(Comment, '') + ''
			,@ImportDate
			,@JobId
		FROM SSIS.ImportCommunicationEvents IA
		LEFT JOIN CommunicationEventReasonType CRT ON CAST(CRT.CommEventReasonCode AS VARCHAR)= CAST(IA.CommunicationReasonCode AS VARCHAR)
			AND CRT.Country_Id = @CountryId
		WHERE CRT.GUIDReference IS NULL
		AND IA.CountryCode=@CountryCode

		IF (@@ROWCOUNT > 0)
			SET @IsErrorOccured = 1

			print 'contact mech'
-- ERROR : 3. InValid ContactMechanism
		INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode
			,ImportType
			,[FileName]
			,PanelCode
			,ErrorSource
			,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,@ErrorSource
			,'0'
			,'Error: Invalid ContactMechanism Code for:  BusinessId - ' + ISNULL(IA.BusinessId, '') + ' , CommunicationReason - ' + ISNULL(IA.CommunicationReasonCode, '') + ', ContactMechanism Code - ' + ISNULL(IA.ContactMechanismType, '') + ', Comment - ' + ISNULL(Comment, '') + ''
			,@ImportDate
			,@JobId
		FROM SSIS.ImportCommunicationEvents IA
		LEFT JOIN ContactMechanismType CMT ON CAST(CMT.ContactMechanismCode  AS VARCHAR) = IA.ContactMechanismType
			AND CMT.Country_Id = @CountryId
		WHERE CMT.GUIDReference IS NULL
		AND IA.CountryCode=@CountryCode

		
		IF (@@ROWCOUNT > 0)
			SET @IsErrorOccured = 1
	
	print 'validate creation date '
-- ERROR : 4. InValid CreationDate	
	;WITH TEMP
		AS (
			SELECT *
				,
				CASE
				WHEN ISDATE(CreationDate)=1 AND  CAST(CreationDate AS  DATE) > CAST(@ImportDate AS DATE) THEN 0
				ELSE  
				ISDATE(CreationDate) 
				END AS ValidDate
			FROM SSIS.ImportCommunicationEvents IA
			WHERE  IA.CountryCode=@CountryCode
			)
		INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode,ImportType,[FileName]
			,PanelCode,ErrorSource,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,@ErrorSource
			,'0'
			,'Error: Invalid CreationDate for:  BusinessId - ' + ISNULL(IA.BusinessId, '') + ' , CommunicationReason - ' + ISNULL(IA.CommunicationReasonCode, '') + ', ContactMechanism Code - ' + ISNULL(IA.ContactMechanismType, '') + ', Comment - ' + ISNULL(Comment, '') + ''
			,@ImportDate
			,@JobId
		FROM TEMP IA
		WHERE ValidDate != 1 --AND CreationDate IS NOT NULL

		IF (@@ROWCOUNT > 0)
			SET @IsErrorOccured = 1

		--ERROR : 5. InValid InComing
		;WITH TEMP
		AS (
			SELECT *
				,CASE 
					WHEN ISNULL(IA.Incoming, 0) = 0
						THEN 1
					WHEN ISNULL(IA.Incoming, 0) = 1
						THEN 1
					ELSE 0
					END AS ValidInComing
			FROM SSIS.ImportCommunicationEvents IA
			WHERE  IA.CountryCode=@CountryCode
			)
		INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode,ImportType,[FileName]
			,PanelCode,ErrorSource,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,@ErrorSource
			,'0'
			,'Error: Invalid InComing for:  BusinessId - ' + ISNULL(IA.BusinessId, '') + ' , CommunicationReason - ' + ISNULL(IA.CommunicationReasonCode, '') 
			+ ', ContactMechanism Code - ' + ISNULL(IA.ContactMechanismType, '') + ', Comment - ' + ISNULL(Comment, '') + ''
			,@ImportDate
			,@JobId
		FROM TEMP IA
		WHERE ValidInComing != 1 --AND InComing IS NOT NULL

		IF (@@ROWCOUNT > 0)
			SET @IsErrorOccured = 1

			print 'validate state'
  -- ERROR : 6. InValid State
	;WITH TEMP
		AS (
			SELECT *
				,CASE 
					WHEN IA.[State] In (1,2,3)
						THEN 1
					ELSE 0
					END AS ValidState
			FROM SSIS.ImportCommunicationEvents IA
			WHERE  IA.CountryCode=@CountryCode
			)
		
		INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode,ImportType,[FileName]
			,PanelCode,ErrorSource,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,@ErrorSource
			,'0'
			,'Error: Invalid State for:  BusinessId - ' + ISNULL(IA.BusinessId, '') + ' , CommunicationReason - ' 
			+ ISNULL(IA.CommunicationReasonCode, '') + ', ContactMechanism Code - ' + ISNULL(IA.ContactMechanismType, '') + ', Comment - ' 
			+ ISNULL(Comment, '') + ''
			,@ImportDate
			,@JobId
		FROM TEMP IA
		WHERE ValidState != 1 

		union all

		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,@ErrorSource
			,'0'
			,'Error: Communication State cannot be in-progess. for:  BusinessId - ' + ISNULL(IA.BusinessId, '') + ' , CommunicationReason - ' 
			+ ISNULL(IA.CommunicationReasonCode, '') + ', ContactMechanism Code - ' + ISNULL(IA.ContactMechanismType, '') + ', Comment - ' 
			+ ISNULL(Comment, '') + ''
			,@ImportDate
			,@JobId
			FROM SSIS.ImportCommunicationEvents IA
			Where IA.[State] In ('1')
			AND IA.CountryCode=@CountryCode


		IF (@@ROWCOUNT > 0)
			SET @IsErrorOccured = 1

			print 'validate callength '
-- ERROR : 7. InValid CallLength
	;WITH TEMP
		AS (
			SELECT *
				,ISNUMERIC(ISNULL(CallLength,0)) AS ValidCallLength
			FROM SSIS.ImportCommunicationEvents IA
			WHERE  IA.CountryCode=@CountryCode
			)
	INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode,ImportType,[FileName]
			,PanelCode,ErrorSource,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,@ErrorSource
			,'0'
			,'Error: Invalid CallLength for:  BusinessId - ' + ISNULL(IA.BusinessId, '') + ' , CommunicationReason - ' + ISNULL(IA.CommunicationReasonCode, '') +
			 ', ContactMechanism Code - ' + ISNULL(IA.ContactMechanismType, '') + ', Comment - ' + ISNULL(Comment, '') + ''
			,@ImportDate
			,@JobId
		FROM TEMP IA
		WHERE ValidCallLength != 1 

		union all

		SELECT @CountryCode
			,@ImportType
			,@FileName
			,NULL
			,@ErrorSource
			,'0'			
			,'Error: CallLength should be in the range 0 to 7200 seconds :  BusinessId - ' + ISNULL(IA.BusinessId, '') + 
			' , CommunicationReason - ' + ISNULL(IA.CommunicationReasonCode, '') + ', ContactMechanism Code - ' 
			+ ISNULL(IA.ContactMechanismType, '') + ', Comment - ' + ISNULL(Comment, '') + ', CallLength - ' + ISNULL(CallLength,'')  +''
			,@ImportDate
			,@JobId
		FROM SSIS.ImportCommunicationEvents IA
		Where CallLength not between 0 and 7200
		AND IA.CountryCode=@CountryCode

		IF (@@ROWCOUNT > 0)
			SET @IsErrorOccured = 1

			print 'validate Panelcode'
			-- ERROR : 5. InValid PanelCode
			INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate ,JobId)
			
			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelId,  
			@ErrorSource, '0', 'Error: Invalid PanelCode for:  BusinessId - ' + ISNULL(IA.BusinessId,'') + '  , CommunicationReason - ' + ISNULL(IA.CommunicationReasonCode, '') + ', ContactMechanism Code - ' + ISNULL(IA.ContactMechanismType, '') + ', Comment - ' + ISNULL(Comment, '') + ''
			,@ImportDate, @JobId
		    FROM SSIS.ImportCommunicationEvents IA
			LEFT JOIN @ValidIndividuals pInfo ON pInfo.PanelId = IA.PanelId AND IA.BusinessId in (pInfo.BusinessID, pInfo.CollectiveId)
			WHERE IA.PanelId IS not NULL 
			AND pInfo.BusinessId is null
			AND IA.CountryCode=@CountryCode
			
						
		IF (@@ROWCOUNT > 0)
			SET @IsErrorOccured = 1


	END TRY
	
	BEGIN CATCH
		PRINT 'VALIDATION ERRROR OCCURED:'

		INSERT INTO [dbo].[FileImportErrorLog] (CountryCode,ImportType,[FileName],PanelCode,ErrorSource
			,ErrorCode,ErrorDescription,ErrorDate,JobId)
		SELECT @CountryCode,@ImportType,@FileName,NULL,'Unknown'
			,ERROR_NUMBER(),ERROR_MESSAGE(),@ImportDate,@JobId

		UPDATE [FileImportAuditSummary]
		SET [Status] = 'Error'
			,Comments = N'' + ERROR_MESSAGE()
			,PassedRows = @InsertedRows
		WHERE AuditId = @AuditId

		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

		PRINT ERROR_MESSAGE();
	END CATCH
	
	PRINT 'Is ErrorOccured :'
	PRINT @IsErrorOccured

	--	SET @IsErrorOccured = 1 ---- *********


	-- PERFORM ACTUAL LOGIC
	IF @IsErrorOccured = 0 --  NO ISSUES WITH DATA
	BEGIN
	print 'no errors'
		BEGIN TRANSACTION;
		BEGIN TRY
			PRINT 'PROCESS STARTED'

			-- Create new data
			
		DECLARE @CommunicationEventsInsert AS TABLE
		(
			 CommunicationEventID uniqueidentifier
			,CommunicationEventReasonID uniqueidentifier
			,CreationDate datetime
			,Incoming bit
			,[STATE]  int
			,CallLength Time
			,ContactMechanism_Id uniqueidentifier
			,Country_Id uniqueidentifier
			,Candidate_Id uniqueidentifier
			,Comment		nvarchar(1000)
			,ReasonType_Id  uniqueidentifier
			,panel_id	 uniqueidentifier
			-- UNIQUE CLUSTERED ( Country_Id, Candidate_Id, CreationDate, ContactMechanism_Id, ReasonType_Id, panel_id )
	)
		INSERT INTO @CommunicationEventsInsert
			select 
				 Id as CommunicationEventID,
				 NewID()  as CommunicationEventReasonID
				,CreationDate
				,Incoming
				,[state]
				,CallLengthTime 
				,ContactMechanism_Id
				,@CountryId
				,PanelistId
				,Comment
				,ReasonType_Id
				,panel_id
			from (
					SELECT 
					distinct Id
						,IA.CreationDate
						,IA.Incoming
						,IA.[state]
						,IA.CallLengthTime 
						,IA.ContactMechanism_Id
						,IA.PanelistId
						,IA.Comment
						,IA.ReasonType_Id
						,IA.Panel_Id
					FROM @StagingCommunications IA
					LEFT Join @CommunicationEvents CE  
					ON CE.Candidate_Id = IA.PanelistId
					AND CE.CreationDate = CONVERT(DATETIME, IA.CreationDate)
					AND CE.ContactMechanism_Id  = IA.ContactMechanism_Id
					AND CE.ReasonType_Id = IA.ReasonType_Id
					AND (IA.PanelCode IS NULL OR CE.panel_id = IA.Panel_Id)
					AND CE.Country_Id = @CountryId
					WHERE CE.CommunicationEventID IS NULL
			) V1


			print '@CommunicationEventsInsert'
--select * from  @CommunicationEventsInsert

			-- actual
			
			INSERT INTO CommunicationEvent (
				GUIDReference
				,CreationDate
				,Incoming
				,[STATE]
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				,CallLength 
				,ContactMechanism_Id
				,Country_Id
				,Candidate_Id
				)
			
			select 
				 CommunicationEventID
				,CreationDate
				,Incoming
				,[state]
				,@GPSUser
				,@ImportDate
				,@ImportDate
				,CallLength 
				,ContactMechanism_Id
				,@CountryId
				,Candidate_Id
			from  @CommunicationEventsInsert

			SET @InsertedRows = @@ROWCOUNT

			print getdate()
						
			INSERT INTO CommunicationEventReason (
				GUIDReference
				,Comment
				,GPSUser
				,GPSUpdateTimestamp
				,CreationTimeStamp
				,ReasonType_Id
				,Country_Id
				,Communication_Id
				,panel_id
				)
				
				SELECT 
				CommunicationEventReasonId
				,Comment
				,@GPSUser
				,@ImportDate
				,CreationDate
				, ReasonType_Id
				,@CountryId
				,CommunicationEventID
				, Panel_ID -- (CASE WHEN Panel_ID = '00000000-0000-0000-0000-000000000000' THEN NULL  ELSE Panel_ID END)  
				FROM @CommunicationEventsInsert

			print getdate()
			

			PRINT '@InsertedRows : ' + convert(VARCHAR(10), @InsertedRows)

			UPDATE [FileImportAuditSummary]
			SET [Status] = 'Completed'
				,PassedRows = @InsertedRows
				,TotalRows = @InsertedRows
			WHERE AuditId = @AuditId
			
			COMMIT TRANSACTION;
		END TRY

		BEGIN CATCH
			PRINT 'CRITICAL ERROR OCCURED'
			ROLLBACK TRANSACTION;
			INSERT INTO [dbo].[FileImportErrorLog] (
				CountryCode
				,ImportType
				,[FileName]
				,PanelCode
				,ErrorSource
				,ErrorCode
				,ErrorDescription
				,ErrorDate
				,JobId
				)
			SELECT @CountryCode
				,@ImportType
				,@FileName
				,NULL
				,'Unknown'+ CAST(ERROR_LINE() AS VARCHAR)
				,ERROR_NUMBER()
				,ERROR_MESSAGE()
				,@ImportDate
				,@JobId

			PRINT ERROR_MESSAGE();

			UPDATE [FileImportAuditSummary]
			SET [Status] = 'Error'
				,Comments = N'' + ERROR_MESSAGE()
				,PassedRows = @InsertedRows
				,TotalRows = @InsertedRows
			WHERE AuditId = @AuditId
		END CATCH

		
	END
	ELSE
	BEGIN
		 Update [FileImportAuditSummary]
		  SET [Status] = 'Error',
		  Comments = 'Input file has invalid data.',
		  PassedRows = 0
		  Where AuditId = @AuditId
	END
 

	SELECT @InsertedRows
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
GO