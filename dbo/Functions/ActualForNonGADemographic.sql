CREATE FUNCTION [dbo].ActualForNonGADemographic 
( @Tuple_Id UNIQUEIDENTIFIER, @StateSet_Id UNIQUEIDENTIFIER, @Panel_Id UNIQUEIDENTIFIER ) RETURNS INT AS 
BEGIN 

DECLARE @Actual INT 
SET @Actual = (SELECT COUNT(*) AS Actual 
	FROM (
		SELECT COUNT(CandidateId) AS Actual 
		FROM PanelTargetValueMapping A	
		INNER JOIN DemographicValue B ON B.GUIDReference = A.DemographicValue_Id 
		INNER JOIN DemographicValueGrouping C ON C.GUIDReference = B.DemographicValueGrouping_Id 
		INNER JOIN AttributeValue D	ON D.DemographicId = C.Demographic_Id 
		INNER JOIN Panelist E ON E.PanelMember_Id = D.CandidateId 
		INNER JOIN StateGroupMapping F	ON E.State_Id = F.StateDefinition_Id 
		WHERE 
			A.RelatedDemographic_Id = @Tuple_Id 
			AND F.DemographicStateSet_Id = @StateSet_Id 
			AND E.Panel_Id = @Panel_Id 
			AND dbo.IsInInterval(D.GUIDReference, B.GUIDReference) = 1	
			AND dbo.IsInIntervalForGADemographic(@Tuple_Id,@StateSet_Id,@Panel_Id, E.GUIDReference ) = 1	
			
		GROUP BY D.CandidateId, A.RelatedDemographic_Id 
		HAVING (SELECT COUNT(*) FROM PanelTargetValueMapping G 
		WHERE G.RelatedDemographic_Id = A.RelatedDemographic_Id) = COUNT(DemographicId) + dbo.CountOfGADemographicsWithValidAnswer(@Tuple_Id ,@StateSet_Id,@Panel_Id )
		) tab1		 
	) 
RETURN @Actual

END