CREATE VIEW [dbo].FullCommunicationActions
	AS
SELECT dbo.Country.CountryISO2A
	,dbo.Individual.IndividualId
	,dbo.ActionTask.StartDate
	,dbo.ActionTask.EndDate
	,dbo.ActionTask.CompletionDate
	,CAST(dbo.ActionTask.ActionComment AS NVARCHAR(255)) AS ActionComment
	,dbo.ActionTask.InternalOrExternal
	,dbo.ActionTask.STATE
	,CASE dbo.ActionTask.STATE
		WHEN 1
			THEN 'ToDo'
		WHEN 2
			THEN 'InProgress'
		WHEN 4
			THEN 'Completed'
		WHEN 8
			THEN 'CanceledByUser'
		WHEN 16
			THEN 'CanceledBySystem'
		ELSE NULL
		END AS StateDescription
	,dbo.ActionTaskType.ActionCode
	,replace(dbo.Translation.KeyName, 'Desc', '') AS ActionDescription
	,dbo.ActionTaskType.IsForDpa
	,dbo.ActionTaskType.Type
	,dbo.Panel.PanelCode
	,dbo.Panel.NAME AS PanelName
	,dbo.ActionTask.GPSUser
	,dbo.ActionTask.GPSUpdateTimestamp
	,dbo.ActionTask.CreationTimeStamp
	,CASE 
		WHEN b.[To] IS NOT NULL
			THEN b.[To]
		WHEN c.[Recipient] IS NOT NULL
			THEN c.[Recipient]
		END AS IncomingAddress
FROM dbo.ActionTask
INNER JOIN dbo.ActionTaskType ON dbo.ActionTask.ActionTaskType_Id = dbo.ActionTaskType.GUIDReference
LEFT JOIN dbo.Candidate ON dbo.ActionTask.Candidate_Id = dbo.Candidate.GUIDReference
LEFT JOIN dbo.Individual ON dbo.Candidate.GUIDReference = dbo.Individual.[GUIDReference]
INNER JOIN dbo.Country ON dbo.ActionTask.Country_ID = dbo.Country.CountryId
INNER JOIN dbo.Translation ON dbo.ActionTaskType.DescriptionTranslation_Id = dbo.Translation.TranslationId
LEFT JOIN dbo.Panel ON dbo.ActionTask.Panel_Id = dbo.Panel.GUIDReference
LEFT JOIN DocumentActionTaskAssociation a ON a.ActionTaskId = ActionTask.GUIDReference
LEFT JOIN EmailDocument b ON b.DocumentId = a.DocumentId
LEFT JOIN TextDocument c ON c.DocumentId = a.DocumentId