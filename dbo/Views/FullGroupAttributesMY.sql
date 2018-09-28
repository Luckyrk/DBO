CREATE VIEW [dbo].FullGroupAttributesMY AS 

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
				WHERE CountryISO2A = 'MY'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [Air_Cond_number_of_units], [Baby_Age_In_Week], [Baby_Car_Seat], [Baby_Hight_Chair], [Baby_Stroller], [Baby_thermometer], [Bathroom], [Bottle_Sterilizer], [Breast_Pump], [Broadband_Subscription], 
[CD], [Claim_Justification], [Comment], [Computer], [CRT_TV], [Date_Expecting], [Digital_Camera], [DM_No], [DVD], [DVD_Video], [Email_Address], [Festive_Card_Type], [Food_Processor], [Fridge], [Hifi], [Hours_Internet_(Average/Day)], [House_Type],
 [Household_Monthly_Income], [Household_Size], [Internet], [Interviewer], [Juicer], [Justification], [Kids_12_and_below], [Kids_14_and_below], [Kids_18_and_below], [Kids_3_and_below], [Kids_4_and_below], [Language_Delivery], [LCD_TV], [LifeStages], [LSM], 
 [Microwave], [Milk_Bottle_Warmer], [Month_of_birth_for_expecting_new_baby], [Music_CD], [Music_Hifi], [Music_Radio], [Newborn_Tracking_Case_#], [No_Of_Cars], [No_Of_Motorbikes], [Pan_Identity(I/C)], [Pay_TV_Subscription], [Period_Terminated], [Plasma_TV], [Points_balance],
  [Race_Household], [Region_Race], [Region_Race_Demog], [Regiondemog], [Sample_Point], [SEC], [Send_baby_to_babysitter], [Standard], [State_Code_Home_Demog], [Strata], [Tenure], [Termination_Reason], [Total_Credit_Card_holder], [Total_Loyalty_Card_Holder], 
  [Total_Pet_Ownership], [TV], [Video], [Video_Camcorder], [Washing_Machine], [With_Maid], [Year_of_birth_for_expecting_new_baby], [Year_Terminated])) AS PivotTable