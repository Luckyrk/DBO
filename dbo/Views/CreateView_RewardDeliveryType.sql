-- =============================================
-- Create Indexed View template
-- =============================================
USE GPS_PM
GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF

IF object_id(N'dbo.RewardDeliveryType', 'V') IS NOT NULL
	DROP VIEW dbo.RewardDeliveryType
GO

CREATE VIEW dbo.RewardDeliveryType 
WITH SCHEMABINDING 
AS
	SELECT
		r.RewardDeliveryTypeID
		, r.Code AS DeliveryCode
		, trd.KeyName AS DeliveryDescription
	FROM dbo.RewardDeliveryType r 
	LEFT JOIN dbo.Translation trd ON r.Translation_Id = trd.TranslationId
GO
--CREATE UNIQUE CLUSTERED INDEX IndividualNextCallDateFrequency_IndexedView
--ON dbo.IndividualNextCallDateFrequency(IndividualID)

--GRANT SELECT ON IndividualNextCallDateFrequency TO GPSBusiness