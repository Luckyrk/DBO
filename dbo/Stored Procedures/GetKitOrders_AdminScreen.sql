
CREATE PROCEDURE [dbo].[GetKitOrders_AdminScreen]
(
@pcountrycode nvarchar(30)
)
AS
Begin
SELECT distinct ordertranslation.Value AS ordertype 
FROM OrderType ot
left join Country c ON c.CountryId=ot.Country_Id
LEFt join TranslationTerm ordertranslation ON ordertranslation.Translation_Id=ot.Description_Id and ordertranslation.CultureCode=2057  
where c.CountryISO2A=@pcountrycode
 and ordertranslation.Value<>'-- Select one from List --'
END
