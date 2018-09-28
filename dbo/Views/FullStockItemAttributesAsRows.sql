CREATE VIEW [dbo].[FullStockItemAttributesAsRows]
AS
SELECT Distinct ct.countryiso2a
	,si.SerialNumber
	,st.Code AS TypeCode
	,st.Name AS TypeName
	,a.[key]
	,(
		CASE 
			WHEN a.[Type] = 'Date'
				THEN FORMAT(TRY_PARSE(av.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
			WHEN a.[Type] = 'Enum'
				THEN ed.Value
			ELSE av.value
			END
	 ) Value
FROM Attribute a
INNER JOIN AttributeScope s ON s.guidreference = a.[scope_id]
INNER JOIN AttributeValue av ON a.guidreference = av.DemographicId
INNER JOIN Respondent r ON r.guidreference = av.RespondentId
INNER JOIN StockItem si ON si.Guidreference = r.Guidreference
INNER JOIN StockType st ON st.GUIDReference = si.Type_Id
INNER JOIN country ct ON ct.CountryId = a.Country_Id
LEFT JOIN EnumDefinition ed ON ed.Id = av.EnumDefinition_Id
WHERE r.DiscriminatorType = 'StockItem'