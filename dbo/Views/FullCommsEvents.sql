
CREATE VIEW [dbo].[FullCommsEvents]
AS

SELECT dbo.Country.CountryISO2A, dbo.Individual.IndividualId, CommunicationEventReason.CreationTimeStamp AS CreationDate, CommunicationEvent.Incoming, 
          dbo.ContactMechanismType.ContactMechanismCode, dbo.GetTranslationValue(dbo.ContactMechanismType.DescriptionTranslation_Id,2057) ContactMechanismDescription ,CommunicationEvent.State, 
           dbo.CommunicationEvent.CallLength, er.CommEventReasonCode, CAST ( tt.Value AS NVARCHAR(255) ) as CommEventReasonDescription,
           CAST ( dbo.CommunicationEventReason.Comment AS NVARCHAR(500) ) as Comment, 
           dbo.CommunicationEvent.GPSUser, dbo.CommunicationEvent.GPSUpdateTimestamp, dbo.CommunicationEvent.CreationTimeStamp
FROM       [dbo].[CommunicationEvent] INNER JOIN
           dbo.Individual ON dbo.Individual.GUIDReference = dbo.CommunicationEvent.Candidate_Id INNER JOIN
           dbo.Country ON dbo.CommunicationEvent.Country_ID = dbo.Country.CountryId and dbo.Country.CountryId = dbo.Individual.CountryId LEFT JOIN
           dbo.ContactMechanismType on dbo.CommunicationEvent.ContactMechanism_Id = dbo.ContactMechanismType.GUIDReference LEFT JOIN
           dbo.CommunicationEventReason on dbo.CommunicationEventReason.Communication_Id = dbo.CommunicationEvent.GUIDReference LEFT JOIN
           dbo.CommunicationEventReasonType er on er.GUIDReference = dbo.CommunicationEventReason.ReasonType_Id
           LEFT join Translation tr on tr.TranslationId = er.TagTranslation_Id
		   INNER JOIN TranslationTerm tt ON tr.TranslationId = tt.Translation_Id AND tt.CultureCode = 2057
