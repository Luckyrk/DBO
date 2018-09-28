-- =============================================
-- Create Indexed View template
-- =============================================
USE GPS_PM
GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF

IF object_id(N'dbo.GroupCreationDateWho', 'V') IS NOT NULL
	DROP VIEW dbo.GroupCreationDateWho
GO

CREATE VIEW dbo.GroupCreationDateWho 
WITH SCHEMABINDING 
AS
	SELECT 
		Sequence AS BusinessID
		, c.GUIDReference AS GroupID
		, c.GPSUser
		, c.CreationTimeStamp AS GroupCreationDate
	FROM dbo.Collective c 
		INNER JOIN dbo.Country cty ON cty.CountryID = c.CountryID
		INNER JOIN dbo.CountryViewAccess cva ON cva.Country = cty.CountryISO2A
	WHERE   cva.UserId = SUSER_SNAME()
GO


--CREATE UNIQUE CLUSTERED INDEX GroupCreationDateWho_IndexedView
--ON dbo.GroupCreationDateWho(BusinessID)

GRANT SELECT ON GroupCreationDateWho TO GPSBusiness
--SELECT * FROM Package WHERE Country_ID = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
