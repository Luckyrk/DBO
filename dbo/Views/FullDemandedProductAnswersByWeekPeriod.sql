CREATE VIEW [dbo].[FullDemandedProductAnswersByWeekPeriod]
AS
SELECT cnt.CountryISO2A[CountryISO2A]
	  ,pan.PanelCode
	  ,pan.Name PanelName
	  ,case when ind.IndividualId is null then cast(col.sequence as nvarchar) else ind.IndividualId end as PanelMemberId
	  ,case when ind.IndividualId is null then MS.IndividualId else ind.IndividualId end as MainShopperId
      ,dpc.ProductCode
	  ,dpc.Productdescription
      ,dpca.AnswerCatCode
	  ,dpca.AnswerCatDescription
	  ,CD.YearPeriodWeek
      ,dpa.[ActionTask_Id]
	  ,dpa.[FreeText]
	  ,ats.StartDate
	  ,ats.EndDate
	  ,ats.[CompletionDate]
      ,ats.[ActionComment]
      ,ats.[InternalOrExternal]
      ,ats.[State]
	  ,ats.[CommunicationCompletion_Id]
      ,dpa.[GPSUser]
      ,dpa.[GPSUpdateTimestamp]
      ,dpa.[CreationTimeStamp]  
	  ,IIF(dpcam.DoNotCallAgain=1,0,1) AS IgnoreCall
	  ,dpcam.AskAgainInterval
FROM [dbo].[DemandedProductAnswer] dpa
inner join Country cnt on cnt.CountryId = dpa.Country_Id
inner join Panelist pst on pst.GUIDReference = dpa.Panelist_Id
left join Individual ind on ind.GUIDReference = pst.PanelMember_Id
left join Collective col on col.GUIDReference = pst.PanelMember_Id
inner join DemandedProductCategory dpc on dpc.Id = dpa.DncProduct_Id
inner join DemandedProductCategoryAnswer dpca on dpca.Id = dpa.DncAnswerCategory_Id
JOIN DemandedProductCategoryAnswerMapping dpcam ON dpcam.DemandedProductCategory_Id = dpc.Id 
												AND dpcam.DemandedProductCategoryAnswer_Id = dpca.Id
JOIN CalendarDenorm CD ON dpa.CalendarPeriod_CalendarId=CD.CalendarId AND dpa.CalendarPeriod_PeriodId=CD.periodPeriodID
left join ActionTask ats on ats.GUIDReference = dpa.ActionTask_Id
left join Panel pan on pan.GUIDReference = pst.Panel_Id
  left join (
select MSh.IndividualId, MSh.GUIDReference ,draMS.Panelist_Id 
                             from dbo.Individual as MSh inner join
                             dbo.DynamicRoleAssignment draMS ON draMS.Candidate_Id = MSh.GUIDReference  inner join
                             dbo.DynamicRole drMS ON drMS.DynamicRoleId = draMS.DynamicRole_Id inner join
                                                dbo.DynamicRoleAssignmentHistory dhMS ON dhMS.DynamicRoleAssignment_Id = draMS.DynamicRoleAssignmentId
                             where drMS.Code = 2 and dhMS.DateTo is null
             union all
                             select MSh2.IndividualId, MSh2.GUIDReference , draMS2.Panelist_Id 
                                           from dbo.Individual as MSh2 inner join
                             dbo.DynamicRoleAssignment draMS2 ON draMS2.Candidate_Id = MSh2.GUIDReference  inner join
                             dbo.DynamicRole drMS2 ON drMS2.DynamicRoleId = draMS2.DynamicRole_Id 
                             where drMS2.Code = 2
                                                and not exists
                                                (select '' from dbo.DynamicRoleAssignmentHistory b
                                                where b.DynamicRoleAssignment_Id = draMS2.DynamicRoleAssignmentId)
                              ) as MS
    on MS.Panelist_Id = dpa.Panelist_Id


