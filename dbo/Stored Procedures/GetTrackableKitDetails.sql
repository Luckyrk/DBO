/*##########################################################################
-- Name				: GetTrackableKitDetails  
-- Date             : 2018-04-19
-- Author           : GPS Developer
-- Purpose          : 
					  param definitions
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : Called from UI
-- PARAM Definitions
			-- @pPanelistId UNIQUEIDENTIFIER -- GUID of Panellist
			-- @pCountryId -- guid reference of country
			--@pdropOut NVARCHAR(100)-- Dropout Status
Usage 

EXEC	[dbo].[GetTrackableKitDetails]	@pPanelistId = '15fa5e46-2b49-c842-1489-08d572ad2e40', @pdropOut = 'Drop Out', @pcountryId  = '17D348D8-A08D-CE7A-CB8C-08CF81794A86'

##########################################################################
-- version  user                  date        change 
-- 1.0  GPS Developer			2018-04-19   Initial

##########################################################################*/
CREATE PROCEDURE [dbo].[GetTrackableKitDetails] @pPanelistId UNIQUEIDENTIFIER , @pdropOut nvarchar(100), @pcountryId UNIQUEIDENTIFIER
AS
BEGIN
BEGIN TRY 
	SET NOCOUNT ON

	SELECT DISTINCT a.Name AS Name
		,a.GUIDReference AS StockKitID
		,a.code AS Code
		,CASE when EXISTS (select 1 from statedefinition s
join translation t ON s.Label_Id = t.translationID
join translationterm tt on t.translationID = tt.translation_ID
 where s.code  = 'PanelistDroppedOffState' AND tt.value = @pdropOut AND Country_Id = @pcountryId) THEN 1 ELSE 0 END	AS IsDropOut
	FROM Panel p
	INNER JOIN Panelist pl ON p.GUIDReference = pl.Panel_Id
	INNER JOIN StockKit a ON pl.ExpectedKit_Id = a.GUIDReference
	INNER JOIN StockKitOrderType b ON a.GUIDReference = b.StockKit_Id
	INNER JOIN OrderType c ON c.Id = b.OrderType_Id
	INNER JOIN StockKitItem d ON a.GUIDReference = d.StockKit_Id
	INNER JOIN StockType e ON d.StockType_Id = e.GUIDReference
	INNER JOIN StockBehavior f ON e.Behavior_Id = f.GUIDReference
	WHERE f.IsTrackable = 1
		AND p.PanelCode = 7
		AND pl.Guidreference = @pPanelistId
END TRY
BEGIN CATCH
		DECLARE @ErrorMsg NVARCHAR(4000);
		DECLARE @Severity INT;
		DECLARE @State INT;

		SELECT @ErrorMsg = ERROR_MESSAGE(),
			   @Severity = ERROR_SEVERITY(),
			   @State = ERROR_STATE();
	
		RAISERROR (@ErrorMsg, -- Message text.
				   @Severity, -- Severity.
				   @State -- State.
				   );
END CATCH
END
