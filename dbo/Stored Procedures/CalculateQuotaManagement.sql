CREATE PROCEDURE [dbo].[CalculateQuotaManagement] @Country UNIQUEIDENTIFIER
	,@GPSUser NVARCHAR(50)
	,@GPSUpdateTimestamp DATETIME
AS
BEGIN

	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	INSERT INTO DemographicStateSetScoreboard (
		GUIDReference
		,Target
		,Actual
		,GPSUser
		,GPSUpdateTimestamp
		,StateSet_Id
		)
	SELECT NEWID() AS GUIDReference
		,CAST(Panel.Total_Target_Population AS BIGINT) * CAST(SGD1.Target_Percentage AS BIGINT) / 100 AS [Target]
		,(
			SELECT COUNT(*)
			FROM StateGroupDefinition SGD2
			LEFT JOIN StateGroupMapping ON StateGroupMapping.DemographicStateSet_Id = SGD2.GUIDReference
			INNER JOIN Panelist ON Panelist.State_Id = StateGroupMapping.StateDefinition_Id
				AND Panelist.Panel_Id = SGD2.Panel_Id
			WHERE SGD2.GUIDReference = SGD1.GUIDReference
			) AS Actual
		,@GPSUser
		,@GPSUpdateTimestamp
		,SGD1.GUIDReference AS StateGroupDefinition_Id
	FROM Panel
	INNER JOIN StateGroupDefinition SGD1 ON SGD1.Panel_Id = Panel.GUIDReference
	WHERE Panel.Country_Id = @Country
	ORDER BY Panel_Id;


	INSERT INTO DemographicTargetScoreboard (
		GUIDReference
		,Target
		,Actual
		,GPSUser
		,GPSUpdateTimestamp
		,Dimension_Id --PTD.Dimension_Id
		,RelatedDemographic_Id --DemographicGroupGUID
		,DemographicStateSetScoreboard_Id
		)
	SELECT NEWID() AS GUIDReference
		,CAST(PTV.[Target] AS BIGINT) * CAST(SGD.Target_Percentage AS BIGINT) / 100 AS [Target]
		,0
		,@GPSUser
		,@GPSUpdateTimestamp
		,Dimension_Id
		,PTV.GUIDReference
		,DSSS.GUIDReference
	FROM Panel P
	JOIN PanelTargetDefinition PTD ON PTD.Panel_Id = p.GUIDReference
	JOIN PanelTargetValueDefinition PTVD ON PTVD.GUIDReference = PTD.Dimension_Id
	JOIN PanelTargetValue PTV ON PTV.DemographicTarget_Id = PTVD.GUIDReference
	JOIN StateGroupDefinition SGD ON SGD.DemographicTargetSet_Id = PTD.GUIDReference
	JOIN DemographicStateSetScoreboard DSSS ON DSSS.StateSet_Id = SGD.GUIDReference
		AND DSSS.GPSUpdateTimestamp = @GPSUpdateTimestamp
	WHERE P.Country_Id = @Country

	
	SELECT P.GUIDReference AS PanelGUID, P.Name AS PanelName, 
		PTD.GUIDReference AS TargetGUID, PTD.Name AS TargetName, PTD.Dimension_Id AS Dimension_Id, 
		PTV.GUIDReference AS DemographicGroupGUID, PTV.[Target], SGD.GUIDReference AS StateGUID, 
		SGD.Name AS StateName, SGD.Target_Percentage, PNL.PanelMember_Id AS CandidateGUID, 
		(SELECT GeographicArea_Id FROM Candidate WHERE GUIDReference = PNL.PanelMember_Id) AS GeographicArea_Id, 
		A.GUIDReference AS AttributeGUID, DV.GUIDReference AS DVGUID, 
		DVI.StartInt, DVI.EndInt, DVI.StartDecimal, DVI.EndDecimal, DVI.StartDate, DVI.EndDate, ED.Id AS EnumDefinition
	INTO #fulltable
	FROM Panel P
	JOIN PanelTargetDefinition PTD ON PTD.Panel_Id = p.GUIDReference
	JOIN PanelTargetValueDefinition PTVD ON PTVD.GUIDReference = PTD.Dimension_Id
	JOIN PanelTargetValue PTV ON PTV.DemographicTarget_Id = PTVD.GUIDReference
	JOIN PanelTargetValueMapping PTVM ON PTVM.RelatedDemographic_Id = PTV.GUIDReference
	JOIN StateGroupDefinition SGD ON SGD.DemographicTargetSet_Id = PTD.GUIDReference
	JOIN StateGroupMapping SGM ON SGM.DemographicStateSet_Id = SGD.GUIDReference
	JOIN DemographicValue DV ON DV.GUIDReference = PTVM.DemographicValue_Id
	JOIN DemographicValueGrouping DVG ON DVG.GUIDReference = DV.DemographicValueGrouping_Id
	JOIN Attribute A ON A.GUIDReference = DVG.Demographic_Id
	JOIN Panelist PNL ON PNL.Panel_Id = P.GUIDReference AND PNL.State_Id = SGM.StateDefinition_Id
	LEFT JOIN DemographicValueInterval DVI ON DVI.GUIDReference = DV.GUIDReference
	LEFT JOIN EnumDefinition ED ON ED.Demographic_Id = A.GUIDReference AND ED.EnumValueSet_Id = DV.GUIDReference
	WHERE P.Country_Id = @Country AND A.Active =1
	GROUP BY P.GUIDReference, P.Name, PTD.GUIDReference, PTD.Name, PTD.Dimension_Id, PTV.GUIDReference, PTV.[Target], SGD.GUIDReference, SGD.Name, 
	SGD.Target_Percentage, PNL.PanelMember_Id, A.GUIDReference, DV.GUIDReference, DVI.StartInt, DVI.EndInt, DVI.StartDecimal, DVI.EndDecimal, DVI.StartDate, DVI.EndDate, ED.Id


	SELECT PanelGUID, PanelName, TargetGUID, TargetName, DemographicGroupGUID, Dimension_Id, T.[Target], StateGUID, 
		StateName, T.Target_Percentage, CandidateGUID, COUNT(*) AS Total
	INTO #panel_demo
	FROM #fulltable AS T
	JOIN AttributeValue AV ON AV.DemographicId = T.AttributeGUID AND AV.CandidateId = T.CandidateGUID
	JOIN PanelDemographic Pnldemo ON Pnldemo.BaseDemographic_Id = T.AttributeGUID AND Pnldemo.Panel_Id = T.PanelGUID
	WHERE (
			(av.Discriminator = 'IntAttributeValue' AND TRY_CAST(av.Value AS INT) BETWEEN T.StartInt AND T.EndInt) OR
			(av.Discriminator = 'FloatAttributeValue' AND TRY_CAST(av.Value AS DECIMAL(18,2)) BETWEEN T.StartDecimal AND T.EndDecimal) OR
			(av.Discriminator = 'DateAttributeValue' AND TRY_CAST(av.Value AS DATETIME) BETWEEN T.StartDate AND T.EndDate) OR
			(av.Discriminator = 'EnumAttributeValue' AND av.EnumDefinition_Id = T.EnumDefinition)
		)
	GROUP BY PanelGUID, PanelName, TargetGUID, TargetName, DemographicGroupGUID, Dimension_Id, T.[Target], StateGUID, 
	StateName, T.Target_Percentage, CandidateGUID

	
	SELECT PanelGUID, PanelName, TargetGUID, TargetName, DemographicGroupGUID, Dimension_Id, T.[Target], StateGUID, 
		StateName, T.Target_Percentage, CandidateGUID, COUNT(*) AS Total
	INTO #geographic_demo
	FROM #fulltable AS T
	JOIN AttributeValue AV ON AV.DemographicId = T.AttributeGUID AND AV.RespondentId = T.GeographicArea_Id
	WHERE (
			(av.Discriminator = 'IntAttributeValue' AND TRY_CAST(av.Value AS INT) BETWEEN T.StartInt AND T.EndInt) OR
			(av.Discriminator = 'FloatAttributeValue'AND TRY_CAST(av.Value AS DECIMAL(18, 2)) BETWEEN T.StartDecimal AND T.EndDecimal) OR
			(av.Discriminator = 'DateAttributeValue' AND TRY_CAST(av.Value AS DATETIME) BETWEEN T.StartDate AND T.EndDate) OR
			(av.Discriminator = 'EnumAttributeValue' AND av.EnumDefinition_Id = T.EnumDefinition)
		)
	GROUP BY PanelGUID, PanelName, TargetGUID, TargetName, DemographicGroupGUID, Dimension_Id, T.[Target], StateGUID, 
	StateName, T.Target_Percentage, CandidateGUID


	UPDATE DTS SET Actual = (
		SELECT COUNT(*)
		FROM (
			SELECT TargetGUID, TargetName, Target, StateGUID, StateName, Target_Percentage, DemographicGroupGUID, Dimension_Id, CandidateGUID, SUM(Total) AS Total
			FROM (
				SELECT TargetGUID, TargetName, [Target], StateGUID, StateName, Target_Percentage, DemographicGroupGUID, Dimension_Id, CandidateGUID, Total
				FROM #panel_demo
				UNION ALL
				SELECT TargetGUID, TargetName, [Target], StateGUID, StateName, Target_Percentage, DemographicGroupGUID, Dimension_Id, CandidateGUID, Total
				FROM #geographic_demo
			) AS G1
			GROUP BY TargetGUID, TargetName, [Target], StateGUID, StateName, Target_Percentage, DemographicGroupGUID, Dimension_Id, CandidateGUID
		) AS G2
		WHERE DSS.StateSet_Id = G2.StateGUID AND DTS.RelatedDemographic_Id = DemographicGroupGUID AND DTS.Dimension_Id = Dimension_Id
			AND Total = (SELECT COUNT(DISTINCT DVG.Demographic_Id)
			FROM PanelTargetDefinition PTD
			JOIN PanelTargetValueDefinition PTVD ON PTVD.GUIDReference = PTD.Dimension_Id
			JOIN PanelTargetValue PTV ON PTV.DemographicTarget_Id = PTVD.GUIDReference
			JOIN PanelTargetValueMapping PTVM ON PTVM.RelatedDemographic_Id = PTV.GUIDReference
			JOIN DemographicValue DV ON DV.GUIDReference = PTVM.DemographicValue_Id
			JOIN DemographicValueGrouping DVG ON DVG.GUIDReference = DV.DemographicValueGrouping_Id
			WHERE PTD.GUIDReference = TargetGUID)
		)
	FROM DemographicTargetScoreboard DTS
	JOIN DemographicStateSetScoreboard DSS ON DTS.DemographicStateSetScoreboard_Id = DSS.GUIDReference
	WHERE DTS.GPSUpdateTimestamp = @GPSUpdateTimestamp


	DROP TABLE #fulltable

	DROP TABLE #geographic_demo

	DROP TABLE #panel_demo
END
