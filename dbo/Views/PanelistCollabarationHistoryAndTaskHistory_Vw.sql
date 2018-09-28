GO
CREATE VIEW PanelistCollabarationHistoryAndTaskHistory_Vw
AS
WITH TEMP
AS (
	SELECT PL.GUIDReference AS Panelist_Id
		,I.IndividualId
		,P.PanelCode 
		,P.NAME AS PanelName
		,CH.[Date] AS [Date]
		,(
			ROW_NUMBER() OVER (
				PARTITION BY CH.Panelist_Id ORDER BY CH.CreationTimeStamp DESC
				)
			) AS RNO
		,dbo.GetTranslationValue(C1.TranslationId, 2057) AS NewMethodology
		,dbo.GetTranslationValue(C2.TranslationId, 2057) AS OldMethodology
		,CMCR.Code AS ChangeReasonCode
		,dbo.GetTranslationValue(CMCR.Description_Id, 2057) AS Reason
		,CH.Comments
		,CH.GPSUser
		,CH.CreationTimeStamp
	FROM Panelist PL
	JOIN Panel P ON P.GUIDReference = PL.Panel_Id
	JOIN CollectiveMembership CM ON (
			CM.Group_Id = PL.PanelMember_Id
			OR CM.Individual_Id = PL.PanelMember_Id
			)
	JOIN Individual I ON I.GUIDReference = CM.Individual_Id
	JOIN CollaborationMethodologyHistory CH ON CH.Panelist_Id = PL.GUIDReference
	JOIN CollaborationMethodology C1 ON C1.GUIDReference = CH.NewCollaborationMethodology_Id
	LEFT JOIN CollaborationMethodology C2 ON C2.GUIDReference = CH.OldCollaborationMethodology_Id
	LEFT JOIN CollaborationMethodologyChangeReason CMCR ON CMCR.ChangeReasonId = CH.CollaborationMethodologyChangeReason_Id
	)
SELECT Panelist_Id
	,IndividualId
	,PanelCode
	,'' AS [PanelTaskType] 
	,PanelName
	,[Date] AS Todate
	,(
		SELECT TOP 1 T2.[Date]
		FROM TEMP T2
		WHERE T1.Panelist_Id = T2.Panelist_Id
			AND T2.RNO < T1.RNO
		ORDER BY T2.RNO DESC
		) AS FromDate
	,'Old: ' + ISNULL(OldMethodology, '') + ' ' + 'New: ' + NewMethodology + ' / Reason: ' + Reason + ' / Comment: ' + ISNULL(Comments, '') AS Comments
	,'CM' AS [Type]
	,GPSUser
	,CreationTimeStamp
FROM TEMP T1

UNION ALL

SELECT pp.GUIDReference
	,I.IndividualId
	,P.PanelCode
	,TT.Value AS [PanelTaskType]
	,P.NAME AS PanelName
	,ppt.[ToDate] AS Todate
	,ppt.FromDate
	,'Name: ' + T.NAME AS Comments
	,'Task' AS [Type]
	,ppt.GPSUser
	,ppt.CreationTimeStamp
FROM [PartyPanelSurveyParticipationTask] ppt
INNER JOIN PanelSurveyParticipationTask pt ON pt.panelsurveyparticipationtaskid = ppt.paneltaskassociation_id
INNER JOIN Country c ON c.countryId = pt.country_id
INNER JOIN SurveyParticipationTask t ON t.surveyparticipationtaskid = pt.task_id
LEFT JOIN PANELTASKTYPE PTT ON T.PANELTASKTYPE_ID = PTT.GUIDREFERENCE
LEFT JOIN TRANSLATION T1 ON T1.TRANSLATIONID = PTT.[DESCRIPTION_Id]
LEFT JOIN TRANSLATIONTERM TT ON T1.TRANSLATIONID = TT.TRANSLATION_ID AND TT.CULTURECODE=2057
INNER JOIN Panelist pp ON pp.guidreference = ppt.panelist_id
INNER JOIN Panel p ON pp.Panel_Id = p.GUIDReference
JOIN CollectiveMembership CM ON (
		CM.Group_Id = pp.PanelMember_Id
		OR CM.Individual_Id = pp.PanelMember_Id
		)
JOIN Individual I ON I.GUIDReference = CM.Individual_Id

GO