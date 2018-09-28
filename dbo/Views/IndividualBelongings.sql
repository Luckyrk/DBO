CREATE VIEW [dbo].[IndividualBelongings]
AS
SELECT dbo.FullIndividualBelongings.CountryISO2A
	,dbo.FullIndividualBelongings.GroupId
	,dbo.FullIndividualBelongings.IndividualId
	,dbo.FullIndividualBelongings.BelongingCode
	,dbo.FullIndividualBelongings.BelongingType
	,dbo.FullIndividualBelongings.BelongingName
	,dbo.FullIndividualBelongings.AttributeType
	,dbo.FullIndividualBelongings.StringValue
	,dbo.FullIndividualBelongings.IntegerValue
	,dbo.FullIndividualBelongings.EnumValue
	,dbo.FullIndividualBelongings.FloatValue
	,dbo.FullIndividualBelongings.DateValue
	,dbo.FullIndividualBelongings.BooleanValue
	,dbo.FullIndividualBelongings.[FreeText]
	,dbo.FullIndividualBelongings.GPSUser
	,dbo.FullIndividualBelongings.GPSUpdateTimestamp
	,dbo.FullIndividualBelongings.CreationTimeStamp
FROM dbo.FullIndividualBelongings
CROSS JOIN dbo.CountryViewAccess
WHERE (
		dbo.CountryViewAccess.UserId = SUSER_SNAME()
		AND dbo.FullIndividualBelongings.CountryISO2A = dbo.CountryViewAccess.Country
		)