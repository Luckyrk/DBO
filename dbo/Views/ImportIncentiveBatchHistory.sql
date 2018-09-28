CREATE VIEW [dbo].[ImportIncentiveBatchHistory]
AS
	select Distinct ImportFileName,  IAT.BatchId, IA.CreationTimestamp as ImportedDate, C.CountryISO2A
	from IncentiveAccountTransaction IAT 
	Join Individual I ON I.GuidReference = IAT.Account_Id
	Join (
		select  DISTINCT IFL.[Name] as ImportFileName, IFL.Country_Id, A.CreationTimestamp, A.[File_Id] 
		from  [ImportAudit] A 
		Join ImportFile IFL ON IFL.GuidReference = A.[File_Id] Where A.CreationTimestamp IS NOT NULL
	) IA 
	ON  IA.CreationTimestamp =  IAT.CreationTimestamp AND IA.Country_Id = IAT.Country_Id
	Join Country C ON C.CountryId = IA.Country_Id
 
GO

