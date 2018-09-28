CREATE VIEW [dbo].FullInterviewers
AS SELECT   i.ID,
			[CountryISO2A],
			i.InterviewerCode as 'InterviewerCode',
			i.Name as 'InterviewerName',
			s.InterviewerCode as 'SupervisorCode',
			i.[Type], 
			i.[Contract],            
		    i.[StartDate],      
		    i.[EndDate],          
			i.[AddressLine1],    
			i.[AddressLine2],     
			i.[AddressLine3],     
			i.[AddressLine4],  
			i.[CityId],   
		    i.[PostCode],        
			i.[HomePhone],       
			i.[MobilePhone],  
			i.[OtherPhone],       
			i.[EmailAddress],      
			i.[DevicePhone],      
		    i.[Document],
			i.[Supervisor_id],
			i.[Comments],
			i.[GPSUser],
			i.[GPSUpdateTimestamp],
			i.[CreationTimeStamp],
			c.Sequence AS 'GroupID'                            			
FROM Interviewer i 
LEFT JOIN Interviewer s ON i.Supervisor_id = s.ID
JOIN Collective c ON c.interviewer_id = i.ID
INNER JOIN dbo.Country ON i.Country_Id = dbo.Country.CountryId