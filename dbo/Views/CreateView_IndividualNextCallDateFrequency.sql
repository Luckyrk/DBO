-- =============================================
-- Create Indexed View template
-- =============================================
USE GPS_PM
GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF

IF object_id(N'dbo.IndividualNextCallDateFrequency', 'V') IS NOT NULL
	DROP VIEW dbo.IndividualNextCallDateFrequency
GO

CREATE VIEW dbo.IndividualNextCallDateFrequency 
WITH SCHEMABINDING AS
	SELECT cr.CountryISO2A AS CountryCode, i.GUIDReference AS IndividualGUID, IndividualID, c.[Date] AS NextCallDate, t.KeyName As Frequency
		FROM dbo.Individual i
			INNER jOIN dbo.CalendarEvent c ON i.Event_ID = c.ID
			INNER JOIN dbo.EventFrequency e ON c.Frequency_Id = e.GUIDReference
			INNER JOIN dbo.Country cr ON e.Country_Id = cr.CountryId
			INNER JOIN dbo.Translation t ON e.Translation_Id = t.TranslationId
			INNER JOIN dbo.CountryViewAccess a ON cr.CountryISO2A = a.Country
		WHERE a.UserId = SUSER_SNAME()
		  AND c.[Date] is not NULL
GO
--CREATE UNIQUE CLUSTERED INDEX IndividualNextCallDateFrequency_IndexedView
--ON dbo.IndividualNextCallDateFrequency(IndividualID)

GRANT SELECT ON IndividualNextCallDateFrequency TO GPSBusiness