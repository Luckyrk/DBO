GO

CREATE VIEW [dbo].[FullGroupAttributesAE]
AS
SELECT *
FROM (
	SELECT [CountryISO2A]
		,Sequence AS [GroupId]
		,A.[Key]
		,(
			CASE 
				WHEN A.[Type] <> 'Enum'
					THEN AV.Value
				ELSE ED.Value
				END
			) AS Value
	FROM Country
	INNER JOIN Collective C ON C.CountryId = Country.CountryId
	LEFT JOIN AttributeValue AV ON AV.CandidateID = C.GuidReference
		OR AV.RespondentID = C.GuidReference
	LEFT JOIN EnumDefinition ed ON ed.Id = av.EnumDefinition_Id
	LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId = A.GUIDReference
	WHERE CountryISO2A = 'AE'
	) AS Source
PIVOT(MAX([Value]) FOR [Key] IN (
[CARS], 
[FAMILYTYPE], 
[HOUSETYPE], 
[INMATESEXCSERVANTSGUESTS], 
[MONTHLYINCOME], 
[NOOFHOUSEHOLD], 
[NOOFSERVANTSDRIVERS]
			)) AS PivotTable
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'Holds details of the associated Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupAttributesAE'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Holds details of the Business Area of data in the View.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupAttributesAE'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=NULL , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupAttributesAE'
GO

--GRANT SELECT ON [FullGroupAttributesAE] TO GPSBusiness

--GO