

CREATE VIEW [dbo].[QBAuditFullIGroups]
AS

SELECT DISTINCT can.GUIDReference
	,dbo.Country.CountryISO2A
	,coll.Sequence GroupId
	,can.Comments
	,(
		SELECT TOP 1 kit.NAME
		FROM dbo.Panelist pst
		LEFT JOIN dbo.StockKit kit ON pst.ExpectedKit_Id = Kit.GUIDReference
		LEFT JOIN dbo.Panel pan ON pan.GUIDReference = pst.Panel_Id
		WHERE pst.PanelMember_Id = can.GUIDReference
		ORDER BY pan.Panels_Order
		) KitType
	,ind.IndividualId AS GroupContact
	,Roles.HeadOfHousehold
	,Roles.MainShopper
	,Roles.ChiefIncomeEarner
	,Roles.MainContact
	,geo.Code GeographicAreaCode
	,coll.GPSUser
	,coll.CreationTimeStamp
	,coll.GPSUpdateTimestamp
	,coll.AuditOperation
	,max(sdh.CreationDate) AS TerminatedDate
	,max(sdhduplicate.CreationDate) AS DuplicatedDate
FROM [GPS_PM_FRA_Audit].[audit].[Collective] coll
INNER JOIN dbo.Candidate can ON coll.GUIDReference = can.GUIDReference
LEFT JOIN statedefinition sd ON sd.id = can.candidatestatus
	AND sd.Code IN (
		'GroupTerminated'
		,'GroupDuplicate'
		)
LEFT JOIN statedefinitionhistory sdh ON sdh.To_Id = sd.id
	AND sdh.candidate_id = can.guidreference
	AND sd.code = 'GroupTerminated'
LEFT JOIN statedefinitionhistory sdhduplicate ON sdhduplicate.to_id = sd.id
	AND sdhduplicate.candidate_id = can.guidreference
	AND sd.code = 'GroupDuplicate'
INNER JOIN dbo.Country ON can.Country_ID = dbo.Country.CountryId
LEFT JOIN dbo.GeographicArea geo ON geo.GUIDReference = can.GeographicArea_Id
LEFT JOIN dbo.Individual ind ON ind.GuidReference = coll.GroupContact_Id
LEFT JOIN (
	SELECT t.Group_Id
		,max(iif(t.Code = 1, IndividualId, NULL)) AS HeadOfHousehold
		,max(iif(t.Code = 2, IndividualId, NULL)) AS MainShopper
		,max(iif(t.Code = 3, IndividualId, NULL)) AS MainContact
		,max(iif(t.Code = 4, IndividualId, NULL)) AS ChiefIncomeEarner
	FROM (
		SELECT Hoh.IndividualId
			,draHH.Group_Id
			,drHH.Code
		FROM dbo.Individual AS Hoh
		INNER JOIN dbo.DynamicRoleAssignment draHH ON draHH.Candidate_Id = Hoh.GUIDReference
		INNER JOIN dbo.DynamicRole drHH ON drHH.DynamicRoleId = draHH.DynamicRole_Id
		INNER JOIN dbo.DynamicRoleAssignmentHistory dhaHH ON dhaHH.DynamicRoleAssignment_Id = draHH.DynamicRoleAssignmentId
		--WHERE dhaHH.DateTo IS NUL
		
		UNION
		
		SELECT Hoh2.IndividualId
			,draHH2.Group_Id
			,drHH2.Code
		FROM dbo.Individual AS Hoh2
		INNER JOIN dbo.DynamicRoleAssignment draHH2 ON draHH2.Candidate_Id = Hoh2.GUIDReference
		INNER JOIN dbo.DynamicRole drHH2 ON drHH2.DynamicRoleId = draHH2.DynamicRole_Id
		WHERE NOT EXISTS (
				SELECT ''
				FROM dbo.DynamicRoleAssignmentHistory a
				WHERE a.DynamicRoleAssignment_Id = draHH2.DynamicRoleAssignmentId
				)
		) t
	GROUP BY t.Group_Id
	) AS Roles ON coll.GUIDReference = Roles.Group_Id
	where coll.GPSUser in ('QBImport','QBFRImport')
	and coll.AuditOperation in ('I', 'N')
GROUP BY can.GUIDReference
	,dbo.Country.CountryISO2A
	,coll.Sequence
	,can.Comments
	,ind.IndividualId
	,Roles.HeadOfHousehold
	,Roles.MainShopper
	,Roles.ChiefIncomeEarner
	,Roles.MainContact
	,geo.Code
	,coll.GPSUser
    ,coll.CreationTimeStamp
	,coll.GPSUpdateTimestamp
    ,coll.AuditOperation

GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GUIDReference  - Holds description of column.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'GUIDReference'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CountryISO2A  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'CountryISO2A'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GroupId  - Holds the Business ID for the Group eg: 123456.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'GroupId'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'Comments  - comment held against the group.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'Comments'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'KitType  - kit type, e.g Clicker, Palm, Opticon mid-range.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'KitType'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GroupContact  - the individual ID of the contact for the group, not null.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'GroupContact'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'HeadOfHousehold  - A dynamic role, head of household.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'HeadOfHousehold'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'MainShopper  - A dynamic role, the main shopper in the household.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'MainShopper'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'ChiefIncomeEarner  - A dynamic role, the chief income earner in a household.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'ChiefIncomeEarner'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'MainContact  - A dynamic role of contact, nullable .' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'MainContact'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'GeographicAreaCode  - The Geographic Area code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'GeographicAreaCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'SignupDate  - the date a Panellist joined KWP and became eligible to join panels. SOme countires may have different definitions on this value.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'SignupDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'TerminatedDate.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'TerminatedDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'DuplicatedDate  - relates to drop and recreate.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups', @level2type=N'COLUMN',@level2name=N'DuplicatedDate'
GO

EXEC sys.sp_addextendedproperty @name=N'Associated Views', @value=N'QBAuditFullIGroups, Groups,' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Groups' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'Shows changes from the Qiuestback import. List of Group details, showing the Individual undertaking each Group Role, eg: head of Household and Main Shopper, as well as Kit Type, any Group comments, Geographic Area and various dates assigned to the Group eg: SignupDate, TerminatedDate' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'QBAuditFullIGroups'
GO

