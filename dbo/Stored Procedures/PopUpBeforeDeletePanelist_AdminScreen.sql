create PROCEDURE [dbo].[PopUpBeforeDeletePanelist_AdminScreen] (
	@IndividualId NVARCHAR(30)
	,@PanelCode INT
	,@CountryISO2A NVARCHAR(30)
	)
AS
BEGIN
BEGIN TRY 
Declare @IsHouseHold Nvarchar(max)
DECLARE @panelistid UNIQUEIDENTIFIER
if exists (select top 1 p.[type] from Panelist pl
									  join Panel p on p.GUIDReference=pl.Panel_Id
									  join collectivemembership cm on pl.panelmember_id=cm.Group_Id
									  JOIN Individual i ON i.GUIDReference = cm.Individual_id
		                              join collective ct on ct.guidreference=cm.Group_id
									  join Country c on c.CountryId=p.Country_Id where i.IndividualId =@IndividualId and c.CountryISO2A=@CountryISO2A and p.panelcode =@PanelCode)
Begin
	SET @panelistid = (
			SELECT TOP 1 pl.GUIDReference
			FROM Panelist pl
			INNER JOIN Panel p ON p.GUIDReference = pl.Panel_Id
			join collectivemembership cm on pl.panelmember_id= cm.Group_Id 
			JOIN Individual i ON i.GUIDReference = cm.Individual_id
		    join collective ct on ct.guidreference=cm.Group_id
			INNER JOIN Country c ON c.CountryId = p.Country_Id
			WHERE i.IndividualId = @IndividualId
				AND p.PanelCode = @PanelCode
				AND c.CountryISO2A = @CountryISO2A
			)

END

Else
Begin
SET @panelistid = (SELECT TOP 1 pl.GUIDReference
			FROM Panelist pl
			INNER JOIN Panel p ON p.GUIDReference = pl.Panel_Id
			join collectivemembership cm on pl.panelmember_id= cm.Individual_Id 
			JOIN Individual i ON i.GUIDReference = cm.Individual_id
		    join collective ct on ct.guidreference=cm.Group_id
			INNER JOIN Country c ON c.CountryId = p.Country_Id
			WHERE i.IndividualId = @IndividualId
				AND p.PanelCode = @PanelCode
				AND c.CountryISO2A = @CountryISO2A)
End


    DECLARE @SpTemp table
	(
	ID INT IDENTITY(1,1),
    PKTABLE_QUALIFIER nvarchar(1000),
	PKTABLE_OWNER	nvarchar(1000),
	PKTABLE_NAME	nvarchar(1000),
	PKCOLUMN_NAME	nvarchar(1000),
	FKTABLE_QUALIFIER	nvarchar(1000),
	FKTABLE_OWNER	nvarchar(1000),
	FKTABLE_NAME	nvarchar(1000),
	FKCOLUMN_NAME	nvarchar(1000),
	KEY_SEQ	         int,
	UPDATE_RULE	     int,
	DELETE_RULE	     int,
	FK_NAME	       nvarchar(1000),
	PK_NAME	       nvarchar(1000),
	DEFERRABILITY nvarchar(1000)
	)
	CREATE TABLE #FinalOp(FKTABLE_NAME nvarchar(1000))
	CREATE TABLE #TT (RecordsCOUNT INT)
	insert into @SpTemp EXEC sp_fkeys 'Panelist' 
	
	DECLARE @RowCount INT,@RotationCount INT,@FTableName VARCHAR(100),@FColumnName VARCHAR(1000)
	,@Query VARCHAR(MAX)=''
	SET @RowCount=(SELECT COUNT(FKTABLE_NAME) FROM @SpTemp)
	print @RowCount
SET @RotationCount=1

WHILE(@RotationCount<=@RowCount)
BEGIN
	SELECT @FTableName=FKTABLE_NAME,@FColumnName=FKCOLUMN_NAME FROM @SpTemp WHERE Id=@RotationCount
	SET @Query='SELECT COUNT(0) FROM '+@FTableName+' WHERE '+@FColumnName+'='''+CAST(@PanelistID AS VARCHAR(1000))+''''

	PRINT @Query
	INSERT INTO #TT
	EXEC (@Query)
	IF((SELECT TOP 1 RecordsCOUNT FROM #TT)>0 )  --0 No records, if >0 then record exists
	BEGIN
		--PRINT 'Records Exists'
		Insert into #FinalOp values (@FTableName)

	
	END
	ELSE
	BEGIN

		PRINT 'Records NOT Exists'
	END

DELETE FROM #TT

SET @RotationCount=@RotationCount+1



END
DROP TABLE #TT


--SELECT @RotationCount,@RowCount

DECLARE @Names VARCHAR(8000) 
SELECT @Names = (COALESCE(@Names + ', ', '')  + FKTABLE_NAME ) 
FROM #FinalOp
select @Names AS TableNames

DROP TABLE #FinalOp

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
End


