--USE GPS_PM_FRA
--GO
CREATE VIEW [dbo].[GetPanelistHistoryInfo_FR]
AS
SELECT 
 x.IndividualId, x.PanelCode, x.StartDate, x.UpdateDate, x.ChangeCode, x.EndDate,x.PanelMember_Id,y.ChangeToolDate, y.ToolCode
,TT.FromDate,TT.ToDate,TT.TaskCode1, TT.TaskCode2, TT.TaskCode3, TT.TaskCode4,TT.TaskCode5, TT.TaskCode6, TT.TaskCode7, TT.TaskCode8, TT.TaskCode9, TT.TaskCode10
--SELECT COUNT(0)
 FROM (
SELECT * FROM
(
SELECT f.IndividualId, g.PanelCode, DATEADD(SECOND,1,a.CreationDate) as StartDate, ISNULL(r.Code,'') as ChangeCode, ISNULL(c.GPSUpdateTimestamp, a.GPSUpdateTimestamp) as UpdateDate, c.CreationDate as EndDate,
e.PanelMember_Id,a.Panelist_Id
FROM 
StateDefinitionHistory a 
JOIN  StateDefinition b ON a.To_Id = b.Id and b.Code = 'PanelistLiveState'
LEFT JOIN StateDefinitionHistory c ON a.Panelist_Id = c.Panelist_Id AND a.To_Id = c.From_Id
										AND a.GPSUpdateTimestamp = c.GPSUpdateTimestamp
LEFT JOIN StateDefinition d ON c.To_Id = d.Id AND d.Code = 'PanelistDroppedOffState'
JOIN Panelist e ON a.Panelist_Id = e.GUIDReference
JOIN Individual f ON e.PanelMember_Id = f.GUIDReference
JOIN Panel g ON e.Panel_Id = g.GUIDReference
LEFT JOIN ReasonForChangeState r ON c.ReasonForchangeState_Id = r.Id
) x
group by x.IndividualId, x.PanelCode, x.StartDate, x.ChangeCode, x.UpdateDate, x.EndDate, x.PanelMember_Id,x.Panelist_Id
) AS x
INNER JOIN (
	select * ,LEAD(ChangeToolDate) OVER(Partition BY PanelMember_Id ORDER BY ChangeToolDate ASC) NextValue  
	from
	(
	select a.[Date] as ChangeToolDate, d.Code as ToolCode, f.PanelCode, p.PanelMember_Id,a.Panelist_Id  As PanelistGuid
	from CollaborationMethodologyHistory a
	JOIN Panelist p ON a.Panelist_Id = p.GUIDReference
	JOIN Panel f on p.Panel_Id = f.GUIDReference
	LEFT JOIN CollaborationMethodologyChangeReason  c ON c.ChangeReasonId = a.CollaborationMethodologyChangeReason_Id
	JOIN CollaborationMethodology d ON d.GUIDReference = a.NewCollaborationMethodology_Id
	) y
) y on x.PanelMember_Id = y.PanelMember_Id
and x.StartDate >= y.ChangeToolDate
and x.StartDate < ISNULL(y.NextValue,'9999-12-31')
--and x.StartDate < 
--					(
--						select ISNULL(MIN(ChangeToolDate), '9999-12-31') from 
--                           (
--							select b.PanelMember_Id, a.[Date] as ChangeToolDate from CollaborationMethodologyHistory a 
--							join Panelist b on a.Panelist_Id = b.GUIDReference
--						 ) AS CM  WHERE y.PanelMember_Id = PanelMember_Id and y.ChangeToolDate < ChangeToolDate
--				  )
INNER JOIN (
SELECT Panelist_Id,PanelCode,FromDate,ToDate,[1] AS TaskCode1, [2] AS TaskCode2, [3] AS TaskCode3, [4] AS TaskCode4,[5] AS TaskCode5, [6] AS TaskCode6, [7] AS TaskCode7
, [8] AS TaskCode8, [9] AS TaskCode9, [10] AS TaskCode10,PanelMember_Id,
LEAD(FromDate) OVER(Partition BY PanelMember_Id ORDER BY FromDate ASC) NextValue 
 FROM (
select ROW_NUMBER() OVER(Partition BY a.Panelist_Id,a.FromDate ORDER BY e.Code ASC ) AS SNO, a.Panelist_Id,c.PanelCode, a.FromDate, a.ToDate, b.PanelMember_Id,e.Code
 from PartyPanelSurveyParticipationTask a
 JOIN Panelist b on a.Panelist_Id = b.GUIDReference
 JOIN Panel c on b.Panel_Id = c.GUIDReference
 JOIN PanelSurveyParticipationTask d ON a.PanelTaskAssociation_Id = d.PanelSurveyParticipationTaskId AND b.Panel_Id = d.Panel_Id
JOIN SurveyParticipationTask e ON d.Task_Id = e.SurveyParticipationTaskId
--WHERE b.PanelMember_Id='9A90FFE2-4578-4200-B47A-9EBEF95085A6'
) AS SourceTable 
PIVOT
(
MIN(Code)
FOR SNO IN ([1], [2], [3], [4],[5],[6],[7], [8], [9],[10])
) AS PivotTable
) TT ON TT.PanelMember_Id=y.PanelMember_Id 
and x.StartDate >= TT.FromDate
and x.StartDate < ISNULL(TT.NextValue,'9999-12-31')
-- (select ISNULL(MIN(ChangeTaskDate), '9999-12-31') from 
--                         (select b.PanelMember_Id, a.FromDate as ChangeTaskdate 
--						 from PartyPanelSurveyParticipationTask a 
--						 join Panelist b on a.Panelist_Id = b.GUIDReference
--						 ) AS PT
--	where TT.PanelMember_Id = PanelMember_Id 
--	and TT.FromDate < ChangeTaskdate)
--WHERE IndividualId='0012024-01'
GO
--GRANT SELECT ON GetPanelistHistoryInfo TO GPSBusiness
--GRANT SELECT ON GetPanelistHistoryInfo TO GPSBusiness_Full
--GO