-- =========================================
-- Create MY Locatliy lookup table
-- =========================================
USE GPS_PM
GO

IF OBJECT_ID('dbo.MYDMLocality', 'U') IS NOT NULL
  DROP TABLE dbo.MYDMLocality
GO

CREATE TABLE dbo.MYDMLocality
(
	LocalityID NVARCHAR(20) NOT NULL
	, DMID NVARCHAR(20) NOT NULL
	, LocalityDescription NVARCHAR(50) NOT NULL
    CONSTRAINT PK_LocalityID PRIMARY KEY (LocalityID)
)
GO