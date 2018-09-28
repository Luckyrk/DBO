CREATE PROCEDURE Usp_SodexoRewardsImport
 @pCountryCode AS VARCHAR(3)	
	,@pFileName AS VARCHAR(200)
	,@pJobId AS VARCHAR(200)
	,@pImportType AS VARCHAR(100)
AS
BEGIN
DECLARE @ActualFileName VARCHAR(2000)
SELECT * INTO #FileName FROM dbo.Split(@pFileName,'\')
SELECT TOP 1 @ActualFileName=items FROm #FileName ORDER BY ID DESC


DECLARE @InsertedRows AS BIGINT
	DECLARE @GPSUser VARCHAR(20) = 'SODEXO Import User'
	DECLARE @CountryId AS UNIQUEIDENTIFIER
	DECLARE @IsErrorOccured AS BIT = 0
	SELECT @CountryId = CountryId FROM Country WHERE CountryISO2A = @pCountryCode

DECLARE @AuditId AS BIGINT
DECLARE @GetDate DATETIME,@TransactionSourceId UniqueIdentifier,@PointID UniqueIdentifier
SET @GetDate = (select dbo.GetLocalDateTime(getdate(),@pCountryCode))
INSERT INTO [FileImportAuditSummary] (
		CountryCode
		,PanelID
		,PanelName
		,[Filename]
		,FileImportDate
		,GPSUser
		,TotalRows
		,PassedRows
		,[Status]
		,Comments
		,ImportType
		,JobId
		)
	VALUES (
		@pCountryCode
		,NULL
		,NULL
		,@pFileName
		,@Getdate
		,@GPSUser
		,0
		,0
		,'Processing'
		,NULL
		,@pImportType
		,@pJobId
		)
		SET @AuditId = @@Identity
		IF EXISTS(SELECT 1 FROM  [FileImportAuditSummary] WHERE [Status] = 'Completed'
			AND ImportType = @pImportType AND ISNULL((SELECT  REVERSE(items) as ss FROM dbo.Split(REVERSE([Filename]),'\') WHERE Id=1),'')=@ActualFileName)
BEGIN 
	UPDATE [FileImportAuditSummary]
			SET [Status] = 'Error'
			,Comments = 'This file has been already successfully processed.'
			,PassedRows = 0
		WHERE AuditId = @AuditId
		RETURN;
END

	IF (OBJECT_Id('tempdb..#TempSodexoRewardImport') is not null) 
	BEGIN
		DROP TABLE #TempSodexoRewardImport
	END
 --SELECT * FROM 	 
CREATE TABLE #TempSodexoRewardImport
(
	JobId UNIQUEIdentifier,
	[Rownumber] [int] NULL, 
	[Hogar] NVARCHAR(MAX),  --Home
	[ID línea de Pedidos] NVARCHAR(MAX),--Order online ID  
	[Referencia del pedido] NVARCHAR(MAX), --Order reference 
	[Proveedor] NVARCHAR(MAX),--Provider
	[Producto] NVARCHAR(MAX),--Product
	[SKU] NVARCHAR(MAX),
	[Cantidad] NVARCHAR(MAX),--Quantity
	[PUNTOS] NVARCHAR(MAX),  --POINTS
	[Precio por unidad] NVARCHAR(MAX),  --Price by unit
	[Total Valor] NVARCHAR(MAX),  --Total Value
	[Nombre Panelista] NVARCHAR(MAX),  --name Panelist
	[Dirección] NVARCHAR(MAX),  --Address
	[Teléfono] NVARCHAR(MAX),  --phone
	[Comentario] NVARCHAR(MAX),--Comment
	[Correo electrónico] NVARCHAR(MAX), --Email
	[Observación] NVARCHAR(MAX),--Observación  Observation
	[isvalidHogar] BIT,
	[isvalidID línea de Pedidos] BIT,
	[isvalidReferencia del pedido] BIT,
	[isvalidProveedor] BIT,
	[isvalidProducto] BIT,
	[isvalidSKU] BIT,
	[isvalidCantidad] BIT,
	[isvalidPUNTOS] BIT,
	[isvalidPrecio por unidad] BIT,
	[isvalidTotal Valor] BIT,
	[isvalidNombre Panelista] BIT,
	[isvalidDirección] BIT,
	[isvalidTeléfono] BIT,
	[isvalidComentario] BIT,
	[isvalidCorreo electrónico] BIT,
	[isvalidObservación] BIT,
	IncentiveAccountTransactionInfoId UNIQUEIDENTIFIER DEFAULT NEWID(),
	MainContactId UNIQUEIDENTIFIER
)

INSERT INTO #TempSodexoRewardImport(JobId,[Rownumber],[Hogar],[ID línea de Pedidos],[Referencia del pedido],[Proveedor],
	[Producto],	[SKU],[Cantidad],[PUNTOS],[Precio por unidad],[Total Valor],[Nombre Panelista],[Dirección],
	[Teléfono],[Comentario],[Correo electrónico],
	[Observación],
	[isvalidHogar] ,
	[isvalidID línea de Pedidos] ,
	[isvalidReferencia del pedido] ,
	[isvalidProveedor] ,
	[isvalidProducto] ,
	[isvalidSKU] ,
	[isvalidCantidad] ,
	[isvalidPUNTOS] ,
	[isvalidPrecio por unidad] ,
	[isvalidTotal Valor] ,
	[isvalidNombre Panelista] ,
	[isvalidDirección] ,
	[isvalidTeléfono] ,
	[isvalidComentario] ,
	[isvalidCorreo electrónico] ,
	[isvalidObservación] )
SELECT @pJobId,[Rownumber],[Hogar],[ID línea de Pedidos],[Referencia del pedido],[Proveedor],
	[Producto],	[SKU],[Cantidad],[PUNTOS],[Precio por unidad],[Total Valor],[Nombre Panelista],[Dirección],
	[Teléfono],[Comentario],[Correo electrónico],
	[Observación],
	IIF(ISNUMERIC([Hogar])=0,0,NULL),
	NULL,NULL,NULL,NULL,NULL,NULL,IIF(ISNUMERIC([PUNTOS])=0,0,NULL),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
	 FROM TempSodexoRewardImport WHERE jobid=@pJobId	

	SET @PointID=	(SELECT IP.GUIDReference
	FROM IncentivePoint IP 
	JOIN IncentivePointAccountEntryType IEP ON IEP.GUIDReference=IP.[Type_Id]
	JOIN Translation T ON T.TranslationId=IEP.TypeName_Id
	WHERE T.Keyname='SODEXO_IncentivePointAccountEntryTypeName'
	AND IEP.Country_Id=@CountryId)


 
	 UPDATE T  SET T.MainContactId=C.GroupContact_Id
	 FROM Collective C
	 JOIN #TempSodexoRewardImport T ON T.Hogar=C.Sequence
	 WHERE C.CountryId=@CountryId

	 INSERT INTO [dbo].[FileImportErrorLog] (
			CountryCode
			,ImportType
			,[FileName]
			,PanelCode
			,ErrorSource
			,ErrorCode
			,ErrorDescription
			,ErrorDate
			,JobId
			)
			SELECT @pCountryCode
			,@pImportType
			,@pFileName
			,NULL
			,'Sodexo Import'			
			,'0'
			,'Error: Incentive Point not available'
			,@Getdate
			,@pJobId
			WHERE @PointID IS NULL
			UNION
			SELECT DISTINCT @pCountryCode
			,@pImportType
			,@pFileName
			,NULL
			,'Sodexo Import'			
			,'0'
			,'Error: invalid house hold'
			,@Getdate
			,@pJobId
			 FROM #TempSodexoRewardImport HT WHERE [isvalidHogar]=0
			 UNION
			 SELECT DISTINCT @pCountryCode
			,@pImportType
			,@pFileName
			,NULL
			,'HHNO'			
			,'0'
			,'Error: invalid house hold'
			,@Getdate
			,@pJobId
			 FROM #TempSodexoRewardImport HT WHERE MainContactId IS NULL
			 UNION
			 SELECT DISTINCT @pCountryCode
			,@pImportType
			,@pFileName
			,NULL
			,'HHNO'			
			,'0'
			,'Error: invalid Points'
			,@Getdate
			,@pJobId
			 FROM #TempSodexoRewardImport HT WHERE [isvalidPUNTOS]=0
			 
		IF @@ROWCOUNT > 0
			SET @IsErrorOccured = 1
	 
	 SELECT @IsErrorOccured,'' AS TransactionSourceId,@PointID AS PointID,* FROM #TempSodexoRewardImport
	IF @IsErrorOccured = 0 --  NO ISSUES WITH DATA
	BEGIN
	BEGIN TRY
	SET @TransactionSourceId=(SELECT TransactionSourceId FROM TransactionSource WHERE Code='SODEXO' AND Country_Id=@CountryId)

	
	


	PRINT 'PROCESS STARTED'
	INSERT INTO IncentiveAccountTransactionInfo(IncentiveAccountTransactionInfoId,Ammount,GPSUser,GPSUpdateTimestamp,CreationTimeStamp,
	GiftPrice,Discriminator,Point_Id,RewardDeliveryType_Id,Country_Id)
	SELECT IncentiveAccountTransactionInfoId,Try_Parse([PUNTOS] AS INT),@GPSUser,@GetDate,@GetDate,
	NULL,'DebitTransactionInfo',@PointID,NULL,@CountryId
	FROM  #TempSodexoRewardImport
	
	INSERT INTO IncentiveAccountTransaction(IncentiveAccountTransactionId,CreationDate,SynchronisationDate,
	TransactionDate,Comments,Balance,GPSUser,GPSUpdateTimestamp
	,CreationTimeStamp,PackageId,TransactionInfo_Id,TransactionSource_Id,Depositor_Id,Panel_Id,DeliveryAddress_Id,Account_Id,
	[Type],Country_Id,GiftPrice,CostPrice,ProviderExtractionDate)

	SELECT NEWID(),@GetDate,NULL,
	@GetDate,'Ref: '+ISNULL([Referencia del pedido],'')+', '+ISNULL(Proveedor,'')+', '+ISNULL(Producto,'')+' (SKU: '+ISNULL(SKU,'')+')',0,@GPSUser,@GetDate
	,@GetDate,NULL,IncentiveAccountTransactionInfoId,@TransactionSourceId,NULL,NULL,NULL,MainContactId,
	'Debit',@CountryId,NULL,NULL,NULL
	FROM  #TempSodexoRewardImport


	SET @InsertedRows = @@ROWCOUNT
	PRINT '@InsertedRows : ' + convert(VARCHAR(10), @InsertedRows)
	
	UPDATE [FileImportAuditSummary]
				SET [Status] = 'Completed'
				,PassedRows = @InsertedRows
			WHERE AuditId = @AuditId
	END TRY
		BEGIN CATCH
			PRINT 'CRITICAL ERROR OCCURED'
			INSERT INTO [dbo].[FileImportErrorLog] (
				CountryCode
				,ImportType
				,[FileName]
				,PanelCode
				,ErrorSource
				,ErrorCode
				,ErrorDescription
				,ErrorDate
				,JobId
				)
			SELECT @pCountryCode
				,@pImportType
				,@pFileName
				,NULL
				,'Unknown'
				,ERROR_NUMBER()
				,ERROR_MESSAGE()
				,@Getdate
				,@pJobId

				PRINT ERROR_MESSAGE();

			UPDATE [FileImportAuditSummary]
				SET [Status] = 'Error'
				,Comments = substring(N'' + ERROR_MESSAGE(), 1, 400)
				,PassedRows = @InsertedRows
			WHERE AuditId = @AuditId
		END CATCH
	END
	ELSE
	BEGIN
		UPDATE [FileImportAuditSummary]
			SET [Status] = 'Error'
			,Comments = 'Input file has invalid data.'
			,PassedRows = 0
		WHERE AuditId = @AuditId
	END
	SET @InsertedRows = ISNULL(@InsertedRows,0)
	DROP TABLE #TempSodexoRewardImport
END
GO