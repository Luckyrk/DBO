CREATE PROCEDURE [dbo].[GetSmsTemplatesByIndividualId] (
    @pCountryId UNIQUEIDENTIFIER
    ,@pIndividualId UNIQUEIDENTIFIER
    )
AS
BEGIN
BEGIN TRY

(SELECT     DISTINCT   TemplateMessageDefinition.Description AS TemplateDescription, TemplateMessageDefinition.TemplateMessageDefinitionId AS TemplateId
FROM            PanelTemplateMessageScheme INNER JOIN
TemplateMessageScheme ON PanelTemplateMessageScheme.TemplateMessageSchemeId = TemplateMessageScheme.TemplateMessageSchemeId INNER JOIN

 TemplateMessageDefinition ON TemplateMessageScheme.TemplateMessageSchemeId = TemplateMessageDefinition.TemplateMessageSchemeId INNER JOIN
                         Panelist ON PanelTemplateMessageScheme.panel_Id = Panelist.Panel_Id INNER JOIN
                         Collective ON Panelist.PanelMember_Id = Collective.GUIDReference INNER JOIN
                         CollectiveMembership ON Collective.GUIDReference = CollectiveMembership.Group_Id INNER JOIN
                         Individual ON   CollectiveMembership.Individual_Id = Individual.GUIDReference INNER JOIN
                         
						 
                        
						  TemplateUsageIntent TI ON TemplateMessageDefinition.TemplateUsageIntentId=TI.TemplateUsageIntentId
						 inner join TemplateMessageConfiguration tmc ON TemplateMessageDefinition.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId
						 where tmc.CommsMessageTemplateTypeId = 2  and Collective.CountryId = @pCountryId  and Individual.GUIDReference=@pIndividualId and TI.Description ='Individual')

						 union
(SELECT     DISTINCT   TemplateMessageDefinition.Description AS TemplateDescription, TemplateMessageDefinition.TemplateMessageDefinitionId AS TemplateId
FROM            PanelTemplateMessageScheme INNER JOIN
TemplateMessageScheme ON PanelTemplateMessageScheme.TemplateMessageSchemeId = TemplateMessageScheme.TemplateMessageSchemeId INNER JOIN

 TemplateMessageDefinition ON TemplateMessageScheme.TemplateMessageSchemeId = TemplateMessageDefinition.TemplateMessageSchemeId INNER JOIN
                         Panelist ON PanelTemplateMessageScheme.panel_Id = Panelist.Panel_Id INNER JOIN
                       
                         Individual ON   Panelist.PanelMember_Id  = Individual.GUIDReference INNER JOIN
                         
						 
                        
						  TemplateUsageIntent TI ON TemplateMessageDefinition.TemplateUsageIntentId=TI.TemplateUsageIntentId
						 inner join TemplateMessageConfiguration tmc ON TemplateMessageDefinition.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId
						 where tmc.CommsMessageTemplateTypeId = 2  and Individual.CountryId = @pCountryId and Individual.GUIDReference=@pIndividualId AND TI.Description ='Individual')
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
						--DECLARE @individualCountryId uniqueidentifier=NEWID()
						----select * from PanelTemplateMessageScheme
						--SELECT * FROM TemplateMessageDefinition
						--insert into PanelTemplateMessageScheme values(18,@individualCountryId,'142B5C5E-4254-C057-0C86-08D11B00442A')
						----mock Id--142B5C5E-4254-C057-0C86-08D11B00442A,HHid===6E3D5FF3-4816-C859-B566-08D11B00446D
						--select * from Individual WHERE IndividualId='000001-00'
						

						

						

GO


