
CREATE VIEW [dbo].[GetPeriodPurchase]
AS
SELECT cnt.CountryISO2A
	,pan.PanelCode
	,scat.Code
	,'Purchase' AS Purchase
	,ind.individualid
	,cd.yearPeriodValue AS [Year]
	,cd.periodperiodvalue [Period]
	,cd.weekperiodvalue AS [Week]
	,SummaryCount
FROM PanelistSummaryCount a
INNER JOIN Country cnt ON cnt.CountryId = a.Country_Id
INNER JOIN Panel pan ON pan.GUIDReference = a.Panel_Id
INNER JOIN Panelist pst ON pst.GUIDReference = a.PanelistId
INNER JOIN individual ind ON ind.GUIDReference = pst.PanelMember_Id
INNER JOIN Summary_Category scat ON scat.SummaryCategoryId = a.SummaryCategoryId
INNER JOIN calendardenorm cd ON cd.weekPeriodID = a.CalendarPeriod_PeriodId
	--inner join CalendarPeriod cpweek on cpweek.CalendarId=a.CalendarPeriod_CalendarId and cpweek.PeriodId=a.CalendarPeriod_PeriodId
	--join CalendarPeriodHierarchy cph on cph.CalendarId=a.CalendarPeriod_CalendarId and cph.SequenceWithinHierarchy=1
	--inner join CalendarPeriod cpperiod on cpperiod.CalendarId=a.CalendarPeriod_CalendarId and cpperiod.StartDate<=cpweek.StartDate and cpperiod.EndDate>=cpweek.EndDate and cpperiod.PeriodTypeId=cph.ChildPeriodTypeId
	--inner join CalendarPeriod cpyear on cpyear.CalendarId=a.CalendarPeriod_CalendarId and cpyear.StartDate<=cpperiod.StartDate and cpyear.EndDate>=cpperiod.EndDate and cpyear.PeriodTypeId=cph.ParentPeriodTypeId