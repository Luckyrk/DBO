CREATE VIEW [dbo].BelongingFidelidadTarjetaViewES
AS
SELECT GroupId, BelongingCode,
 [Loyalty card],[Loyalty card others name],[Loyalty card posession],[Loyalty card use],[Status]
FROM(
 SELECT 
      GroupId,BelongingCode, AttributeType, VALUE,[Status]
  FROM dbo.FullGroupBelongings
  WHERE CountryISO2A='ES' AND BelongingName='fidelidad tarjeta'
) p
PIVOT 
(
 MAX(value)
 FOR AttributeType in (
  [Loyalty card],
  [Loyalty card others name],
  [Loyalty card posession],
  [Loyalty card use]
 )
)
AS pt 

GO