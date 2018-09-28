CREATE VIEW [dbo].[ExtraccionGenerica_ES]
AS
SELECT pan.gid
	,Metod_Calc AS metod
	,t.KeyName AS Frec
	,c.DATE AS fecprox
	,PersonalIdentification.DateOfBirth AS DateOfBirth
	,Rol_Calc AS rol
	,Telecom.TELEF
	,Telecom.TELEF_STATE
	,StateDefinition.Code AS [STATUS]
	,STATUSDATES.StateChangeDate AS [STATUS_DATE]
	,isnull(PersonalIdentification.FirstOrderedName, '') + ' ' + ISNULL(PersonalIdentification.MiddleOrderedName, '') + ' ' + isnull(PersonalIdentification.LastOrderedName, '') AS Nom
	,TelephoneContacts.tel1 AS ntel
	,TelephoneContacts.tel2 AS ntel2
	,Email_consult AS CORREO
	,FuenteCaptacion AS ENTREV
	,Email_desc AS CORREODESC
	,ic.Comment AS obser
	,EmailJoin.EmailAddress AS Email
	,TIPO_3D_Calc AS TIPO_3D_Calc
	,IncentiveBalances.Amount AS SALDO
	,Convert(VARCHAR(11), dbo.Candidate.EnrollmentDate, 103) AS FECCAP
	--,Alta_Web AS Alta_Web  
	,Recompt AS RECOMENDADORA
	,Motivobaja AS MBA
	,ColaboracionOOH AS TIPO_SMART
	,FrecuenciaUso_internet AS INTERNET
	,DIR.Dir1
	,DIR.Dir2
	,DIR.Dir3
	,DIR.CPOSTAL
	,HAB.Habitat16 AS HABMUN
	,HAB.Region AS REG
	,HAB.PROV
	,HAB.MUNI
	,RECIBEEMAIL
	--,TT.TELEF  
	,AltaWebCom
	,AltaWebMD
	,AltaWeb
	,[EnumValue] AS [CONEXION]
	,SEX.Code AS Sex
	,TAM.NF
	,CASE 
		WHEN EX.gid IS NULL
			THEN '1'
		ELSE '2'
		END AS VACASI
FROM (
	SELECT panelmember_id AS panelmember_id
		,max(CollaborationMethodology_Id) AS CollaborationMethodology_Id
		,max(state_id) AS state_id
	FROM Panelist
	WHERE Country_Id = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
	GROUP BY panelmember_id
	) Panelist
INNER JOIN candidate ON candidate.GUIDReference = panelist.PanelMember_Id
INNER JOIN dbo.StateDefinition ON Panelist.State_Id = dbo.StateDefinition.Id
INNER JOIN (
	SELECT Individual.GUIDReference
		,Individual.IndividualId PanelMemberID
		,c.sequence AS gid
		,Individual.PersonalIdentificationId
		,Individual.Event_ID
		,Individual.IndividualID
		,Individual.Sex_Id
	FROM CollectiveMembership cm
	INNER JOIN individual ON cm.individual_id = individual.GUIDReference
	INNER JOIN collective c ON c.guidreference = cm.Group_Id
		AND c.GroupContact_Id = individual.guidreference
	WHERE cm.Country_Id = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
	
	UNION
	
	SELECT C.GUIDReference
		,Individual.IndividualId PanelMemberID
		,c.sequence AS gid
		,Individual.PersonalIdentificationId
		,Individual.Event_ID
		,Individual.IndividualID
		,Individual.Sex_Id
	FROM CollectiveMembership cm
	INNER JOIN individual ON cm.individual_id = individual.GUIDReference
	INNER JOIN collective c ON c.guidreference = cm.Group_Id
		AND c.GroupContact_Id = individual.guidreference
	WHERE cm.Country_Id = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
	) AS PAN ON Panelist.PanelMember_Id = PAN.GUIDReference
--LEFT JOIN Individual ON panelist.PanelMember_Id = individual.GUIDReference  
INNER JOIN IndividualSex SEX ON Sex.GUIDReference = pan.Sex_Id
INNER JOIN dbo.PersonalIdentification ON PAN.PersonalIdentificationId = dbo.PersonalIdentification.PersonalIdentificationId
LEFT JOIN (
	SELECT Individual_id
		,comment
	FROM IndividualComment ico
	WHERE id = (
			SELECT TOP 1 ici.Id
			FROM IndividualComment ici
			WHERE ici.Individual_Id = ico.Individual_Id
			--AND comment <> ''  
			ORDER BY ici.GPSUpdatetimestamp DESC
			)
	) ic ON ic.Individual_Id = PAN.GUIDReference
