GO

CREATE VIEW [dbo].[FullGeographicAreaAttributesCL] AS 
SELECT * FROM (	SELECT [CountryISO2A], ga.Code AS [Code], A.[Key], ISNULL(AV.Value, ED.Value) AS Value
				FROM Country C
				JOIN Attribute A WITH (NOLOCK) ON A.Country_ID = C.CountryId
				JOIN AttributeValue AV ON A.GUIDReference = AV.DemographicId
				LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
				JOIN GeographicArea GA on GA.GUIDReference=AV.RespondentId
				WHERE CountryISO2A = 'CL'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ([CL900], 
[CL901], 
[CL902], 
[CL903], 
[CL904], 
[CL905], 
[CL906])) AS PivotTable
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'Holds details of the associated Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGeographicAreaAttributesCL'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Holds details of the Business Area of data in the View.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGeographicAreaAttributesCL'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Country specific data for ES GDAs. Lists all the GA Attributes as column headings with associated values in the rows. Each row contains 1 GA code. A pivot table is used to get the attribtues and their values. The view is dynamically recreated should any n' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGeographicAreaAttributesCL'
GO

--GRANT SELECT ON FullGeographicAreaAttributesCL TO GPSBusiness

--GO
