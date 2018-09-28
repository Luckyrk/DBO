
CREATE VIEW [dbo].[FullTextMessage] 
AS
SELECT cnt.CountryISO2A
      ,txtdoc.[DocumentId]
       ,CASE 
              WHEN ind.IndividualId IS NULL
                     THEN cast(col.sequence AS NVARCHAR(30))
              ELSE ind.IndividualId
              END AS PanelMemberId
      ,txtdoc.[TextDate]
      ,txtdoc.[SenderId]
      ,txtdoc.[Recipient]
      ,txtdoc.[Message]
      ,txtdoc.[GPSUser]
      ,txtdoc.[GPSUpdateTimestamp]
      ,txtdoc.[CreationTimeStamp]
      ,txtdoc.[Unusable]
         ,dta.ActionTaskId
         ,dce.CommunicationEventId
  FROM [dbo].[TextDocument] txtdoc
  inner join dbo.Document doc on doc.DocumentId = txtdoc.DocumentId
  left join dbo.DocumentActionTaskAssociation dta on dta.DocumentId = txtdoc.DocumentId
  left join dbo.DocumentCommunicationEventAssociation dce on dce.DocumentId = txtdoc.DocumentId
  left join dbo.DocumentPanelistAssociation dpa on dpa.DocumentId = txtdoc.DocumentId
  left join dbo.DocumentType dty on dty.DocumentTypeId = doc.DocumentTypeId
  left join dbo.DocumentSubType dst on dst.DocumentSubTypeId = doc.DocumentSubTypeId
  left join dbo.ActionTask atk on atk.GUIDReference = dta.ActionTaskId
  LEFT JOIN dbo.CommunicationEvent cev on cev.GUIDReference = dce.CommunicationEventId
  left join dbo.Panelist pst on pst.GUIDReference = dpa.PanelistId
  JOIN Country cnt ON  cnt.CountryId = doc.CountryId
  left join dbo.individual ind on ind.GUIDReference = cev.Candidate_Id
  left join dbo.Collective col on col.GUIDReference = cev.Candidate_Id

GO
 