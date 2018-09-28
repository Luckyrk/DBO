CREATE VIEW [dbo].FullGeographicAreaAttributesTH AS 

SELECT * FROM (	SELECT [CountryISO2A], ga.Code AS [Code], A.[Key], (
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
				WHERE CountryISO2A = 'TH'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [GDABabyRuralQuotaTarget], [GDABabyUrbanQuotaTarget], [GDACoffeeMachineQuotaTarget], [GDADistrict], [GDAOOHQuotaTarget], [GDAProvince], [GDARegion], [GDARuralQuotaTarget], [GDASubDistrict], [GDASubRegion], 
[GDAUrbanQuotaTarget])) AS PivotTable