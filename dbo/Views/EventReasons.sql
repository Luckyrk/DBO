
CREATE VIEW [dbo].[EventReasons]
AS
SELECT fer.CountryISO2A
	,fer.CommEventReasonCode
	,fer.CommEventReasonDescription
FROM dbo.FullEventReasons fer
INNER JOIN dbo.CountryViewAccess ON fer.CountryISO2A = dbo.CountryViewAccess.Country
WHERE (dbo.CountryViewAccess.UserId = SUSER_SNAME())
	AND fer.CountryISO2A = dbo.CountryViewAccess.Country