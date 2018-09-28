CREATE FUNCTION fn_GetOrderIsReadyToSend (@OrderId BIGINT)
RETURNS BIT
AS
BEGIN
	DECLARE @ReturnValue BIT = 0

	IF NOT EXISTS (
			SELECT *
			FROM OrderItem OI
			INNER JOIN StockType ST ON ST.GUIDReference = OI.StockType_Id
			INNER JOIN StockBehavior SB ON SB.GUIDReference = ST.Behavior_Id
			WHERE OI.Order_Id = @OrderId
			)
	BEGIN
		RETURN 1
	END

	--If there is at least one order item which does not satisfy the condition to be ready to be sent, then the count is not 0, so return 0 (is not ready)
	IF EXISTS (
			SELECT 1
			FROM OrderItem OI
			INNER JOIN StockType ST ON ST.GUIDReference = OI.StockType_Id
			INNER JOIN StockBehavior SB ON SB.GUIDReference = ST.Behavior_Id
			WHERE OI.Order_Id = @OrderId
				AND sb.IsTrackable = 1
				AND oi.stockitemid IS NULL
			)
	BEGIN
		RETURN 0
	END
	ELSE
		RETURN 1

	RETURN @ReturnValue
END