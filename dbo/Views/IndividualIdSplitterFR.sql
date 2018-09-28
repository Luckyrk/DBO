
CREATE VIEW [dbo].[IndividualIdSplitterFR]
AS
SELECT DISTINCT ind.IndividualId
	,CAST(PARSENAME(REPLACE(ind.IndividualId, '-', '.'), 2) AS INT) AS GroupId
	,PARSENAME(REPLACE(ind.IndividualId, '-', '.'), 1) AS IndividualNumber
	,CAST(PARSENAME(REPLACE(ind.IndividualId, '-', '.'), 1) AS INT) AS IndividualOrder
	,CASE 
		WHEN ISNUMERIC(na.[Key]) = 1
			THEN CAST(na.[Key] AS INT)
		ELSE NULL
		END AS AliasHouseholdNumber
	,SUBSTRING(na.[Key], 1, LEN(na.[Key]) - 2) + RIGHT(ind.IndividualId, 2) AS AliasIndividualID
FROM dbo.Individual AS ind
INNER JOIN dbo.Candidate AS ca ON ca.GUIDReference = ind.GUIDReference
INNER JOIN dbo.Country AS ct ON ct.CountryId = ca.Country_Id
INNER JOIN dbo.CollectiveMembership AS cm ON cm.Individual_Id = ind.GUIDReference
INNER JOIN dbo.Candidate AS ca2 ON ca2.GUIDReference = cm.Group_Id
INNER JOIN dbo.NamedAlias AS na ON na.Candidate_Id = ca2.GUIDReference
WHERE (ct.CountryISO2A = 'FR')