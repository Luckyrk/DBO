create Procedure GetStockKitNames_AdminScreen(
@pcountrycode nvarchar(30)
)
AS
Begin
select SK.GUIDReference,SK.Code,SK.Name from StockKit  SK
join Country C on SK.Country_Id=C.CountryId
where CountryISO2A=@pcountrycode
order by SK.Name
End
