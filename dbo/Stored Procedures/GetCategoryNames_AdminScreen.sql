Create Procedure GetCategoryNames_AdminScreen(
@pcountrycode nvarchar(30)
)
As
Begin
Declare @countryid uniqueidentifier 
set @countryid= (select Top 1 CountryId from Country where CountryISO2A=@pcountrycode)
select TT.Value as CategoryName,SC.GUIDReference from StockCategory SC 
join translation T on SC.Translation_Id=T.TranslationId 
join Country C on C.CountryId=sc.country_id
join TranslationTerm TT on TT.Translation_Id= T.TranslationId
where   TT.CultureCode=2057 and c.countryiso2a=@pcountrycode
order by tt.value 
END



