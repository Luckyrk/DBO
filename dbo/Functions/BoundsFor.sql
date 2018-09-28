﻿CREATE FUNCTION BoundsFor ( @interval_id uniqueidentifier ) RETURNS @bounds table( lowerBound decimal(6), upperBound decimal(6) ) AS BEGIN DECLARE @lowerBound DECIMAL DECLARE @upperBound DECIMAL INSERT INTO @bounds SELECT CASE WHEN C.[Type]  = 'Int' THEN convert(DECIMAL(6), StartInt) ELSE CASE WHEN C.[Type] = 'Float' THEN StartDecimal ELSE CASE WHEN C.[Type] = 'Bool' THEN 0 END END END AS lowerBound, CASE WHEN C.[Type] = 'Int' THEN convert(DECIMAL(6),EndInt) ELSE CASE WHEN C.[Type] = 'Float' THEN EndDecimal ELSE CASE WHEN C.[Type] = 'Bool' THEN 1 END END END AS upperBound FROM DemographicValue A INNER JOIN DemographicValueGrouping B ON A.Grouping_Id = B.GUIDReference INNER JOIN Attribute C ON B.Demographic_Id = C.GUIDReference INNER JOIN DemographicValueInterval D ON D.GUIDReference = A.GUIDReference WHERE A.GUIDReference = @interval_id RETURN END