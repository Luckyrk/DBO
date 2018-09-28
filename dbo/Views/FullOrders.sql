CREATE VIEW [dbo].[FullOrders]
AS
SELECT o.[OrderId]
	,c.CountryISO2A
	,p.PanelCode
	,p.NAME PanelName
	,o.[OrderedDate]
	,o.[DispatchedDate]
	,ISNULL(gl.Location,i.IndividualId) AS Location
	,s.Code OrderState
	,at.STATE ActionTaskState
	,ot.Code Type
	,id.UserName SentByUsername
	,at.ActionComment
	,att.ActionCode
	,o.[Comments]
	,o.[GPSUser]
	,o.[GPSUpdateTimestamp]
	,o.[CreationTimeStamp]
	,(CASE WHEN RED.Translation_Id IS NULL THEN NULL ELSE RED.Value+'-'+dbo.GetTranslationValue(RED.Translation_Id,2057) END) as Region
	,o.PickUpdate
	,o.[FromHours]
	,o.[ToHours]
	,pa.[AddressLine1]
	,pa.[AddressLine2]
	,pa.[AddressLine3]
	,pa.[AddressLine4]
	,pa.[PostCode]
FROM [Order] o
INNER JOIN OrderType ot ON ot.Id = o.Type_Id
INNER JOIN ActionTask at ON o.ActionTask_Id = at.GUIDReference
INNER JOIN ActionTaskType att ON at.ActionTaskType_Id = att.GUIDReference
	AND at.Country_Id = att.Country_Id
JOIN StockLocation sl ON sl.GuidReference = o.Location_id
LEFT JOIN GenericStockLocation gl ON gl.GuidReference = sl.GuidReference
LEFT JOIN StockPanelistLocation pl ON pl.GuidReference = sl.GuidReference
INNER JOIN Individual i ON at.Candidate_Id = i.GUIDReference
INNER JOIN Candidate ci ON ci.GUIDReference = i.GUIDReference
INNER JOIN Country c ON at.Country_Id = c.CountryId
LEFT JOIN IdentityUser id ON id.Id = o.SentBy_Id
LEFT JOIN Panel p ON at.Panel_Id = p.GUIDReference
LEFT JOIN StateDefinition s ON s.Id = o.State_Id
LEFT JOIN [Address] pa ON pa.GuidReference = o.PostalAddress_Id
LEFT JOIN GeographicArea ga ON ga.GUIDReference = ci.GeographicArea_Id
LEFT JOIN Attribute RA ON RA.[Key] = 'Region' AND RA.Country_Id = c.CountryId
LEFT JOIN AttributeValue RAV ON RAV.RespondentId = ga.GUIDReference AND RAV.DemographicId = RA.GUIDReference
LEFT JOIN EnumDefinition RED ON RAV.EnumDefinition_Id = RED.Id
	