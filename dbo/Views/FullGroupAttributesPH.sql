CREATE VIEW [dbo].FullGroupAttributesPH AS 

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
				WHERE CountryISO2A = 'PH'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [Address_1], [Address_2], [Address_3], [Address_4], [Air_Conditioner], [Babies_Age_In_Months], [Barangay_Code], [Bathroom], [Cable_TV_Subscription_(Average/Month)], [Cassette], [CD_Player], 
[Cellphone_number_1], [Cellphone_number_2], [Comment], [Compo/Hifi], [Construction_Material], [Credit_Cards_Owned], [Desktop_PC], [Digital_Camera], [Dish_Washer], [Electric_Stove], [Electricity_Consumption_(Average/Month)], [EOPTYPE], [Field_Interviewer_Code], 
[Floor_Polisher], [Freezer], [Fridge_1_door], [Fridge_2_or_more_door], [Gas_Stove], [Habitat_calculated], [Handheld_Vid_Games], [House_Type], [Household_Size_calculated], [Installed_Water_Heater], [Internet_Subscription_(Average/Month)], [Ipod/MP3_4], [Karaoke], 
[Kids_12_and_below_calculated], [Kids_6_and_below_calculated], [Laptop], [LCD/Plasma], [LIFESTAGE], [LSM_Code], [Microwave_oven], [Monthly_Income], [NSEC_Code], [Panelist_Name], [Period_Recruited], [Period_Terminated], [Postpaid_Mobile_number_of_units], 
[Prepaid_Mobile_number_of_units], [Printer], [Property], [Range_with_oven], [Reason_for_Termination], [Running_Water], [Sample_Point], [Socio_Eco_Class], [Standard], [State_of_Repair], [Telephone_number], [Telephone_Subscription_(Average/Month)], [Total_OFW], 
[Total_Points], [TV], [Vacuum_Cleaner], [Video], [Video_Camera], [Video_Console_(eg_PS2_xbox_wii)], [Videoke_Microphone], [Washing_Machine_with_Spin_Dryer], [Washing_Machine_without_Spin_Dryer], [Water_Dispenser_(Hot/Cold)], [Week_expected_HH], 
[Week_Recruited], [Working_Status_calculated], [Year_expected_HH], [Year_of_birth_calculated], [Year_Recruited], [Year_Terminated])) AS PivotTable