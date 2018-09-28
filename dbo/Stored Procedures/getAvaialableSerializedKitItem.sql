--EXEC getAvaialableSerializedKitItem '878e9558-4e50-4b7d-b63b-9e0a6fe522b6','ES'

CREATE PROCEDURE getAvaialableSerializedKitItem (
	@pKitId UNIQUEIDENTIFIER
	,@pCountryCode VARCHAR(5)
	)
AS
BEGIN
	SELECT
		X.NAME AS AssetTypeName
		,X.NAME AS AssetCategoryName
		,ISNULL(x.GrossCount, 0) - ISNULL(y.OrderedQuantity, 0) AS Quantity
	FROM (
		SELECT c.CountryISO2A
			,b.Code
			,b.NAME
			,b.Quantity
			,e.Location
			,count(*) AS GrossCount
			,SKI.GUIDReference
		FROM StockType b
		LEFT JOIN [StockItem] a ON b.GUIDReference = a.Type_Id
		JOIN Country c ON c.CountryId = b.CountryId
			AND c.CountryISO2A = @pCountryCode
		JOIN STOCKKITITEM SKI ON SKI.STOCKTYPE_ID =B.GUIDReference AND SKI.StockKit_Id=@pKitId
		JOIN GenericStockLocation e ON e.GUIDReference = a.Location_Id
			AND e.Location = 'LAB'
		JOIN StateDefinition f ON f.Id = a.State_Id
			AND f.Code = ('AssetCommissioned')
		JOIN StockBehavior g ON g.GUIDReference = b.Behavior_Id
			AND g.IsTrackable = 1
		GROUP BY c.CountryISO2A
			,b.Code
			,b.NAME
			,b.Quantity
			,e.Location
			,SKI.GUIDReference
		) x
	LEFT JOIN (
		SELECT c.CountryISO2A
			,f.Code
			,f.NAME
			,sum(b.Quantity) AS OrderedQuantity
			,SKI.GUIDReference
		FROM [Order] a
		JOIN OrderItem b ON b.Order_Id = a.OrderId
		JOIN Country c ON c.CountryId = a.Country_Id
		JOIN StateDefinition d ON d.Id = a.State_Id
		JOIN StateModel e ON e.GUIDReference = d.StateModel_Id
			AND e.[Type] = 'Domain.PanelManagement.Orders.Order'
		JOIN StockType f ON f.GUIDReference = b.StockType_Id
		JOIN STOCKKITITEM SKI ON SKI.STOCKTYPE_ID =F.GUIDReference AND SKI.StockKit_Id=@pKitId
		JOIN StockBehavior g ON g.GUIDReference = f.Behavior_Id
			AND g.IsTrackable = 1
		WHERE c.CountryISO2A = @pCountryCode
			AND d.Code <> 'OrderSentState'
		GROUP BY c.CountryISO2A
			,f.Code
			,f.NAME
			,SKI.GUIDReference
		) y ON y.CountryISO2A = x.CountryISO2A
		AND y.Code = x.Code
		AND y.NAME = x.NAME
END
