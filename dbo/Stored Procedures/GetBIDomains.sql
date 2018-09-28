CREATE PROCEDURE GetBIDomains @pCountryCode VARCHAR(2)
AS
BEGIN

SELECT GroupBusinessIdDigits AS GroupDigits
FROM Country CN
JOIN CountryConfiguration CC ON CN.Configuration_Id = CC.Id
WHERE CN.CountryISO2A = @pCountryCode

SELECT Domain 
FROM BIDomain BID
JOIN Country CN ON BID.Country_Id = CN.CountryId
WHERE CN.CountryISO2A = @pCountryCode

END

