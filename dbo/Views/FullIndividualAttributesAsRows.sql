CREATE VIEW [dbo].[FullIndividualAttributesAsRows]
AS
SELECT ct.countryiso2a
	,c.individualid AS IndividualId
	,a.[key]
	,(
		CASE 
			WHEN a.[Type] = 'Date'
				THEN FORMAT(TRY_PARSE(av.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
			WHEN a.[Type] = 'Enum'
				THEN ed.Value
			ELSE av.value
			END
		) Value
		,av.[FreeText]
	,av.GPSUser
	,av.CreationTimeStamp
	,av.GPSUpdateTimestamp
FROM attributevalue av
INNER JOIN attribute a ON a.guidreference = av.DemographicId
INNER JOIN individual c ON c.guidreference = av.candidateid
INNER JOIN country ct ON ct.CountryId = c.CountryId
LEFT JOIN EnumDefinition ed ON ed.Id = av.EnumDefinition_Id