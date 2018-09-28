Create view FullExclusionsHoldiayES 
as
SELECT IndividualId, MAX([Range_Form1]) as From1, MAX([Range_To1]) as To1, 
 MAX([Range_Form2]) as From2, MAX([Range_To2]) as To2, 
 MAX([Range_Form3]) as From3, MAX([Range_To3]) as To3
FROM (
 SELECT [IndividualId] ,[Range_From]   ,[Range_To], 
  'Range_Form' + CONVERT(varchar,ROW_NUMBER() OVER(PARTITION BY IndividualID ORDER BY Range_From)) AS Range_FromR,
  'Range_To' + CONVERT(varchar,ROW_NUMBER() OVER(PARTITION BY IndividualID ORDER BY Range_From)) AS Range_ToR
 FROM [dbo].[FullExclusions]
 WHERE CountryISO2A = 'ES' AND KeyName = 'Holiday' 
  AND DATEPART(YEAR,[Range_From]) > DATEPART(YEAR,GETDATE()) - 2
  AND DATEPART(YEAR,[Range_To]) > DATEPART(YEAR,GETDATE()) - 2
) st
PIVOT (
      MAX(Range_From) FOR Range_FromR IN([Range_Form1], [Range_Form2], [Range_Form3]) 
) pvt1
PIVOT (
      MAX([Range_To]) FOR Range_ToR IN([Range_To1], [Range_To2], [Range_To3])
) pvt2
GROUP BY IndividualId