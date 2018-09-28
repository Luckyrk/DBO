Create procedure dbo.GetCountryFlag_AdminScreen(@pcountryCode varchar(10))

as

begin



select Flag from Country where CountryISO2A=@pcountryCode



end