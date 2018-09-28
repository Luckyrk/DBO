CREATE VIEW [dbo].[GetOrderItems]
AS
select 'GB' as CountryISO2A,'Empty' as Code ,'Empty' as Value
union all 
SELECT c.CountryISO2A,st.Code Code,st.name+' ['+sk.Name+']' Value
FROM stocktype st
inner join StockKitItem ski on st.GUIDReference=ski.StockType_Id
inner join StockKit sk on sk.GUIDReference=ski.StockKit_Id
inner join Country c on st.CountryId=c.CountryId 
