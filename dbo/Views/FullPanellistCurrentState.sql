Create view FullPanellistCurrentState
as
Select 
 b.CountryISO2A, c.PanelCode, g.Sequence as GroupId, e.Sequence as GroupPanellist, d.IndividualId
 ,case when c.[Type] = 'Individual' then  d.IndividualId else cast(e.sequence as nvarchar(30)) end as PanellistId
 ,sdh.Code as StateCode
 ,rsc.Code as ReasonCode
 ,sdh.CollaborateInFuture
 ,sdh.GPSUser
 ,sdh.CreationDate
From Panelist a
JOIN Country b ON b.CountryId = a.Country_Id
JOIN Panel c ON c.GUIDReference = a.Panel_Id
LEFT JOIN Individual d ON d.GUIDReference = a.PanelMember_Id
LEFT JOIN Collective e ON e.GUIDReference = a.PanelMember_Id 
LEFT JOIN
 (
       SELECT x.Panelist_Id
	          ,x.To_Id
			  ,x.GPSUser
			  ,x.CreationDate
			  ,x.Code
			  ,x.ReasonForchangeState_Id
			  ,x.CollaborateInFuture
       FROM (
              SELECT Row_Number() OVER (
                           PARTITION BY b.Panelist_id ORDER BY b.CreationDate DESC
                           ) AS RowNumber
                     ,Panelist_Id
                     ,To_Id
                     ,ReasonForchangeState_Id
                     ,CollaborateInFuture
                     ,b.GPSUser
					 ,b.CreationDate
					 ,c.Code
              FROM StateDefinitionHistory b
			  JOIN Panelist PL ON PL.GUIDReference=b.Panelist_Id AND b.To_Id=PL.State_Id
              JOIN StateDefinition c ON c.Id = b.To_Id
              JOIN StateModel d ON d.GUIDReference = c.StateModel_Id AND d.[Type] = 'Domain.PanelManagement.Candidates.Panelist'
              ) x
			  WHERE x.RowNumber = 1
   ) sdh
ON sdh.Panelist_Id = a.GUIDReference AND sdh.To_Id = a.State_Id
LEFT JOIN ReasonForChangeState rsc ON rsc.Id = sdh.ReasonForchangeState_Id
LEFT JOIN CollectiveMembership f ON f.Individual_Id = d.GUIDReference
LEFT JOIN collective g ON g.GUIDReference = f.Group_Id

GO

