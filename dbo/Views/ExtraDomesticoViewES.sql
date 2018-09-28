Create view ExtraDomesticoViewES
as
SELECT PanelMemberID
	,StateCode AS StateCodeExtraDomestico
	,SignupDate
	,i.DateOfBirth
	,Tipo_3D
	,TipoDiccionarioExtraDomestico
	,FuenteExtraDomestico
FROM (
	SELECT PanelMemberID
		,SignupDate
		,StateCode
	FROM dbo.FullPanellistSet
	WHERE countryiso2a = 'ES'
		AND PanelCode = 13
	) p
INNER JOIN (
	SELECT IndividualId
		,DateOfBirth
	FROM dbo.FullIndividualPID
	WHERE CountryISO2A = 'ES'
	) i ON p.PanelMemberID = i.IndividualId
LEFT JOIN (
	SELECT IndividualId
		,[TipoDiccionarioExtraDomestico]
		,[FuenteExtraDomestico]
	FROM (
		SELECT IndividualId
			,[key]
			,Value
		FROM dbo.FullIndividualAttributesAsRows
		WHERE countryiso2a = 'ES'
			AND [key] IN (
				'TipoDiccionarioExtraDomestico'
				,'FuenteExtraDomestico'
				)
		) pvt
	PIVOT(MAX(Value) FOR [key] IN (
				[TipoDiccionarioExtraDomestico]
				,[FuenteExtraDomestico]
				)) pp
	) d ON p.PanelMemberID = d.IndividualId
LEFT JOIN (
	SELECT RIGHT('000000' + CAST(GroupId AS VARCHAR), 6) + '-00' AS IndividualId
		,Value AS Tipo_3D
	FROM dbo.FullGroupAttributesAsRows
	WHERE countryiso2a = 'ES'
		AND [key] IN ('Tipo_3D_Calc')
	) t ON p.PanelMemberID = t.IndividualId