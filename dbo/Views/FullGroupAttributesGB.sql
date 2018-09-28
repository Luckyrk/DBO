CREATE VIEW [dbo].FullGroupAttributesGB AS 

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
				LEFT JOIN AttributeValue AV ON AV.CandidateID=C.GuidReference OR AV.RespondentID=C.GuidReference
				LEFT JOIN EnumDefinition ED ON ED.Id = AV.EnumDefinition_Id
				LEFT JOIN Attribute A WITH (NOLOCK) ON AV.DemographicId=A.GUIDReference
				WHERE CountryISO2A = 'GB'
) AS Source PIVOT (MAX([Value]) FOR [Key] IN ( [Cieage], [Ciecompany], [Ciename], [Clickerneedswiping], [Clickernotworking], [Company], [Companytype], [Currentoccupation], [Demographictest], [Desktopapp], [Detailsupdate], 
[Doyouagreetoreceiveshopandscantillreceiptreminderemails?], [Doyouwanttobepartoffol], [Explorerordesktopapp], [FireserviceOtherpulse], [Foodsonlinedayscompleted], [Foodsonlinedayspaid], [Foodsonlinehasbonusbeenpaid?], [Foodsonlinehhconsentedto2ndweek?], 
[Foodsonlinelatestinvitedate], [Foodsonlinetaskcompleted], [Forgottenyourlogindetails?], [Guytest1group], [H1], [H10], [H100], [H101], [H102], [H103], [H107], [H108], [H109], [H11], [H110], [H111], [H112], [H113], [H114], [H115], [H116], [H117], [H118], [H12], [H13], 
[H14], [H15], [H16], [H17], [H18], [H19], [H2], [H20], [H21], [H22], [H23], [H24], [H25], [H26], [H27], [H28], [H29], [H3], [H30], [H31], [H32], [H33], [H34], [H35], [H36], [H37], [H38], [H39], [H4], [H40], [H41], [H42], [H43], [H44], [H45], [H46], [H47], [H48], [H49], [H5], 
[H501], [H502], [H503], [H504], [H505], [H506], [H507], [H508], [H509], [H51], [H510], [H511], [H512], [H513], [H514], [H515], [H516], [H517], [H518], [H519], [H52], [H520], [H521], [H522], [H523], [H524], [H525], [H526], [H527], [H528], [H529], [H53], [H530], 
[H54], [H55], [H56], [H57], [H58], [H59], [H60], [H601], [H602], [H61], [H62], [H63], [H64], [H65], [H66], [H67], [H68], [H69], [H7], [H70], [H71], [H72], [H74], [H76], [H77], [H78], [H79], [H8], [H80], [H81], [H82], [H84], [H85], [H86], [H87], [H88], 
[H89], [H9], [H90], [H91], [H92], [H93], [H94], [H95], [H96], [H98], [H99], [Haroon10daycalltest], [Holidayemail], [Howtouninstalldesktopapp], [Https:WwwFotgCoUk], [Joiningshopandscan], [Lasttransmittedon], [Mainshoppername],
 [Missedyourremoteassistanceappointment], [NappiesorbabyfoodboughtButnobabyunder15months], [Noredscanningbeamonyourclicker?], [Notreceivedyourreplacementclickeryet?], [Occstatus], [Occupationpulse], [Optintoreceivedfolinvites], [PoliceOtherpulse], 
 [PrisonserviceOtherpulse], [RankOtherpulse], [Remoteassistance], [Replacementclickerhasbeendispatched], [Replacementclickerisonitsway], [SelfScansignupdate], [Sendingusblead], [Settinguprewardaccount], [Sign_Up_Date], [Sorrytohearyouareleaving], [Testdemog], [Testharoon],
  [Unemployedmorethan6months], [Weeklyreminder], [Yourremoteassistanceappointment])) AS PivotTable