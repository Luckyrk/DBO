CREATE PROCEDURE [dbo].[getSamplePointMappings_AdminScreen] (

	@pUserName NVARCHAR(200)

	,@pCountryCode VARCHAR(5)

	)

AS

BEGIN

	SELECT DISTINCT SPM.GUIDReference AS MappingId

		,TT.Value AS RegionCode

		,'' AS LocalOffice

		,'' AS City

		,'' AS GeographicalArea

	FROM IDENTITYUSER IU

	JOIN SYSTEMUSERROLE SUR ON IU.ID = SUR.IDENTITYUSERID

	JOIN COUNTRY C ON SUR.CountryId = C.CountryId

	JOIN SAMPLEPOINTMAPPING SPM ON IU.ID = SPM.IdentityUserID

	JOIN REGION R ON SPM.Value = R.GUIDReference

	JOIN TRANSLATION T ON R.Description_Id = T.TranslationId

	JOIN TRANSLATIONTERM TT ON T.TranslationId = TT.Translation_Id AND TT.CULTURECODE = 2057

	WHERE IU.USERNAME = @pUserName

		AND SPM.DiscriminatorType = 'Region'

		AND C.CountryISO2A = @pCountryCode

		AND SPM.IsDeleted = 0

	

	UNION ALL

	

	SELECT DISTINCT SPM.GUIDReference AS MappingId

		,TT1.Value AS RegionCode

		,TT.Value AS LocalOffice

		,'' AS City

		,'' AS GeographicalArea

	FROM IDENTITYUSER IU

	JOIN SYSTEMUSERROLE SUR ON IU.ID = SUR.IDENTITYUSERID

	JOIN COUNTRY C ON SUR.CountryId = C.CountryId

	JOIN SAMPLEPOINTMAPPING SPM ON IU.ID = SPM.IdentityUserID

	JOIN LocalOffice L ON SPM.Value = L.GUIDReference

	JOIN REGION R ON L.Region_Id = R.GUIDREFERENCE

	LEFT JOIN TRANSLATION T ON L.Description_Id = T.TranslationId

	LEFT JOIN TRANSLATIONTERM TT ON T.TranslationId = TT.Translation_Id AND TT.CULTURECODE = 2057

	LEFT JOIN TRANSLATION T1 ON R.Description_Id = T1.TranslationId

	LEFT JOIN TRANSLATIONTERM TT1 ON T1.TranslationId = TT1.Translation_Id AND TT1.CULTURECODE = 2057

	WHERE IU.USERNAME = @pUserName

		AND SPM.DiscriminatorType = 'LocalOffice'

		AND C.CountryISO2A = @pCountryCode

		AND SPM.IsDeleted = 0

	

	UNION ALL

	

	SELECT DISTINCT SPM.GUIDReference AS MappingId

		,TT1.Value AS RegionCode

		,TT2.Value AS LocalOffice

		,TT.Value AS City

		,'' AS GeographicalArea

	FROM IDENTITYUSER IU

	JOIN SYSTEMUSERROLE SUR ON IU.ID = SUR.IDENTITYUSERID

	JOIN COUNTRY C ON SUR.CountryId = C.CountryId

	JOIN SAMPLEPOINTMAPPING SPM ON IU.ID = SPM.IdentityUserID

	JOIN CITY CI ON SPM.Value = CI.GUIDReference

	JOIN LocalOffice L ON CI.LocalOffice_id = L.GUIDReference

	JOIN REGION R ON L.Region_Id = R.GUIDREFERENCE

	LEFT JOIN TRANSLATION T ON L.Description_Id = T.TranslationId

	LEFT JOIN TRANSLATIONTERM TT ON T.TranslationId = TT.Translation_Id AND TT.CULTURECODE = 2057

	LEFT JOIN TRANSLATION T1 ON R.Description_Id = T1.TranslationId

	LEFT JOIN TRANSLATIONTERM TT1 ON T1.TranslationId = TT1.Translation_Id AND TT1.CULTURECODE = 2057

	LEFT JOIN TRANSLATION T2 ON L.Description_Id = T2.TranslationId

	LEFT JOIN TRANSLATIONTERM TT2 ON T2.TranslationId = TT2.Translation_Id AND TT2.CULTURECODE = 2057

	WHERE IU.USERNAME = @pUserName

		AND SPM.DiscriminatorType = 'City'

		AND C.CountryISO2A = @pCountryCode

		AND SPM.IsDeleted = 0

	

	UNION ALL

	

	SELECT DISTINCT SPM.GUIDReference AS MappingId

		,TT1.VALUE AS RegionCode

		,TT2.VALUE AS LocalOffice

		,TT3.VALUE AS City

		,TT.Value AS GeographicalArea

	FROM IDENTITYUSER IU

	JOIN SYSTEMUSERROLE SUR ON IU.ID = SUR.IDENTITYUSERID

	JOIN COUNTRY C ON SUR.CountryId = C.CountryId

	JOIN SAMPLEPOINTMAPPING SPM ON IU.ID = SPM.IdentityUserID

	JOIN CITYGEOGRAPHICS CG ON SPM.Value = CG.GeohgraphicAreaId

	JOIN GEOGRAPHICAREA GA ON CG.GeohgraphicAreaId=GA.GUIDReference

	JOIN CITY CI ON CG.CityId = CI.GUIDReference

	JOIN LocalOffice L ON CI.LocalOffice_id = L.GUIDReference

	JOIN REGION R ON L.Region_Id = R.GUIDREFERENCE

	JOIN TRANSLATION T ON GA.Translation_Id= T.TranslationId

	JOIN TRANSLATIONTERM TT ON T.TranslationId = TT.Translation_Id AND TT.CULTURECODE = 2057

	LEFT JOIN TRANSLATION T1 ON R.Description_Id = T1.TranslationId

	LEFT JOIN TRANSLATIONTERM TT1 ON T1.TranslationId = TT1.Translation_Id AND TT1.CULTURECODE = 2057

	LEFT JOIN TRANSLATION T2 ON L.Description_Id = T2.TranslationId

	LEFT JOIN TRANSLATIONTERM TT2 ON T2.TranslationId = TT2.Translation_Id AND TT2.CULTURECODE = 2057

	LEFT JOIN TRANSLATION T3 ON CI.Description_Id = T3.TranslationId

	LEFT JOIN TRANSLATIONTERM TT3 ON T3.TranslationId = TT3.Translation_Id AND TT3.CULTURECODE = 2057

	WHERE IU.USERNAME = @pUserName

		AND SPM.DiscriminatorType = 'GeographicArea'

		AND C.CountryISO2A = @pCountryCode

		AND SPM.IsDeleted = 0

END
