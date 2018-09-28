
CREATE VIEW [dbo].[GetSMSTemplates]
AS
SELECT DISTINCT Cnt.CountryISO2A
	,TMD.templatemessagedefinitionId AS TemplateId
	,TMD.Description AS TemplateName
FROM templatemessageconfiguration TMC
INNER JOIN templatemessagedefinition TMD ON TMC.templatemessagedefinitionId = TMD.templatemessagedefinitionId
INNER JOIN commsmessagetemplatetype CT ON CT.commsmessagetemplatetypeId = TMC.commsmessagetemplatetypeId
INNER JOIN templatemessagescheme SC ON SC.TemplateMessageSchemeId = TMC.TemplateMessageSchemeId
INNER JOIN Country Cnt ON Cnt.CountryId = SC.CountryId
INNER JOIN CommsMessageTemplateComponent CC ON CC.CommsMessageTemplateComponentId = TMC.CommsMessageTemplateComponentId
	AND CC.CommsMessageTemplateTypeId = TMC.CommsMessageTemplateTypeId
	AND CC.CommsMessageTemplateSubTypeId = TMC.CommsMessageTemplateSubTypeId
	AND CC.CommsMessageTemplateComponentTypeId = TMC.CommsMessageTemplateComponentTypeId
WHERE CT.Description = 'SMS'
	AND CC.CommsMessageTemplateComponentTypeId = 4