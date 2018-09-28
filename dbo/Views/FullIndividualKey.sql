
CREATE VIEW [dbo].[FullIndividualKey]
WITH SCHEMABINDING
AS
select dbo.Country.CountryISO2A, dbo.Individual.IndividualId, dbo.Individual.GUIDReference [IndividualKey]
From  dbo.Candidate 
inner join dbo.Individual on dbo.Individual.GUIDReference = dbo.Candidate.GUIDReference
INNER JOIN dbo.Country ON dbo.Candidate.Country_ID = dbo.Country.CountryId


--GO
--alter view [dbo].[DiaryImportAuditTW]
--as
--select * from TWN_OnLineDiaryProcessing.dbo.ImportAudit 
--GO