LEFT JOIN dbo.CollaborationMethodology ON dbo.CollaborationMethodology.GUIDReference = Panelist.CollaborationMethodology_Id
LEFT JOIN dbo.CalendarEvent c ON PAN.Event_ID = c.ID
LEFT JOIN dbo.EventFrequency e ON c.Frequency_Id = e.GUIDReference
LEFT JOIN dbo.Translation t ON e.Translation_Id = t.TranslationId
LEFT JOIN (
	SELECT PanelMember_Id
		,max(sdh.creationdate) AS StateChangeDate
	FROM StateDefinitionHistory sdh
	INNER JOIN panelist p ON sdh.Panelist_Id = p.GUIDReference
		AND sdh.Country_Id = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
	INNER JOIN dbo.StateDefinition LIVESTATE ON sdh.To_Id = LIVESTATE.id
	GROUP BY PanelMember_Id
	) AS STATUSDATES ON STATUSDATES.PanelMember_Id = PANELIST.panelmember_id
LEFT JOIN (
	SELECT IncentiveAccountId
		,ISNULL(sum(CASE IAT.[Type]
					WHEN 'Debit'
						THEN (- 1 * (Abs(ISNULL(Ammount, 0))))
					ELSE ISNULL(info.Ammount, 0)
					END), 0) AS Amount
	FROM IncentiveAccount ia
	INNER JOIN IncentiveAccountTransaction AS iat ON iat.Account_Id = ia.IncentiveAccountId
		AND ia.Country_Id = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
		AND iat.Country_Id = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
	LEFT JOIN IncentiveAccountTransactionInfo Info ON IAT.TransactionInfo_Id = Info.IncentiveAccountTransactionInfoId
	GROUP BY IncentiveAccountId
	) IncentiveBalances ON IncentiveBalances.IncentiveAccountId = PAN.GUIDReference
LEFT JOIN (
	SELECT Candidate_Id
		,MIN(CASE 
				WHEN OrderedContactMechanism.[Order] = 1
					THEN [AddressLine1]
				ELSE NULL
				END) AS tel1
		,MIN(CASE 
				WHEN OrderedContactMechanism.[Order] = 2
					THEN [AddressLine1]
				ELSE NULL
				END) AS tel2
	FROM dbo.AddressType
	INNER JOIN ADDRESS ON dbo.AddressType.Id = dbo.Address.Type_Id
		AND [DiscriminatorType] = 'PhoneAddressType'
		AND address.Country_Id = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
	INNER JOIN dbo.OrderedContactMechanism ON dbo.OrderedContactMechanism.Address_Id = dbo.Address.GUIDReference
		AND OrderedContactMechanism.[Order] IN (
			1
			,2
			)
	GROUP BY Candidate_Id
	) TelephoneContacts ON TelephoneContacts.Candidate_Id = PAN.GUIDReference
LEFT JOIN (
	SELECT IndividualId
		,[Email_consult]
		,[Email]
		,[Motivobaja]
		,[Rol_Calc]
		,[Email_desc]
		,[ColaboracionOOH]
		,[TELEF]
		,[RECIBEEMAIL]
		,[AltaWebMD]
		,[AltaWebCom]
		,[AltaWeb]
	FROM (
		SELECT IndividualId AS IndividualId
			,[key]
			,(
				CASE 
					WHEN i.[Type] = 'Enum'
						THEN ed.Value
					ELSE i.Value
					END
				) AS Value
		FROM [dbo].IXV_Individual_ATTRIBUTE_AsRows(NOEXPAND) i
		LEFT JOIN EnumDefinition ed ON ed.Id = i.EnumDefinition_Id
		WHERE CountryISO2A = 'ES'
			AND [Key] IN (
				'Email_consult'
				,'Email'
				,'Motivobaja'
				,'Rol_Calc'
				,'Email_desc'
				,'ColaboracionOOH'
				,'TELEF'
				,'RECIBEEMAIL'
				,'AltaWebMD'
				,'AltaWebCom'
				,'AltaWeb'
				)
		) Indattrdata
	pivot(max(value) FOR [key] IN (
				[Email_consult]
				,[Email]
				,[Motivobaja]
				,[Rol_Calc]
				,[Email_desc]
				,[ColaboracionOOH]
				,[TELEF]
				,[RECIBEEMAIL]
				,[AltaWebMD]
				,[AltaWebCom]
				,[AltaWeb]
				)) AS IndKeys
	) IndividualAttributes ON IndividualAttributes.IndividualId = Pan.PanelMemberID
