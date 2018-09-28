
CREATE VIEW [dbo].[CommsEvents]
AS
SELECT dbo.FullCommsEvents.CountryISO2A
	,dbo.FullCommsEvents.IndividualId
	,dbo.FullCommsEvents.CreationDate
	,dbo.FullCommsEvents.Incoming
	,dbo.FullCommsEvents.ContactMechanismCode
	,dbo.FullCommsEvents.ContactMechanismDescription
	,dbo.FullCommsEvents.STATE
	,dbo.FullCommsEvents.CallLength
	,dbo.FullCommsEvents.CommEventReasonCode
	,dbo.FullCommsEvents.CommEventReasonDescription
	,dbo.FullCommsEvents.Comment
	,dbo.FullCommsEvents.GPSUser
	,dbo.FullCommsEvents.GPSUpdateTimestamp
	,dbo.FullCommsEvents.CreationTimeStamp
FROM dbo.FullCommsEvents
INNER JOIN dbo.CountryViewAccess ON dbo.FullCommsEvents.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND dbo.FullCommsEvents.CountryISO2A = dbo.CountryViewAccess.Country