CREATE PROCEDURE [dbo].[GetAvailableindividualPanelPanelists] (
       @pCultureCode INT
	   --,@pPanelId UNIQUEIDENTIFIER
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

			  set @isHouseHoldPanel  ='false'			

              SELECT P.GUIDReference AS PanelId,i.IndividualId AS BusinessId
                     ,tt.Value AS PanelistState
					 ,@isHouseHoldPanel as IsHouseHoldPanel
                     ,pl.CreationDate AS CreationDate
                     ,i.GUIDReference AS CandidateId
					 ,T.KeyName,ISNULL(CM.Code,'') AS DiaryTypeCode
              FROM Panelist pl
			  INNER JOIN Panel P ON P.GUIDReference=pl.Panel_Id
              INNER JOIN Individual i ON i.GUIDReference = pl.PanelMember_Id                     
			  INNER JOIN DynamicRoleAssignment DA ON DA.Candidate_Id = i.GUIDReference
                     AND da.DynamicRole_Id = @MainShopperId  AND DA.Panelist_Id=pl.GUIDReference and Group_Id is null
              INNER JOIN StateDefinition s ON pl.State_Id = s.Id
              INNER JOIN TranslationTerm tt ON s.Label_Id = tt.Translation_Id
			  INNER JOIN Translation T ON T.TranslationId=tt.Translation_Id
			  LEFT JOIN CollaborationMethodology CM ON CM.GUIDReference=pl.CollaborationMethodology_Id
              WHERE tt.CultureCode = @pCultureCode
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