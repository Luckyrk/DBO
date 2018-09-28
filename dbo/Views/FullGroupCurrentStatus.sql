CREATE VIEW [dbo].[FullGroupCurrentStatus]
AS
Select cr.CountryISO2A, c.Sequence, sd.Code as CurrentState, sdh.GPSUser, sdh.CreationDate as ChangeDate
from Collective c
join Candidate cd on cd.GUIDReference=c.GUIDReference
join StateDefinition sd on sd.Id=cd.CandidateStatus
join Country cr on cr.CountryId=c.CountryId
 JOIN (
       SELECT T.Candidate_Id
	          ,T.To_Id
			  ,T.GPSUser
			  ,T.CreationDate
	FROM (
		SELECT Row_Number() OVER (
                           PARTITION BY b.candidate_id ORDER BY b.CreationDate DESC
                           ) AS RowNumber
			,Candidate_Id
			,To_Id
			,ReasonForchangeState_Id
			,CollaborateInFuture
                     ,b.GPSUser
					 ,b.CreationDate
              FROM StateDefinitionHistory b
              Join StateDefinition c
              on c.Id = b.To_Id
              Join StateModel d
              on d.GUIDReference = c.StateModel_Id
              and d.[Type] = 'Domain.PanelManagement.Candidates.Groups.Group'
		) T
			  where T.RowNumber = 1
       ) sdh
	    ON sdh.Candidate_Id = c.GUIDReference
	   And sdh.To_Id = sd.Id

Go

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'CountryISO2A  - Holds the ISO value for each GPS Country eg: VN, CL, TW. Could be used as a filter on the Full Views.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullEventReasons', @level2type=N'COLUMN',@level2name=N'CountryISO2A'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'Sequence  - the GroupId.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullEventReasons', @level2type=N'COLUMN',@level2name=N'CommEventReasonCode'
GO

EXEC sys.sp_addextendedproperty @name=N'Column Description', @value=N'Code  - the State Definition Code.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullEventReasons', @level2type=N'COLUMN',@level2name=N'CommEventReasonDescription'
GO

EXEC sys.sp_addextendedproperty @name=N'Business Area', @value=N'Group' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullEventReasons'
GO

EXEC sys.sp_addextendedproperty @name=N'Description', @value=N'All Country data. Shows reference data for the Event Reason codes including the description' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'FullEventReasons'