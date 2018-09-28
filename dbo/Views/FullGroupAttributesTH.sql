CREATE VIEW [dbo].FullGroupAttributesTH AS 

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
				LEFT JOIN AttributeValue AV ON AV.CandidateID=C.GuidReference 
				LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
				LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
				WHERE CountryISO2A = 'TH' AND AV.CandidateID IS NOT NULL
				UNION ALL
					SELECT [CountryISO2A], Sequence AS [GroupId], A.[Key],  (
					CASE 
						WHEN A.[Type] = 'Date'
							THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
						WHEN A.[Type]='Enum'
							THEN ED.Value
						ELSE AV.Value
					END) Value
				FROM Country
				JOIN Collective C on C.CountryId=Country.CountryId
				LEFT JOIN AttributeValue AV ON AV.RespondentID=C.GuidReference
				LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
				LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
				WHERE CountryISO2A = 'TH' AND AV.RespondentID IS NOT NULL
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [Air_Con], [Baby], [BabyCarriage], [Bath], [BigCCardBabyRural], [BigCCardBabyUrban], [BigCCardRural], [BigCCardUrban], [Birds], [Booleantest], [Brand_code], [BreastPump], [Buywater], [CableTV], 
[Can_access_internet_(Y/N)], [Car_1], [Car_2], [Car_3], [Car_4], [Car_ownership], [CarSeat], [Cats], [cc_1], [cc_2], [cc_3], [cc_4], [Claimcode], [ClasseBabyRural], [ClasseBabyUrban], [Classecoffeemachine], [ClasseRural], [ClasseUrban], [ClubcardBabyRural], 
[ClubcardBabyUrban], [ClubcardRural], [ClubcardUrban], [Compl_Quarter], [Computer], [Credit_CardyesNo], [Date_Recruit], [Dateofclaim], [DishWash], [Dogs], [Dogs_breed], [Domestic_Trip], [DVD], [Email_address], [FecAlt], [FECHA_BAJA], [First_Baby], [Fishes], 
[FitnessSportclubSportcenteryesNo], [Fridge], [Grandwater], [Hab], [Hogaridth], [Home_Phone_(Yes/No)], [HomeOwnership], [Household_Size], [Housetype], [Income], [InsuranceyesNo], [Internethome], [Interv], [InvestmentyesNo], [Ipod/MP3/MP4], [Kid_<=_12], [Kid_<=_3]
, [Laptop], [LifestyleBabyRural], [LifestyleBabyUrban], [LifestyleRural], [LifestyleUrban], [Maid], [MakrocardyesNo], [Microwave], [Milk_Club], [Model], [model_firstcar1], [model_forthcar4], [model_secondcar2], [model_thirdcar3], [MYgivebaby], [Naturalwater], 
[nb_kids_under_7], [nb_women_between_13_and_50], [New_LSMBabyRural], [New_LSMBabyUrban], [New_LSMRural], [New_LSMUrban], [Notebook], [Number_of_Cars], [Number_of_Room], [Numberofbathroom], [Numberofbedroom], [NumberOfMotorcycle], [OtherCardBabyRural]
, [OtherCardBabyUrban], [OtherCardRural], [OtherCardUrban], [Oven], [Oversea_Trip], [Passenger_Car], [PC/Laptop_Internet_Access], [PC_Desktop/laptop], [Pick_up], [Pregnantwomen], [Satellite], [Smart_Phone_(Yes/No)], [SmartPurseCardBabyRural], 
[SmartPurseCardBabyUrban], [SmartPurseCardRural], [SmartPurseCardUrban], [SportRewardsCardBabyRural], [SportRewardsCardBabyUrban], [SportRewardsCardRural], [SportRewardsCardUrban], [Std], [Sterilizer], [SubSample], [TheMallCardBabyRural], [TheMallCardBabyUrban], 
[TheMallCardRural], [TheMallCardUrban], [Trim], [Truck], [TV], [Van], [WashMach], [Water_Source])) AS PivotTable