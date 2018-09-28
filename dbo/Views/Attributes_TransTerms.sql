CREATE VIEW [dbo].[Attributes_TransTerms]
       AS

       SELECT 
              c.UserId,
              c.Country,
              a.AttributeKey,
              a.Term_EnglishCulture,
              a.Term_LocalCulture
       From  CountryViewAccess  as c 
       INNER JOIN [FullAttributes_TransTerms] as a
                                                ON a.CountryISO2A = c.Country
       WHERE (c.UserId = SUSER_SNAME())
       --WHERE (c.UserId = 'GPSReadonlyMX') -- testing
       AND (c.AllowPID = 1)
       AND a.CountryISO2A = c.Country

GO
--GRANT SELECT ON [dbo].[Attributes_TransTerms] TO [GPSBusiness_Full] AS [dbo]
