
CREATE VIEW [dbo].[GetEmailTemplates]
AS
SELECT DISTINCT Cnt.CountryISO2A
	,TMD.templatemessagedefinitionId AS TemplateId
	,CMT.Subject
	,TMD.Description AS TemplateName
FROM templatemessageconfiguration TMC
INNER JOIN templatemessagedefinition TMD ON TMC.templatemessagedefinitionId = TMD.templatemessagedefinitionId
INNER JOIN commsmessagetemplatetype CT ON CT.commsmessagetemplatetypeId = TMC.commsmessagetemplatetypeId
INNER JOIN commsMessageTemplateComponent CMT ON CMT.[CommsMessageTemplateComponentId] = TMC.[CommsMessageTemplateComponentId]
	AND CMT.[CommsMessageTemplateTypeId] = TMC.[CommsMessageTemplateTypeId]
	AND CMT.[CommsMessageTemplateSubTypeId] = TMC.[CommsMessageTemplateSubTypeId]
	AND CMT.[CommsMessageTemplateComponentTypeId] = TMC.[CommsMessageTemplateComponentTypeId]
INNER JOIN templatemessagescheme SC ON SC.TemplateMessageSchemeId = TMC.TemplateMessageSchemeId
INNER JOIN Country Cnt ON Cnt.CountryId = SC.CountryId
WHERE CT.Description = 'Email'
	AND tmc.ActiveTo IS NULL
	AND TMC.CommsMessageTemplateComponentTypeId = 2