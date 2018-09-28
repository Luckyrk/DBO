
CREATE VIEW [dbo].[GetPhoneTypes]
AS
SELECT TT.Value AS PhoneTypes
FROM AddressType AT
INNER JOIN TranslationTerm TT ON AT.Description_Id = TT.Translation_Id
WHERE DiscriminatorType = 'PhoneAddressType'
	AND TT.CultureCode = 2057