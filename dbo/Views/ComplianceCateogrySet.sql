 CREATE VIEW [dbo].[ComplianceCateogrySet]
 AS
 SELECT CC.KeyName AS ComplianceCategory, C.CountryISO2A FROM ComplianceCategory CC
 JOIN Country C ON C.CountryId = CC.Country_Id

