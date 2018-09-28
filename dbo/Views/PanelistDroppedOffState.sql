
CREATE VIEW [dbo].[PanelistDroppedOffState]
AS
SELECT SD.Id AS StateDefinitionId
	,SDH.Country_Id AS CountryId
	,SDH.Panelist_Id AS PanelistId
	,Code AS PanelStateCode
	,MAX(SDH.CreationDate) MaxCreationDate
FROM dbo.StateDefinitionHistory SDH
INNER JOIN StateDefinition sd ON sd.id = SDH.To_Id
WHERE Code = 'PanelistDroppedOffState'
--('PanelistInterestedState','PanelistLiveState','PanelistDroppedOffState')
GROUP BY SDH.Country_Id
	,Panelist_Id
	,Code
	,SD.Id