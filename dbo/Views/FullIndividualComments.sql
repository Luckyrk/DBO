

CREATE VIEW [dbo].[FullIndividualComments] 

AS

SELECT 
	cy.CountryISO2A
	, i.IndividualID
	, ic.Comment
	, ic.GPSUser
	, ic.CreationTimeStamp
	, ic.GPSUpdateTimestamp
FROM Individual i
	INNER JOIN IndividualComment ic ON i.GUIDReference = ic.Individual_Id
	INNER JOIN Country cy ON cy.CountryId = i.CountryId

GO

--GRANT SELECT ON [IndividualComments] TO GPSBusiness

--GO
