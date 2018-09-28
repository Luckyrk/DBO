CREATE VIEW [dbo].BelongingCreditoTarjetaViewES
AS 
SELECT 
GroupId,[Credit card],[Other credit card name], [Credit card possession],[Credit card use],[Status], BelongingCode
FROM(
 SELECT 
      GroupId,BelongingCode,AttributeType,VALUE,[Status]
  FROM dbo.FullGroupBelongings
  WHERE CountryISO2A='ES' AND BelongingName='Credito tarjeta'
) p
PIVOT 
(
 MAX(value)
 FOR AttributeType in (
  [Credit card],
  [Other credit card name],
  [Credit card possession],
  [Credit card use]
 )
)
AS pt 

GO