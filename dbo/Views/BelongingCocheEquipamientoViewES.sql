CREATE VIEW [dbo].BelongingCocheEquipamientoViewES
AS
SELECT GroupId,BelongingCode,[Status]
,LEFT([Fuel  type_hh],LEN([Fuel  type_hh])-CHARINDEX('$',REVERSE([Fuel  type_hh]))) AS [TipoCarburante_coche_hh],RIGHT([Fuel  type_hh],CHARINDEX('$',REVERSE([Fuel  type_hh]))-1) AS [TipoCarburante_coche_hhDesc]
,LEFT([Car brand hh],LEN([Car brand hh])-CHARINDEX('$',REVERSE([Car brand hh]))) AS [Marca_coche_hh],RIGHT([Car brand hh],CHARINDEX('$',REVERSE([Car brand hh]))-1) AS [Marca_coche_hhDesc]
,LEFT([Car model hh],LEN([Car model hh])-CHARINDEX('$',reverse([Car model hh]))) AS [Modelo_coche_hh],RIGHT([Car model hh],CHARINDEX('$',REVERSE([Car model hh]))-1) AS [Modelo_coche_hhDesc]
,LEFT([Car Owner hh],LEN([Car Owner hh])-CHARINDEX('$',REVERSE([Car Owner hh]))) AS [Propietario_coche_hh],RIGHT([Car Owner hh],CHARINDEX('$',REVERSE([Car Owner hh]))-1) AS [Propietario_coche_hhDesc]
,LEFT([Engine capacity hh Enum],LEN([Engine capacity hh Enum])-CHARINDEX('$',REVERSE([Engine capacity hh Enum]))-1) AS [Enginecapacityhhenum],RIGHT([Engine capacity hh Enum],CHARINDEX('$',REVERSE([Engine capacity hh Enum]))-1) AS [EnginecapacityhhenumDesc]
 FROM (
SELECT *
 FROM (
  SELECT fib.GroupId, fib.BelongingCode, AttributeType, 
		CAST(ISNULL([IntegerValue],'') as varchar)
		+CAST(ISNULL([EnumValue],'')+ ' $ ' + isnull(fib.EnumDesc,'') as varchar)
		+CAST(ISNULL([StringValue],'') as varchar)
		+CAST(ISNULL([FloatValue],'') as varchar)
		+CAST(ISNULL([DateValue],'') as varchar)
		+CAST(ISNULL([FloatValue],'') as varchar)
		+CAST(ISNULL([BooleanValue],'') as varchar) as value,fib.[Status]
  FROM dbo.FullGroupBelongings fib 
  WHERE AttributeType in (
						'Fuel  type_hh',
						'Car brand hh',
						'Car model hh',
						'Car Owner hh',
						'Engine capacity hh Enum') 
 ) pvp
 PIVOT (
  MAX(value)
  FOR AttributeType in (
						[Fuel  type_hh],
						[Car brand hh],
						[Car model hh],
						[Car Owner hh],
						[Engine capacity hh Enum])
 ) AS pt


) TT

