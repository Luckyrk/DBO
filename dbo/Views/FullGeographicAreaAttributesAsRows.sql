CREATE VIEW [dbo].[FullGeographicAreaAttributesAsRows]
AS
SELECT DISTINCT CountryISO2A
	,Code
	,GADescription
	,[Key]
	,Attribute
	,[Value]
FROM (
	SELECT dbo.Country.CountryISO2A
		,ga.Code
		,A.[Key]
		,GADesc.KeyName AS GADescription
		,CAST(TYPETERM.Value AS NVARCHAR(255)) AS Attribute
		,(
		CASE 
			WHEN a.[Type] = 'Date'
				THEN FORMAT(TRY_PARSE(av.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
			When A.[Type]='Enum'
				THEN ED.Value
			ELSE AV.value 
		END
		) Value
	FROM dbo.Attribute A
	INNER JOIN dbo.AttributeValue AV ON A.GUIDReference = AV.DemographicId
	LEFT JOIN dbo.EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
	INNER JOIN dbo.GeographicArea ga ON AV.RespondentId = ga.GUIDReference
	INNER JOIN dbo.Translation GADesc ON ga.Translation_Id = GADesc.TranslationId
	INNER JOIN dbo.Country ON A.Country_ID = dbo.Country.CountryId
	INNER JOIN dbo.Translation AS TYPETRANS ON TYPETRANS.TranslationId = A.Translation_Id
	LEFT JOIN (
		SELECT Translation_Id
			,Value
		FROM dbo.TranslationTerm
		WHERE CultureCode = 2057
		) AS TYPETERM ON TYPETRANS.TranslationId = TYPETERM.Translation_Id
	) A