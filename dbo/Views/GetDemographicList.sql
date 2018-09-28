
CREATE VIEW [dbo].[GetDemographicList]
AS
SELECT C.CountryISO2A
	,A.GUIDReference AS Id
	,A.[Key]
	,A.Type
	,SC.Type AS Scope
FROM Attribute A
INNER JOIN Country C ON C.CountryId = A.Country_Id
INNER JOIN AttributeScope SC ON A.Scope_Id = SC.GUIDReference