CREATE PROCEDURE [dbo].[ImportActions]
	 @CountryCode AS VARCHAR(3) = '',
	@FileName AS VARCHAR(200)='',
	@ImportType VARCHAR(100)  = 'ActionTasks',
	@JobId UNIQUEIDENTIFIER,
	@InsertedRows AS BIGINT OUTPUT
AS

/***********************************************************
Created By : Suresh P
Updates:
6-Jan-2016: Changes Related to 37504
24-fEB-2016 : Uncommented Insert into and removed countryID IE specific
11-May-2016 : Made Dropout Logic specific to UK/IE.
26-Jun-2016 : Logic changed for BusinessId to accept individualid also for HH PanelType.
01-Aug-2016 : check for existing issues and stop importing
03-Aug-2016	: Updated logic for Endate as part of Bug- 41567 and Panelist validations
16-Dec-2016:  Updated logic to allow import when panelcode is null.
21-Dec-2016: Allowed panelists with dropoff and refusal stae as part of CR-43110,BUG-43251 FOR UK/IE
27-Dec-2016:Restricted duplicate entries as part of CR-43110,BUG-43251 for UK/IE
15-May-2017 : Morpheus - eliminating Dynamic roles implementation, instead GroupContact is considered
20-Jun-2017 : PBI 44903 updates - Adding Priority and CallBackDateTime fields to template. 
03-Aug-2017	: Validation for CallBackDateTime added

EXEC [ImportActions] 'GB' , 'file.csv', 'ActionTasks', '1428D0A1-1B93-40DF-9468-5A87FC68F0E4' , 0
***********************************************************/
BEGIN
BEGIN TRY

DECLARE @Getdate DATETIME
	SET @Getdate = (select dbo.GetLocalDateTime(GETDATE(),@CountryCode))

DECLARE @GPSUser VARCHAR(20)  = 'ImportUser'
DECLARE @ImportDate DATETIME = @Getdate
DECLARE @CountryId AS UNIQUEIDENTIFIER
DECLARE @AuditId AS BIGINT
DECLARE @State VARCHAR(100)=''
DECLARE @IsErrorOccured AS BIT = 0
DECLARE @ErrorSource VARCHAR(500)='ActionTasks'
DECLARE @CompletionDate DATETIME=NULL
DECLARE @CommunicationCompletion_Id UNIQUEIDENTIFIER=NULL
DECLARE @FormId UNIQUEIDENTIFIER=NULL
DECLARE @Assignee_Id UNIQUEIDENTIFIER=NULL
DECLARE @Panel_Id UNIQUEIDENTIFIER=NULL
DECLARE @InternalOrExternal int
set @InternalOrExternal=1

BEGIN TRY
PRINT 'STARTED'
SELECT @CountryId = CountryId
		FROM Country
		WHERE CountryISO2A = @CountryCode
		
--	SELECT * FROM SSIS.ImportActionTasks WHERE CountryCode = 'ES'


-- DELETE UNWANTED DATA
DELETE FROM SSIS.ImportActionTasks
Where ISNULL(BusinessId,'') = '' and ISNULL(ActionCode,'') = ''
and  ISNULL(AssignedTo,'') = '' and ISNULL(PanelCode,'') = ''
and ISNULL(StartDate,'') = '' and ISNULL(EndDate,'') = ''
--and ISNULL(InternalOrExternal,'') = '' and ISNULL(Comment,'') = '' and ISNULL([State],'') = ''


UPDATE SSIS.ImportActionTasks 
SET StartDate = (CASE RTRIM(LTRIM(StartDate)) WHEN '' THEN NULL ELSE StartDate END )
,EndDate = (CASE RTRIM(LTRIM(EndDate)) WHEN '' THEN NULL ELSE EndDate END )
,PanelCode = (CASE WHEN ltrim(PanelCode) ='' then NULL else ltrim(rtrim(PanelCode)) end)
where CountryCode=@CountryCode
--,InternalOrExternal=(CASE WHEN ltrim(rtrim(InternalOrExternal)) ='0' then '1'else ltrim(rtrim(InternalOrExternal)) end)



