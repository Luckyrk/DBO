CREATE VIEW [dbo].FullIndividualAttributesMY AS 

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
		WHERE CountryISO2A = 'MY'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [Age_calculated], [Baby_Gender], [BMI], [Day_Of_Birth], [Education_Level], [Employment_Status], [First_Baby], [Frequencyofooh], [Gender], [Height], [Individual_Name], [Individualhomephone], 
[Individualmobilephone], [Individualworkphone], [Marital_Status], [Month_Of_Birth], [Occupation], [Race_Individual], [Rec_Period], [Rec_week], [Rec_year], [Type_of_Individual], [Weight], [Year_Of_Birth])) AS PivotTable