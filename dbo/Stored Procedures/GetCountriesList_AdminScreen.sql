Create procedure GetCountriesList_AdminScreen

as

select c.CountryISO2A as CountryCode,c.CountryId as CountryGuid,tt.Value as CountryName from Country c

join TranslationTerm tt on tt.Translation_Id=c.TranslationId and tt.CultureCode=2057