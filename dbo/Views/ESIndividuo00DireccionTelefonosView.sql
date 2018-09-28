Create view ESIndividuo00DireccionTelefonosView 
as
SELECT LEFT(FIP.IndividualId, 6) AS NPAN
	,FIP.IndividualId
	,FIP.DateOfBirth
	,SexCode
	,FIP.FirstOrderedName
	,FIP.MiddleOrderedName
	,FIP.LastOrderedName
	,FIP.StateCode
	,FIP.Comment
	,FIA.AddressLine1
	,FIA.AddressLine2
	,FIA.AddressLine3
	,FIA.AddressLine4
	,FIA.PostCode
	,FIP.GeographicAreaCode
	,t1.Telef1
	,t2.Telef2
FROM (
	SELECT IndividualId
		,DateOfBirth
		,SexCode
		,FirstOrderedName
		,MiddleOrderedName
		,LastOrderedName
		,StateCode
		,GeographicAreaCode
		,Comment
	FROM [FullIndividualPID]
	WHERE CountryISO2A = 'ES'
		AND RIGHT(IndividualId, 2) = '00'
	) FIP
LEFT JOIN (
	SELECT IndividualId
		,AddressLine1
		,AddressLine2
		,AddressLine3
		,AddressLine4
		,PostCode
	FROM [FullIndividualAddressEmailPhone] FIA
	WHERE CountryISO2A = 'ES'
		AND [Order] = 1
		AND DiscriminatorType = 'PostalAddressType'
		AND RIGHT(IndividualId, 2) = '00'
	) FIA ON FIP.IndividualId = FIA.IndividualId
LEFT JOIN (
	SELECT IndividualId
		,AddressLine1 AS Telef1
	FROM [FullIndividualAddressEmailPhone] FIA
	WHERE CountryISO2A = 'ES'
		AND [Order] = 1
		AND DiscriminatorType = 'PhoneAddressType'
		AND RIGHT(IndividualId, 2) = '00'
	) t1 ON FIP.IndividualId = t1.IndividualId
LEFT JOIN (
	SELECT IndividualId
		,AddressLine1 AS Telef2
	FROM [FullIndividualAddressEmailPhone] FIA
	WHERE CountryISO2A = 'ES'
		AND [Order] = 2
		AND DiscriminatorType = 'PhoneAddressType'
		AND RIGHT(IndividualId, 2) = '00'
	) t2 ON FIP.IndividualId = t2.IndividualId