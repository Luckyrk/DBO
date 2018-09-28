CREATE VIEW [dbo].FullIndividualAttributesGB AS 

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
		WHERE CountryISO2A = 'GB'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [Counciltaxband], [FOL], [H104], [H105], [H73], [H75], [H83], [I1], [I10], [I11], [I12], [I13], [I14], [I15], [I16], [I17], [I18], [I19], [I2], [I20], [I21], [I22], [I23], [I24], [I25], [I26], [I27], [I28], [
I29], [I3], [I30], [I31], [I32], [I33], [I34], [I35], [I36], [I37], [I38], [I39], [I4], [I40], [I41], [I42], [I43], [I44], [I45], [I46], [I47], [I48], [I49], [I5], [I50], [I501], [I502], [I503], [I6], [I7], [I8], [I9], [Irage], [Miketest1], [Miketest2], [
Miketest3], [Miketest4], [Numberofrooms], [Smsreminder], [TeenAccount], [Testbool], [Testindividualage], [Teststring])) AS PivotTable