GO
CREATE VIEW [dbo].[FullOrders_GB]
AS
SELECT o.[OrderId]
       ,c.CountryISO2A
       ,p.PanelCode
       ,p.NAME PanelName
       ,i.IndividualId
       ,o.[OrderedDate]
       ,o.[DispatchedDate]
       ,s.Code OrderState
       ,oi.Quantity
       ,st.Code as StockTypeCode
       ,st.NAME as StockTypeName
       ,at.STATE ActionTaskState
       ,ot.Code as OrderType
       ,tt.Value AS Description
       ,id.UserName SentByUsername
       ,at.ActionComment
       ,att.ActionCode
       ,o.[Comments]
       ,o.[GPSUser]
       ,o.[GPSUpdateTimestamp]
       ,o.[CreationTimeStamp]
       ,adr.[AddressLine1]
       ,adr.[AddressLine2]
       ,adr.[AddressLine3]
       ,adr.[AddressLine4]
       ,adr.[PostCode]
       ,r.Code AS 'ReasonCode'
       ,ttr.value AS 'Reason'
       ,oi.Id as OrderItemGuidRef
FROM [Order] o
INNER JOIN OrderType ot ON ot.Id = o.Type_Id
INNER JOIN ActionTask at ON o.ActionTask_Id = at.GUIDReference
INNER JOIN ActionTaskType att ON at.ActionTaskType_Id = att.GUIDReference
       AND at.Country_Id = att.Country_Id
INNER JOIN Individual i ON at.Candidate_Id = i.GUIDReference
INNER JOIN Country c ON at.Country_Id = c.CountryId
LEFT JOIN IdentityUser id ON id.Id = o.SentBy_Id
LEFT JOIN Panel p ON at.Panel_Id = p.GUIDReference
LEFT JOIN StateDefinition s ON s.Id = o.State_Id
LEFT JOIN Address adr ON adr.GUIDReference = o.PostalAddress_Id
INNER JOIN TranslationTerm tt ON tt.Translation_Id = ot.Description_Id
       AND tt.CultureCode = 2057
LEFT JOIN reasonforordertype r ON o.Reason_Id = r.Id
LEFT JOIN TranslationTerm ttr ON ttr.Translation_Id = r.Description_Id
       AND ttr.CultureCode = 2057
INNER JOIN orderitem oi ON oi.order_id = o.OrderId
INNER JOIN stocktype st ON st.GUIDReference = oi.StockType_id
WHERE c.countryiso2a = 'GB'
GO