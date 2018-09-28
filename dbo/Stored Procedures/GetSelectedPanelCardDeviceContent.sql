CREATE PROCEDURE [dbo].[GetSelectedPanelCardDeviceContent] @pPanelistId UNIQUEIDENTIFIER

	,@pScopeReferenceId UNIQUEIDENTIFIER

	,@pCountryId UNIQUEIDENTIFIER

	,@pCultureCode INT

	,@pIsAdmin BIT

AS

BEGIN
BEGIN TRY

--ExpectedKit(AssetKitDTO)

	SELECT DISTINCT St.GUIDReference AS Id
		,st.Code AS Code
		,st.Name AS NAME

		,indv.GUIDReference

		,indv.IndividualId AS MainContact
		,KAV.Value AS Photo
	FROM Panelist PL
	--JOIN StockItem SIt ON SIt.Panelist_Id=PL.GUIDReference
	JOIN StockKit ST ON PL.ExpectedKit_Id = ST.GUIDReference
	JOIN DynamicRoleAssignment DRA ON DRA.Panelist_Id = pl.GUIDReference
	JOIN DynamicRole DR ON DR.DynamicRoleId = DRA.DynamicRole_Id AND DR.Code=3
	JOIN Individual indv ON indv.GUIDReference = DRA.Candidate_Id
	LEFT JOIN StockKitItem SI ON ST.GUIDReference = SI.StockKit_Id
	LEFT JOIN KeyAppSetting KA ON KA.KeyName = REPLACE(LTRIM(RTRIM(ST.Name)), SPACE(1), '' )
	LEFT JOIN KeyValueAppSetting KAV ON KAV.KeyAppSetting_Id = KA.GUIDReference
	WHERE PL.GUIDReference = @pPanelistId



	/*Stock Items*/

	DECLARE @ConectivityAttributeId UNIQUEIDENTIFIER

	DECLARE @SoftwareVersionAttributeId UNIQUEIDENTIFIER

	DECLARE @ModelAttributeId UNIQUEIDENTIFIER

	DECLARE @PhotoAttributeId UNIQUEIDENTIFIER



	SELECT @ConectivityAttributeId = at.GUIDReference

	FROM Attribute at

	WHERE at.Country_Id = @pCountryId

		AND at.[Key] = 'Connectivity'



	SELECT @SoftwareVersionAttributeId = at.GUIDReference

	FROM Attribute at

	WHERE at.Country_Id = @pCountryId

		AND at.[Key] = 'SoftwareVersion'



	SELECT TOP 1 @ModelAttributeId = at.GUIDReference

	FROM Attribute at

	INNER JOIN Translation t ON at.Translation_Id = t.TranslationId

	LEFT JOIN TranslationTerm tt ON t.TranslationId = tt.Translation_Id

		AND tt.CultureCode = @pCultureCode

	WHERE tt.Value = 'Model'

		AND at.Country_Id = @pCountryId



	SELECT TOP 1 @PhotoAttributeId = at.GUIDReference

	FROM Attribute at

	where at.[Key] = 'Photo'

		AND at.Country_Id = @pCountryId



	SELECT t1.Id AS Id

		,AssetCategoryName

		,AssetTypeName

		,AssetConectivity

		,AssetModel

		,AssetPhoto

		,AssetSoftwareVersion

		,AssetCategoryCode

		,IsTrackeable

	FROM (

		SELECT DISTINCT sitems.GUIDReference AS Id

			,[dbo].[GetTranslationValue](sc.Translation_Id, @pCultureCode) AS AssetCategoryName

			,st.Name AS AssetTypeName

			,(

				CASE 

					WHEN av.DemographicId = @ModelAttributeId

						THEN av.Value

					ELSE NULL

					END

				) AS AssetModel

			,(

				CASE 

					WHEN avp.DemographicId = @PhotoAttributeId

						THEN avp.Value

					ELSE NULL

					END

				) AS AssetPhoto

			,sc.Code AS AssetCategoryCode

			,sb.IsTrackable AS IsTrackeable

		FROM Panelist pl

		INNER JOIN StockKit sk ON pl.ExpectedKit_Id = sk.GUIDReference

		INNER JOIN StockKitItem sitems ON sitems.StockKit_Id = sk.GUIDReference

		INNER JOIN StockType st ON sitems.StockType_Id = st.GUIDReference

		INNER JOIN StockCategory sc ON sc.GUIDReference = st.Category_Id

		INNER JOIN StockBehavior sb ON sb.GUIDReference = st.Behavior_Id

		INNER JOIN Respondent r ON r.GUIDReference = st.GUIDReference

		LEFT JOIN AttributeValue av ON av.RespondentId = r.GUIDReference

			AND av.DemographicId = @ModelAttributeId

		--LEFT JOIN StringAttributeValue sav ON sav.GUIDReference = av.GUIDReference

		LEFT JOIN AttributeValue avp ON avp.RespondentId = r.GUIDReference

			AND avp.DemographicId = @PhotoAttributeId

		--LEFT JOIN StringAttributeValue savp ON savp.GUIDReference = avp.GUIDReference

		WHERE pl.GUIDReference = @pPanelistId

		) t1

	LEFT JOIN (

		SELECT sitems.GUIDReference AS Id

			,(

				CASE 

					WHEN avc.DemographicId = @ConectivityAttributeId

						THEN [dbo].[GetTranslationValue](ed.Translation_Id, @pCultureCode)

					ELSE NULL

					END

				) AS AssetConectivity

		FROM Panelist pl

		INNER JOIN StockKit sk ON pl.ExpectedKit_Id = sk.GUIDReference

		INNER JOIN StockKitItem sitems ON sitems.StockKit_Id = sk.GUIDReference

		INNER JOIN StockType st ON sitems.StockType_Id = st.GUIDReference

		INNER JOIN StockCategory sc ON sc.GUIDReference = st.Category_Id

		INNER JOIN StockBehavior sb ON sb.GUIDReference = st.Behavior_Id

		INNER JOIN Respondent r ON r.GUIDReference = st.GUIDReference

		INNER JOIN AttributeValue avc ON avc.RespondentId = r.GUIDReference

		--INNER JOIN EnumAttributeValue ev ON ev.GUIDReference = avc.GUIDReference
		AND avc.Discriminator='EnumAttributeValue'
		AND avc.DemographicId = @ConectivityAttributeId

		INNER JOIN EnumDefinition ed ON ed.Demographic_Id = @ConectivityAttributeId

			AND ed.Id = avc.EnumDefinition_Id

		WHERE pl.GUIDReference = @pPanelistId

		) t2 ON t1.Id = t2.Id

	LEFT JOIN (

		SELECT sitems.GUIDReference AS Id

			,(

				CASE 

					WHEN avs.DemographicId = @SoftwareVersionAttributeId

						THEN [dbo].[GetTranslationValue](eds.Translation_Id, @pCultureCode)

					ELSE NULL

					END

				) AS AssetSoftwareVersion

		FROM Panelist pl

		INNER JOIN StockKit sk ON pl.ExpectedKit_Id = sk.GUIDReference

		INNER JOIN StockKitItem sitems ON sitems.StockKit_Id = sk.GUIDReference

		INNER JOIN StockType st ON sitems.StockType_Id = st.GUIDReference

		INNER JOIN StockCategory sc ON sc.GUIDReference = st.Category_Id

		INNER JOIN StockBehavior sb ON sb.GUIDReference = st.Behavior_Id

		INNER JOIN Respondent r ON r.GUIDReference = st.GUIDReference

		INNER JOIN AttributeValue avs ON avs.RespondentId = r.GUIDReference

		--INNER JOIN EnumAttributeValue evs ON evs.GUIDReference = avs.GUIDReference
		AND avs.Discriminator='EnumAttributeValue'
		AND avs.DemographicId = @SoftwareVersionAttributeId

		INNER JOIN EnumDefinition eds ON eds.Demographic_Id = @SoftwareVersionAttributeId

			AND eds.Id = avs.EnumDefinition_Id

		WHERE pl.GUIDReference = @pPanelistId

		) t3 ON t1.Id = t3.Id

		END TRY
		BEGIN CATCH
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT @ErrorMessage = ERROR_MESSAGE(),
			   @ErrorSeverity = ERROR_SEVERITY(),
			   @ErrorState = ERROR_STATE();
	
		RAISERROR (@ErrorMessage, -- Message text.
				   @ErrorSeverity, -- Severity.
				   @ErrorState -- State.
				   );
END CATCH 
END
