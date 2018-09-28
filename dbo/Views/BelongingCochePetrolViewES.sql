CREATE VIEW BelongingCochePetrolViewES
AS
SELECT CAST(LEFT(IndividualId,6) as Integer) as gid, *
FROM (
	SELECT fib.IndividualId, AttributeType,  
			CAST(ISNULL([IntegerValue],'') as varchar)
			+CAST(ISNULL([EnumValue],'') as varchar)
			+CAST(ISNULL([StringValue],'') as varchar)
			+CAST(ISNULL([FloatValue],'') as varchar)
			+CAST(ISNULL([DateValue],'') as varchar)
			+CAST(ISNULL([FloatValue],'') as varchar)
			+CAST(ISNULL([BooleanValue],'') as varchar) as value
			,scp.BelongingCode
			,fib.[Status]
	FROM dbo.FullIndividualBelongings fib
	INNER JOIN (
		SELECT IndividualId, BelongingName, BelongingCode
		FROM dbo.FullIndividualBelongings
		WHERE CountryISO2A = 'ES' AND BelongingName = 'coche petrol'
		GROUP BY  IndividualId, BelongingName, BelongingCode
	) scp ON fib.IndividualId = scp.IndividualId AND fib.BelongingName = scp.BelongingName AND fib.BelongingCode = scp.BelongingCode 
	WHERE CountryISO2A = 'ES' 
		AND AttributeType in ('Car number',
								'Collaborator',
								'Registration number petrol',
								'Purchase year',
								'Circulation year',
								'Car Brand petrol',
								'Car model petrol',
								'Version',
								'Purchase type',
								'Registration date petrol',
								'Engine capacity petrol',
								'Power rating',
								'Maximum horse power',
								'Catalytic converter petrol',
								'Car Owner petrol',
								'Order',
								'Dropped off reason petrol',
								'Petrol Dropped off date',
								'Fuel  type',
								'Region_Mat_petrolpart',
								'Prov_Mat_petrolpart') 
) pvp
PIVOT (
	MAX(value)
	FOR AttributeType in ([Car number],
							[Collaborator],
							[Registration number petrol],
							[Purchase year],
							[Circulation year],
							[Car Brand petrol],
							[Car model petrol],
							[Version],
							[Purchase type],
							[Registration date petrol],
							[Engine capacity petrol],
							[Power rating],
							[Maximum horse power],
							[Catalytic converter petrol],
							[Car Owner petrol],
							[Order],
							[Dropped off reason petrol],
							[Petrol Dropped off date],
							[Fuel  type],
							[Region_Mat_petrolpart],
							[Prov_Mat_petrolpart])
) AS pt
