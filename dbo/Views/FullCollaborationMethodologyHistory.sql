
CREATE VIEW [dbo].[FullCollaborationMethodologyHistory]
AS
SELECT cnt.[CountryISO2A]
	,pan.[PanelCode]
	,pan.NAME AS [PanelName]
	,CASE 
		WHEN ind.IndividualId IS NULL
			THEN cast(col.sequence AS NVARCHAR)
		ELSE ind.IndividualId
		END AS [PanelistId]
	,a.DATE
	,a.CreationTimeStamp
	,a.GPSUser
	,a.GPSUpdateTimestamp
	,cm1.Code AS OldCode
	,tr1.KeyName AS OldCollaborationMethodology
	,cm2.Code AS NewCode
	,tr2.KeyName AS NewCollaborationMethodology
	,cmcr.Code AS ChangeReasonCode
	,tr3.KeyName AS ChangeReasonDescription
	,a.Comments
FROM CollaborationMethodologyHistory a
INNER JOIN dbo.Country cnt ON cnt.CountryId = a.Country_Id
INNER JOIN dbo.Panelist pst ON pst.GUIDReference = a.Panelist_Id
INNER JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
LEFT JOIN dbo.individual ind ON ind.GUIDReference = pst.PanelMember_Id
LEFT JOIN dbo.collective col ON col.GUIDReference = pst.PanelMember_Id
LEFT JOIN CollaborationMethodology cm1 ON cm1.GUIDReference = a.OldCollaborationMethodology_Id
LEFT JOIN Translation tr1 ON tr1.TranslationId = cm1.TranslationId
LEFT JOIN CollaborationMethodology cm2 ON cm2.GUIDReference = a.NewCollaborationMethodology_Id
LEFT JOIN Translation tr2 ON tr2.TranslationId = cm2.TranslationId
LEFT JOIN CollaborationMethodologyChangeReason cmcr ON cmcr.ChangeReasonId = a.CollaborationMethodologyChangeReason_Id
LEFT JOIN Translation tr3 ON tr3.TranslationId = cmcr.Description_Id