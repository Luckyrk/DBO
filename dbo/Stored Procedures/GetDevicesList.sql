/*##########################################################################
-- Name             : GetDevicesList
-- Date             : 2015-01-27
-- Author           : Venkata Ramana
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure used to get the devices based on type
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        :
-- PARAM Definitions
      	 @pCountryId	     -- Country Guid
		 @pCultureCode		 -- Culture Code
		 @pOrderBy           -- The column name on which user is going to perform the sorting 
		 @pOrderType         -- Specifies the Sorting type ASC OR DESC
		 @pPageNumber        -- Page number of the page
		 @pPageSize          -- Page size (The number of Records user wants to see in the grid)
		 @pIsExport          -- Specifies user want to export the data
		 @pParametersTable dbo.GridParametersTable readonly -- This is going to have all the searching criteria performed through the Gridview.
-- Sample Execution :
DECLARE @pParametersTable dbo.GridParametersTable 

	--INSERT INTO  @pParametersTable ParameterName,ParameterValue,Opertor,LogicalOperator,SecondParameterOperator,SecondParameterValue)
	--VALUES('Type','OP','Contains',NULL,NULL,NULL)

	EXEC GetDevicesList '17D348D8-A08D-CE7A-CB8C-08CF81794A86',2057,'',NULL,NULL,1,10,0,@pParametersTable   

##########################################################################
-- ver  user               date        change 
-- 1.0  Venkata Ramana     2015-01-27  New
-- 1.1  Venkata Ramana     2015-01-27  Performence Improve

##########################################################################*/

CREATE PROCEDURE GetDevicesList
	 @pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT 
	,@pSerialNumber NVARCHAR(80) = NULL
	,@pOrderBy VARCHAR(100)
	,@pOrderType VARCHAR(10) -- ASC OR DESC
	,@pPageNumber INT = 1
	,@pPageSize INT = 100
	,@pIsExport BIT = 0
	,@pParametersTable dbo.GridParametersTable READONLY
