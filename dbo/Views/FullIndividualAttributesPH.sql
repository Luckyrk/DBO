CREATE VIEW [dbo].FullIndividualAttributesPH AS 
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
		WHERE CountryISO2A = 'PH'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [BMI], [Country_of_OFW], [Educational_Attainment_EO/DP], [Educational_Attainment_HH], [Gender], [Height], [Income_of_OFW], [Marital_Status], [Name_of_Individual], [Occupation_EO/DP], [Occupation_HH], [Status_
in_Household], [Weight], [Working_Status])) AS PivotTable