
CREATE VIEW [dbo].[FullIndividualAttributesFR]
AS
SELECT *
FROM (	SELECT [CountryISO2A], [IndividualId], A.[Key], (
					CASE 
						WHEN A.[Type] = 'Date'
							THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
						WHEN A.[Type]='Enum'
							THEN ED.Value
						ELSE AV.Value
					END) Value
		FROM Country
		JOIN Individual C on C.CountryId=Country.CountryId
		LEFT JOIN AttributeValue AV ON AV.CandidateID=C.GuidReference OR AV.RespondentID=C.GuidReference
		LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id	
		LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
	WHERE CountryISO2A = 'FR'
	) AS source
PIVOT(MAX([Value]) FOR [Key] IN (
			[Individualageyears]
			,[IPHO]
			,[ISPF]
			,[ITAB]
			,[ITLP]
			,[ITRA]
			)) AS PivotTable