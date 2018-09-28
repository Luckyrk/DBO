CREATE VIEW [dbo].[PanelistTaskAssociations]
AS
SELECT i.IndividualId
	,t.Code
	,TT.VALUE AS [PanelTaskType]
	,t.NAME
	,p.panelcode
	,p.NAME AS PanelName
	,c.CountryISO2A
	,ppt.[FromDate]
	,ppt.[ToDate]
	,ppt.Active
FROM [partypanelsurveyparticipationtask] ppt
INNER JOIN panelsurveyparticipationtask pt ON pt.panelsurveyparticipationtaskid = ppt.paneltaskassociation_id
INNER JOIN Country c ON c.countryId = pt.country_id
INNER JOIN surveyparticipationtask t ON t.surveyparticipationtaskid = pt.task_id
LEFT JOIN PANELTASKTYPE PTT ON T.PANELTASKTYPE_ID = PTT.GUIDREFERENCE
LEFT JOIN TRANSLATION T1 ON T1.TRANSLATIONID = PTT.[DESCRIPTION_Id]
LEFT JOIN TRANSLATIONTERM TT ON T1.TRANSLATIONID = TT.TRANSLATION_ID AND TT.CULTURECODE=2057
INNER JOIN panelist pp ON pp.guidreference = ppt.panelist_id
INNER JOIN panel p ON pp.Panel_Id = p.GUIDReference
LEFT JOIN collective g ON g.guidreference = pp.panelmember_id
INNER JOIN individual i ON i.guidreference = g.groupcontact_id
	OR i.guidreference = pp.panelmember_id
