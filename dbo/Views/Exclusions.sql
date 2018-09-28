
CREATE VIEW [dbo].[Exclusions]
AS
SELECT  dbo.FullExclusions.CountryISO2A, dbo.FullExclusions.IndividualId, dbo.FullExclusions.KeyName,
       dbo.FullExclusions.Range_From, dbo.FullExclusions.Range_To, dbo.FullExclusions.AllIndividuals, dbo.FullExclusions.AllPanels, dbo.FullExclusions.IsClosed,
       dbo.FullExclusions.GPSUpdateTimestamp, dbo.FullExclusions.CreationTimeStamp, dbo.FullExclusions.GPSUser
FROM         dbo.FullExclusions CROSS JOIN
                      dbo.CountryViewAccess
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME() AND dbo.FullExclusions.CountryISO2A = dbo.CountryViewAccess.Country)