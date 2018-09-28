--EXEC [Usp_PanelistCollabarationHistoryAndTaskHistory] '0121213-01',24

CREATE PROCEDURE [dbo].[Usp_PanelistCollabarationHistoryAndTaskHistory] --'150103-00' --'150103-00'
@pIndividualId VARCHAR(100),
@pPanelCode INT
AS
BEGIN
BEGIN TRY
WITH TEMP AS (
SELECT PL.GUIDReference AS Panelist_Id,I.IndividualId,P.PanelCode,P.Name AS PanelName,CH.[Date] AS [Date],
(ROW_NUMBER() OVER(PARTITION BY CH.Panelist_Id ORDER BY CH.CreationTimeStamp DESC)) AS RNO,
dbo.GetTranslationValue(C1.TranslationId,2057) AS NewMethodology,
dbo.GetTranslationValue(C2.TranslationId,2057) AS OldMethodology,
CMCR.Code AS ChangeReasonCode,
dbo.GetTranslationValue(CMCR.Description_Id,2057) AS Reason,CH.Comments,CH.GPSUser,CH.CreationTimeStamp
FROM 
Panelist PL
JOIN Panel P ON P.GUIDReference=PL.Panel_Id
JOIN CollectiveMembership CM ON (CM.Group_Id=PL.PanelMember_Id  OR CM.Individual_Id=PL.PanelMember_Id)
JOIN Individual I ON I.GUIDReference=CM.Individual_Id
JOIN CollaborationMethodologyHistory CH ON CH.Panelist_Id=PL.GUIDReference
JOIN CollaborationMethodology C1 ON C1.GUIDReference=CH.NewCollaborationMethodology_Id
LEFT JOIN CollaborationMethodology C2 ON C2.GUIDReference=CH.OldCollaborationMethodology_Id
LEFT JOIN CollaborationMethodologyChangeReason CMCR ON CMCR.ChangeReasonId=CH.CollaborationMethodologyChangeReason_Id
WHERE I.IndividualId=@pIndividualId AND PanelCode=@pPanelCode
)
SELECT Panelist_Id,IndividualId,PanelCode,PanelName,[Date] AS FromDate,
(
SELECT TOP 1 T2.[Date]  FROM TEMP T2 WHERE T1.Panelist_Id=T2.Panelist_Id AND T2.RNO<T1.RNO ORDER BY T2.RNO DESC
) AS Todate, 'Old: '+ISNULL(OldMethodology,'')+' '+'New: '+NewMethodology+' / Reason: '+Reason+' / Comment: ' +ISNULL(Comments,'') AS Comments
,'CM' AS [Type],GPSUser,CreationTimeStamp FROM TEMP T1

UNION ALL

SELECT pp.GUIDReference, I.IndividualId,P.PanelCode,P.Name AS PanelName,ppt.FromDate,ppt.[ToDate] AS Todate,
'Name: '+T.Name AS Comments,'Task' AS [Type],ppt.GPSUser,ppt.CreationTimeStamp
FROM
[PartyPanelSurveyParticipationTask] ppt
INNER JOIN PanelSurveyParticipationTask pt ON pt.panelsurveyparticipationtaskid = ppt.paneltaskassociation_id
INNER JOIN Country c ON c.countryId = pt.country_id
INNER JOIN SurveyParticipationTask t ON t.surveyparticipationtaskid = pt.task_id
INNER JOIN Panelist pp ON pp.guidreference = ppt.panelist_id
INNER JOIN Panel p ON pp.Panel_Id = p.GUIDReference
JOIN CollectiveMembership CM ON (CM.Group_Id=pp.PanelMember_Id  OR CM.Individual_Id=pp.PanelMember_Id)
JOIN Individual I ON I.GUIDReference=CM.Individual_Id
WHERE I.IndividualId=@pIndividualId AND PanelCode=@pPanelCode
ORDER BY CreationTimeStamp DESC
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




