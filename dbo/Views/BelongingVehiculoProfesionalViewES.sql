CREATE VIEW [dbo].BelongingVehiculoProfesionalViewES AS 
SELECT *
 FROM (
  SELECT fib.IndividualId, scp.BelongingCode, AttributeType, fib.[status],
    CAST(ISNULL([IntegerValue],'') as varchar)
    +CAST(ISNULL([EnumValue],'') as varchar)
    +CAST(ISNULL([StringValue],'') as varchar)
    +CAST(ISNULL([FloatValue],'') as varchar)
    +CAST(ISNULL([DateValue],'') as varchar)
    +CAST(ISNULL([FloatValue],'') as varchar)
    +CAST(ISNULL([BooleanValue],'') as varchar) as value       
  FROM dbo.FullIndividualBelongings fib
  INNER JOIN (
   SELECT IndividualId, BelongingName, BelongingCode 
   FROM dbo.FullIndividualBelongings
   WHERE CountryISO2A = 'ES' AND BelongingName = 'vehiculo profesional'
   GROUP BY  IndividualId, BelongingName, BelongingCode   
  ) scp ON fib.IndividualId = scp.IndividualId AND fib.BelongingName = scp.BelongingName AND fib.BelongingCode = scp.BelongingCode 
  WHERE AttributeType in ('Adblue',
        'Catalytic converter professionals',
        'CUTI (code)',
        'Dropped off reason professional',
        'Maximum_weight_code_petrolprof',
        'Model professional vehicles',
        'Panelist choose where refuelling',
        'Region_Mat_petrolprof',
        'Registration date professionals',
        'Route',
        'Route description',
        'Sector',
        'Vehicle type',
        'Year of registration number',
        'Car Brand professionals',
        'Car model petrol',
        'Maximum weight',
        'Owner professional vehicles',
        'Payload',
        'Petrol type professionals',
        'Professional vehicles Dropped off date',
        'Province (code)',
        'Registration number  professionals',
        'Route type',
        'Tare',
        'Vehicle number') 
 ) pvp
 PIVOT (
  MAX(value)
  FOR AttributeType in ([Adblue],
        [Catalytic converter professionals],
        [CUTI (code)],
        [Dropped off reason professional],
        [Maximum_weight_code_petrolprof],
        [Model professional vehicles],
        [Panelist choose where refuelling],
        [Region_Mat_petrolprof],
        [Registration date professionals],
        [Route],
        [Route description],
        [Sector],
        [Vehicle type],
        [Year of registration number],
        [Car Brand professionals],
        [Car model petrol],
        [Maximum weight],
        [Owner professional vehicles],
        [Payload],
        [Petrol type professionals],
        [Professional vehicles Dropped off date],
        [Province (code)],
        [Registration number  professionals],
        [Route type],
        [Tare],
        [Vehicle number])
 ) AS pt
GO