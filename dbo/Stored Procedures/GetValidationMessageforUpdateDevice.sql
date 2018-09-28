CREATE PROCEDURE [dbo].[GetValidationMessageforDevice] @pAssetId UNIQUEIDENTIFIER
	,@pCultureCode VARCHAR(250)
	,@pBusinessId VARCHAR(250)
AS
BEGIN
	DECLARE @pCountryId UNIQUEIDENTIFIER
		,@pGroupid VARCHAR(250)
		,@PanelType VARCHAR(250)
		,@SequenceId VARCHAR(250)
		,@ErrorMessage VARCHAR(250)
		,@PanelName VARCHAR(250)
		,@PanelId UNIQUEIDENTIFIER
		,@PanelCode int;

	SET @pCountryId = (
			SELECT CountryId
			FROM Country
			WHERE CountryISO2A = @pCultureCode
			)


SElect @PanelType	= pan.Type , @PanelName =pan.Name ,@PanelId = stp.Panel_Id,@PanelCode = pan.PanelCode
		FROM Stockitem stkitem
		INNER JOIN StockType st ON stkitem.Type_Id = st.GUIDReference
		INNER JOIN StockTypePanel stp ON st.GUIDReference = stp.StockType_Id
		INNER JOIN panel pan ON pan.GUIDReference = stp.Panel_Id
		WHERE stkitem.GUIDReference = @pAssetId
			AND st.CountryId =@pCountryId

	IF (@PanelType = 'HouseHold')
	BEGIN
		SET @pGroupid = substring(@pBusinessId, 0, CHARINDEX('-', @pBusinessId))

		BEGIN
			IF NOT (
					@pGroupid IN (
						SELECT col.Sequence
						FROM Stockitem stkitem
						INNER JOIN StockType st ON stkitem.Type_Id = st.GUIDReference
						INNER JOIN StockTypePanel stp ON st.GUIDReference = stp.StockType_Id
						INNER JOIN panel pan ON pan.GUIDReference = stp.Panel_Id
						INNER JOIN Panelist pns ON pns.Panel_Id = pan.GUIDReference
						INNER JOIN Collective col ON col.GUIDReference = pns.PanelMember_Id
						WHERE stkitem.GUIDReference = @pAssetId
							AND stkitem.Country_Id = @pCountryId
						)
					)
			BEGIN
				SET @ErrorMessage = 'Please select the valid individual for the '+ @PanelName+ ' Panel'
			END
		END
	END

	IF (@PanelType = 'Individual')
	BEGIN
		IF NOT (
				@pBusinessId IN (
					SELECT ind.IndividualId
					FROM Stockitem stkitem
					INNER JOIN StockType st ON stkitem.Type_Id = st.GUIDReference
					INNER JOIN StockTypePanel stp ON st.GUIDReference = stp.StockType_Id
					INNER JOIN panel pan ON pan.GUIDReference = stp.Panel_Id
					INNER JOIN Panelist pns ON pns.Panel_Id = pan.GUIDReference
					INNER JOIN Individual ind ON ind.GUIDReference = pns.PanelMember_Id
					WHERE stkitem.GUIDReference = @pAssetId
						AND stkitem.Country_Id = @pCountryId
					)
				)
		BEGIN
			SET @ErrorMessage = 'Please select the valid individual for the '+ @PanelName+ ' Panel'
		END
	END

	SELECT @ErrorMessage AS ErrorMessage,@PanelName as PanelName,@PanelId as PanelId,@PanelCode as PanelCode
END