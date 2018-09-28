CREATE VIEW [dbo].[FullIndividualStockItemAttributesAsRows]
AS
SELECT ct.Countryiso2a
	,c.individualid AS IndividualId
	,si.SerialNumber
	,st.Code AS TypeCode
	,st.Name AS TypeName
	,a.[key]
	,(
		CASE 
			WHEN a.[Type] = 'Date'
				THEN FORMAT(TRY_PARSE(av.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
			WHEN a.[Type] = 'Enum'
				THEN ed.Value + ' - ' + t.Value
			ELSE av.value
			END
		) Value
FROM AttributeValue av
INNER JOIN Attribute a ON a.GUIDReference = av.DemographicId
INNER JOIN StockItem si on av.RespondentId = si.GUIDReference
INNER JOIN StockType st ON st.GUIDReference = si.Type_Id
INNER JOIN Panelist p ON p.GUIDReference = si.Panelist_Id and av.CandidateId = p.PanelMember_Id
INNER JOIN AttributeScope s ON s.GUIDReference = a.[scope_id]
INNER JOIN Individual c ON c.GUIDReference = av.candidateid 
INNER JOIN Country ct ON ct.CountryId = c.CountryId
LEFT JOIN EnumDefinition ed ON ed.Id = av.EnumDefinition_Id
LEFT JOIN TranslationTerm t ON ed.Translation_Id = t.Translation_Id AND t.CultureCode = 2057
WHERE s.[Type] = 'StockBehavior'