-- Log Audit Summary 				
		INSERT INTO [FileImportAuditSummary] (
			 CountryCode,PanelID,PanelName,[Filename]
			,FileImportDate,GPSUser,TotalRows,PassedRows,[Status]
			,Comments,ImportType, JobId)
		VALUES (
				@CountryCode,NULL,NULL,@FileName,@ImportDate,@GPSUser,0,0
				,'Processing',NULL,@ImportType, @JobId)

		SET @AuditId = @@Identity

	------------------------------------------
	-- Panelist
	------------------------------------------
	DECLARE @PanelistInfo AS TABLE (
			 BusinessID VARCHAR(20)
			,PanelistId UNIQUEIDENTIFIER
			,PanelCode  VARCHAR(50)
			,PanelType NVARCHAR(100)
			,CollaborationMethodology_GUID UNIQUEIDENTIFIER
			,IndividualId UNIQUEIDENTIFIER
			,CandidateId UNIQUEIDENTIFIER
			,PanelId UNIQUEIDENTIFIER
			,CollectiveId VARCHAR(20)
			)


		DECLARE @RoleName VARCHAR(50) = (CASE WHEN @CountryCode in ('GB', 'IE','ES') 
		THEN 'MainContactRoleName' ELSE 'MainShopperRoleName'  END )

				INSERT INTO @PanelistInfo(BusinessID,PanelistId,PanelCode,PanelType,CollaborationMethodology_GUID,IndividualId,
				CandidateId,PanelId, CollectiveId)
				SELECT  I.IndividualId AS BusinessId
				,pl.GUIDReference AS Panelist,P.PanelCode,P.[Type]					
				,pl.CollaborationMethodology_Id,I.GUIDReference,i.GUIDReference,pl.Panel_Id, C.Sequence as CollectiveId
				FROM Panelist pl				
				INNER JOIN CollectiveMembership cm ON cm.Group_Id = pl.PanelMember_Id
				Inner JOIN Collective C ON C.GUIDReference = cm.Group_Id
				INNER JOIN Individual i ON i.GUIDReference = cm.Individual_Id
				INNER JOIN Panel P ON P.GUIDReference=pl.Panel_Id	
			
				INNER JOIN (SELECT DRA.Candidate_Id ,DR.Code, T.KeyName, DRA.Panelist_Id
				FROM  dbo.DynamicRoleAssignment DRA
				JOIN dbo.DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id and DR.Country_Id = DRA.Country_ID
				JOIN dbo.Translation T ON T.TranslationId = DR.Translation_Id
				WHERE DRA.Country_Id = @CountryId
				AND KeyName = @RoleName ) rol  -- Main Contact
				ON rol.Candidate_Id = I.GUIDReference AND rol.Panelist_Id = pl.GUIDReference
				WHERE Pl.Country_Id= @CountryId

		UNION ALL
		SELECT  i.IndividualId AS BusinessId,pl.GUIDReference AS Panelist,P.PanelCode,P.[Type]		
			,pl.CollaborationMethodology_Id,i.GUIDReference,i.GUIDReference,pl.Panel_Id, NULL
				FROM Panelist pl
				INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id
				LEFT JOIN Panel P ON P.GUIDReference=pl.Panel_Id
				INNER JOIN (SELECT DRA.Candidate_Id ,DR.Code, T.KeyName, DRA.Panelist_Id
				FROM  dbo.DynamicRoleAssignment DRA
				JOIN dbo.DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id and DR.Country_Id = DRA.Country_ID
				JOIN dbo.Translation T ON T.TranslationId = DR.Translation_Id
				WHERE DRA.Country_Id = @CountryId
				AND KeyName = @RoleName ) rol  -- Main Contact
				ON rol.Candidate_Id = I.GUIDReference AND rol.Panelist_Id = pl.GUIDReference
			WHERE Pl.Country_Id=@CountryId
			AND @CountryCode NOT IN ('ES') -- ***  

			UNION ALL		
			SELECT  i.IndividualId AS BusinessId,pl.GUIDReference AS Panelist,P.PanelCode,P.[Type]		
			,pl.CollaborationMethodology_Id,i.GUIDReference,i.GUIDReference,pl.Panel_Id, NULL
				FROM Panelist pl
				INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id
				LEFT JOIN Panel P ON P.GUIDReference=pl.Panel_Id
				/*INNER JOIN (SELECT DRA.Candidate_Id ,DR.Code, T.KeyName, DRA.Panelist_Id
				FROM  dbo.DynamicRoleAssignment DRA
				JOIN dbo.DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id and DR.Country_Id = DRA.Country_ID
				JOIN dbo.Translation T ON T.TranslationId = DR.Translation_Id
				WHERE DRA.Country_Id = @CountryId
				AND KeyName = @RoleName ) rol  -- Main Contact
				ON rol.Candidate_Id = I.GUIDReference AND rol.Panelist_Id = pl.GUIDReference*/
			WHERE Pl.Country_Id=@CountryId
			AND @CountryCode IN ('ES') -- *** 
		UNION ALL

		SELECT  I.IndividualId AS BusinessId
				,C.GroupContact_Id AS CandidateId,P.PanelCode,P.[Type]					
				,pl.CollaborationMethodology_Id, I.GUIDReference, C.GroupContact_Id, pl.Panel_Id, C.Sequence as CollectiveId
			--SELECT  I.IndividualId AS BusinessId,
			--  C.GroupContact_Id  AS CandidateId					
			--,pl.CollaborationMethodology_Id, C.Sequence as CollectiveId
			--,SD.Code, P.PanelCode, P.[Type]
			--,P.GUIDReference
			 FROM Collective C
			INNER JOIN  CollectiveMembership CM ON CM.Group_Id = C.GUIDReference
				LEFT JOIN Individual ind ON  ind.GUIDReference = C.GroupContact_Id
			INNER JOIN Individual I ON I.GUIDReference =  CM.Individual_Id
			INNER JOIN  Panelist pl ON pl.PanelMember_Id = C.GUIDReference 
			INNER JOIN StateDefinition SD ON pl.State_Id = SD.Id  AND SD.Country_Id = @CountryId
			INNER JOIN Panel P ON P.GUIDReference = pl.Panel_Id 
			WHERE Pl.Country_Id= @CountryId
			AND @CountryCode IN ('MH') -- *** 
		
		print 'Validations'
		----------------------------------------
		-- Validations
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
		
		-- ERROR : 1. Invalid Panelist
		
		
		/*
		IF @CountryCode in ('GB', 'IE')
		BEGIN
			INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate , JobId)
			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			@ErrorSource, '0', 'Error: Panelist has Dropped off. BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ISNULL(IA.PanelCode,'')+'' , @ImportDate, @JobId
		    FROM SSIS.ImportActionTasks IA
			LEFT JOIN Individual i ON IA.BusinessId = i.IndividualId
			LEFT JOIN  Panelist pl ON i.GUIDReference = pl.PanelMember_Id
			LEFT JOIN Panel P ON P.GUIDReference=pl.Panel_Id and P.PanelCode = IA.PanelCode
			INNER JOIN StateDefinition SD ON pl.State_Id = SD.Id and SD.Country_Id = @CountryId
			AND SD.Code  in ('PanelistDroppedOffState', 'PanelistRefusalState')   -- Live Panelist only
			WHERE Pl.Country_Id = @CountryId

			union all

			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			@ErrorSource, '0', 'Error: Panelist has Dropped off. BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ISNULL(IA.PanelCode,'')+'' , @ImportDate, @JobId
		    FROM SSIS.ImportActionTasks IA
			LEFT JOIN Collective i ON IA.BusinessId = convert(varchar(20),i.Sequence) 
			LEFT JOIN  Panelist pl ON i.GUIDReference = pl.PanelMember_Id
			LEFT JOIN Panel P ON P.GUIDReference=pl.Panel_Id and P.PanelCode = IA.PanelCode
			INNER JOIN StateDefinition SD ON pl.State_Id = SD.Id and SD.Country_Id = @CountryId
			AND SD.Code  in ('PanelistDroppedOffState', 'PanelistRefusalState')   -- Live Panelist only
			WHERE Pl.Country_Id = @CountryId
		
			IF(@@ROWCOUNT > 0)
				SET @IsErrorOccured=1
				
		END
		*/

			INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate , JobId)
		
			--SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			--@ErrorSource, '0', 'Error: Invalid BusinessId (not a Panelist for given PanelCode). BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ISNULL(IA.PanelCode,'')+'' 
			--, @ImportDate, @JobId
		 --   FROM SSIS.ImportActionTasks IA
			--LEFT JOIN @PanelistInfo PInfo ON IA.BusinessId  IN ( PInfo.BusinessId  , PInfo.CollectiveId )
			-- AND IA.PanelCode = PInfo.PanelCode
			--WHERE PInfo.BusinessID IS NULL AND IA.PanelCode IS NOT NULL
			--and IA.CountryCode=@CountryCode


			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			@ErrorSource, '0', 'Error: Invalid BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ISNULL(IA.PanelCode,'')+'' 
			, @ImportDate, @JobId
			FROM SSIS.ImportActionTasks IA
			LEFT JOIN 
			(
				SELECT VI.BusinessId  AS BusinessId
				from @PanelistInfo VI
				--WHERE VI.CollectiveId IS NULL 

				UNION ALL 

				SELECT VI.CollectiveId  AS BusinessId
				from @PanelistInfo VI
				WHERE VI.CollectiveId IS NOT NULL 

			) V ON  V.BusinessId  = IA.BusinessId

			WHERE V.BusinessID IS NULL
			AND IA.CountryCode=@CountryCode

			UNION ALL
			
			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			@ErrorSource, '0', 'Error: No ' + @RoleName + ' in this group.  BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ISNULL(IA.PanelCode,'')+'' , @ImportDate, @JobId
			from  dbo.DynamicRoleAssignment DRA
			INNER JOIN  dbo.DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id and DR.Country_Id = DRA.Country_ID AND DRA.Country_Id = @CountryId
			INNER JOIN  dbo.Translation T ON T.TranslationId = DR.Translation_Id  and KeyName = @RoleName
			INNER JOIN CollectiveMembership cm ON DRA.Candidate_Id = cm.Individual_Id 
			Inner JOIN Collective C ON C.GUIDReference = cm.Group_Id   
			INNER JOIN Individual I ON i.GUIDReference = cm.Individual_Id and I.CountryId = @CountryId
			RIGHT JOIN  SSIS.ImportActionTasks IA  ON  (convert(varchar(20),C.sequence) = IA.BusinessId  OR IA.BusinessId = i.IndividualId)
			Where DRA.Candidate_Id IS NULL
				AND @CountryCode NOT IN ('ES') -- *** 
				and IA.CountryCode=@CountryCode
	 
			IF(@@ROWCOUNT>0)
			SET @IsErrorOccured=1


			 -- ERROR : 1.2.  Duplicate check
                     If (@CountryCode in('GB' ,'IE', 'MH'))
					 BEGIN 
                      print 'validate duplicates'
					 INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate ,JobId )
                     SELECT @CountryCode, @ImportType,  @FileName , PanelCode,  
                     @ErrorSource, '0', 'Error: Duplicate Action Tasks for:  BusinessId - ' + ISNULL(BusinessId,'') + ' , ActionCode - '+ISNULL(ActionCode,'') +', PanelCode - '+ISNULL(PanelCode,'')+'' , @ImportDate, @JobId
                     FROM (
                           SELECT BusinessId,PanelCode, IA.ActionCode, StartDate, count(1) cnt
                           FROM SSIS.ImportActionTasks IA
                           JOIN ActionTaskType AT ON CAST(AT.ActionCode AS VARCHAR)=IA.ActionCode AND AT.Country_Id=@CountryId
						   where IA.CountryCode=@CountryCode
                           group by BusinessId,PanelCode, IA.ActionCode, StartDate
                           having count(1) >1
                     ) V1

                     union all

                     SELECT @CountryCode, @ImportType,  @FileName , PanelCode,  
                     @ErrorSource, '0', 'Error: Duplicate Action Tasks for:  BusinessId - ' + ISNULL(BusinessId,'') 
                     + ' , ActionCode - '+ISNULL(ActionCode,'') +', PanelCode - '+ISNULL(PanelCode,'')+'' , @ImportDate, @JobId
                     FROM (
                           SELECT DISTINCT AT.Candidate_Id, AT.ActionTaskType_Id, AT.StartDate,Panel_Id, AT.Country_Id
                           ,IA.BusinessId, IA.ActionCode , IA.PanelCode
                           FROM SSIS.ImportActionTasks IA
                           INNER JOIN ActionTaskType ATT ON ATT.ActionCode=IA.ActionCode AND ATT.Country_Id=@CountryId
                           INNER JOIN @PanelistInfo PInfo1 ON IA.BusinessId in (PInfo1.BusinessId  , PInfo1.CollectiveId )  AND (IA.PanelCode=PInfo1.PanelCode)
                           INNER JOIN ActionTask AT ON 
                           AT.Candidate_Id = PInfo1.CandidateId
                           AND AT.ActionTaskType_Id= ATT.GUIDReference
                           AND AT.StartDate = IA.StartDate
                           AND AT.Panel_Id = PInfo1.PanelId
                           AND AT. Country_Id = @CountryId
						   where IA.CountryCode=@CountryCode
                     ) V2

                     
                     IF(@@ROWCOUNT>0)
                     SET @IsErrorOccured=1
					 END

			
			print 'validate ActionCode'
			-- ERROR : 2. InValid ActionCode
			INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate ,JobId )
			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			@ErrorSource, '0', 'Error: Invalid Action Code for:  BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ISNULL(IA.PanelCode,'')+'' , @ImportDate, @JobId
		    FROM SSIS.ImportActionTasks IA
			LEFT JOIN ActionTaskType AT ON CAST(AT.ActionCode AS VARCHAR)=IA.ActionCode AND AT.Country_Id=@CountryId
			WHERE AT.GUIDReference IS NULL
			and IA.CountryCode=@CountryCode
			
			IF(@@ROWCOUNT>0)
			SET @IsErrorOccured=1

			print 'validate Start and End Date'
			-- ERROR : 3.1 InValid Startdate
			--         3.2 InValid Enddate
			--         3.3 InValid dates. Start Date must be Less than End Date.
			;WITH TEMP AS (
			SELECT *,

			CASE
				WHEN ISDATE(StartDate)=1 AND  CAST(StartDate AS  DATE) > CAST(@ImportDate AS DATE) THEN 0
				ELSE  
				ISDATE(StartDate) 
				END AS ValidStartDate,
			-- ISDATE(StartDate) AS ValidStartDate ,
			 CASE
			 WHEN EndDate IS NULL THEN 1
			 ELSE
			 ISDATE(EndDate) END AS ValidEndDate 
			 FROM SSIS.ImportActionTasks IA
			 where IA.CountryCode=@CountryCode
			)

			INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate ,JobId)
			SELECT @CountryCode, @ImportType,  @FileName , PanelCode, 			
			@ErrorSource, '0', 
			CASE
			WHEN ValidStartDate!=1 AND ValidEndDate!=1 THEN
			'Error: Invalid Start Date and Invalid End Date for:  BusinessId - ' + ISNULL(BusinessId,'') + ' , ActionCode - '+ISNULL(ActionCode,'')+', AssigenTo - '+ISNULL(AssignedTo,'')+', PanelCode - '+ISNULL(PanelCode,'')+'' 
			WHEN ValidStartDate!=1 THEN
			'Error: Invalid Start Date for:  BusinessId - ' + ISNULL(BusinessId,'') + ' , ActionCode - '+ISNULL(ActionCode,'')+', AssigenTo - '+ISNULL(AssignedTo,'')+', PanelCode - '+ISNULL(PanelCode,'')+'' 
			WHEN ValidEndDate!=1 THEN 
			'Error: Invalid End Date for:  BusinessId - ' + ISNULL(BusinessId,'') + ' , ActionCode - '+ISNULL(ActionCode,'')+', AssigenTo - '+ISNULL(AssignedTo,'')+', PanelCode - '+ISNULL(PanelCode,'')+'' 
			WHEN (ValidStartDate=1 AND ValidEndDate=1 AND StartDate>EndDate) THEN
			'Error: Start Date must be Less than End Date. Invalid dates for:  BusinessId - ' + ISNULL(BusinessId,'') + ' , ActionCode - '+ISNULL(ActionCode,'')+', AssigenTo - '+ISNULL(AssignedTo,'')+', PanelCode - '+ISNULL(PanelCode,'')+'' 
			END
			
			,@ImportDate,@JobId
		    FROM TEMP
			WHERE (ValidStartDate!=1 OR ValidEndDate!=1 OR  (EndDate IS NOT NULL AND StartDate>EndDate))

			IF(@@ROWCOUNT>0)
			SET @IsErrorOccured=1

			-- ERROR : 4. InValid AssignedTo
			INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate,JobId )
			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			@ErrorSource, '0', 'Error: Invalid AssgnedTo '+ ISNULL(IA.AssignedTo,'')  + ' for:  BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ISNULL(IA.PanelCode,'')+'' , @ImportDate, @JobId
		    FROM SSIS.ImportActionTasks IA
			WHERE ( IA.AssignedTo IS NOT NULL AND  IA.AssignedTo <> '') 
			AND IA.AssignedTo  not in (
				select IU.UserName from SystemUserRole R
				join IdentityUser IU  ON R.IdentityUserId = IU.Id
				where R.CountryId =   @CountryId
			)
			and IA.CountryCode=@CountryCode

			IF(@@ROWCOUNT>0)
			SET @IsErrorOccured=1

			print 'validate Panelcode'
			-- ERROR : 5. InValid PanelCode
			INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate ,JobId)
			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			@ErrorSource, '0', 'Error: Invalid PanelCode for:  BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ISNULL(IA.PanelCode,'')+'' , @ImportDate, @JobId
		    FROM SSIS.ImportActionTasks IA
			LEFT JOIN @PanelistInfo pInfo ON pInfo.PanelCode = IA.PanelCode AND IA.BusinessId in (pInfo.BusinessID, pInfo.CollectiveId)
			WHERE pInfo.PanelCode IS NULL  AND IA.PanelCode IS NOT NULL
			and IA.CountryCode=@CountryCode

			 
			IF(@@ROWCOUNT>0)
			SET @IsErrorOccured=1
				
		print 'validate State'
		-- ERROR : 6. InValid State
		;WITH TEMP
		AS (
			SELECT *
				,CASE 
					WHEN [State] IN (1,2,4,8,16)
						THEN 1
					ELSE 0
					END AS ValidState
			FROM SSIS.ImportActionTasks
			where  CountryCode=@CountryCode
			)
				INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate ,JobId)
			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			@ErrorSource, '0', 'Error: Invalid State for:  BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ISNULL(IA.PanelCode,'')+'' , @ImportDate, @JobId
		    FROM TEMP IA  WHERE ValidState != 1 --AND InComing IS NOT NULL

			IF(@@ROWCOUNT>0)
			SET @IsErrorOccured=1
		
			INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate ,JobId)
			SELECT @CountryCode, @ImportType,  @FileName , TEMP.PanelCode,  
			@ErrorSource, '0', 'Error: End Date is mandatory when Action State is completed (State = 4). for:  BusinessId - ' + ISNULL(TEMP.BusinessId,'') + ' , ActionCode - '+ISNULL(TEMP.ActionCode,'')+', AssigenTo - '+ISNULL(TEMP.AssignedTo,'')+', PanelCode - '+ISNULL(TEMP.PanelCode,'')+'' , @ImportDate, @JobId
			FROM SSIS.ImportActionTasks TEMP 
			Where TEMP.[State] = 4 AND TEMP.EndDate IS NULL 
			and TEMP.CountryCode=@CountryCode

			IF(@@ROWCOUNT>0)
				SET @IsErrorOccured=1

			IF @CountryCode in ('GB', 'IE', 'MH')
			BEGIN
				INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate ,JobId)
				SELECT @CountryCode, @ImportType,  @FileName , TEMP.PanelCode,  
				@ErrorSource, '0', 'Error: End Date is not required when Action State: In-Progress (State = 1 or 2). for:  BusinessId - ' + ISNULL(TEMP.BusinessId,'') + ' , ActionCode - '+ISNULL(TEMP.ActionCode,'')+', AssigenTo - '+ISNULL(TEMP.AssignedTo,'')+', PanelCode - '+ISNULL(TEMP.PanelCode,'')+'' , @ImportDate, @JobId
				FROM SSIS.ImportActionTasks TEMP 
				Where TEMP.[State] in (1,2) AND TEMP.EndDate IS NOT NULL
				and TEMP.CountryCode=@CountryCode

				IF(@@ROWCOUNT>0)
					SET @IsErrorOccured=1
			END
			ELSE 
			BEGIN  -- FOR ASIA COUNTIRES
				
				INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate ,JobId)
				SELECT @CountryCode, @ImportType,  @FileName , TEMP.PanelCode,  
				@ErrorSource, '0', 'Error: End Date is required for:  BusinessId - ' + ISNULL(TEMP.BusinessId,'') + ' , ActionCode - '+ISNULL(TEMP.ActionCode,'')+', AssigenTo - '+ISNULL(TEMP.AssignedTo,'')+', PanelCode - '+ISNULL(TEMP.PanelCode,'')+'' , @ImportDate, @JobId
				FROM SSIS.ImportActionTasks TEMP 
				Where TEMP.[State] in (1,2,8,16) AND TEMP.EndDate IS NULL
				and TEMP.CountryCode=@CountryCode

				IF(@@ROWCOUNT>0)
					SET @IsErrorOccured=1
			END

		/*print 'validate InternalOrExternal'
		
		;WITH TEMP
		AS (
				SELECT * FROM SSIS.ImportActionTasks

			)
				INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate ,JobId)
			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			@ErrorSource, '0', 'Error: Invalid InternalOrExternal (Valid: 1 or 2) for:  BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ISNULL(IA.PanelCode,'')+'' , @ImportDate, @JobId
		    FROM TEMP IA  WHERE InternalOrExternal not in ('1','2') --AND ValidInternalOrExternal IS NOT NULL

			IF(@@ROWCOUNT>0)
			SET @IsErrorOccured=1
			*/


		--	validate Priority column
			INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate ,JobId)
			
			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			@ErrorSource, '0', 'Error: Invalid Priority for:  BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ 
			ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ ISNULL(IA.PanelCode,'')+'' , @ImportDate, @JobId
		  
		    FROM SSIS.ImportActionTasks IA
			WHERE IA.[Priority] IS NOT NULL  AND IA.[Priority] not in (0,1,2)
			and IA.CountryCode = @CountryCode

			IF(@@ROWCOUNT>0)
			SET @IsErrorOccured=1


		--	 validate CallBackDateTime	
			INSERT INTO [dbo].[FileImportErrorLog] (CountryCode, ImportType, [FileName], PanelCode, ErrorSource, ErrorCode, ErrorDescription, ErrorDate ,JobId)
			
			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			@ErrorSource, '0', 'Error: Invalid CallBackDateTime for:  BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ 
			ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ ISNULL(IA.PanelCode,'')+'' , @ImportDate, @JobId
		  
		    FROM SSIS.ImportActionTasks IA
			WHERE IA.CallBackDateTime IS NOT NULL AND ISDATE(IA.CallBackDateTime) <> 1
			and IA.CountryCode = @CountryCode

			UNION ALL 

			SELECT @CountryCode, @ImportType,  @FileName , IA.PanelCode,  
			@ErrorSource, '0', 'Error: CallBackDateTime should be between StartDate and End Date for:  BusinessId - ' + ISNULL(IA.BusinessId,'') + ' , ActionCode - '+ 
			ISNULL(IA.ActionCode,'')+', AssigenTo - '+ISNULL(IA.AssignedTo,'')+', PanelCode - '+ ISNULL(IA.PanelCode,'')+'' , @ImportDate, @JobId
		  
		    FROM SSIS.ImportActionTasks IA
			WHERE IA.CallBackDateTime NOT BETWEEN IA.StartDate  AND ISNULL(IA.EndDate, '2100-01-01')
			and IA.CountryCode = @CountryCode

			IF(@@ROWCOUNT>0)
			SET @IsErrorOccured=1
			 

