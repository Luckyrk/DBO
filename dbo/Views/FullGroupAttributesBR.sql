
CREATE VIEW [dbo].[FullGroupAttributesBR]
AS
SELECT * FROM (	SELECT [CountryISO2A], Sequence AS [GroupId], A.[Key]
					, (CASE
							WHEN a.[Type] = 'Date'
								THEN FORMAT(TRY_PARSE(av.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
							WHEN A.[Type]='Enum' 
								THEN ED.Value ELSE AV.value END
						) AS Value
				FROM Country
				JOIN Collective C on C.CountryId=Country.CountryId
				LEFT JOIN AttributeValue AV ON AV.CandidateID=C.GuidReference OR AV.RespondentID=C.GuidReference
				LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
				LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
				WHERE CountryISO2A = 'BR'
	) AS source
PIVOT(MAX([Value]) FOR [Key] IN ([NSE_ACTUALIZADO])) AS PivotTable