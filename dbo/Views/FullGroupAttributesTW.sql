CREATE VIEW [dbo].[FullGroupAttributesTW] AS 
SELECT * FROM (	SELECT [CountryISO2A], Sequence AS [GroupId], A.[Key], (
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
				WHERE CountryISO2A = 'TW'
				UNION
				SELECT [CountryISO2A], Sequence AS [GroupId], A.[Key], (
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
				WHERE CountryISO2A = 'TW'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [1stpriorityofPurchaseLocation], [2ndpriorityofPurchaseLocation], [Bathroomstructure], [Blender], [Broadband_MOD], [CableTV], [Car], [Carrefourmembershipcard], [CoffeeMaker], [Cosmedmembershipcard], [Costcomembershipcard], [Demographiccorrectionmethod], [Diaperofferbyhospital-HUGGIES], [Diaperofferbyhospital-I-CHI-BAN], [Diaperofferbyhospital-KIMBIES], [Diaperofferbyhospital-KNH_Carnation], [Diaperofferbyhospital-MAMYPOKO], [Diaperofferbyhospital-MERRIES], [DiaperofferbyhospitalNONE], [Diaperofferbyhospital-Others], [Diaperofferbyhospital-Pampers], [Diaperofferbyhospital-PROKIDS], [Diaperofferbyhospital-SEALER], [Diaperofferbyhospital-Unknown], [Diapertrialbyhospital-HUGGIES], [Diapertrialbyhospital-I-CHI-BAN], [Diapertrialbyhospital-KIMBIES], [Diapertrialbyhospital-KNH_Carnation], [Diapertrialbyhospital-MAMYPOKO], [Diapertrialbyhospital-MERRIES], [DiapertrialbyhospitalNONE], [Diapertrialbyhospital-Others], [Diapertrialbyhospital-Pampers], [Diapertrialbyhospital-PROKIDS], [Diapertrialbyhospital-SEALER], [Diapertrialbyhospital-Unknown], [DigitalSingleLensReflex Camera], [Directsellingmember], [Dishdryer], [Dishwasher], [Dogs], [Familymonthlyincome], [FemalecountBetween13and50], [GRANTmembershipcard], [Hi-Fiequipment], [HomeTheaterAmplifier], [Householdsize], [Householdsize_New], [Houseownership], [Howmanybigdog], [Howmanyminidog], [Howmanysmalldog], [Hugeheavymotorbikes], [IndividualPanelHouseholdSize], [Infantformulaofferedathospital], [Infantformulaofferedatpostpartumservice], [InfantformularSamplerofferedathospital], [InfantformularSamplerofferedatPostpartumservice], [Interviewlocation], [Introducer], [Kidcount-ageSmallerThan14_Baby_panel], [Kidcount-ageSmallerThan14_Male_panel], [Kidcount-ageSmallerThan14_World_panel], [Kidcount-ageSmallerThan18_Lady_Panel], [Kidcount-ageSmallerThan7_Baby_Panel], [Kidcount-ageSmallerThan7_World_Panel], [Kidcount-ageSmallerThank18_Male_Panel], [Kidsmallerthan7count], [Kidssmallerthan14count], [LaptopPC], [LCDscreenTV], [Lifestage_BP], [Lifestage_LP], [Lifestage_MP], [Lifestage_WP], [Lifestagenew], [Lifestagenextyear], [Lifestagetesting], [LP_Ifmemberssagebetween0and9], [LP_Ifmemberssagebetween10and19], [LP_Ifmemberssagebetween35and44], [LP_Ifmemberssagebetween45and999], [MaidInhouse], [Matsuseisupermarketmembershipcard], [Membersagebetween45and54], [Membersagebetween55and65], [Membersagemorethan65], [memberssagebetween0and4], [memberssagebetween10and14], [memberssagebetween15and19], [memberssagebetween20and34], [memberssagebetween35and44], [memberssagebetween5and9], [memberssageGreaterThan45], [Microwave], [motorcycle], [MPRecruitmethod], [New_2ndInterviewdate], [New_2ndInterviewmethod], [NooffemalewhoseageBetween12and19], [NooffemalewhoseageBetween20and29], [NooffemalewhoseageBetween30and39], [NooffemalewhoseageBetween40and49], [Not in use - Houseownership], [NotInUserFemalecountBetween13and50], [NPANbeforerelocation], [Numberofmotorcycles], [OldDistrictcode], [Onlinedate], [Oven], [PC], [PC_Outside], [Petcat], [Pet-medium_largedog], [Pet-smalldog], [Placeofpurchase-babydiapersHousehold], [Placeofpurchase-infantformula_Household], [PlasmaTV], [Printer], [Projector], [PXCenterE-invoicesystem], [PXCentermembershipcard], [Reason-dropout], [RecruiterID], [Recruitmethod], [Refrigerator], [RTmembershipcard], [satellitedishreceiver_communitylan], [SV], [TabletComputer], [TSChypermarketmembershipcard], [TV], [VCR_VCD_DVDVideo], [Villagecode], [Washingmachine], [Watsonsmembershipcard], [Wellcomesupermarketmembershipcard], [WPPet-Dogs-count], [Wpweekbb], [Wpyearbb],[Equipmentforonlineshopping],[OnlineshoppingDesktop],[OnlineshoppingLaptop],[OnlineshoppingTabletIpad],[OnlineshoppingOthers])) AS PivotTable
GO

-- For alter it is not reqd.
EXEC sys.sp_addextendedproperty @name=N'Description', @value=NULL , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullGroupAttributesTW'
GO