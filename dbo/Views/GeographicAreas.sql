
CREATE VIEW [dbo].[GeographicAreas]
AS
SELECT    [dbo].[FullGeographicAreas].CountryISO2A, [dbo].[FullGeographicAreas].Code, [dbo].[FullGeographicAreas].KeyName, [dbo].[FullGeographicAreas].CreationTimeStamp, [dbo].[FullGeographicAreas].GPSUpdateTimestamp, [dbo].[FullGeographicAreas].GPSUser
FROM         [dbo].[FullGeographicAreas] INNER JOIN
                      dbo.CountryViewAccess ON [dbo].[FullGeographicAreas].CountryISO2A = dbo.CountryViewAccess.Country
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME()) AND (dbo.CountryViewAccess.AllowPID = 1) AND [dbo].[FullGeographicAreas].CountryISO2A = dbo.CountryViewAccess.Country