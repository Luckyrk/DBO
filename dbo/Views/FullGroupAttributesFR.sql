﻿
CREATE VIEW [dbo].[FullGroupAttributesFR]
AS
SELECT * FROM (	SELECT [CountryISO2A], Sequence AS [GroupId], A.[Key],  (
					CASE 
						WHEN A.[Type] = 'Date'
							THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
						WHEN A.[Type]='Enum'
							THEN ED.Value
						ELSE AV.Value
					END) Value
				FROM Country
				JOIN Collective C on C.CountryId=Country.CountryId
				LEFT JOIN AttributeValue AV ON AV.CandidateID=C.GuidReference OR AV.RespondentID=C.GuidReference
				LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
				LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
	WHERE CountryISO2A = 'FR'
	) AS source
PIVOT(MAX([Value]) FOR [Key] IN (
			[MAG]
			,[MALT]
			,[RS2]
			,[JAR2]
			,[VOIT]
			,[NET1]
			,[EXPR]
			,[LEG2]
			,[MACE]
			,[NOLA]
			,[TOND]
			,[SDEB]
			,[EPIL]
			,[RS1]
			,[DOGU]
			,[JAR1]
			,[CARA]
			,[NF]
			,[LIHD]
			,[CGL2]
			,[LSEC]
			,[DENT]
			,[TASS]
			,[MOND]
			,[PHNU]
			,[EMDO]
			,[TVC1]
			,[RVD]
			,[PTEL]
			,[CGL1]
			,[CHIG]
			,[EXRI]
			,[NESP]
			,[BOLA]
			,[CAP1]
			,[CAVI]
			,[EXSO]
			,[BONO]
			,[LIBO]
			,[RFCO]
			,[LDDE]
			,[SLIN]
			,[EPIC]
			,[SOCC]
			,[BODD]
			,[LEG1]
			,[MPIN]
			,[SODA]
			,[TVAD]
			,[FRU2]
			,[RF3*]
			,[RFFI]
			,[NET2]
			,[CJV]
			,[COMP]
			,[LITE]
			,[CAMA]
			,[RF1P]
			,[CAP2]
			,[PRWB]
			,[CAF]
			,[RASO]
			,[BASF]
			,[LEG3]
			,[HOCI]
			,[BRAY]
			,[CGIN]
			,[SENS]
			,[FRU1]
			,[NEST]
			,[DOGG]
			,[FRIT]
			,[IPOD]
			,[RAST]
			,[FRU3]
			,[MIFI]
			,[MOR]
			,[SOLU]
			,[MIPO]
			,[CACE]
			,[RVE]
			,[JAR3]
			,[CAS]
			,[THAB]
			,[CHIE]
			,[EXPE]
			,[CAME]
			,[LVAI]
			,[MABI]
			,[OURT]
			)) AS PivotTable