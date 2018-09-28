CREATE VIEW [dbo].[PanelTaskDefinition]
AS
SELECT t.Code
	,TT.VALUE AS [PanelTaskType]
	,t.NAME
	,p.PanelCode
	,p.NAME AS PanelName
	,c.CountryISO2A
	,pt.ActiveFrom
	,pt.ActiveTo
	,pt.Mandatory
FROM panelsurveyparticipationtask pt
INNER JOIN Country c ON c.countryId = pt.country_id
INNER JOIN Panel p ON p.GUIDReference = pt.Panel_Id
INNER JOIN surveyparticipationtask t ON t.surveyparticipationtaskid = pt.task_id
LEFT JOIN PANELTASKTYPE PTT ON T.PANELTASKTYPE_ID = PTT.GUIDREFERENCE
LEFT JOIN TRANSLATION T1 ON T1.TRANSLATIONID = PTT.[DESCRIPTION_Id]
LEFT JOIN TRANSLATIONTERM TT ON T1.TRANSLATIONID = TT.TRANSLATION_ID
	AND TT.CULTURECODE = 2057
