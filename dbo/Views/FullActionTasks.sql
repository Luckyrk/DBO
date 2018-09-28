
CREATE VIEW [dbo].[FullActionTasks]
AS
SELECT dbo.Country.CountryISO2A, dbo.Individual.IndividualId, dbo.ActionTask.StartDate, dbo.ActionTask.EndDate, dbo.ActionTask.CompletionDate, 
CAST ( dbo.ActionTask.ActionComment AS NVARCHAR(255) ) as ActionComment, dbo.ActionTask.InternalOrExternal, dbo.ActionTask.State, 
CASE dbo.ActionTask.State
WHEN 1 THEN 'ToDo'
WHEN 2 THEN 'InProgress'
WHEN 4 THEN 'Completed'
WHEN 8 THEN 'CanceledByUser'
WHEN 16 THEN 'CanceledBySystem'
ELSE Null END AS StateDescription,
dbo.ActionTaskType.ActionCode, 
dbo.GetTranslationvalue(DescriptionTranslation_Id,2057) as ActionDescription,
dbo.ActionTaskType.IsForDpa, dbo.ActionTaskType.Type, dbo.Panel.PanelCode, dbo.Panel.Name as PanelName,
dbo.ActionTask.GPSUser, dbo.ActionTask.GPSUpdateTimestamp, dbo.ActionTask.CreationTimeStamp
FROM dbo.ActionTask INNER JOIN
dbo.ActionTaskType ON dbo.ActionTask.ActionTaskType_Id = dbo.ActionTaskType.GUIDReference LEFT JOIN
dbo.Candidate ON dbo.ActionTask.Candidate_Id = dbo.Candidate.GUIDReference LEFT JOIN
dbo.Individual ON dbo.Candidate.GUIDReference = dbo.Individual.[GUIDReference] INNER JOIN
dbo.Country ON dbo.ActionTask.Country_ID = dbo.Country.CountryId iNNER JOIN
dbo.Translation on dbo.ActionTaskType.DescriptionTranslation_Id = dbo.Translation.TranslationId
LEFT JOIN
dbo.Panel ON dbo.ActionTask.Panel_Id = dbo.Panel.GUIDReference
