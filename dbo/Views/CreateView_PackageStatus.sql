-- =============================================
-- Create Indexed View template
-- =============================================
USE GPS_PM
GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF

IF object_id(N'dbo.PackageStatus', 'V') IS NOT NULL
	DROP VIEW dbo.PackageStatus
GO

CREATE VIEW dbo.PackageStatus 
WITH SCHEMABINDING 
AS
	SELECT
		p.GUIDReference AS PackageID
		, State_Id
		--, Reward_Id
		--, Debit_Id
		, c.CountryISO2A
		, DateSent
		, sd.Label_ID
		, t.KeyName
		, tt.Value
	FROM [dbo].[Package] p 
		INNER JOIN dbo.StateDefinition sd ON p.State_ID = sd.ID
		INNER JOIN dbo.Translation t ON sd.Label_ID = t.TranslationId
		INNER JOIN dbo.TranslationTerm tt ON t.TranslationID = tt.Translation_ID
		LEFT OUTER JOIN dbo.Country c ON c.CountryID = p.Country_ID AND tt.CultureCode IN (
								CASE c.CountryISO2A 
									WHEN 'TW' THEN 1028
									WHEN 'FR' THEN 1036
									WHEN 'ES' THEN 3082 
									WHEN 'GB' THEN 2057
									WHEN 'PH' THEN 1124
									WHEN 'MY' THEN 1086
						 END)


GO
--CREATE UNIQUE CLUSTERED INDEX PackageStatus_IndexedView
--ON dbo.PackageStatus(GUIDReference, State_ID, Label_ID, Value)

GRANT SELECT ON PackageStatus TO GPSBusiness
--SELECT * FROM Package WHERE Country_ID = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'


--SELECT top 10 *
--  FROM [GPS_PM].[dbo].[FullIndividualRedemptions] f
--  LEFT JOIN [GPS_PM].[dbo].PackageStatus p on f.PackageID = p.PackageID AND f.CountryISO2A = p.CountryISO2A
--  WHERE f.[CountryISO2A] = 'ES'
--  Order by f.PackageID
