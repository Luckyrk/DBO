Create view [dbo].[ActionCodeList] as
select c.CountryISO2A, ATT.ActionCode as ActionCode,tt.Value as ActionTask
from ActionTaskType ATT 
Join Country C on c.CountryId=ATT.Country_Id 
Join TranslationTerm tt on att.DescriptionTranslation_Id=tt.Translation_Id 
and tt.CultureCode=2057



