
CREATE VIEW [dbo].[FullMainShopperSummaryCount]
AS
SELECT cnt.CountryISO2A
	,dyn.IndividualId AS MainShopper
	,pan.PanelCode
	,pan.NAME AS PanelName
	,scat.Code AS CategoryCode
	,a.SummaryCount
	,a.CalendarPeriod_CalendarId AS CalendarId
	,a.CalendarPeriod_PeriodId AS CalendarTypePeriodId
FROM PanelistSummaryCount a
INNER JOIN Country cnt ON cnt.CountryId = a.Country_Id
INNER JOIN Panelist pst ON pst.GUIDReference = a.PanelistId
INNER JOIN Summary_Category scat ON scat.SummaryCategoryId = a.SummaryCategoryId
INNER JOIN Panel pan ON pan.GUIDReference = pst.Panel_Id
LEFT JOIN Collective col ON col.GUIDReference = pst.PanelMember_Id
LEFT JOIN Individual ind ON ind.GUIDReference = pst.PanelMember_Id
LEFT JOIN CollectiveMembership mem ON mem.Individual_Id = ind.GUIDReference
LEFT JOIN Collective col2 ON col2.GUIDReference = mem.Group_Id
LEFT JOIN FullDynamicRoles dyn ON dyn.CountryISO2A = cnt.CountryISO2A
	AND dyn.GroupId = CASE 
		WHEN col.Sequence IS NULL
			THEN col2.Sequence
		ELSE col.Sequence
		END
	AND dyn.PanelCode IS NULL
	AND dyn.RoleName = 'MainShopperRoleName'