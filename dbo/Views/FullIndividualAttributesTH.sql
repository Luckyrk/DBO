CREATE VIEW [dbo].FullIndividualAttributesTH AS 

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
		LEFT JOIN AttributeValue AV ON AV.CandidateID=C.GuidReference 
		LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id	
		LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
		WHERE CountryISO2A = 'TH' AND AV.CandidateID IS NOT NULL

		UNION ALL
		SELECT [CountryISO2A], [IndividualId], A.[Key], (
					CASE 
						WHEN A.[Type] = 'Date'
							THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
						WHEN A.[Type]='Enum'
							THEN ED.Value
						ELSE AV.Value
					END) Value
		FROM Country
		JOIN Individual C on C.CountryId=Country.CountryId
		LEFT JOIN AttributeValue AV ON AV.RespondentID=C.GuidReference
		LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id	
		LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
		WHERE CountryISO2A = 'TH' AND AV.RespondentID IS NOT NULL

) AS Source PIVOT (MAX([Value]) FOR [Key] IN ([Baby],[Babyageinmonth], [BeeTalk], [BMI], [Carrier], [ClasseOOH], [EducationNew], [Facebook], [Facebook_Name], [Height], [Individuosid], [Instagram], [Internet_Data_access_(yes/no)], [Line], [Line_ID], 
[Location_of_school/work_(Bangkok_districts)], [Marriage_Status], [Mobile_Phone_Brand], [Mobile_Phone_Model], [Occupations], [PanelSmart_UserName], [Prepaid_or_Postpaid], [Prof], [Refer_name], [Religion], [Self_Empl], [Skype], [Tablet], [Testenum], [Testinteger], 
[Type], [Veget], [WeChat], [Weight_of_panelist], [Whatsapp], [Working_status])) AS PivotTable