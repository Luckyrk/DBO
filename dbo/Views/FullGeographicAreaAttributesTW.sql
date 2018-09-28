CREATE VIEW [dbo].FullGeographicAreaAttributesTW 
AS 
SELECT * FROM (	SELECT [CountryISO2A]
				,ga.Code AS [Code]
				,A.[Key]
				,(
					CASE 
						WHEN A.[Type] = 'Date'
							THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
						WHEN A.[Type]='Enum'
							THEN ED.Value
						ELSE AV.Value
					END) Value
				FROM Country C
				JOIN Attribute A WITH (NOLOCK) ON A.Country_ID = C.CountryId
				JOIN AttributeValue AV ON A.GUIDReference = AV.DemographicId
				LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
				JOIN GeographicArea GA on GA.GUIDReference=AV.RespondentId
				WHERE CountryISO2A = 'TW'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [GeographicArea_Alt_code], [GeographicArea_BP_Quota_GA_Target], [GeographicArea_Governmental_Admin], [GeographicArea_Habitat_code], [GeographicArea_Inactive_date], [GeographicArea_Interviewer],
 [GeographicArea_LP_Quota_GA_Target], [GeographicArea_MP_Quota_GA_Target], [GeographicArea_Population], [GeographicArea_Region], [GeographicArea_TW_City_County], [GeographicArea_WP_Quota_GA_Target])) AS PivotTable