AS
BEGIN

	DECLARE @op1 VARCHAR(50)
		,@op2 VARCHAR(50)
		,@op3 VARCHAR(50)
		,@op4 VARCHAR(50)
		,@op5 VARCHAR(50)
		,@op6 VARCHAR(50)
		,@op7 VARCHAR(50)
		,@op8 VARCHAR(50)
		,@op9 VARCHAR(50)
		,@op10 VARCHAR(50)
	DECLARE @LogicalOperator9 VARCHAR(5)
	DECLARE @Secondop9 VARCHAR(50)
	DECLARE @SecondLastUpDate DATE
	DECLARE @SerialNumber NVARCHAR(80)
		,@Location NVARCHAR(100)
		,@Type NVARCHAR(100)
		,@Range NVARCHAR(100)
		,@Conectivity NVARCHAR(200)
		,@Software NVARCHAR(200)
		,@Model NVARCHAR(200)
		,@Status NVARCHAR(200)
		,@LastUpdate DATETIME
		,@Comments NVARCHAR(1000)

	SELECT @op1 = Opertor
		,@SerialNumber = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'SerialNumber'

	SELECT @op2 = Opertor
		,@Location = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Location'

	SELECT @op3 = Opertor
		,@Type = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Type'

	SELECT @op4 = Opertor
		,@Range = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Range'

	SELECT @op5 = Opertor
		,@Conectivity = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Conectivity'

	SELECT @op6 = Opertor
		,@Software = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Software'

	SELECT @op7 = Opertor
		,@Model = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Model'

	SELECT @op8 = Opertor
		,@Status = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Status'

	SELECT @op9 = Opertor
		,@LastUpdate = CAST(ParameterValue AS DATE)
		,@Secondop9 = SecondParameterOperator
		,@SecondLastUpDate = CAST(SecondParameterValue AS DATE)
		,@LogicalOperator9 = LogicalOperator
	FROM @pParametersTable
	WHERE ParameterName = 'LastUpdate'

	SELECT @op10 = Opertor
		,@Comments = ParameterValue
	FROM @pParametersTable
	WHERE ParameterName = 'Comments'

	DECLARE @LastUpDateVarchar VARCHAR(100) = CAST(@LastUpDate AS VARCHAR)
		,@SecondLastUpDateVarchar VARCHAR(100) = CAST(@SecondLastUpDate AS VARCHAR)

	IF (@pOrderBy IS NULL)
		SET @pOrderBy = 'DESC'

	IF (@pOrderType IS NULL)
		SET @pOrderType = 'LastUpdate'

	DECLARE @OFFSETRows INT = 0
	DECLARE @IsLessThan VARCHAR(50) = 'IsLessThan'
		,@IsLessThanOrEqualTo VARCHAR(50) = 'IsLessThanOrEqualTo'
		,@IsEqualTo VARCHAR(50) = 'IsEqualTo'
		,@IsNotEqualTo VARCHAR(50) = 'IsNotEqualTo'
		,@IsGreaterThanOrEqualTo VARCHAR(50) = 'IsGreaterThanOrEqualTo'
		,@IsGreaterThan VARCHAR(50) = 'IsGreaterThan'
		,@StartsWith VARCHAR(50) = 'StartsWith'
		,@EndsWith VARCHAR(50) = 'EndsWith'
		,@Contains VARCHAR(50) = 'Contains'
		,@IsContainedIn VARCHAR(50) = 'IsContainedIn'
		,@DoesNotContain VARCHAR(50) = 'DoesNotContain'

	IF (@pIsExport = 0)
		SET @OFFSETRows = (@pPageSize * (@pPageNumber - 1))
	ELSE
		SET @pPageSize = 15000


	IF(@pSerialNumber='')
	SET @pSerialNumber=NULL

	IF (@pIsExport = 0)
	BEGIN
		SELECT COUNT(0)
		FROM (
			SELECT SS.SIGUIDReference AS Id
				,SerialNumber
				,SS.STName AS [Type]
				,SS.SICreationTimeStamp AS CreationTimeStamp
				,dbo.GetTranslationValue(SS.SDLabel_Id, @pCultureCode) AS [Status]
				,SS.SIGPSUpdateTimestamp AS LastUpdate
				,SS.SLGUIDReference AS LocationId
				,CASE 
					WHEN SS.GSLLocation IS NOT NULL
						THEN CAST(SS.GSLLocation AS VARCHAR)
					WHEN c.GUIDReference IS NOT NULL
						THEN dbo.[GetGroupSequence](c.Sequence, c.CountryId)
					WHEN i2.IndividualId IS NOT NULL
						THEN CAST(i2.IndividualId AS VARCHAR)
					END AS Location
				,
				'' AS Model,'' AS [Range],'' AS Software,'' AS Conectivity,			
				CASE 
					WHEN SS.GSLLocation IS NOT NULL
						THEN ''
					WHEN c.GUIDReference IS NOT NULL
						THEN dbo.[GetGroupSequence](c.Sequence, c.CountryId)
					WHEN i2.IndividualId IS NOT NULL
						THEN CAST(i2.IndividualId AS VARCHAR)
					END AS MainContactBussinesId
				,'' AS Comments
			FROM 	(
			SELECT SI.GUIDReference AS SIGUIDReference,ST.GUIDReference AS STGUIDReference,spl.Panelist_Id,ST.CountryId AS  STCountryId
			,GSL.Location AS GSLLocation
			,SI.GUIDReference AS SIId
				,SerialNumber
				,ST.Name AS STName
				,SI.CreationTimeStamp AS SICreationTimeStamp
				,SD.Label_Id AS SDLabel_Id
				,CAST(SI.GPSUpdateTimestamp AS DATE) AS SIGPSUpdateTimestamp
				,SL.GUIDReference AS SLGUIDReference
			 FROM 
			 StockItem SI
			INNER JOIN StockType ST ON ST.GUIDReference = SI.Type_Id
			INNER JOIN StateDefinition SD ON SD.Id = SI.State_Id
			INNER JOIN StockLocation SL ON SL.GUIDReference = SI.Location_Id
			LEFT JOIN GenericStockLocation GSL ON GSL.GUIDReference = SL.GUIDReference
			LEFT JOIN StockPanelistLocation SPL ON SPL.GUIDReference = SL.GUIDReference
			WHERE @pCountryId =ST.CountryId
			AND SI.SerialNumber=ISNULL(@pSerialNumber,SI.SerialNumber)
			) AS SS
			LEFT JOIN Panelist p ON p.GUIDReference = SS.Panelist_Id
			LEFT JOIN (
			SELECT DISTINCT Group_Id FROM
			CollectiveMembership ) cm ON cm.Group_Id = p.PanelMember_Id
			LEFT JOIN Collective c ON c.GUIDReference = cm.Group_Id
			LEFT JOIN Individual i2 ON i2.GUIDReference = p.PanelMember_Id
			) AS TEMPTABLE
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND SerialNumber = @SerialNumber
					)
				OR (
					@op1 = @IsNotEqualTo
					AND SerialNumber <> @SerialNumber
					)
				OR (
					@op1 = @IsLessThan
					AND SerialNumber < @SerialNumber
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND SerialNumber <= @SerialNumber
					)
				OR (
					@op1 = @IsGreaterThan
					AND SerialNumber > @SerialNumber
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND SerialNumber >= @SerialNumber
					)
				OR (
					@op1 = @Contains
					AND SerialNumber LIKE '%' + @SerialNumber + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND SerialNumber NOT LIKE '%' + @SerialNumber + '%'
					)
				OR (
					@op1 = @StartsWith
					AND SerialNumber LIKE '' + @SerialNumber + '%'
					)
				OR (
					@op1 = @EndsWith
					AND SerialNumber LIKE '%' + @SerialNumber + ''
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND Location = @Location
					)
				OR (
					@op2 = @IsNotEqualTo
					AND Location <> @Location
					)
				OR (
					@op2 = @IsLessThan
					AND Location < @Location
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND Location <= @Location
					)
				OR (
					@op2 = @IsGreaterThan
					AND Location > @Location
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND Location >= @Location
					)
				OR (
					@op2 = @Contains
					AND Location LIKE '%' + @Location + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND Location NOT LIKE '%' + @Location + '%'
					)
				OR (
					@op2 = @StartsWith
					AND Location LIKE '' + @Location + '%'
					)
				OR (
					@op2 = @EndsWith
					AND Location LIKE '%' + @Location + ''
					)
				)
			AND (
				(@op3 IS NULL)
				OR (
					@op3 = @IsEqualTo
					AND [Type] = @Type
					)
				OR (
					@op3 = @IsNotEqualTo
					AND [Type] <> @Type
					)
				OR (
					@op3 = @IsLessThan
					AND [Type] < @Type
					)
				OR (
					@op3 = @IsLessThanOrEqualTo
					AND [Type] <= @Type
					)
				OR (
					@op3 = @IsGreaterThan
					AND [Type] > @Type
					)
				OR (
					@op3 = @IsGreaterThanOrEqualTo
					AND [Type] >= @Type
					)
				OR (
					@op3 = @Contains
					AND [Type] LIKE '%' + @Type + '%'
					)
				OR (
					@op3 = @DoesNotContain
					AND [Type] NOT LIKE '%' + @Type + '%'
					)
				OR (
					@op3 = @StartsWith
					AND [Type] LIKE '' + @Type + '%'
					)
				OR (
					@op3 = @EndsWith
					AND [Type] LIKE '%' + @Type + ''
					)
				)
			AND (
				(@op4 IS NULL)
				OR (
					@op4 = @IsEqualTo
					AND [Range] = @Range
					)
				OR (
					@op4 = @IsNotEqualTo
					AND [Range] <> @Range
					)
				OR (
					@op4 = @IsLessThan
					AND [Range] < @Range
					)
				OR (
					@op4 = @IsLessThanOrEqualTo
					AND [Range] <= @Range
					)
				OR (
					@op4 = @IsGreaterThan
					AND [Range] > @Range
					)
				OR (
					@op4 = @IsGreaterThanOrEqualTo
					AND [Range] >= @Range
					)
				OR (
					@op4 = @Contains
					AND [Range] LIKE '%' + @Range + '%'
					)
				OR (
					@op4 = @DoesNotContain
					AND [Range] NOT LIKE '%' + @Range + '%'
					)
				OR (
					@op4 = @StartsWith
					AND [Range] LIKE '' + @Range + '%'
					)
				OR (
					@op4 = @EndsWith
					AND [Range] LIKE '%' + @Range + ''
					)
				)
			AND (
				(@op5 IS NULL)
				OR (
					@op5 = @IsEqualTo
					AND Conectivity = @Conectivity
					)
				OR (
					@op5 = @IsNotEqualTo
					AND Conectivity <> @Conectivity
					)
				OR (
					@op5 = @IsLessThan
					AND Conectivity < @Conectivity
					)
				OR (
					@op5 = @IsLessThanOrEqualTo
					AND Conectivity <= @Conectivity
					)
				OR (
					@op5 = @IsGreaterThan
					AND Conectivity > @Conectivity
					)
				OR (
					@op5 = @IsGreaterThanOrEqualTo
					AND Conectivity >= @Conectivity
					)
				OR (
					@op5 = @Contains
					AND Conectivity LIKE '%' + @Conectivity + '%'
					)
				OR (
					@op5 = @DoesNotContain
					AND Conectivity NOT LIKE '%' + @Conectivity + '%'
					)
				OR (
					@op5 = @StartsWith
					AND Conectivity LIKE '' + @Conectivity + '%'
					)
				OR (
					@op5 = @EndsWith
					AND Conectivity LIKE '%' + @Conectivity + ''
					)
				)
			AND (
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND Software = @Software
					)
				OR (
					@op6 = @IsNotEqualTo
					AND Software <> @Software
					)
				OR (
					@op6 = @IsLessThan
					AND Software < @Software
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND Software <= @Software
					)
				OR (
					@op6 = @IsGreaterThan
					AND Software > @Software
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND Software >= @Software
					)
				OR (
					@op6 = @Contains
					AND Software LIKE '%' + @Software + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND Software NOT LIKE '%' + @Software + '%'
					)
				OR (
					@op6 = @StartsWith
					AND Software LIKE '' + @Software + '%'
					)
				OR (
					@op6 = @EndsWith
					AND Software LIKE '%' + @Software + ''
					)
				)
			AND (
				(@op7 IS NULL)
				OR (
					@op7 = @IsEqualTo
					AND Model = @Model
					)
				OR (
					@op7 = @IsNotEqualTo
					AND Model <> @Model
					)
				OR (
					@op7 = @IsLessThan
					AND Model < @Model
					)
				OR (
					@op7 = @IsLessThanOrEqualTo
					AND Model <= @Model
					)
				OR (
					@op7 = @IsGreaterThan
					AND Model > @Model
					)
				OR (
					@op7 = @IsGreaterThanOrEqualTo
					AND Model >= @Model
					)
				OR (
					@op7 = @Contains
					AND Model LIKE '%' + @Model + '%'
					)
				OR (
					@op7 = @DoesNotContain
					AND Model NOT LIKE '%' + @Model + '%'
					)
				OR (
					@op7 = @StartsWith
					AND Model LIKE '' + @Model + '%'
					)
				OR (
					@op7 = @EndsWith
					AND Model LIKE '%' + @Model + ''
					)
				)
			AND (
				(@op8 IS NULL)
				OR (
					@op8 = @IsEqualTo
					AND [Status] = @Status
					)
				OR (
					@op8 = @IsNotEqualTo
					AND [Status] <> @Status
					)
				OR (
					@op8 = @IsLessThan
					AND [Status] < @Status
					)
				OR (
					@op8 = @IsLessThanOrEqualTo
					AND [Status] <= @Status
					)
				OR (
					@op8 = @IsGreaterThan
					AND [Status] > @Status
					)
				OR (
					@op8 = @IsGreaterThanOrEqualTo
					AND [Status] >= @Status
					)
				OR (
					@op8 = @Contains
					AND [Status] LIKE '%' + @Status + '%'
					)
				OR (
					@op8 = @DoesNotContain
					AND [Status] NOT LIKE '%' + @Status + '%'
					)
				OR (
					@op8 = @StartsWith
					AND [Status] LIKE '' + @Status + '%'
					)
				OR (
					@op8 = @EndsWith
					AND [Status] LIKE '%' + @Status + ''
					)
				)
			AND (
				(@op9 IS NULL)
				OR (
					@op9 IS NULL
					AND @LogicalOperator9 IS NULL
					)
				OR (
					@LogicalOperator9 = 'OR'
					AND (
						(
							(
								@op9 = @IsEqualTo
								AND LastUpdate = @LastUpdate
								)
							OR (
								@op9 = @IsNotEqualTo
								AND LastUpdate <> @LastUpdate
								)
							OR (
								@op9 = @IsLessThan
								AND LastUpdate < @LastUpdate
								)
							OR (
								@op9 = @IsLessThanOrEqualTo
								AND LastUpdate <= @LastUpdate
								)
							OR (
								@op9 = @IsGreaterThan
								AND LastUpdate > @LastUpdate
								)
							OR (
								@op9 = @IsGreaterThanOrEqualTo
								AND LastUpdate >= @LastUpdate
								)
							OR (
								@op9 = @Contains
								AND LastUpdate LIKE '%' + @LastUpdateVarchar + '%'
								)
							OR (
								@op9 = @DoesNotContain
								AND LastUpdate NOT LIKE '%' + @LastUpdateVarchar + '%'
								)
							OR (
								@op9 = @StartsWith
								AND LastUpdate LIKE '' + @LastUpdateVarchar + '%'
								)
							OR (
								@op9 = @EndsWith
								AND LastUpdate LIKE '%' + @LastUpdateVarchar + ''
								)
							)
						OR (
							(
								@Secondop9 = @IsEqualTo
								AND LastUpdate = @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsNotEqualTo
								AND LastUpdate <> @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsLessThan
								AND LastUpdate < @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsLessThanOrEqualTo
								AND LastUpdate <= @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsGreaterThan
								AND LastUpdate > @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsGreaterThanOrEqualTo
								AND LastUpdate >= @SecondLastUpdate
								)
							OR (
								@Secondop9 = @Contains
								AND LastUpdate LIKE '%' + @SecondLastUpdateVarchar + '%'
								)
							OR (
								@Secondop9 = @DoesNotContain
								AND LastUpdate NOT LIKE '%' + @SecondLastUpDateVarchar + '%'
								)
							OR (
								@Secondop9 = @StartsWith
								AND LastUpdate LIKE '' + @SecondLastUpdateVarchar + '%'
								)
							OR (
								@Secondop9 = @EndsWith
								AND LastUpdate LIKE '%' + @SecondLastUpdateVarchar + ''
								)
							)
						)
					)
				OR (
					@LogicalOperator9 = 'AND'
					AND (
						(
							(
								@op9 = @IsEqualTo
								AND LastUpdate = @LastUpdate
								)
							OR (
								@op9 = @IsNotEqualTo
								AND LastUpdate <> @LastUpdate
								)
							OR (
								@op9 = @IsLessThan
								AND LastUpdate < @LastUpdate
								)
							OR (
								@op9 = @IsLessThanOrEqualTo
								AND LastUpdate <= @LastUpdate
								)
							OR (
								@op9 = @IsGreaterThan
								AND LastUpdate > @LastUpdate
								)
							OR (
								@op9 = @IsGreaterThanOrEqualTo
								AND LastUpdate >= @LastUpdate
								)
							OR (
								@op9 = @Contains
								AND LastUpdate LIKE '%' + @LastUpdateVarchar + '%'
								)
							OR (
								@op9 = @DoesNotContain
								AND LastUpdate NOT LIKE '%' + @LastUpdateVarchar + '%'
								)
							OR (
								@op9 = @StartsWith
								AND LastUpdate LIKE '' + @LastUpdateVarchar + '%'
								)
							OR (
								@op9 = @EndsWith
								AND LastUpdate LIKE '%' + @LastUpdateVarchar + ''
								)
							)
						AND (
							(
								@Secondop9 = @IsEqualTo
								AND LastUpdate = @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsNotEqualTo
								AND LastUpdate <> @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsLessThan
								AND LastUpdate < @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsLessThanOrEqualTo
								AND LastUpdate <= @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsGreaterThan
								AND LastUpdate > @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsGreaterThanOrEqualTo
								AND LastUpdate >= @SecondLastUpdate
								)
							OR (
								@Secondop9 = @Contains
								AND LastUpdate LIKE '%' + @SecondLastUpdateVarchar + '%'
								)
							OR (
								@Secondop9 = @DoesNotContain
								AND LastUpdate NOT LIKE '%' + @SecondLastUpdateVarchar + '%'
								)
							OR (
								@Secondop9 = @StartsWith
								AND LastUpdate LIKE '' + @SecondLastUpdateVarchar + '%'
								)
							OR (
								@Secondop9 = @EndsWith
								AND LastUpdate LIKE '%' + @SecondLastUpdateVarchar + ''
								)
							)
						)
					)
				OR (
					@Secondop9 IS NULL
					AND (
						(
							@op9 = @IsEqualTo
							AND LastUpdate = @LastUpdate
							)
						OR (
							@op9 = @IsNotEqualTo
							AND LastUpdate <> @LastUpdate
							)
						OR (
							@op9 = @IsLessThan
							AND LastUpdate < @LastUpdate
							)
						OR (
							@op9 = @IsLessThanOrEqualTo
							AND LastUpdate <= @LastUpdate
							)
						OR (
							@op9 = @IsGreaterThan
							AND LastUpdate > @LastUpdate
							)
						OR (
							@op9 = @IsGreaterThanOrEqualTo
							AND LastUpdate >= @LastUpdate
							)
						OR (
							@op9 = @Contains
							AND LastUpdate LIKE '%' + @LastUpdateVarchar + '%'
							)
						OR (
							@op9 = @DoesNotContain
							AND LastUpdate NOT LIKE '%' + @LastUpdateVarchar + '%'
							)
						OR (
							@op9 = @StartsWith
							AND LastUpdate LIKE '' + @LastUpdateVarchar + '%'
							)
						OR (
							@op9 = @EndsWith
							AND LastUpdate LIKE '%' + @LastUpdateVarchar + ''
							)
						)
					)
				)
			AND (
				(@op10 IS NULL)
				OR (
					@op10 = @IsEqualTo
					AND Comments = @Comments
					)
				OR (
					@op10 = @IsNotEqualTo
					AND Comments <> @Comments
					)
				OR (
					@op10 = @IsLessThan
					AND Comments < @Comments
					)
				OR (
					@op10 = @IsLessThanOrEqualTo
					AND Comments <= @Comments
					)
				OR (
					@op10 = @IsGreaterThan
					AND Comments > @Comments
					)
				OR (
					@op10 = @IsGreaterThanOrEqualTo
					AND Comments >= @Comments
					)
				OR (
					@op10 = @Contains
					AND Comments LIKE '%' + @Comments + '%'
					)
				OR (
					@op10 = @DoesNotContain
					AND Comments NOT LIKE '%' + @Comments + '%'
					)
				OR (
					@op10 = @StartsWith
					AND Comments LIKE '' + @Comments + '%'
					)
				OR (
					@op10 = @EndsWith
					AND Comments LIKE '%' + @Comments + ''
					)
				)
		OPTION (RECOMPILE)
		END
		SELECT *
		FROM (
			SELECT SS.SIGUIDReference AS Id
				,SerialNumber
				,SS.STName AS [Type]
				,SS.SICreationTimeStamp AS CreationTimeStamp
				,dbo.GetTranslationValue(SS.SDLabel_Id, @pCultureCode) AS [Status]
				,SS.SIGPSUpdateTimestamp AS LastUpdate
				,SS.SLGUIDReference AS LocationId
				,CASE 
					WHEN SS.GSLLocation IS NOT NULL
						THEN CAST(SS.GSLLocation AS VARCHAR)
					WHEN c.GUIDReference IS NOT NULL
						THEN dbo.[GetGroupSequence](c.Sequence, c.CountryId)
					WHEN i2.IndividualId IS NOT NULL
						THEN CAST(i2.IndividualId AS VARCHAR)
					END AS Location
				,
				'' AS Model,'' AS [Range],'' AS Software,'' AS Conectivity,			
				CASE 
					WHEN SS.GSLLocation IS NOT NULL
						THEN ''
					WHEN c.GUIDReference IS NOT NULL
						THEN dbo.[GetGroupSequence](c.Sequence, c.CountryId)
					WHEN i2.IndividualId IS NOT NULL
						THEN CAST(i2.IndividualId AS VARCHAR)
					END AS MainContactBussinesId
				,'' AS Comments
			FROM (
			SELECT SI.GUIDReference AS SIGUIDReference,ST.GUIDReference AS STGUIDReference,spl.Panelist_Id,ST.CountryId AS  STCountryId
			,GSL.Location AS GSLLocation
			,SI.GUIDReference AS SIId
				,SerialNumber
				,ST.Name AS STName
				,SI.CreationTimeStamp AS SICreationTimeStamp
				,SD.Label_Id AS SDLabel_Id
				,CAST(SI.GPSUpdateTimestamp AS DATE) AS SIGPSUpdateTimestamp
				,SL.GUIDReference AS SLGUIDReference
			 FROM 
			 StockItem SI
			INNER JOIN StockType ST ON ST.GUIDReference = SI.Type_Id
			INNER JOIN StateDefinition SD ON SD.Id = SI.State_Id
			INNER JOIN StockLocation SL ON SL.GUIDReference = SI.Location_Id
			LEFT JOIN GenericStockLocation GSL ON GSL.GUIDReference = SL.GUIDReference
			LEFT JOIN StockPanelistLocation SPL ON SPL.GUIDReference = SL.GUIDReference
			WHERE @pCountryID =ST.CountryId
			AND SI.SerialNumber=ISNULL(@pSerialNumber,SI.SerialNumber)
			) AS SS
			LEFT JOIN Panelist p ON p.GUIDReference = SS.Panelist_Id
			LEFT JOIN (
			SELECT DISTINCT Group_Id FROM
			CollectiveMembership ) cm ON cm.Group_Id = p.PanelMember_Id
			LEFT JOIN Collective c ON c.GUIDReference = cm.Group_Id
			LEFT JOIN Individual i2 ON i2.GUIDReference = p.PanelMember_Id
			) AS TEMPTABLE
		WHERE (
				(@op1 IS NULL)
				OR (
					@op1 = @IsEqualTo
					AND SerialNumber = @SerialNumber
					)
				OR (
					@op1 = @IsNotEqualTo
					AND SerialNumber <> @SerialNumber
					)
				OR (
					@op1 = @IsLessThan
					AND SerialNumber < @SerialNumber
					)
				OR (
					@op1 = @IsLessThanOrEqualTo
					AND SerialNumber <= @SerialNumber
					)
				OR (
					@op1 = @IsGreaterThan
					AND SerialNumber > @SerialNumber
					)
				OR (
					@op1 = @IsGreaterThanOrEqualTo
					AND SerialNumber >= @SerialNumber
					)
				OR (
					@op1 = @Contains
					AND SerialNumber LIKE '%' + @SerialNumber + '%'
					)
				OR (
					@op1 = @DoesNotContain
					AND SerialNumber NOT LIKE '%' + @SerialNumber + '%'
					)
				OR (
					@op1 = @StartsWith
					AND SerialNumber LIKE '' + @SerialNumber + '%'
					)
				OR (
					@op1 = @EndsWith
					AND SerialNumber LIKE '%' + @SerialNumber + ''
					)
				)
			AND (
				(@op2 IS NULL)
				OR (
					@op2 = @IsEqualTo
					AND Location = @Location
					)
				OR (
					@op2 = @IsNotEqualTo
					AND Location <> @Location
					)
				OR (
					@op2 = @IsLessThan
					AND Location < @Location
					)
				OR (
					@op2 = @IsLessThanOrEqualTo
					AND Location <= @Location
					)
				OR (
					@op2 = @IsGreaterThan
					AND Location > @Location
					)
				OR (
					@op2 = @IsGreaterThanOrEqualTo
					AND Location >= @Location
					)
				OR (
					@op2 = @Contains
					AND Location LIKE '%' + @Location + '%'
					)
				OR (
					@op2 = @DoesNotContain
					AND Location NOT LIKE '%' + @Location + '%'
					)
				OR (
					@op2 = @StartsWith
					AND Location LIKE '' + @Location + '%'
					)
				OR (
					@op2 = @EndsWith
					AND Location LIKE '%' + @Location + ''
					)
				)
			AND (
				(@op3 IS NULL)
				OR (
					@op3 = @IsEqualTo
					AND [Type] = @Type
					)
				OR (
					@op3 = @IsNotEqualTo
					AND [Type] <> @Type
					)
				OR (
					@op3 = @IsLessThan
					AND [Type] < @Type
					)
				OR (
					@op3 = @IsLessThanOrEqualTo
					AND [Type] <= @Type
					)
				OR (
					@op3 = @IsGreaterThan
					AND [Type] > @Type
					)
				OR (
					@op3 = @IsGreaterThanOrEqualTo
					AND [Type] >= @Type
					)
				OR (
					@op3 = @Contains
					AND [Type] LIKE '%' + @Type + '%'
					)
				OR (
					@op3 = @DoesNotContain
					AND [Type] NOT LIKE '%' + @Type + '%'
					)
				OR (
					@op3 = @StartsWith
					AND [Type] LIKE '' + @Type + '%'
					)
				OR (
					@op3 = @EndsWith
					AND [Type] LIKE '%' + @Type + ''
					)
				)
			AND (
				(@op4 IS NULL)
				OR (
					@op4 = @IsEqualTo
					AND [Range] = @Range
					)
				OR (
					@op4 = @IsNotEqualTo
					AND [Range] <> @Range
					)
				OR (
					@op4 = @IsLessThan
					AND [Range] < @Range
					)
				OR (
					@op4 = @IsLessThanOrEqualTo
					AND [Range] <= @Range
					)
				OR (
					@op4 = @IsGreaterThan
					AND [Range] > @Range
					)
				OR (
					@op4 = @IsGreaterThanOrEqualTo
					AND [Range] >= @Range
					)
				OR (
					@op4 = @Contains
					AND [Range] LIKE '%' + @Range + '%'
					)
				OR (
					@op4 = @DoesNotContain
					AND [Range] NOT LIKE '%' + @Range + '%'
					)
				OR (
					@op4 = @StartsWith
					AND [Range] LIKE '' + @Range + '%'
					)
				OR (
					@op4 = @EndsWith
					AND [Range] LIKE '%' + @Range + ''
					)
				)
			AND (
				(@op5 IS NULL)
				OR (
					@op5 = @IsEqualTo
					AND Conectivity = @Conectivity
					)
				OR (
					@op5 = @IsNotEqualTo
					AND Conectivity <> @Conectivity
					)
				OR (
					@op5 = @IsLessThan
					AND Conectivity < @Conectivity
					)
				OR (
					@op5 = @IsLessThanOrEqualTo
					AND Conectivity <= @Conectivity
					)
				OR (
					@op5 = @IsGreaterThan
					AND Conectivity > @Conectivity
					)
				OR (
					@op5 = @IsGreaterThanOrEqualTo
					AND Conectivity >= @Conectivity
					)
				OR (
					@op5 = @Contains
					AND Conectivity LIKE '%' + @Conectivity + '%'
					)
				OR (
					@op5 = @DoesNotContain
					AND Conectivity NOT LIKE '%' + @Conectivity + '%'
					)
				OR (
					@op5 = @StartsWith
					AND Conectivity LIKE '' + @Conectivity + '%'
					)
				OR (
					@op5 = @EndsWith
					AND Conectivity LIKE '%' + @Conectivity + ''
					)
				)
			AND (
				(@op6 IS NULL)
				OR (
					@op6 = @IsEqualTo
					AND Software = @Software
					)
				OR (
					@op6 = @IsNotEqualTo
					AND Software <> @Software
					)
				OR (
					@op6 = @IsLessThan
					AND Software < @Software
					)
				OR (
					@op6 = @IsLessThanOrEqualTo
					AND Software <= @Software
					)
				OR (
					@op6 = @IsGreaterThan
					AND Software > @Software
					)
				OR (
					@op6 = @IsGreaterThanOrEqualTo
					AND Software >= @Software
					)
				OR (
					@op6 = @Contains
					AND Software LIKE '%' + @Software + '%'
					)
				OR (
					@op6 = @DoesNotContain
					AND Software NOT LIKE '%' + @Software + '%'
					)
				OR (
					@op6 = @StartsWith
					AND Software LIKE '' + @Software + '%'
					)
				OR (
					@op6 = @EndsWith
					AND Software LIKE '%' + @Software + ''
					)
				)
			AND (
				(@op7 IS NULL)
				OR (
					@op7 = @IsEqualTo
					AND Model = @Model
					)
				OR (
					@op7 = @IsNotEqualTo
					AND Model <> @Model
					)
				OR (
					@op7 = @IsLessThan
					AND Model < @Model
					)
				OR (
					@op7 = @IsLessThanOrEqualTo
					AND Model <= @Model
					)
				OR (
					@op7 = @IsGreaterThan
					AND Model > @Model
					)
				OR (
					@op7 = @IsGreaterThanOrEqualTo
					AND Model >= @Model
					)
				OR (
					@op7 = @Contains
					AND Model LIKE '%' + @Model + '%'
					)
				OR (
					@op7 = @DoesNotContain
					AND Model NOT LIKE '%' + @Model + '%'
					)
				OR (
					@op7 = @StartsWith
					AND Model LIKE '' + @Model + '%'
					)
				OR (
					@op7 = @EndsWith
					AND Model LIKE '%' + @Model + ''
					)
				)
			AND (
				(@op8 IS NULL)
				OR (
					@op8 = @IsEqualTo
					AND [Status] = @Status
					)
				OR (
					@op8 = @IsNotEqualTo
					AND [Status] <> @Status
					)
				OR (
					@op8 = @IsLessThan
					AND [Status] < @Status
					)
				OR (
					@op8 = @IsLessThanOrEqualTo
					AND [Status] <= @Status
					)
				OR (
					@op8 = @IsGreaterThan
					AND [Status] > @Status
					)
				OR (
					@op8 = @IsGreaterThanOrEqualTo
					AND [Status] >= @Status
					)
				OR (
					@op8 = @Contains
					AND [Status] LIKE '%' + @Status + '%'
					)
				OR (
					@op8 = @DoesNotContain
					AND [Status] NOT LIKE '%' + @Status + '%'
					)
				OR (
					@op8 = @StartsWith
					AND [Status] LIKE '' + @Status + '%'
					)
				OR (
					@op8 = @EndsWith
					AND [Status] LIKE '%' + @Status + ''
					)
				)
			AND (
				(@op9 IS NULL)
				OR (
					@op9 IS NULL
					AND @LogicalOperator9 IS NULL
					)
				OR (
					@LogicalOperator9 = 'OR'
					AND (
						(
							(
								@op9 = @IsEqualTo
								AND LastUpdate = @LastUpdate
								)
							OR (
								@op9 = @IsNotEqualTo
								AND LastUpdate <> @LastUpdate
								)
							OR (
								@op9 = @IsLessThan
								AND LastUpdate < @LastUpdate
								)
							OR (
								@op9 = @IsLessThanOrEqualTo
								AND LastUpdate <= @LastUpdate
								)
							OR (
								@op9 = @IsGreaterThan
								AND LastUpdate > @LastUpdate
								)
							OR (
								@op9 = @IsGreaterThanOrEqualTo
								AND LastUpdate >= @LastUpdate
								)
							OR (
								@op9 = @Contains
								AND LastUpdate LIKE '%' + @LastUpdateVarchar + '%'
								)
							OR (
								@op9 = @DoesNotContain
								AND LastUpdate NOT LIKE '%' + @LastUpdateVarchar + '%'
								)
							OR (
								@op9 = @StartsWith
								AND LastUpdate LIKE '' + @LastUpdateVarchar + '%'
								)
							OR (
								@op9 = @EndsWith
								AND LastUpdate LIKE '%' + @LastUpdateVarchar + ''
								)
							)
						OR (
							(
								@Secondop9 = @IsEqualTo
								AND LastUpdate = @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsNotEqualTo
								AND LastUpdate <> @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsLessThan
								AND LastUpdate < @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsLessThanOrEqualTo
								AND LastUpdate <= @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsGreaterThan
								AND LastUpdate > @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsGreaterThanOrEqualTo
								AND LastUpdate >= @SecondLastUpdate
								)
							OR (
								@Secondop9 = @Contains
								AND LastUpdate LIKE '%' + @SecondLastUpdateVarchar + '%'
								)
							OR (
								@Secondop9 = @DoesNotContain
								AND LastUpdate NOT LIKE '%' + @SecondLastUpDateVarchar + '%'
								)
							OR (
								@Secondop9 = @StartsWith
								AND LastUpdate LIKE '' + @SecondLastUpdateVarchar + '%'
								)
							OR (
								@Secondop9 = @EndsWith
								AND LastUpdate LIKE '%' + @SecondLastUpdateVarchar + ''
								)
							)
						)
					)
				OR (
					@LogicalOperator9 = 'AND'
					AND (
						(
							(
								@op9 = @IsEqualTo
								AND LastUpdate = @LastUpdate
								)
							OR (
								@op9 = @IsNotEqualTo
								AND LastUpdate <> @LastUpdate
								)
							OR (
								@op9 = @IsLessThan
								AND LastUpdate < @LastUpdate
								)
							OR (
								@op9 = @IsLessThanOrEqualTo
								AND LastUpdate <= @LastUpdate
								)
							OR (
								@op9 = @IsGreaterThan
								AND LastUpdate > @LastUpdate
								)
							OR (
								@op9 = @IsGreaterThanOrEqualTo
								AND LastUpdate >= @LastUpdate
								)
							OR (
								@op9 = @Contains
								AND LastUpdate LIKE '%' + @LastUpdateVarchar + '%'
								)
							OR (
								@op9 = @DoesNotContain
								AND LastUpdate NOT LIKE '%' + @LastUpdateVarchar + '%'
								)
							OR (
								@op9 = @StartsWith
								AND LastUpdate LIKE '' + @LastUpdateVarchar + '%'
								)
							OR (
								@op9 = @EndsWith
								AND LastUpdate LIKE '%' + @LastUpdateVarchar + ''
								)
							)
						AND (
							(
								@Secondop9 = @IsEqualTo
								AND LastUpdate = @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsNotEqualTo
								AND LastUpdate <> @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsLessThan
								AND LastUpdate < @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsLessThanOrEqualTo
								AND LastUpdate <= @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsGreaterThan
								AND LastUpdate > @SecondLastUpdate
								)
							OR (
								@Secondop9 = @IsGreaterThanOrEqualTo
								AND LastUpdate >= @SecondLastUpdate
								)
							OR (
								@Secondop9 = @Contains
								AND LastUpdate LIKE '%' + @SecondLastUpdateVarchar + '%'
								)
							OR (
								@Secondop9 = @DoesNotContain
								AND LastUpdate NOT LIKE '%' + @SecondLastUpdateVarchar + '%'
								)
							OR (
								@Secondop9 = @StartsWith
								AND LastUpdate LIKE '' + @SecondLastUpdateVarchar + '%'
								)
							OR (
								@Secondop9 = @EndsWith
								AND LastUpdate LIKE '%' + @SecondLastUpdateVarchar + ''
								)
							)
						)
					)
				OR (
					@Secondop9 IS NULL
					AND (
						(
							@op9 = @IsEqualTo
							AND LastUpdate = @LastUpdate
							)
						OR (
							@op9 = @IsNotEqualTo
							AND LastUpdate <> @LastUpdate
							)
						OR (
							@op9 = @IsLessThan
							AND LastUpdate < @LastUpdate
							)
						OR (
							@op9 = @IsLessThanOrEqualTo
							AND LastUpdate <= @LastUpdate
							)
						OR (
							@op9 = @IsGreaterThan
							AND LastUpdate > @LastUpdate
							)
						OR (
							@op9 = @IsGreaterThanOrEqualTo
							AND LastUpdate >= @LastUpdate
							)
						OR (
							@op9 = @Contains
							AND LastUpdate LIKE '%' + @LastUpdateVarchar + '%'
							)
						OR (
							@op9 = @DoesNotContain
							AND LastUpdate NOT LIKE '%' + @LastUpdateVarchar + '%'
							)
						OR (
							@op9 = @StartsWith
							AND LastUpdate LIKE '' + @LastUpdateVarchar + '%'
							)
						OR (
							@op9 = @EndsWith
							AND LastUpdate LIKE '%' + @LastUpdateVarchar + ''
							)
						)
					)
				)
			AND (
				(@op10 IS NULL)
				OR (
					@op10 = @IsEqualTo
					AND Comments = @Comments
					)
				OR (
					@op10 = @IsNotEqualTo
					AND Comments <> @Comments
					)
				OR (
					@op10 = @IsLessThan
					AND Comments < @Comments
					)
				OR (
					@op10 = @IsLessThanOrEqualTo
					AND Comments <= @Comments
					)
				OR (
					@op10 = @IsGreaterThan
					AND Comments > @Comments
					)
				OR (
					@op10 = @IsGreaterThanOrEqualTo
					AND Comments >= @Comments
					)
				OR (
					@op10 = @Contains
					AND Comments LIKE '%' + @Comments + '%'
					)
				OR (
					@op10 = @DoesNotContain
					AND Comments NOT LIKE '%' + @Comments + '%'
					)
				OR (
					@op10 = @StartsWith
					AND Comments LIKE '' + @Comments + '%'
					)
				OR (
					@op10 = @EndsWith
					AND Comments LIKE '%' + @Comments + ''
					)
				)
		ORDER BY CASE 
				WHEN @pOrderBy = 'SerialNumber'
					AND @pOrderType = 'ASC'
					THEN SerialNumber
				END ASC
			,CASE 
				WHEN @pOrderBy = 'SerialNumber'
					AND @pOrderType = 'DESC'
					THEN SerialNumber
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Location'
					AND @pOrderType = 'ASC'
					THEN Location
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Location'
					AND @pOrderType = 'DESC'
					THEN Location
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Type'
					AND @pOrderType = 'ASC'
					THEN [Type]
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Type'
					AND @pOrderType = 'DESC'
					THEN [Type]
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Range'
					AND @pOrderType = 'ASC'
					THEN [Range]
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Range'
					AND @pOrderType = 'DESC'
					THEN [Range]
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Conectivity'
					AND @pOrderType = 'ASC'
					THEN Conectivity
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Conectivity'
					AND @pOrderType = 'DESC'
					THEN Conectivity
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Software'
					AND @pOrderType = 'ASC'
					THEN Software
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Software'
					AND @pOrderType = 'DESC'
					THEN Software
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Model'
					AND @pOrderType = 'ASC'
					THEN Model
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Model'
					AND @pOrderType = 'DESC'
					THEN Model
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Status'
					AND @pOrderType = 'ASC'
					THEN [Status]
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Status'
					AND @pOrderType = 'DESC'
					THEN [Status]
				END DESC
			,CASE 
				WHEN @pOrderBy = 'LastUpdate'
					AND @pOrderType = 'ASC'
					THEN LastUpdate
				END ASC
			,CASE 
				WHEN @pOrderBy = 'LastUpdate'
					AND @pOrderType = 'DESC'
					THEN LastUpdate
				END DESC
			,CASE 
				WHEN @pOrderBy = 'Comments'
					AND @pOrderType = 'ASC'
					THEN Comments
				END ASC
			,CASE 
				WHEN @pOrderBy = 'Comments'
					AND @pOrderType = 'DESC'
					THEN Comments
				END DESC OFFSET @OFFSETRows ROWS

		FETCH NEXT @pPageSize ROWS ONLY
		OPTION (RECOMPILE)
END