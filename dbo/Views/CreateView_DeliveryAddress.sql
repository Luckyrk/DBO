-- =============================================
-- Create Indexed View template
-- =============================================
USE GPS_PM
GO
SET ANSI_NULLS, ANSI_PADDING, ANSI_WARNINGS, CONCAT_NULL_YIELDS_NULL, QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF

IF object_id(N'dbo.DeliveryAddress', 'V') IS NOT NULL
	DROP VIEW dbo.DeliveryAddress
GO

CREATE VIEW dbo.DeliveryAddress 
WITH SCHEMABINDING 
AS
	SELECT 
		DISTINCT
		a.GUIDReference AS DeliveryAddressID
		, AddressLine1
		, AddressLine2
		, AddressLine3
		, AddressLine4
		, PostCode
		--, Type_Id AS AddressTypeID
		--, AddressType
		--, t.KeyName
		--, c.GUIDReference AS CandidateID
	FROM [dbo].[Address] a
		INNER JOIN dbo.OrderedContactMechanism ocm ON ocm.Address_Id = a.GUIDReference
		INNER JOIN dbo.Candidate c ON ocm.Candidate_Id = c.GUIDReference
		INNER JOIN dbo.Country cty ON cty.CountryID = c.Country_ID
		INNER JOIN dbo.CountryViewAccess cva ON cva.Country = cty.CountryISO2A
		INNER JOIN dbo.AddressType at ON a.Type_Id = at.Id
		INNER JOIn dbo.Translation t on at.Description_Id = t.TranslationId
WHERE   cva.UserId = SUSER_SNAME()
AND t.KeyName IN ('DeliveryAddressType', 'PostalAddressType', 'HomeAddressType')
GO


--CREATE UNIQUE CLUSTERED INDEX DeliveryAddress_IndexedView
--ON dbo.DeliveryAddress(DeliveryAddressID)

GRANT SELECT ON DeliveryAddress TO GPSBusiness
--SELECT * FROM Package WHERE Country_ID = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
