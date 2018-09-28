CREATE VIEW [dbo].[FullGroupAttributesIE]
AS 
SELECT * 
FROM (	SELECT [CountryISO2A], Sequence AS [GroupId], A.[Key], (
					CASE 
						WHEN A.[Type] = 'Date'
							THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
						WHEN A.[Type]='Enum'
							THEN ED.Value
						ELSE AV.Value
					END) Value
				FROM Country
				JOIN Collective C on C.CountryId=Country.CountryId
				LEFT JOIN AttributeValue AV ON AV.CandidateID=C.GuidReference OR AV.RespondentID=C.GuidReference
				LEFT JOIN EnumDefinition ed ON ed.Id=av.EnumDefinition_Id
				LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
				WHERE CountryISO2A = 'IE'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [Explorerordesktopapp], [H1], [H110], [H111], [H112], [H116], [H28], [H29], [H501], [H503], [H510], [H511], [H520], [H521], [H522], [OpticonCradleConnectionType], 
[Opticonpriceornoprice], [Simnumber], [Simphone], [Sizeofhousehold], [Testdemo])) AS PivotTable
