CREATE VIEW [dbo].[FullAddressAttributes]
AS 
SELECT   f.CountryISO2A
       ,e.Sequence as GroupId
       ,b.[Key]
        ,(
		CASE 
			WHEN b.[Type] = 'Date'
				THEN FORMAT(TRY_PARSE(a.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
			WHEN b.[Type]='Enum'
				THEN ed.Value
			ELSE a.value
			END
		) Value
        ,a.[GPSUser]
        ,a.[GPSUpdateTimestamp]
        ,a.[CreationTimeStamp]
FROM [AttributeValue] a
JOIN Attribute b ON b.GUIDReference = a.DemographicId
JOIN Address c ON c.GUIDReference = a.Address_Id
JOIN OrderedContactMechanism d ON d.Address_Id = a.Address_Id
	AND d.[Order]  = 1
JOIN Collective e ON e.GUIDReference = d.Candidate_Id
JOIN Country f ON f.CountryId = a.Country_Id
LEFT JOIN EnumDefinition ed on ed.Id = a.EnumDefinition_Id
