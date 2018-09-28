

CREATE VIEW [dbo].[FullContactInfo]
AS
SELECT CN.CountryISO2A
	,MS.IndividualId AS MainShopperId
	,C.Sequence AS GroupId
	,PID.FirstOrderedName AS MainContactName
	,P.PanelCode
	,P.NAME AS PanelName
	,CMD.Code AS CollaborationMethodology
	,SD.Code AS PanellistState
	,PhonePostalAddress.HomePhone
	,PhonePostalAddress.WorkPhone
	,PhonePostalAddress.MobilePhone
	,PhonePostalAddress.PersonalEmailAddress AS EmailAddress
	,PhonePostalAddress.HomeAddress
	,PhonePostalAddress.PostalAddress
	,(
		SELECT TOP 1 Comment
		FROM IndividualComment
		WHERE Individual_Id = MS.GUIDReference
		ORDER BY GPSUpdateTimestamp DESC
		) AS Comment
FROM Panelist PL
INNER JOIN Panel P ON PL.Panel_Id = P.GUIDReference
	AND pl.Country_Id = p.Country_Id
INNER JOIN DynamicRole DRMS ON DRMS.Code = 2
	AND DRMS.Country_Id = PL.Country_Id
INNER JOIN DynamicRoleAssignment DRAMS ON DRAMS.Panelist_Id = PL.GUIDReference
	AND DRAMS.DynamicRole_Id = DRMS.DynamicRoleId
INNER JOIN DynamicRole DRMC ON DRMC.Code = 3
	AND DRMC.Country_Id = PL.Country_Id
LEFT JOIN DynamicRoleAssignment DRAMC ON DRAMC.Panelist_Id = PL.GUIDReference
	AND DRAMC.DynamicRole_Id = DRMC.DynamicRoleId
INNER JOIN Individual MS ON DRAMS.Candidate_Id = MS.GUIDReference
LEFT JOIN Individual MC ON DRAMC.Candidate_Id = MC.GUIDReference
LEFT JOIN (
	SELECT max(iif(tr1.KeyName = 'HomePhoneType', adr.addressline1, NULL)) AS HomePhone
		,max(iif(tr1.KeyName = 'WorkPhoneType', adr.addressline1, NULL)) AS WorkPhone
		,max(iif(tr1.KeyName = 'MobilePhoneType', adr.addressline1, NULL)) AS MobilePhone
		,max(iif(tr1.KeyName = 'PersonalEmailAddressType', adr.addressline1, NULL)) AS PersonalEmailAddress
		,max(iif(tr1.KeyName = 'HomeAddressType', ISNULL(adr.addressline1, '') + ', ' + ISNULL(adr.addressline2, '') + ', ' + ISNULL(adr.addressline3, '') + ', ' + ISNULL(adr.addressline4, '') + ', ' + ISNULL(adr.postcode, ''), NULL)) AS HomeAddress
		,max(iif(tr1.KeyName = 'PostalAddressType', ISNULL(adr.addressline1, '') + ', ' + ISNULL(adr.addressline2, '') + ', ' + ISNULL(adr.addressline3, '') + ', ' + ISNULL(adr.addressline4, '') + ', ' + ISNULL(adr.postcode, ''), NULL)) AS PostalAddress
		,ord.Candidate_Id
	FROM dbo.OrderedContactMechanism ord
	INNER JOIN dbo.Address adr ON adr.GUIDReference = ord.Address_Id
	INNER JOIN dbo.AddressType aty ON aty.Id = adr.Type_Id
	INNER JOIN dbo.Translation tr1 ON tr1.TranslationId = aty.Description_Id
	WHERE tr1.KeyName IN (
			'HomePhoneType'
			,'WorkPhoneType'
			,'MobilePhoneType'
			,'PersonalEmailAddressType'
			,'HomeAddressType'
			,'PostalAddressType'
			)
	GROUP BY Candidate_Id
	) AS PhonePostalAddress ON PhonePostalAddress.Candidate_Id = MS.GUIDReference
INNER JOIN CollectiveMembership CM ON CM.Individual_Id = MS.GUIDReference
INNER JOIN Collective C ON CM.Group_Id = C.GUIDReference
INNER JOIN Country CN ON CN.CountryId = PL.Country_Id
INNER JOIN PersonalIdentification PID ON MS.PersonalIdentificationId = PID.PersonalIdentificationId
LEFT JOIN CollaborationMethodology CMD ON PL.CollaborationMethodology_Id = CMD.GUIDReference
LEFT JOIN StateDefinition SD ON PL.State_Id = SD.Id