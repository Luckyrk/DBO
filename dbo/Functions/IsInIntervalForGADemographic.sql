CREATE FUNCTION [dbo].IsInIntervalForGADemographic 
( @Tuple_Id UNIQUEIDENTIFIER, @StateSet_Id UNIQUEIDENTIFIER, @Panel_Id UNIQUEIDENTIFIER, @Panelist_Id UNIQUEIDENTIFIER ) RETURNS INT AS 
BEGIN 

DECLARE @Actual INT 
DECLARE @CountOfGADemographics INT 
SET @CountOfGADemographics = dbo.CountGADemographicsForTuple( @Tuple_Id)

SET @Actual = (
		SELECT COUNT(D.DemographicId) AS Actual 
		FROM PanelTargetValueMapping A	
		INNER JOIN DemographicValue B ON B.GUIDReference = A.DemographicValue_Id 
		INNER JOIN DemographicValueGrouping C ON C.GUIDReference = B.DemographicValueGrouping_Id 
		INNER JOIN AttributeValue D	ON D.DemographicId = C.Demographic_Id 
		INNER JOIN GeographicArea GA ON GA.GUIDReference = D.RespondentId 
		INNER JOIN Candidate Can ON Can.GeographicArea_Id = GA.GUIDReference
		INNER JOIN Panelist E ON E.PanelMember_Id = Can.GUIDReference
		INNER JOIN StateGroupMapping F	ON E.State_Id = F.StateDefinition_Id 
		WHERE 
			A.RelatedDemographic_Id = @Tuple_Id 
			AND F.DemographicStateSet_Id = @StateSet_Id 
			AND E.GUIDReference = @Panelist_Id
			AND E.Panel_Id = @Panel_Id 
			AND dbo.IsInInterval(D.GUIDReference, B.GUIDReference) = 1	
)
IF @Actual = @CountOfGADemographics
	RETURN 1

RETURN 0

END