CREATE VIEW [dbo].FullGroupAttributesVN AS 

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
				WHERE CountryISO2A = 'VN'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [Address_1], [Air_Conditioner], [BABY_0_6], [BABY_13_24], [BABY_25_36], [BABY_7_12], [BABY_CODE], [BABY_CODE_BBP], [Back_up], [Bathroom], [Bicycle], [Black&white_TV], [BREAST], [CableDigitaltelevision], [Came
ra], [Camera_digital], [Cassette], [CD_Player], [Cellphone_number], [Code_reason_drop], [Colortvyesorno], [Date_become_newborn], [Desktop_PC], [Dish_Washer], [DOB_of_BABY], [DVD], [Electric_Bicycle], [Electric_Rice], [Fan], [Fax], [FM_12_50], [Fridge], [F
ridge_1_door], [Fridge_2_or_more_door], [FW_Number], [Gas_Stove], [Habitat_calculated], [Handphone], [Hhincomesc1yearly], [Hhincomesc2yearly], [Hifi], [Hot_Water], [House_Type], [Household_Income], [Household_size_calculated], [HP_3G], [INCOME GROUP], [In
come_Class], [INCOME_PER_CAPITA], [INCOME_PERCAPITA], [INCOME_PERCAPITA_BBP], [INCOME_PERCAPITA_NEW], [Internet], [Interviewer_Code], [Karaokemachineyesorno], [Kids_12_and_below_calculated], [Kids_3_and_below_calculated], [Laptop], [LCD_Plasma], [LS_2013]
, [LS_NEW], [LS_P&G], [LSMV2], [LSV2], [Maid], [Microwave_oven], [MP3MP4Ipodyesorno], [NESTLE], [Noofatmcard], [Noofcreditcard], [Noofdebitcard], [Noofmembercard], [Number_of_car], [Number_of_moto], [Numberofatmcard], [Numberofcreditcard], [Numberofdebitc
ard], [Numberofmembercard], [PDA], [Period_Recruited], [Period_Terminated], [Pet], [Radio_CD_Walkman], [Radio_transistor], [Running_Water], [Sample_Point], [Second_House], [Sound_system], [Standard], [Stereo_sys], [Tabletyesorno], [take_note], [Tel_Home_n
umber], [Telephone], [Tenure], [Total_Points], [TV], [Update], [Video], [Videocameradigitalyesorno], [Videocamerayesorno], [W_LIVE], [Washing_Machine], [Washing_Machine_Front_load], [Washing_Machine_Up_load], [Week_Recruited], [Week_Termination], [Year_Re
cruited], [Year_Terminated])) AS PivotTable