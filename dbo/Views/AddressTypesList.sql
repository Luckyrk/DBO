
CREATE VIEW [dbo].[AddressTypesList]
AS
SELECT at.DiscriminatorType AS AddressType
	,tt.KeyName AS Address
FROM AddressType at
INNER JOIN Translation tt ON tt.TranslationId = at.Description_Id