GO
--USE [GPS_PM]
--GO

--/****** Object:  View [dbo].[FullPanelMembersVN]    Script Date: 12/03/2014 11:33:27 ******/
--SET ANSI_NULLS ON
--GO

--SET QUOTED_IDENTIFIER ON
--GO

CREATE VIEW [dbo].[FullPanelMembersVN]
as

select ct.CountryISO2A
, ind.IndividualId
, pi.DateOfBirth
, isx.Code SexCode
, sex.KeyName SexDescription
, tit.KeyName TitleDescription
, pi.FirstOrderedName
, pan.PanelCode
, pan.Name PanelName
, stat.Code PanellistState 
, Ind.IndividualId as MainShopperId 
, pst.CreationDate as SignupDate
, LIVEDATE.LiveDate
from 
dbo.Individual ind 
inner join dbo.PersonalIdentification pi on pi.PersonalIdentificationId = ind.PersonalIdentificationId
left join dbo.IndividualTitle it on it.GUIDReference = pi.TitleId
left join dbo.translation tit on tit.TranslationId = it.Translation_Id
left join dbo.IndividualSex isx on isx.GUIDReference = ind.Sex_Id
left join dbo.translation sex on sex.TranslationId = isx.Translation_Id
inner join dbo.Panelist pst on pst.PanelMember_Id = ind.GUIDReference
inner join dbo.Country ct on ct.CountryId = pst.Country_Id
inner join dbo.Panel pan on pan.GUIDReference = pst.Panel_Id
inner join dbo.StateDefinition stat on stat.Id = pst.State_Id
LEFT JOIN (
      SELECT Country_Id
            ,Panelist_Id
            ,MAX(CreationDate) LiveDate
      FROM dbo.StateDefinitionHistory HIST1
      WHERE HIST1.To_Id = (
                  SELECT ID
                  FROM dbo.StateDefinition LIVESTATE1
                  WHERE LIVESTATE1.Code = 'PanelistLiveState' and LIVESTATE1.Country_Id = HIST1.Country_Id
                  )
      GROUP BY Country_Id
            ,Panelist_Id
      ) AS LIVEDATE ON LIVEDATE.Country_Id = ct.CountryId
      AND LIVEDATE.Panelist_Id = pst.GUIDReference
LEFT JOIN (
      SELECT Country_Id
            ,Panelist_Id
            ,MAX(CreationDate) DroppedOffDate
      FROM dbo.StateDefinitionHistory HIST2
      WHERE HIST2.To_Id = (
                  SELECT ID
                  FROM dbo.StateDefinition LIVESTATE2
                  WHERE LIVESTATE2.Code = 'PanelistDroppedOffState' and LIVESTATE2.Country_Id = HIST2.Country_Id
                  )
      GROUP BY Country_Id
            ,Panelist_Id
      ) AS DROPDATE ON DROPDATE.Country_Id = ct.CountryId
      AND DROPDATE.Panelist_Id = pst.GUIDReference
      
      
where stat.Code in ('PanelistLiveState','PanelistInterestedState','PanelistPreLiveState')
and DROPDATE.DroppedOffDate is null
and Ct.CountryISO2A = 'VN'

UNION ALL

select ct.CountryISO2A
, ind.IndividualId
, pi.DateOfBirth
, isx.Code SexCode
, sex.KeyName SexDescription
, tit.KeyName TitleDescription
, pi.FirstOrderedName
, pan.PanelCode
, pan.Name PanelName
, stat.Code PanellistState
, MainSh.IndividualId as MainShopperId 
, pst.CreationDate as SignupDate
, LIVEDATE.LiveDate
from 



dbo.Individual ind 
inner join CollectiveMembership cmem on cmem.Individual_Id = ind.GUIDReference
inner join dbo.PersonalIdentification pi on pi.PersonalIdentificationId = ind.PersonalIdentificationId
left join dbo.IndividualTitle it on it.GUIDReference = pi.TitleId
left join dbo.translation tit on tit.TranslationId = it.Translation_Id
left join dbo.IndividualSex isx on isx.GUIDReference = ind.Sex_Id
left join dbo.translation sex on sex.TranslationId = isx.Translation_Id
inner join dbo.Panelist pst on pst.PanelMember_Id = cmem.Group_Id
inner join dbo.Country ct on ct.CountryId = pst.Country_Id
inner join dbo.Panel pan on pan.GUIDReference = pst.Panel_Id
inner join dbo.StateDefinition stat on stat.Id = pst.State_Id
LEFT JOIN (
      SELECT Country_Id
            ,Panelist_Id
            ,MAX(CreationDate) LiveDate
      FROM dbo.StateDefinitionHistory HIST1
      WHERE HIST1.To_Id = (
                  SELECT ID
                  FROM dbo.StateDefinition LIVESTATE1
                  WHERE LIVESTATE1.Code = 'PanelistLiveState' and LIVESTATE1.Country_Id = HIST1.Country_Id
                  )
      GROUP BY Country_Id
            ,Panelist_Id
      ) AS LIVEDATE ON LIVEDATE.Country_Id = ct.CountryId
      AND LIVEDATE.Panelist_Id = pst.GUIDReference
LEFT JOIN (
      SELECT Country_Id
            ,Panelist_Id
            ,MAX(CreationDate) DroppedOffDate
      FROM dbo.StateDefinitionHistory HIST2
      WHERE HIST2.To_Id = (
                  SELECT ID
                  FROM dbo.StateDefinition LIVESTATE2
                  WHERE LIVESTATE2.Code = 'PanelistDroppedOffState' and LIVESTATE2.Country_Id = HIST2.Country_Id
                  )
      GROUP BY Country_Id
            ,Panelist_Id
      ) AS DROPDATE ON DROPDATE.Country_Id = ct.CountryId
      AND DROPDATE.Panelist_Id = pst.GUIDReference
LEFT JOIN
		(select MSh.IndividualId, draMS.Panelist_Id from dbo.Individual as MSh inner join
			  dbo.DynamicRoleAssignment draMS ON draMS.Candidate_Id = MSh.GUIDReference  inner join
			  dbo.DynamicRole drMS ON drMS.DynamicRoleId = draMS.DynamicRole_Id
              where drMS.Code = 2
			   ) as MainSh on pst.GUIDReference = MainSh.Panelist_Id      
      
where stat.Code in ('PanelistLiveState','PanelistInterestedState','PanelistPreLiveState')
and DROPDATE.DroppedOffDate is null
and Ct.CountryISO2A = 'VN'




GO

--GRANT SELECT ON FullPanelMembersVN TO GPSBusiness
--GO
