
Create PROCEDURE GetAttributeHistory_AdminScreen
@pCountrycode varchar(5)
AS
BEGIN
Declare @countrycode uniqueidentifier 

	
	DECLARE @countryid uniqueidentifier 
	set @countryid = (select CountryId from country where CountryISO2A=@pCountrycode) 
	EXEC [InsertAttributeHistory] null,null,null,null,@countryid
END