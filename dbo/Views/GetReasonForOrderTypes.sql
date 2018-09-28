CREATE VIEW [dbo].[GetReasonForOrderTypes]
AS
SELECT c.CountryISO2A,st.Code  as Code, isnull(tr.value,'') + ' [ (' + cast(st.Code as nvarchar(5)) + '),'+isnull(troct.value,'')+' ]' Value
FROM ReasonForOrderType st
inner join ordertype ot on ot.Id=st.OrderType_Id
inner join Translationterm tr on tr.Translation_Id=st.Description_Id and tr.CultureCode=2057
inner join Translationterm troct on troct.Translation_Id=ot.Description_Id and troct.CultureCode=2057
join Country c on st.Country_Id=c.CountryId