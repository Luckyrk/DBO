
CREATE PROCEDURE [dbo].[CheckDuplicateDiaryEntry] (
	@pBusinessId VARCHAR(100)
	,@pPanelId UNIQUEIDENTIFIER
	,@pDiaryDateYear INT
	,@pDiaryDatePeriod INT
	,@pDiaryDateWeek INT
	,@pCultureCode INT
	,@pCountryid UNIQUEIDENTIFIER
	,@pSequence INT
	)
AS
BEGIN
BEGIN TRY
	DECLARE @panelType VARCHAR(20)
		,@MainShopperId UNIQUEIDENTIFIER
		,@CountryId UNIQUEIDENTIFIER
		,@MainShopperTranslation UNIQUEIDENTIFIER
		,@isHouseHoldPanel BIT


	SELECT @panelType = Type
	FROM Panel
	WHERE GUIDReference = @pPanelId

	SELECT @MainShopperId = DynamicRoleId
	FROM DynamicRole
	INNER JOIN Translation trn ON trn.TranslationId = dynamicrole.Translation_Id
		AND trn.KeyName = 'MainShopperRoleName'
	WHERE Country_Id = @pCountryid

	IF (@panelType = 'HouseHold')
	BEGIN
		SET @isHouseHoldPanel = 'true'

		SELECT * INTO  #TEMPHouseholdDiaryInfo FROM (
		SELECT i.IndividualId AS BusinessId
			,tt.Value AS PanelistState
			,@isHouseHoldPanel AS IsHouseHoldPanel
			,p.CreationDate AS CreationDate
			,i.GUIDReference AS CandidateId
			,T.KeyName
			,ISNULL(CM.Code, '') AS DiaryTypeCode 
			,pid.FirstOrderedName+' '+ pid.LastOrderedName as PanelistName
		FROM Collective c
		INNER JOIN Panelist p ON c.GUIDReference = p.PanelMember_Id
			AND C.Sequence = @pSequence
			AND c.CountryId = @pCountryid
			AND p.Panel_Id = @pPanelId
		INNER JOIN DynamicRoleAssignment DA ON DA.Panelist_Id = p.GUIDReference
			AND da.DynamicRole_Id = @MainShopperId
			AND DA.Group_Id IS NULL
		INNER JOIN Individual i ON i.GUIDReference = da.Candidate_Id
		INNER JOIN PersonalIdentification pid ON pid.PersonalIdentificationId = i.PersonalIdentificationId
		INNER JOIN StateDefinition s ON p.State_Id = s.Id
		INNER JOIN TranslationTerm tt ON s.Label_Id = tt.Translation_Id
		INNER JOIN Translation T ON T.TranslationId = tt.Translation_Id
		LEFT JOIN CollaborationMethodology CM ON CM.GUIDReference = P.CollaborationMethodology_Id
		WHERE tt.CultureCode = @pCultureCode
		
		UNION ALL
		
		SELECT i.IndividualId AS BusinessId
			,tt.Value AS PanelistState
			,@isHouseHoldPanel AS IsHouseHoldPanel
			,p.CreationDate AS CreationDate
			,i.GUIDReference AS CandidateId
			,T.KeyName
			,ISNULL(CM.Code, '') AS DiaryTypeCode
			,pid.FirstOrderedName+' '+ pid.LastOrderedName as PanelistName 
		FROM Collective c
		INNER JOIN Panelist p ON c.GUIDReference = p.PanelMember_Id
			AND C.Sequence = @pSequence
			AND c.CountryId = @pCountryid
			AND p.Panel_Id = @pPanelId
		INNER JOIN DynamicRoleAssignment DA ON DA.Group_Id = c.GUIDReference
			AND da.DynamicRole_Id = @MainShopperId
			AND DA.Panelist_Id IS NULL
		INNER JOIN Individual i ON i.GUIDReference = da.Candidate_Id
	    INNER JOIN PersonalIdentification pid ON pid.PersonalIdentificationId = i.PersonalIdentificationId
		INNER JOIN StateDefinition s ON p.State_Id = s.Id
		INNER JOIN TranslationTerm tt ON s.Label_Id = tt.Translation_Id
		INNER JOIN Translation T ON T.TranslationId = tt.Translation_Id
		LEFT JOIN CollaborationMethodology CM ON CM.GUIDReference = P.CollaborationMethodology_Id
		WHERE tt.CultureCode = @pCultureCode
		) AS TT
		SELECT * FROM  #TEMPHouseholdDiaryInfo
	END
	ELSE
	BEGIN -- Individual panel type
		SET @isHouseHoldPanel = 'false'

		SELECT i.IndividualId AS BusinessId
			,tt.Value AS PanelistState
			,@isHouseHoldPanel AS IsHouseHoldPanel
			,p.CreationDate AS CreationDate
			,i.GUIDReference AS CandidateId
			,T.KeyName
			,ISNULL(CM.Code, '') AS DiaryTypeCode
			,pid.FirstOrderedName+' '+ pid.LastOrderedName  as PanelistName 
		FROM Panelist p
		INNER JOIN Individual i ON i.GUIDReference = p.PanelMember_Id
			AND i.IndividualId = @pBusinessId
			AND p.Panel_Id = @pPanelId
		INNER JOIN PersonalIdentification pid ON pid.PersonalIdentificationId = i.PersonalIdentificationId
		INNER JOIN DynamicRoleAssignment DA ON DA.Candidate_Id = i.GUIDReference
			AND da.DynamicRole_Id = @MainShopperId
			AND DA.Panelist_Id = p.GUIDReference
			AND Group_Id IS NULL
		INNER JOIN StateDefinition s ON p.State_Id = s.Id
		INNER JOIN TranslationTerm tt ON s.Label_Id = tt.Translation_Id
		INNER JOIN Translation T ON T.TranslationId = tt.Translation_Id
		LEFT JOIN CollaborationMethodology CM ON CM.GUIDReference = P.CollaborationMethodology_Id
		WHERE tt.CultureCode = @pCultureCode
		END

		IF EXISTS (
				SELECT 1
				FROM DiaryEntry
				WHERE DiaryDateYear = @pDiaryDateYear
					AND DiaryDatePeriod = @pDiaryDatePeriod
					AND DiaryDateWeek = @pDiaryDateWeek
					AND PanelId = @pPanelId
					AND BusinessId = @pBusinessId
				)
			SELECT 1
		ELSE
		BEGIN
		if(@isHouseHoldPanel='false')
		BEGIN
			SELECT 0
		END
		ELSE
		BEGIN
			DECLARE @mainshopbusinessID VARCHAR(100)
            SET @mainshopbusinessID=(SELECT TOP 1 T.BusinessId FROM #TEMPHouseholdDiaryInfo T)
				IF EXISTS (
					SELECT 1
					FROM DiaryEntry
					WHERE DiaryDateYear = @pDiaryDateYear
						AND DiaryDatePeriod = @pDiaryDatePeriod
						AND DiaryDateWeek = @pDiaryDateWeek
						AND PanelId = @pPanelId
						AND BusinessId = @mainshopbusinessID
						and @pBusinessId<>@mainshopbusinessID
						)
						BEGIN
							SELECT 1
						END
						ELSE
						BEGIN
							SELECT 0
						END
		END
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
End