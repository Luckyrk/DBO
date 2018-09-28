/*##########################################################################    
-- Name				: DeleteDemographicTargetSetById.sql    
-- Date             : 2015-28-10
-- Author           : GPSDeveloper    
-- Company          : Cognizant Technology Solution    
-- Purpose          : Delete Data from Demographic Target Set By Id
-- Usage   : From the UI once we click on the Delete Demographic Target Button 
-- Required grants  :     
-- Called by        : Preallocated      
-- Params Defintion :    
    @pDemographicTargetSetId -- DemographicTargetSet Id
-- Sample Execution :    
 
##########################################################################    
-- ver  user		date        change     
-- 1.0  Parimi     2015-28-10   InitialVersion
##########################################################################*/

CREATE PROCEDURE [dbo].[DeleteDemographicTargetSetById] (
	@pDemographicTargetSetId UNIQUEIDENTIFIER
	)
AS
BEGIN
	BEGIN TRANSACTION T
		BEGIN TRY
		DECLARE @relatedDemographicId UNIQUEIDENTIFIER
		DECLARE @panelId UNIQUEIDENTIFIER
		DECLARE @dimensionId UNIQUEIDENTIFIER

		SET @panelId = (SELECT Panel_Id FROM [PanelTargetDefinition] WHERE GUIDReference = @pDemographicTargetSetId)
		SET @dimensionId = (SELECT Dimension_Id FROM [PanelTargetDefinition] WHERE GUIDReference = @pDemographicTargetSetId)

		DELETE FROM DemographicTargetScoreboard WHERE DemographicStateSetScoreboard_Id IN (
		SELECT GUIDReference FROM DemographicStateSetScoreboard WHERE StateSet_Id IN (SELECT GUIDReference FROM StateGroupDefinition WHERE DemographicTargetSet_Id=@pDemographicTargetSetId))

		DELETE FROM DemographicStateSetScoreboard WHERE StateSet_Id IN (SELECT GUIDReference FROM StateGroupDefinition WHERE DemographicTargetSet_Id=@pDemographicTargetSetId)

		DELETE FROM StateGroupDefinition WHERE DemographicTargetSet_Id=@pDemographicTargetSetId

		DELETE FROM DVS
		FROM DemographicValueSet DVS
		INNER JOIN PanelTargetValueMapping PTVM 
		on DVS.GUIDReference = PTVM.DemographicValue_Id
		INNER JOIN [PanelTargetValue] PTV on PTVM.RelatedDemographic_Id = PTV.GUIDReference where  DemographicTarget_Id IN (@pDemographicTargetSetId)


		DELETE FROM DV
		FROM DemographicValue DV  
		INNER JOIN PanelTargetValueMapping PTVM 
		on DV.GUIDReference = PTVM.DemographicValue_Id
		INNER JOIN [PanelTargetValue] PTV on PTVM.RelatedDemographic_Id = PTV.GUIDReference where  DemographicTarget_Id IN (@pDemographicTargetSetId)

		DELETE FROM DVI
		FROM DemographicValueInterval DVI 
		INNER JOIN PanelTargetValueMapping PTVM 
		on DVI.GUIDReference = PTVM.DemographicValue_Id
		INNER JOIN [PanelTargetValue] PTV on PTVM.RelatedDemographic_Id = PTV.GUIDReference where  DemographicTarget_Id IN (@pDemographicTargetSetId)

		DELETE FROM DemographicValueGrouping WHERE GUIDReference IN (
		SELECT DV.[Grouping_Id] FROM DemographicValue DV  
		INNER JOIN DemographicValueGrouping DVG ON DV.DemographicValueGrouping_Id = DVG.GUIDReference
		INNER JOIN PanelTargetValueMapping PTVM 
		on DV.GUIDReference = PTVM.DemographicValue_Id
		INNER JOIN [PanelTargetValue] PTV on PTVM.RelatedDemographic_Id = PTV.GUIDReference where  DemographicTarget_Id IN (@pDemographicTargetSetId))


		DELETE FROM PanelTargetValueMapping WHERE RelatedDemographic_Id IN (SELECT GUIDReference FROM [PanelTargetValue] WHERE DemographicTarget_Id IN (@dimensionId))

		DELETE FROM [PanelTargetValue] WHERE DemographicTarget_Id IN (@dimensionId)

		DELETE FROM [PanelTargetDefinition] WHERE GUIDReference = @pDemographicTargetSetId

		DELETE FROM [PanelTargetValueDefinition] WHERE GUIDReference = @dimensionId
		COMMIT TRANSACTION T
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION T
		DECLARE @ERR_MSG AS NVARCHAR(4000)
			,@ERR_STA AS SMALLINT

		SET @ERR_MSG = ERROR_MESSAGE();
		SET @ERR_STA = ERROR_STATE();

		THROW 50001
			,@ERR_MSG
			,@ERR_STA;
	END CATCH
END


