
--USE [GPS_PM]
--GO
--/****** Object:  View [dbo].[FullEmailTemplateVariables]    Script Date: 13/02/2015 16:05:30 ******/
--SET ANSI_NULLS ON
--GO
--SET QUOTED_IDENTIFIER ON
--GO
CREATE VIEW [dbo].[FullEmailTemplateVariables]
AS
SELECT CountryISO2A
	,TemplateMessageDefinitionId AS TemplateId
	,Description AS TemplateDescription
	,ItemNumber / 2 AS VariableNo
	,replace(Item, ';', '') AS VariableName
FROM (
	SELECT cnt.CountryISO2A
		,tem.TemplateMessageDefinitionId
		,def.Description
		,replace([TextContent], '&#172', '¬') AS string
	FROM [TemplateMessageConfiguration] tem
	INNER JOIN TemplateMessageDefinition def ON def.TemplateMessageDefinitionId = tem.TemplateMessageDefinitionId
	INNER JOIN CommsMessageTemplateComponent com ON com.CommsMessageTemplateComponentId = tem.CommsMessageTemplateComponentId
	INNER JOIN TemplateMessageScheme sch ON sch.TemplateMessageSchemeId = def.TemplateMessageSchemeId
	INNER JOIN Country cnt ON cnt.CountryId = sch.CountryId
	WHERE tem.[CommsMessageTemplateComponentTypeId] = 2
	) a
CROSS APPLY dbo.DelimitedSplit8K(a.string, '¬') split
WHERE split.ItemNumber IN (
		2
		,4
		,6
		,8
		,10
		,12
		,14
		,16
		,18
		,20
		,22
		,24
		,26
		,28
		,30
		,32
		,34
		,36
		,38
		,40
		,42
		,44
		,46
		,48
		,50
		,52
		,54
		,56
		,58
		,60
		,62
		,64
		,66
		,68
		,70
		,72
		,74
		,76
		,78
		,80
		)