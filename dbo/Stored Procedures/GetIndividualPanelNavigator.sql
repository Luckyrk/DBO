/*##########################################################################
-- Name				: GetIndividualPanelNavigator
-- Date             : 2014-10-27
-- Author           : Teena Areti
-- Purpose          : GetIndividualPanelNavigator fetches the individual details, panels associated with that provided individuals and the collaberation methodoloy details for the individual
					  param definitions
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : Called from UI
-- PARAM Definitions
			-- @pindividualid guid reference of individual

			-- @pculturecode int variable of culture code.

			-- EXEC GetIndividualPanelNavigator  'BC05A5FD-CB7E-C4F4-C1A6-08D11B004586',2057
##########################################################################
-- version  user                  date        change 
-- 1.0  Teena Areti				2014-10-27   Initial
-- 1.1	Teena Areti				2014-11-21	 Added gettranslatedvalue function to retrieve key and value
-- 1.2	Venkata Ramana			2014-11-28	 Added the resultset for Collabaration Methodology
##########################################################################*/
CREATE PROCEDURE [dbo].[GetIndividualPanelNavigator] @pindividualid UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
AS
BEGIN
BEGIN TRY 
	DECLARE @GetDate DATETIME
	SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@pCountryId))
	DECLARE @LastMethodologyDate DATETIME = @GetDate

	SELECT TOP 1 I.GUIDReference AS IndividualId
		,I.IndividualId AS BusinessId
		,CASE (cm.DiscriminatorType)
			WHEN 'HOUSEHOLD'
				THEN 1
			ELSE 0
			END AS HasHouseholdMemberShip
	FROM Individual I
	LEFT JOIN CollectiveMembership CM ON CM.Individual_Id = I.GUIDReference
	WHERE I.GUIDReference = @pindividualid

	DECLARE @plindi UNIQUEIDENTIFIER
	DECLARE @plgroup UNIQUEIDENTIFIER

	SELECT @plindi = cm.Individual_Id
		,@plgroup = cm.Group_Id
	FROM CollectiveMembership cm
	WHERE cm.Individual_Id = @pindividualid

	SELECT PL.GUIDReference AS PanelistId
		,P.Name AS PanelName
		,P.GUIDReference AS Panelid
		,PL.CreationDate AS SignUpDate
		,P.Panels_Order AS PanelOrder
		,PL.CollaborationMethodology_Id AS Id
		,dbo.GetTranslationValue(CM.TranslationId, NULL) AS TranslationKeyName
		,dbo.GetTranslationValue(CM.TranslationId, @pCultureCode) AS NAME
		,dbo.GetTranslationValue(CM.TranslationId, @pCultureCode) AS CollaborationMethodologyName
		,@LastMethodologyDate AS LastMethodologyDate
		,SD.Code AS StateName
		,SD.TrafficLightBehavior AS DisplayBehavior
	FROM Panelist PL
	INNER JOIN Panel P ON P.GUIDReference = PL.Panel_Id
	LEFT JOIN CollaborationMethodology CM ON PL.CollaborationMethodology_Id = CM.GUIDReference
	INNER JOIN StateDefinition SD ON SD.Id = PL.State_Id
	WHERE PanelMember_Id IN (
			@plindi
			,@plgroup
			)
	ORDER BY p.Panels_Order

	SELECT CM.GUIDReference AS Id
		,dbo.GetTranslationValue(TranslationId, NULL) AS TranslationKeyName
		,dbo.GetTranslationValue(TranslationId, @pCultureCode) AS NAME
	FROM CollaborationMethodology CM
	WHERE Country_Id = @pCountryId
END TRY 
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH
END
GO