LEFT JOIN (
	SELECT GroupID
		,[FrecuenciaUso_internet]
		,[Recompt]
		,[Metod_Calc]
		--,[Alta_Web]  
		,[Tipo_3D_Calc]
		,[FuenteCaptacion]
	FROM (
		SELECT CONVERT(VARCHAR, Sequence) AS GroupID
			,[key]
			,(
				CASE 
					WHEN it.[Type] = 'Enum'
						THEN eddef.Value
					ELSE it.VALUE
					END
				) AS Value
		FROM [dbo].[IX_FullGroupAttributeAsRows](NOEXPAND) it
		LEFT JOIN EnumDefinition eddef ON eddef.Id = it.EnumDefinition_Id
		WHERE CountryISO2A = 'ES'
			AND [Key] IN (
				'FrecuenciaUso_internet'
				,'Recompt'
				,'Metod_Calc'
				--,'Alta_Web'  
				,'Tipo_3D_Calc'
				,'FuenteCaptacion'
				)
		) groupattrdata
	pivot(max(value) FOR [key] IN (
				[FrecuenciaUso_internet]
				,[Recompt]
				,[Metod_Calc]
				--,[Alta_Web]  
				,[FuenteCaptacion]
				,[Tipo_3D_Calc]
				)) AS GroupKeys
	) GAR ON CAST(GAR.GroupID AS INT) = CAST(PAN.gid AS INT)
LEFT JOIN FullIndividualBelongings ON FullIndividualBelongings.IndividualId = PAN.PanelMemberID
	AND CountryISO2A = 'ES'
	AND BelongingName = 'movil'
	AND AttributeType = 'Connection type'
LEFT JOIN (
	SELECT DISTINCT LEFT(IndividualID, 6) AS gid
		,[AddressLine1] AS DIR1
		,[AddressLine2] AS DIR2
		,[AddressLine3] AS DIR3
		,PostCode AS CPOSTAL
	FROM [dbo].[FullIndividualAddressEmailPhone]
	WHERE [CountryISO2A] = 'ES'
		AND [DiscriminatorType] = 'PostalAddressType'
		AND [ORDER] = 1
		AND RIGHT(IndividualId, 2) = '00'
	) DIR ON CAST(DIR.gid AS INT) = CAST(pan.gid AS INT)
LEFT JOIN (
	SELECT DISTINCT LEFT(IndividualId, 6) AS gid
		,[AddressLine1] AS EmailAddress
	FROM [dbo].[FullIndividualAddressEmailPhone]
	WHERE [CountryISO2A] = 'ES'
		AND [DiscriminatorType] = 'ElectronicAddressType'
		AND [ORDER] = 1
		AND RIGHT(IndividualId, 2) = '00'
	) EmailJoin ON EmailJoin.gid = pan.gid
LEFT JOIN (
	SELECT DISTINCT LEFT(IndividualId, 6) AS gid
	FROM [dbo].[FullExclusions]
	WHERE GETDATE() BETWEEN Range_From
			AND Range_To
		AND CountryISO2A = 'ES'
	) EX ON EX.gid = pan.gid
LEFT JOIN (
	SELECT Sequence AS gid
		,FGA.Region
		,fga.Habitat16
		,FGA.Municipio AS MUNI
		,FGA.Provincia AS PROV
	FROM dbo.Collective
	INNER JOIN dbo.Candidate can ON dbo.Collective.GUIDReference = can.GUIDReference
	INNER JOIN dbo.GeographicArea geo ON geo.GUIDReference = can.GeographicArea_Id
	INNER JOIN [dbo].[FullGeographicAreaAttributesES] FGA ON geo.Code = FGA.code
	WHERE Collective.CountryId = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'
		AND FGA.CountryISO2A = 'ES'
	) HAB ON HAB.gid = pan.gid
LEFT JOIN (
	SELECT [GroupId]
		,COUNT(*) AS NF
	FROM [dbo].[FullGroupMembership]
	WHERE [State] = 'GroupMembershipResident'
		AND CountryISO2A = 'ES'
	GROUP BY GroupId
	) TAM ON TAM.GroupId = pan.gid
LEFT JOIN (
	SELECT [PanelMemberID]
		,CollabCode AS TELEF
		,StateCode AS TELEF_STATE
	FROM [dbo].[FullPanellistSet]
	WHERE CountryISO2A = 'ES'
		AND PanelCode = 3
	) Telecom ON Telecom.[PanelMemberID] = PAN.IndividualID
WHERE StateDefinition.Code IN (
		'PanelistLiveState'
		,'PanelistPreLiveState'
		,'PanelistSelectedState'
		)
	OR (
		StateDefinition.Code IN (
			'PanelistDroppedOffState'
			,'PanelistRefusalState'
			)
		AND DATEPART(Year, STATUSDATES.StateChangeDate) >= DATEPART(Year, GETDATE()) - 1
		)
GO

