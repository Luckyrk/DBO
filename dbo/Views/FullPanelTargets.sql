
CREATE VIEW [dbo].[FullPanelTargets]
AS
SELECT t1.[CountryISO2A]
	,t1.[PanelCode]
	,t1.[PanelName]
	,t1.[TotalTargetPopulation]
	,t1.[TargetName]
	,t1.[Target]
	,STUFF((
			SELECT ', ' + t2.[Description]
			FROM (
				SELECT cnt.CountryISO2a
					,pan.PanelCode
					,pan.NAME PanelName
					,pan.Total_Target_Population AS TotalTargetPopulation
					,ptd.[Name] TargetName
					,ptv.Target
					,ptvm.relateddemographic_id AS RelatedDemographicId
					,ptvm.DemographicValue_Id
					,CAST(term2.Value + ' ' + term.Value AS NVARCHAR(255)) AS [Description]
				FROM [dbo].[PanelTargetDefinition] ptd
				INNER JOIN dbo.Country cnt ON cnt.CountryId = ptd.Country_Id
				INNER JOIN dbo.Panel pan ON pan.GUIDReference = ptd.Panel_Id
				INNER JOIN dbo.PanelTargetValue ptv ON ptv.DemographicTarget_Id = ptd.[Dimension_Id]
				INNER JOIN dbo.PanelTargetValueMapping ptvm ON ptvm.RelatedDemographic_Id = ptv.GUIDReference
				LEFT JOIN dbo.DemographicValue dv ON ptvm.DemographicValue_Id = dv.GUIDReference
				LEFT JOIN dbo.TranslationTerm term ON term.Translation_Id = dv.Label_Id
					AND term.CultureCode = 2057
				LEFT JOIN DemographicValueGrouping dvg ON dvg.GUIDReference = dv.Grouping_Id
				LEFT JOIN TranslationTerm term2 ON term2.Translation_Id = dvg.Label_Id
					AND term2.CultureCode = 2057
				) t2
			WHERE t1.RelatedDemographicId = t2.RelatedDemographicId
			ORDER BY t2.[Description]
			FOR XML PATH('')
				,TYPE
			).value('.', 'varchar(max)'), 1, 2, '') AS CellDescription
	,STUFF((
			SELECT ', ' + t3.[Description]
			FROM (
				SELECT cnt.CountryISO2a
					,pan.PanelCode
					,pan.NAME PanelName
					,pan.Total_Target_Population AS TotalTargetPopulation
					,ptd.[Name] TargetName
					,ptv.Target
					,ptvm.relateddemographic_id AS RelatedDemographicId
					,ptvm.DemographicValue_Id
					,CAST(term.Value AS NVARCHAR(255)) AS [Description]
				FROM [dbo].[PanelTargetDefinition] ptd
				INNER JOIN dbo.Country cnt ON cnt.CountryId = ptd.Country_Id
				INNER JOIN dbo.Panel pan ON pan.GUIDReference = ptd.Panel_Id
				INNER JOIN dbo.PanelTargetValue ptv ON ptv.DemographicTarget_Id = ptd.[Dimension_Id]
				INNER JOIN dbo.PanelTargetValueMapping ptvm ON ptvm.RelatedDemographic_Id = ptv.GUIDReference
				LEFT JOIN dbo.DemographicValue dv ON ptvm.DemographicValue_Id = dv.GUIDReference
				LEFT JOIN dbo.TranslationTerm term ON term.Translation_Id = dv.Label_Id
					AND term.CultureCode = 2057
				LEFT JOIN DemographicValueGrouping dvg ON dvg.GUIDReference = dv.Grouping_Id
				LEFT JOIN TranslationTerm term2 ON term2.Translation_Id = dvg.Label_Id
					AND term2.CultureCode = 2057
				) t3
			WHERE t1.RelatedDemographicId = t3.RelatedDemographicId
				AND t3.DemographicValue_Id = (
					SELECT min(DemographicValue_Id)
					FROM [dbo].[PanelTargetDefinition] ptd
					INNER JOIN dbo.Country cnt ON cnt.CountryId = ptd.Country_Id
					INNER JOIN dbo.Panel pan ON pan.GUIDReference = ptd.Panel_Id
					INNER JOIN dbo.PanelTargetValue ptv ON ptv.DemographicTarget_Id = ptd.[Dimension_Id]
					INNER JOIN dbo.PanelTargetValueMapping ptvm ON ptvm.RelatedDemographic_Id = ptv.GUIDReference
					LEFT JOIN dbo.DemographicValue dv ON ptvm.DemographicValue_Id = dv.GUIDReference
					LEFT JOIN dbo.TranslationTerm term ON term.Translation_Id = dv.Label_Id
						AND term.CultureCode = 2057
					LEFT JOIN DemographicValueGrouping dvg ON dvg.GUIDReference = dv.Grouping_Id
					LEFT JOIN TranslationTerm term2 ON term2.Translation_Id = dvg.Label_Id
						AND term2.CultureCode = 2057
					WHERE ptvm.RelatedDemographic_Id = t3.RelatedDemographicId
					)
			ORDER BY t3.[Description]
			FOR XML PATH('')
				,TYPE
			).value('.', 'varchar(max)'), 1, 2, '') AS Dimension1
	,STUFF((
			SELECT ', ' + t4.[Description]
			FROM (
				SELECT cnt.CountryISO2a
					,pan.PanelCode
					,pan.NAME PanelName
					,pan.Total_Target_Population AS TotalTargetPopulation
					,ptd.[Name] TargetName
					,ptv.Target
					,ptvm.relateddemographic_id AS RelatedDemographicId
					,ptvm.DemographicValue_Id
					,CAST(term.Value AS NVARCHAR(255)) AS [Description]
				FROM [dbo].[PanelTargetDefinition] ptd
				INNER JOIN dbo.Country cnt ON cnt.CountryId = ptd.Country_Id
				INNER JOIN dbo.Panel pan ON pan.GUIDReference = ptd.Panel_Id
				INNER JOIN dbo.PanelTargetValue ptv ON ptv.DemographicTarget_Id = ptd.[Dimension_Id]
				INNER JOIN dbo.PanelTargetValueMapping ptvm ON ptvm.RelatedDemographic_Id = ptv.GUIDReference
				LEFT JOIN dbo.DemographicValue dv ON ptvm.DemographicValue_Id = dv.GUIDReference
				LEFT JOIN dbo.TranslationTerm term ON term.Translation_Id = dv.Label_Id
					AND term.CultureCode = 2057
				LEFT JOIN DemographicValueGrouping dvg ON dvg.GUIDReference = dv.Grouping_Id
				LEFT JOIN TranslationTerm term2 ON term2.Translation_Id = dvg.Label_Id
					AND term2.CultureCode = 2057
				) t4
			WHERE t1.RelatedDemographicId = t4.RelatedDemographicId
				AND t4.DemographicValue_Id = (
					SELECT max(DemographicValue_Id)
					FROM [dbo].[PanelTargetDefinition] ptd
					INNER JOIN dbo.Country cnt ON cnt.CountryId = ptd.Country_Id
					INNER JOIN dbo.Panel pan ON pan.GUIDReference = ptd.Panel_Id
					INNER JOIN dbo.PanelTargetValue ptv ON ptv.DemographicTarget_Id = ptd.[Dimension_Id]
					INNER JOIN dbo.PanelTargetValueMapping ptvm ON ptvm.RelatedDemographic_Id = ptv.GUIDReference
					LEFT JOIN dbo.DemographicValue dv ON ptvm.DemographicValue_Id = dv.GUIDReference
					LEFT JOIN dbo.TranslationTerm term ON term.Translation_Id = dv.Label_Id
						AND term.CultureCode = 2057
					LEFT JOIN DemographicValueGrouping dvg ON dvg.GUIDReference = dv.Grouping_Id
					LEFT JOIN TranslationTerm term2 ON term2.Translation_Id = dvg.Label_Id
						AND term2.CultureCode = 2057
					WHERE ptvm.RelatedDemographic_Id = t4.RelatedDemographicId
						AND (
							SELECT COUNT(1)
							FROM [dbo].[PanelTargetDefinition] ptd
							INNER JOIN dbo.Country cnt ON cnt.CountryId = ptd.Country_Id
							INNER JOIN dbo.Panel pan ON pan.GUIDReference = ptd.Panel_Id
							INNER JOIN dbo.PanelTargetValue ptv ON ptv.DemographicTarget_Id = ptd.[Dimension_Id]
							INNER JOIN dbo.PanelTargetValueMapping ptvm ON ptvm.RelatedDemographic_Id = ptv.GUIDReference
							LEFT JOIN dbo.DemographicValue dv ON ptvm.DemographicValue_Id = dv.GUIDReference
							LEFT JOIN dbo.TranslationTerm term ON term.Translation_Id = dv.Label_Id
								AND term.CultureCode = 2057
							LEFT JOIN DemographicValueGrouping dvg ON dvg.GUIDReference = dv.Grouping_Id
							LEFT JOIN TranslationTerm term2 ON term2.Translation_Id = dvg.Label_Id
								AND term2.CultureCode = 2057
							WHERE ptvm.RelatedDemographic_Id = t4.RelatedDemographicId
							) > 1
					)
			ORDER BY t4.[Description]
			FOR XML PATH('')
				,TYPE
			).value('.', 'varchar(max)'), 1, 2, '') AS Dimension2
