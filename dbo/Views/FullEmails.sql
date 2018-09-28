CREATE VIEW [dbo].[FullEmails]
AS
SELECT cnt.CountryISO2A
       ,edoc.[DocumentId]
       ,CASE 
              WHEN ind.IndividualId IS NULL
                     THEN cast(col.sequence AS NVARCHAR(30))
              ELSE ind.IndividualId
              END AS PanelMemberId
       ,edoc.[EmailDate]
       ,edoc.[Subject]
       ,edoc.[From]
       ,edoc.[To]
       ,edoc.[EmailContent]
       ,edoc.[GPSUser]
       ,edoc.[GPSUpdateTimestamp]
       ,edoc.[CreationTimeStamp]
       ,edoc.[Unusable]
       ,dta.ActionTaskId
       ,dce.CommunicationEventId
FROM [dbo].[EmailDocument] edoc
INNER JOIN dbo.Document doc ON doc.DocumentId = edoc.DocumentId
LEFT JOIN dbo.DocumentActionTaskAssociation dta ON dta.DocumentId = edoc.DocumentId
LEFT JOIN dbo.DocumentCommunicationEventAssociation dce ON dce.DocumentId = edoc.DocumentId
LEFT JOIN dbo.DocumentPanelistAssociation dpa ON dpa.DocumentId = edoc.DocumentId
LEFT JOIN dbo.DocumentType dty ON dty.DocumentTypeId = doc.DocumentTypeId
LEFT JOIN dbo.DocumentSubType dst ON dst.DocumentSubTypeId = doc.DocumentSubTypeId
LEFT JOIN dbo.ActionTask atk on atk.GUIDReference = dta.ActionTaskId
LEFT JOIN dbo.CommunicationEvent cev on cev.GUIDReference = dce.CommunicationEventId
LEFT JOIN dbo.Panelist pst ON pst.GUIDReference = dpa.PanelistId
JOIN Country cnt ON cnt.CountryId = doc.CountryId 
LEFT JOIN dbo.individual ind ON ind.GUIDReference = cev.Candidate_Id
LEFT JOIN dbo.Collective col ON col.GUIDReference = cev.Candidate_Id
