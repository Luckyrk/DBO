CREATE VIEW [dbo].FullIndividualAttributesTW AS 

SELECT *

FROM (	SELECT [CountryISO2A], [IndividualId], A.[Key], (
					CASE 
						WHEN A.[Type] = 'Date'
							THEN FORMAT(TRY_PARSE(AV.Value AS DATETIME USING 'en-US'), 'yyyy-MM-dd hh:mm:ss')
						WHEN A.[Type]='Enum'
							THEN ED.Value
						ELSE AV.Value
					END) Value
		FROM Country
		JOIN Individual C on C.CountryId=Country.CountryId
		LEFT JOIN AttributeValue AV ON AV.CandidateID=C.GuidReference OR AV.RespondentID=C.GuidReference
		LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id	
		LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
		WHERE CountryISO2A = 'TW'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [Acnerelatedproduct], [Babyweekold], [Babyweekoldplus12], [Babyweekoldplus16], [Babyweekoldplus20], [Babyweekoldplus8], [Babyweekplust4], [BB_MomIndividualid], [BB_MomStayinpostpartumservice], [BB_Mothereduca
tionlevel], [BB_Mothernationality], [BMI], [Bodywash], [BugfacialNeckmask], [BugfacialneckmaskEnum], [Buyacnerelatedproduct], [Buybodycareproduct], [BuybodycareproductEnum], [Buybodywash], [Buychewinggum], [BuychewinggumEnum], [Buycoughdrop], [Buycoughdro
pEnum], [Buydeodorant], [BuydeodorantEnum], [Buyeyescareproduct], [BuyeyescareproductEnum], [Buyfacialcare], [Buyfacialcleansereyecleanser], [BuyfreshmilkFlavoredmilk], [BuyfreshmilkflavoredmilkEnum], [Buyhaircoloringproducts], [BuyhaircoloringproductsEnu
m], [Buyhairconditioners], [BuyhairconditionersEnum], [Buyhairstyleproducts], [BuyhairstyleproductsEnum], [Buyhealthfood], [BuyhealthfoodEnum], [Buyinstantcoffee], [BuyinstantcoffeeEnum], [Buyinstanttea], [BuyinstantteaEnum], [Buylipsmakeup], [Buylipsmake
upEnum], [Buyothercandy], [BuyothercandyEnum], [Buyperfume], [BuyperfumeEnum], [Buyshampoo], [BuyshampooEnum], [Buysoap], [Buysoftdrink], [BuysoftdrinkEnum], [Buyspeednuddle], [BuyspeednuddleEnum], [Buysportsdrink], [BuysportsdrinkEnum], [Buysuncrime], [B
uytoner], [BuytonerEnum], [Buytreatmentproducts], [BuytreatmentproductsEnum], [Buyyoghourt], [BuyyoghourtEnum], [Collaboratewithpanelfornextquarter], [Datacollectmethod], [Educationallevel], [EmailCashID], [EmployedStatus], [Equipmentforonlineshopping], [
FacialcleanserEyecleanser], [FaciallotionEssence], [FB], [Fbaccount], [Fbmatch], [Femalesuperbuyer], [FirstchildofMom], [FreshFoodMainShopper], [Gender], [Giftcatalog], [GSS], [GSSQ1], [GSSQ2], [GSSQ3], [GSSQ4], [GSSQ5], [GSSQ6], [GSSQ7], [GSSQ8], [HavePe
rsonalmotorcycle], [HaveSmartphone], [Havingparttimejob], [Height], [Individualpanelmsage], [Internetsurfingequipmentdesktop], [InternetsurfingequipmentLaptop], [InternetsurfingequipmentlaptopEnum], [InternetsurfingequipmentOthers1], [Internetsurfingequip
mentPCMac], [InternetsurfingequipmentSmartphone], [InternetsurfingequipmentsmartphoneEnum], [InternetsurfingequipmentTabletIpad], [InternetsurfingequipmenttabletipadEnum], [Interviewdate], [LPIsMainshopperofHHcommodities], [Lpweekbb], [Lpyearbb], [Mainsho
ppersageplusone], [MaritalStatus], [MPIsMainshopperofPersonalLivingCommodities], [New_QBOnlinePwd], [Occupationalcode], [Onlinediarysinceyyyypp], [Onlineexam], [OnlineshoppingDesktop], [OnlineshoppingLaptop], [OnlineshoppingOthers], [OnlineshoppingTabletI
pad], [Outide_UseEmailFrequency], [Personalmonthlyincome], [PersonalSmartphone_OS], [PersonalSurfInternetusually], [PlaceforsurfingInternet], [Placeofpurchase-babydiapers_Individual], [Placeofpurchase-infantformula_Individual], [Privacy], [Purchasefrequen
cyBodywash], [PurchasefrequencyChewinggum], [PurchasefrequencyChickenessenceBirdsnest], [PurchasefrequencyChocolate], [PurchasefrequencyCoughdrop], [PurchasefrequencyFacialcleanserEyecleanser], [PurchasefrequencyFreshmilkFlavoredmilk], [PurchasefrequencyH
ealthfood], [PurchasefrequencyInstantcoffee], [PurchasefrequencyInstanthealthdrink], [PurchasefrequencyInstanttea], [PurchasefrequencyOthercandy], [PurchasefrequencySoap], [PurchasefrequencySoftdrink], [PurchasefrequencySoyRicemilk], [PurchasefrequencySpe
ednuddle], [PurchasefrequencySportsdrink], [PurchasefrequencySupplement], [PurchasefrequencyYoghourt], [Purchaseplace-Bodycare_Bodylotion], [Purchaseplace-Cologne_Perfume], [Purchaseplace-Eyecream], [Purchaseplace-Facialcleanser_eyecleanser], [Purchasepla
ce-Faciallotion_Essence], [Purchaseplace-Facialmask], [Purchaseplace-Sunscreen_faketanlotion], [Purchaseplace-Toninglotion], [QBdiaryuaccount], [QBOnlineuid], [Relation], [Smssending], [Soap], [Sswnpan], [Suncrime], [SurfingplaceDesktophome], [Surfingplac
edesktophomeEnum], [SurfingplaceDesktopoffice], [SurfingplacedesktopofficeEnum], [SurfingplaceDesktopotherplaces], [SurfingplacedesktopotherplacesEnum], [SurfingplaceLaptophome], [SurfingplacelaptophomeEnum], [SurfingplaceLaptopoffice], [Surfingplacelapto
pofficeEnum], [SurfingplaceLaptopotherplaces], [SurfingplacelaptopotherplacesEnum], [SurfingplaceOtherequipmenthome], [SurfingplaceotherequipmenthomeEnum], [SurfingplaceOtherequipmentoffice], [SurfingplaceotherequipmentofficeEnum], [SurfingplaceOtherequip
mentotherplaces], [SurfingplaceotherequipmentotherplacesEnum], [SurfingplaceSmartphoneHome], [SurfingplacesmartphonehomeEnum], [SurfingplaceSmartphoneoffice], [SurfingplacesmartphoneofficeEnum], [SurfingplaceSmartphoneotherplaces], [Surfingplacesmartphone
otherplacesEnum], [SurfingplaceTablethome], [SurfingplacetablethomeEnum], [SurfingplaceTabletoffice], [SurfingplacetabletofficeEnum], [SurfingplaceTabletotherplaces], [SurfingplacetabletotherplacesEnum], [TypeofInhabitancy], [Usagefrequency-Bodycare_Bodyl
otion], [Usagefrequency-Cologne_perfume], [Usagefrequency-Eyecream], [Usagefrequency-Facialcleanser_eyecleanser], [Usagefrequency-Faciallotion_Essence], [Usagefrequency-Facialmask], [Usagefrequency-Sunscreen_faketanlotion], [Usagefrequency-Toninglotion], 
[Usebodycare_bodylotion], [Usecologne_perfume], [Useeyecare_eyecream], [Usefacial_eyecleanser], [Usefaciallotion_Essence], [Usefacialmask], [Usesmartphone], [Usesmartphoneenum], [Usesunscreen_faketanlotion], [Usetoninglotion], [Weekbb], [WeekofBabyDuedate
_Birthday], [Weight], [WpSuperwomen], [Yearbb])) AS PivotTable