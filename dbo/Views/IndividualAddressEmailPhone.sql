
CREATE VIEW [dbo].[IndividualAddressEmailPhone]
AS
select dbo.FullIndividualAddressEmailPhone.CountryISO2A, dbo.FullIndividualAddressEmailPhone.DiscriminatorType, dbo.FullIndividualAddressEmailPhone.AddressType,
       dbo.FullIndividualAddressEmailPhone.[Order], dbo.FullIndividualAddressEmailPhone.IndividualId, dbo.FullIndividualAddressEmailPhone.AddressLine1, 
       dbo.FullIndividualAddressEmailPhone.AddressLine2, dbo.FullIndividualAddressEmailPhone.AddressLine3, dbo.FullIndividualAddressEmailPhone.AddressLine4, 
       dbo.FullIndividualAddressEmailPhone.PostCode,
       dbo.FullIndividualAddressEmailPhone.GPSUser, dbo.FullIndividualAddressEmailPhone.GPSUpdateTimestamp, dbo.FullIndividualAddressEmailPhone.CreationTimeStamp

FROM         dbo.FullIndividualAddressEmailPhone INNER JOIN
                      dbo.CountryViewAccess ON dbo.FullIndividualAddressEmailPhone.CountryISO2A = dbo.CountryViewAccess.Country
WHERE     (dbo.CountryViewAccess.UserId = SUSER_SNAME()) AND (dbo.CountryViewAccess.AllowPID = 1) AND dbo.FullIndividualAddressEmailPhone.CountryISO2A = dbo.CountryViewAccess.Country