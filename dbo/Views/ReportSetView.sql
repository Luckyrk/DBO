create view [dbo].[ReportsSet]
as
select r.ReportsId,r.ReportPath,r.ReportName,c.CountryISO2A from Reports r
join Country c on c.CountryId=r.Country_id
GO

