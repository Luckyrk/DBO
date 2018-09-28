CREATE PROCEDURE [dbo].[GetAvailablePanelists] (
       @pCultureCode INT
       ,@pPanelId UNIQUEIDENTIFIER
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
               set @isHouseHoldPanel  ='true'
			
              SELECT i.IndividualId AS BusinessId
                     ,tt.Value AS PanelistState
					 ,@isHouseHoldPanel as IsHouseHoldPanel
                     ,p.CreationDate AS CreationDate
                     ,i.GUIDReference AS CandidateId
					 ,T.KeyName,ISNULL(CM.Code,'') AS DiaryTypeCode
              FROM Panelist p
			  INNER JOIN Collective c ON p.PanelMember_Id = c.GUIDReference
                     AND p.Panel_Id = @pPanelId 
              INNER JOIN DynamicRoleAssignment DA ON DA.Group_Id = c.GUIDReference
                     AND da.DynamicRole_Id = @MainShopperId  AND DA.Panelist_Id IS NULL
              INNER JOIN Individual i ON i.GUIDReference = da.Candidate_Id
              INNER JOIN StateDefinition s ON p.State_Id = s.Id
              INNER JOIN TranslationTerm tt ON s.Label_Id = tt.Translation_Id
			  INNER JOIN Translation T ON T.TranslationId=tt.Translation_Id
			  LEFT JOIN CollaborationMethodology CM ON CM.GUIDReference=P.CollaborationMethodology_Id
              WHERE tt.CultureCode = @pCultureCode			 
              AND DA.Panelist_Id IS NULL
              UNION               
               SELECT i.IndividualId AS BusinessId
                     ,tt.Value AS PanelistState
					 ,@isHouseHoldPanel as IsMainShopper
                     ,p.CreationDate AS CreationDate
                     ,i.GUIDReference AS CandidateId
					 ,T.KeyName,ISNULL(CM.Code,'') AS DiaryTypeCode
              FROM Panelist p
              INNER JOIN Collective c ON p.PanelMember_Id = c.GUIDReference
                     AND p.Panel_Id = @pPanelId
              INNER JOIN DynamicRoleAssignment DA ON DA.Panelist_Id = p.GUIDReference
                     AND da.DynamicRole_Id = @MainShopperId  AND DA.Group_Id IS NULL
              INNER JOIN Individual i ON i.GUIDReference = da.Candidate_Id
              INNER JOIN StateDefinition s ON p.State_Id = s.Id
              INNER JOIN TranslationTerm tt ON s.Label_Id = tt.Translation_Id
			  INNER JOIN Translation T ON T.TranslationId=tt.Translation_Id
			  LEFT JOIN CollaborationMethodology CM ON CM.GUIDReference=P.CollaborationMethodology_Id
              WHERE tt.CultureCode = @pCultureCode
			  AND DA.Group_Id IS NULL
       END
       ELSE
       BEGIN -- Individual panel type
			  set @isHouseHoldPanel  ='false'
			
              SELECT i.IndividualId AS BusinessId
                     ,tt.Value AS PanelistState
					 ,@isHouseHoldPanel as IsHouseHoldPanel
                     ,p.CreationDate AS CreationDate
                     ,i.GUIDReference AS CandidateId
					 ,T.KeyName,ISNULL(CM.Code,'') AS DiaryTypeCode
              FROM Panelist p
              INNER JOIN Individual i ON i.GUIDReference = p.PanelMember_Id
                     AND p.Panel_Id = @pPanelId
			  INNER JOIN DynamicRoleAssignment DA ON DA.Candidate_Id = i.GUIDReference
                     AND da.DynamicRole_Id = @MainShopperId  AND DA.Panelist_Id=p.GUIDReference and Group_Id is null
              INNER JOIN StateDefinition s ON p.State_Id = s.Id
              INNER JOIN TranslationTerm tt ON s.Label_Id = tt.Translation_Id
			  INNER JOIN Translation T ON T.TranslationId=tt.Translation_Id
			  LEFT JOIN CollaborationMethodology CM ON CM.GUIDReference=P.CollaborationMethodology_Id
              WHERE tt.CultureCode = @pCultureCode
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

