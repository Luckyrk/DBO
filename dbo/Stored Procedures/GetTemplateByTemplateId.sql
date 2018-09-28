

CREATE procedure [dbo].[GetTemplateByTemplateId]
@templateId bigint
as 
begin
select 
cmc.CommsMessageTemplateComponentTypeId,
cmc.TextContent,
cmc.Subject
from TemplateMessageDefinition tmd
join TemplateMessageStructure tms on tms.TemplateMessageDefinitionId=tmd.TemplateMessageDefinitionId
join TemplateMessageConfiguration tmc on tms.TemplateMessageDefinitionId = tmc.TemplateMessageDefinitionId 
						and tms.CommsMessageTemplateComponentTypeId=tmc.CommsMessageTemplateComponentTypeId
						and tmc.CommsMessageTemplateSubTypeId=tms.CommsMessageTemplateSubTypeId
						and tmc.CommsMessageTemplateTypeId=tms.CommsMessageTemplateTypeId
join CommsMessageTemplateComponent cmc on tmc.CommsMessageTemplateComponentId=cmc.CommsMessageTemplateComponentId
									and tmc.CommsMessageTemplateComponentTypeId=cmc.CommsMessageTemplateComponentTypeId
									and tmc.CommsMessageTemplateSubTypeId=cmc.CommsMessageTemplateSubTypeId
									and tmc.CommsMessageTemplateTypeId=cmc.CommsMessageTemplateTypeId
where tmd.TemplateMessageDefinitionId=@templateId
end