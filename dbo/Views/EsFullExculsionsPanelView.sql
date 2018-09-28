

CREATE view EsFullExculsionsPanelView  

as
SELECT IndividualId,KeyName, Range_From,Range_To,AllIndividuals,IsClosed,
 [Beauty],[Master],[Extra Doméstico],[Impulse],[Telecom],[Professionals vehicles],[Petrol],[Fashion],GPSUpdateTimestamp,CreationTimeStamp,GPSUser
FROM (
SELECT [IndividualId] ,[Range_From]   ,[Range_To], 
PanelName  as PanelName,KeyName,AllPanels,AllIndividuals,IsClosed,GPSUpdateTimestamp,CreationTimeStamp,GPSUser
 FROM [dbo].[FullExclusions]
 WHERE CountryISO2A = 'ES'  
) st
PIVOT(Count(PanelName) for PanelName in ([Beauty],[Master],[Extra Doméstico],[Impulse],[Telecom],[Professionals vehicles],[Petrol],[Fashion])) pvt3
GROUP BY IndividualId,KeyName,[Beauty],[Master],[Extra Doméstico],[Impulse],[Telecom],[Professionals vehicles],[Petrol],[Fashion], Range_From,Range_To,AllIndividuals,IsClosed
,GPSUpdateTimestamp,CreationTimeStamp,GPSUser