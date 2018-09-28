
CREATE PROCEDURE AnonymizeIndividualBulk
	@CountryCode NVARCHAR(10) = ''
AS
BEGIN

	SET NOCOUNT ON;
    
BEGIN TRY
	IF OBJECT_ID('tempdb..#ActiveIndividuals') IS NOT NULL
		DROP TABLE #ActiveIndividuals

	SELECT DISTINCT i.GUIDReference
	INTO #ActiveIndividuals
	FROM Individual i	
	JOIN Country c ON i.CountryId=c.CountryId
	JOIN Panelist p ON p.PanelMember_Id=i.GUIDReference
	JOIN StateDefinition sd ON sd.Id=p.State_Id
	WHERE
		(@CountryCode = '' OR c.CountryISO2A LIKE @CountryCode) AND 
		sd.Code <> 'PanelistDroppedOffState'
		
	UPDATE i SET IsAnonymized=1
	FROM Individual i
	JOIN Country c ON i.CountryId=c.CountryId
	JOIN KeyAppSetting kas ON kas.KeyName='AnonymizeIndividualTimeIntervalMonths'
	LEFT JOIN KeyValueAppSetting kv ON kv.Country_Id=c.CountryId AND kv.KeyAppSetting_Id=kas.GUIDReference
	JOIN Panelist p ON p.PanelMember_Id=i.GUIDReference
	JOIN StateDefinition sd ON sd.Id=p.State_Id
	JOIN 
		(SELECT Panelist_id, To_Id, MAX(CreationTimeStamp) as CreationTimeStamp
		FROM StateDefinitionHistory 
		GROUP BY Panelist_id, To_Id) sdh ON sdh.Panelist_Id=p.GUIDReference AND sd.Id=sdh.To_Id
	LEFT JOIN #ActiveIndividuals ai ON ai.GUIDReference=i.GUIDReference
	WHERE 
		(@CountryCode = '' OR c.CountryISO2A LIKE @CountryCode) AND 
		sd.Code = 'PanelistDroppedOffState' AND
		ai.GUIDReference IS NULL AND
		i.IsAnonymized = 0 AND
		DATEADD(month, CAST(ISNULL(kv.Value, kas.DefaultValue) AS INT), sdh.CreationTimeStamp) < GETUTCDATE()
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;

    SELECT @ErrorMessage = ERROR_MESSAGE(),
           @ErrorSeverity = ERROR_SEVERITY(),
           @ErrorState = ERROR_STATE();
	
	RAISERROR (@ErrorMessage, -- Message text.
               @ErrorSeverity, -- Severity.
               @ErrorState -- State.
               );
END CATCH
END
GO
