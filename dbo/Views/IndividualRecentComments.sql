
CREATE VIEW [dbo].[IndividualRecentComments]
AS
WITH TEMP
AS (
	SELECT Individual_Id
		,MAX(GPSUpdateTimestamp) AS GPSUpdateTimestamp
	FROM individualcomment
	GROUP BY Individual_Id
	)
SELECT IC.Individual_Id
	,i.IndividualId AS BusinessId
	,C.CountryISO2A AS CountryCode
	,IC.Comment
FROM individualcomment IC
INNER JOIN TEMP ON IC.Individual_Id = TEMP.Individual_Id
	AND IC.GPSUpdateTimestamp = TEMP.GPSUpdateTimestamp
INNER JOIN individual i ON i.guidreference = ic.individual_id
INNER JOIN country c ON c.countryid = i.Countryid