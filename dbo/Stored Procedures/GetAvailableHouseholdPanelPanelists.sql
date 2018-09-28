--EXEC GetAvailableHouseholdPanelPanelists 2057,'70387977-88F8-40C4-BCD0-1173F1AAFFC4'
CREATE PROCEDURE [dbo].[GetAvailableHouseholdPanelPanelists] (
       @pCultureCode INT       
       ,@pCountryid UNIQUEIDENTIFIER
       )

AS

BEGIN
BEGIN TRY
       DECLARE @panelType VARCHAR(20)
              ,@MainShopperId UNIQUEIDENTIFIER
              ,@CountryId UNIQUEIDENTIFIER
              ,@MainShopperTranslation UNIQUEIDENTIFIER
			  ,@isHouseHoldPanel bit

       SELECT @MainShopperId = DynamicRoleId
       FROM DynamicRole
       INNER JOIN Translation trn ON trn.TranslationId = dynamicrole.Translation_Id
              AND trn.KeyName = 'MainShopperRoleName'
       WHERE Country_Id = @pCountryid

     SET @isHouseHoldPanel  ='true'
			
     SELECT  Pnl.GUIDReference AS PanelId,i.IndividualId AS BusinessId
     ,tt.Value AS PanelistState
	 ,@isHouseHoldPanel as IsHouseHoldPanel
     ,p.CreationDate AS CreationDate
     ,i.GUIDReference AS CandidateId
	 ,T.KeyName,ISNULL(CM.Code,'') AS DiaryTypeCode
     FROM Panelist p
	 INNER JOIN Collective c ON p.PanelMember_Id = c.GUIDReference
	  INNER JOIN Panel Pnl ON Pnl.GUIDReference=P.Panel_Id
     --AND p.Panel_Id = @pPanelId 
     INNER JOIN DynamicRoleAssignment DA ON DA.Group_Id = c.GUIDReference
     AND da.DynamicRole_Id = @MainShopperId  AND DA.Panelist_Id IS NULL
	 INNER JOIN Individual i ON i.GUIDReference = da.Candidate_Id
     INNER JOIN StateDefinition s ON p.State_Id = s.Id
	 INNER JOIN TranslationTerm tt ON s.Label_Id = tt.Translation_Id
	 INNER JOIN Translation T ON T.TranslationId=tt.Translation_Id
	 LEFT JOIN CollaborationMethodology CM ON CM.GUIDReference=P.CollaborationMethodology_Id
              WHERE tt.CultureCode = @pCultureCode			 
              AND DA.Panelist_Id IS NULL
     UNION ALL

     SELECT  Pnl.GUIDReference AS PanelId,i.IndividualId AS BusinessId
	,tt.Value AS PanelistState
	,@isHouseHoldPanel as IsMainShopper
	,p.CreationDate AS CreationDate
	,i.GUIDReference AS CandidateId
	,T.KeyName,ISNULL(CM.Code,'') AS DiaryTypeCode
	 FROM Panelist p
	  INNER JOIN Panel Pnl ON Pnl.GUIDReference=P.Panel_Id
	 INNER JOIN Collective c ON p.PanelMember_Id = c.GUIDReference
		--AND p.Panel_Id = @pPanelId
	INNER JOIN DynamicRoleAssignment DA ON DA.Panelist_Id = p.GUIDReference
	AND da.DynamicRole_Id = @MainShopperId  AND DA.Group_Id IS NULL
	INNER JOIN Individual i ON i.GUIDReference = da.Candidate_Id
	INNER JOIN StateDefinition s ON p.State_Id = s.Id
	INNER JOIN TranslationTerm tt ON s.Label_Id = tt.Translation_Id
	INNER JOIN Translation T ON T.TranslationId=tt.Translation_Id
	LEFT JOIN CollaborationMethodology CM ON CM.GUIDReference=P.CollaborationMethodology_Id
	WHERE tt.CultureCode = @pCultureCode
	AND DA.Group_Id IS NULL
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