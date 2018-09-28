CREATE FUNCTION [dbo].[CountGADemographicsForTuple] 
( @Tuple_Id UNIQUEIDENTIFIER ) RETURNS INT AS 
BEGIN 

DECLARE @CountOfGADemographics INT 

SET @CountOfGADemographics = (SELECT COUNT( DemographicValue_Id)
				FROM PanelTargetValueMapping ptvm,
					DemographicValue dv,
					DemographicValueGrouping dvg,
						Attribute at,
					AttributeScope ascop
					WHERE ptvm.DemographicValue_Id = dv.GUIDReference
					AND dv.Grouping_Id = dvg.GUIDReference
					AND dvg.Demographic_Id = at.GUIDReference
					AND at.Scope_Id = ascop.GUIDReference
					AND ascop.Type = 'GeographicArea'
					AND ptvm.RelatedDemographic_Id = @Tuple_Id )

RETURN @CountOfGADemographics

END