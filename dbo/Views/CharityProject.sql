CREATE VIEW [dbo].[CharityProject]
	AS
SELECT DISTINCT
       cy.CountryISO2A
       ,i.IndividualID
       ,ca.Value AS Value
       --, ca.Subscription
FROM Individual i
       INNER JOIN IncentiveAccount ia ON ia.IncentiveAccountId = i.GuidReference AND ia.[Type] = 'OwnAccount'
       INNER JOIN [dbo].[CharitySubscription] cs ON i.[CharitySubscription_Id] = cs.ID
       INNER JOIN [dbo].[CharityAmount] ca ON cs.Amount_Id = ca.GUIDReference
       INNER JOIN Country cy ON cy.CountryId = i.CountryId
WHERE CharitySubscription_Id IS NOT NULL 
 