FROM (
	SELECT cnt.CountryISO2a
		,pan.PanelCode
		,pan.NAME PanelName
		,pan.Total_Target_Population AS TotalTargetPopulation
		,ptd.[Name] TargetName
		,ptv.Target
		,ptvm.relateddemographic_id AS RelatedDemographicId
		,CAST(term2.Value + ' ' + term.Value AS NVARCHAR(255)) AS [Description]
	FROM [dbo].[PanelTargetDefinition] ptd
	INNER JOIN dbo.Country cnt ON cnt.CountryId = ptd.Country_Id
	INNER JOIN dbo.Panel pan ON pan.GUIDReference = ptd.Panel_Id
	INNER JOIN dbo.PanelTargetValue ptv ON ptv.DemographicTarget_Id = ptd.[Dimension_Id]
	INNER JOIN dbo.PanelTargetValueMapping ptvm ON ptvm.RelatedDemographic_Id = ptv.GUIDReference
	LEFT JOIN dbo.DemographicValue dv ON ptvm.DemographicValue_Id = dv.GUIDReference
	LEFT JOIN dbo.TranslationTerm term ON term.Translation_Id = dv.Label_Id
		AND term.CultureCode = 2057
	LEFT JOIN DemographicValueGrouping dvg ON dvg.GUIDReference = dv.Grouping_Id
	LEFT JOIN TranslationTerm term2 ON term2.Translation_Id = dvg.Label_Id
		AND term2.CultureCode = 2057
	) t1
GROUP BY t1.[CountryISO2a]
	,t1.[PanelCode]
	,t1.[PanelName]
	,t1.[TotalTargetPopulation]
	,t1.[TargetName]
	,t1.[Target]
	,t1.[RelatedDemographicId]