
create function fn_GetOrderItems(@OrderId BIGINT)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	declare @v nvarchar(max)
	set @v=(
	select ' + ' + ' '+st.name
	from 
	orderitem oi inner join stocktype st on oi.StockType_Id=st.GUIDReference
	where  Order_Id=@OrderId
	Group by oi.StockType_Id,st.name
	FOR XML PATH(''))
	RETURN LTRIM(RTRIM(stuff(@v,1,3,'')))
END