END TRY
	BEGIN CATCH
	PRINT 'VALIDATION ERRROR OCCURED:'
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
			,'Unknown'
			,ERROR_NUMBER()
			,ERROR_MESSAGE()
			,@ImportDate
			,@JobId

			UPDATE [FileImportAuditSummary]
		SET [Status] = 'Error'
			,Comments = N'' + ERROR_MESSAGE()
			,PassedRows = @InsertedRows
		WHERE AuditId = @AuditId

		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1

		PRINT ERROR_MESSAGE();
			
	END CATCH
	

	-- PERFORM ACTUAL LOGIC
	IF @IsErrorOccured = 0 --  NO ISSUES WITH DATA
	BEGIN
		BEGIN TRY
			PRINT 'PROCESS STARTED'     

			DECLARE @ActionTaskInsert as TABLE (
			StartDate datetime,
			EndDate datetime,
			CompletionDate datetime,
			ActionComment nvarchar(1000),
			InternalOrExternal  int,
			GPSUser  nvarchar(100),
			GPSUpdateTimestamp datetime,
			CreationTimeStamp datetime,
			[State]  int, 
			CommunicationCompletion_Id uniqueidentifier,
			ActionTaskType_Id uniqueidentifier,
			Candidate_Id uniqueidentifier,
			Country_Id uniqueidentifier,
			FormId uniqueidentifier,
			Assignee_Id uniqueidentifier,
			Panel_Id uniqueidentifier,
			ActionTaskPriority int,
			CallBackDateTime datetime
			)

			INSERT INTO @ActionTaskInsert

			SELECT  distinct IA.StartDate,IA.EndDate,IA.EndDate,Comment,@InternalOrExternal,@GPSUser,@ImportDate,@ImportDate,[State],
			@CommunicationCompletion_Id,ATT.GUIDReference,PInfo1.CandidateId,@CountryId,@FormId,IU.Id,PInfo1.PanelId
			,[Priority], CallBackDateTime
			FROM SSIS.ImportActionTasks IA
			INNER JOIN ActionTaskType ATT ON ATT.ActionCode=IA.ActionCode AND ATT.Country_Id=@CountryId
			INNER  JOIN @PanelistInfo PInfo1 ON IA.BusinessId in (PInfo1.BusinessId  , PInfo1.CollectiveId )  AND (IA.PanelCode=PInfo1.PanelCode)
			LEFT JOIN IdentityUser IU ON IU.UserName=IA.AssignedTo  
			LEFT JOIN SystemUserRole R ON R.IdentityUserId = IU.Id AND R.CountryId =   @CountryId
			 where IA.PanelCode is not null and IA.CountryCode=@CountryCode
			
			UNION

			SELECT  distinct IA.StartDate,IA.EndDate,IA.EndDate CompletionDate,Comment,@InternalOrExternal,@GPSUser,@ImportDate,@ImportDate,[State],
			@CommunicationCompletion_Id,ATT.GUIDReference ,PInfo1.CandidateId, @CountryId, @FormId, IU.Id, NULL as PanelId
			,[Priority], CallBackDateTime
			FROM SSIS.ImportActionTasks IA
			INNER JOIN ActionTaskType ATT ON ATT.ActionCode=IA.ActionCode AND ATT.Country_Id=@CountryId
			INNER  JOIN @PanelistInfo PInfo1 ON IA.BusinessId in (PInfo1.BusinessId  , PInfo1.CollectiveId )  
			LEFT JOIN IdentityUser IU ON IU.UserName=IA.AssignedTo  
			LEFT JOIN SystemUserRole R ON R.IdentityUserId = IU.Id AND R.CountryId =   @CountryId
				where IA.PanelCode is  null and IA.CountryCode=@CountryCode
			

			INSERT INTO ActionTask(GUIDReference,StartDate,EndDate,CompletionDate,ActionComment,
								   InternalOrExternal,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,[State],
								   CommunicationCompletion_Id,ActionTaskType_Id,Candidate_Id,Country_Id,
									FormId,Assignee_Id,Panel_Id, ActionTaskPriority, CallBackDateTime)

			select newID(), StartDate,EndDate,CompletionDate, ActionComment,
								   InternalOrExternal,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,[State],
								   CommunicationCompletion_Id,ActionTaskType_Id,Candidate_Id,Country_Id,
									FormId,Assignee_Id,Panel_Id,
									ActionTaskPriority, CallBackDateTime
			FROM @ActionTaskInsert
			
			 
			SET @InsertedRows = @@ROWCOUNT

			PRINT '@InsertedRows : ' + convert(VARCHAR(10), @InsertedRows)

			UPDATE [FileImportAuditSummary]
			SET [Status] = 'Completed'
				,PassedRows = @InsertedRows
				,TotalRows = @InsertedRows
			WHERE AuditId = @AuditId
		END TRY

		BEGIN CATCH
			PRINT 'CRITICAL ERROR OCCURED'

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
			WHERE AuditId = @AuditId
		END CATCH
	END
	ELSE
	BEGIN 
			UPDATE [FileImportAuditSummary]
			SET [Status] = 'Error'
				,Comments = N'' + 'Import Process failed'
				,PassedRows = 0
			WHERE AuditId = @AuditId
			
			SELECT 'ERROR OCCURED'
	END

	SELECT @InsertedRows AS Rowsinserted
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