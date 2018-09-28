/*##########################################################################
-- Name             : AccountTransactionsList
-- Date             : 2014-11-08
-- Author           : Venkata Ramana
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure used to get the individual Incentive Account details
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        :
-- PARAM Definitions:
		@pindividualID NVARCHAR(20)-- Individual GUID reference Of IndividualTable
		@pCultureCode INT -- Culture Code of type int		      
-- Sample Execution :
       exec usp_AccountTransactionsList 'bc05a5fd-cb7e-c4f4-c1a6-08d11b004586',2057                                    
##########################################################################
-- ver  user               date        change 
-- 1.0  Venkata Ramana     2014-11-08 initail
-- 1.1  Matias Fernandez   2016-06-07 Added support for 'All panels'
##########################################################################*/
CREATE PROCEDURE [dbo].[GetAccountTransactionsList] @pindividualId UNIQUEIDENTIFIER

	,@pCultureCode INT = NULL

	,@OrderBy VARCHAR(100)

	,@OrderType VARCHAR(10) -- ASC or DESC

	,@PageNumber INT = 1

	,@PageSize INT = 100

	,@IsExport BIT = 0

	,@ParametersTable dbo.GridParametersTable readonly

AS

BEGIN

	SET NOCOUNT ON;



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

		,@op11 VARCHAR(50)

		,@op12 VARCHAR(50)

	DECLARE @LogicalOperator1 VARCHAR(5)

		,@LogicalOperator12 VARCHAR(5)

	DECLARE @Secondop1 VARCHAR(50)

		,@Secondop12 VARCHAR(50)

	DECLARE @SecondTransactionDate DATE

		,@SecondSynchronisationDate DATE

	DECLARE @TransactionDate DATE

		,@PointType NVARCHAR(1000)

		,@Description NVARCHAR(1000)

		,@Comments NVARCHAR(1000)

		,@DeliveryType NVARCHAR(1000)

		,@HumanReadableId NVARCHAR(60)

		,@Amount INT

		,@PackageStatus NVARCHAR(1000)

		,@TransactionSource NVARCHAR(20)

		,@Code INT

		,@Origin NVARCHAR(1000)

		,@SynchronisationDate DATE



	SELECT @op1 = Opertor

		,@TransactionDate = CAST(ParameterValue AS DATE)

		,@Secondop1 = SecondParameterOperator

		,@SecondTransactionDate = CAST(SecondParameterValue AS DATE)

		,@LogicalOperator1 = LogicalOperator

	FROM @ParametersTable

	WHERE ParameterName = 'TransactionDate'



	SELECT @op2 = Opertor

		,@PointType = ParameterValue

	FROM @ParametersTable

	WHERE ParameterName = 'PointType'



	SELECT @op3 = Opertor

		,@Description = ParameterValue

	FROM @ParametersTable

	WHERE ParameterName = 'Description'



	SELECT @op4 = Opertor

		,@Comments = ParameterValue

	FROM @ParametersTable

	WHERE ParameterName = 'Comments'



	SELECT @op5 = Opertor

		,@DeliveryType = ParameterValue

	FROM @ParametersTable

	WHERE ParameterName = 'DeliveryType'



	SELECT @op6 = Opertor

		,@HumanReadableId = ParameterValue

	FROM @ParametersTable

	WHERE ParameterName = 'HumanReadableId'



	SELECT @op7 = Opertor

		,@Amount = ParameterValue

	FROM @ParametersTable

	WHERE ParameterName = 'Amount'



	SELECT @op8 = Opertor

		,@PackageStatus = ParameterValue

	FROM @ParametersTable

	WHERE ParameterName = 'PackageStatus'



	SELECT @op9 = Opertor

		,@TransactionSource = ParameterValue

	FROM @ParametersTable

	WHERE ParameterName = 'TransactionSource'



	SELECT @op10 = Opertor

		,@Code = ParameterValue

	FROM @ParametersTable

	WHERE ParameterName = 'Code'



	SELECT @op11 = Opertor

		,@Origin = ParameterValue

	FROM @ParametersTable

	WHERE ParameterName = 'Origin'



	SELECT @op12 = Opertor

		,@SynchronisationDate = CAST(ParameterValue AS DATE)

		,@Secondop12 = SecondParameterOperator

		,@SecondSynchronisationDate = cast(SecondParameterValue AS DATE)

		,@LogicalOperator12 = LogicalOperator

	FROM @ParametersTable

	WHERE ParameterName = 'SynchronisationDate'



	DECLARE @TransactionDateVarchar VARCHAR(100) = CAST(@TransactionDate AS VARCHAR)

		,@SecondTransactionDateVarchar VARCHAR(100) = CAST(@SecondTransactionDate AS VARCHAR)

		,@SynchronisationDateVarchar VARCHAR(100) = CAST(@SynchronisationDate AS VARCHAR)

		,@SecondSynchronisationDateVarchar VARCHAR(100) = CAST(@SecondSynchronisationDate AS VARCHAR)

		,@AmountVarchar VARCHAR(10) = CAST(@Amount AS VARCHAR)

		,@CodeVarchar VARCHAR(10) = CAST(@Code AS VARCHAR)

		,@OriginVarchar VARCHAR(10) = CAST(@Origin AS VARCHAR)

	DECLARE @OFFSETRows INT = 0



	IF (@OrderBy IS NULL)

		SET @OrderBy = 'TransactionDate'



	IF (@OrderType IS NULL)

		SET @OrderBy = 'desc'



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



	IF (@IsExport = 0)

		SET @OFFSETRows = (@PageSize * (@PageNumber - 1))

	ELSE

		SET @PageSize = 65000



	IF (@IsExport = 0)

	BEGIN

		SELECT COUNT(0) AS TotlaRows

		FROM (

			SELECT iat.IncentiveAccountTransactionId AS Id

				,iat.Balance

				,iat.TransactionDate AS TransactionDate

				,iat.Comments

				,c.CreationTimeStamp

				,dbo.[GetTranslationValue](ipae.TypeName_Id, @pCultureCode) AS [PointType]

				,(select IndividualId from Individual  where GUIDReference  =iat.Depositor_Id)  AS [HumanReadableId]

				,dbo.[GetTranslationValue](ip.Description_Id, @pCultureCode) AS [Description]

				,ip.RewardCode AS Code

				,'' AS Origin

				,(ISNULL(iati.Ammount, 0) * - 1) AS Debit

				,(ISNULL(iati.Ammount, 0) * - 1) AS Amount

				,0 AS Credit

				,0 AS IsCredit

				,dbo.[GetTranslationValue](sd.Label_Id, @pCultureCode) PackageStatus

				,CAST(iat.SynchronisationDate AS DATE) AS SynchronisationDate

				,dbo.[GetTranslationValue](rdt.Translation_Id, @pCultureCode) AS DeliveryType

				,ts.Code AS TransactionSource

			FROM IncentiveAccount ia

			INNER JOIN Individual i ON i.GUIDReference = ia.IncentiveAccountId

			INNER JOIN Candidate c ON c.GUIDReference = ia.IncentiveAccountId

			INNER JOIN IncentiveAccountTransaction iat ON ia.IncentiveAccountId = iat.Account_Id

				AND iat.Type = 'Debit'

			LEFT JOIN IncentiveAccountTransactionInfo iati ON iati.IncentiveAccountTransactionInfoId = iat.TransactionInfo_Id

			LEFT JOIN TransactionSource ts ON iat.TransactionSource_Id = ts.TransactionSourceId

			LEFT JOIN IncentivePoint ip ON ip.GUIDReference = iati.Point_Id

			LEFT JOIN IncentivePointAccountEntryType ipae ON ipae.GUIDReference = ip.Type_Id

			LEFT JOIN Package p ON p.Debit_Id = iat.IncentiveAccountTransactionId

			LEFT JOIN StateDefinition sd ON sd.Id = p.State_Id

			LEFT JOIN RewardDeliveryType rdt ON rdt.RewardDeliveryTypeId = iati.RewardDeliveryType_Id

			WHERE c.GUIDReference = @pindividualId

			

			UNION

			

			SELECT iat.IncentiveAccountTransactionId AS Id

				,iat.Balance

				,iat.TransactionDate AS TransactionDate

				,iat.Comments

				,c.CreationTimeStamp

				,dbo.[GetTranslationValue](ipae.TypeName_Id, @pCultureCode) AS [PointType]

				,(select IndividualId from Individual  where GUIDReference =iat.Depositor_Id) AS [HumanReadableId]

				,dbo.[GetTranslationValue](ip.Description_Id, @pCultureCode) [Description]

				,ip.Code

				,IIF(ISNULL(ip.HasAllPanels, 0) = 1 AND iat.Panel_Id IS NULL, dbo.[GetTranslationValue](t.TranslationId, @pCultureCode), ISNULL(p.Name, '')) AS Origin
				
				,0 AS Debit

				,iati.Ammount AS Credit

				,iati.Ammount AS Amount

				,1 AS IsCredit

				,'' AS PackageStatus

				,CAST(iat.SynchronisationDate AS DATE) AS SynchronisationDate

				,'' AS DeliveryType

				,ts.Code AS TransactionSource

			FROM IncentiveAccount ia

			INNER JOIN Candidate c ON c.GUIDReference = ia.IncentiveAccountId

			INNER JOIN IncentiveAccountTransaction iat ON ia.IncentiveAccountId = iat.Account_Id

				AND iat.Type = 'Credit'

			INNER JOIN Individual i ON i.GUIDReference = iat.Account_Id

			LEFT JOIN Translation t ON t.Keyname='AllPanels'

			LEFT JOIN IncentiveAccountTransactionInfo iati ON iati.IncentiveAccountTransactionInfoId = iat.TransactionInfo_Id

			LEFT JOIN TransactionSource ts ON iat.TransactionSource_Id = ts.TransactionSourceId

			LEFT JOIN IncentivePoint ip ON ip.GUIDReference = iati.Point_Id

			LEFT JOIN IncentivePointAccountEntryType ipae ON ipae.GUIDReference = ip.[Type_Id]

			LEFT JOIN Panel p ON p.GUIDReference = iat.Panel_Id

			WHERE c.GUIDReference = @pindividualId

			) AS outputtable

		WHERE (

				(@op1 IS NULL)

				OR (

					@op1 IS NULL

					AND @LogicalOperator1 IS NULL

					)

				OR (

					@LogicalOperator1 = 'OR'

					AND (

						(

							(

								@op1 = @IsEqualTo

								AND TransactionDate = @TransactionDate

								)

							OR (

								@op1 = @IsNotEqualTo

								AND TransactionDate <> @TransactionDate

								)

							OR (

								@op1 = @IsLessThan

								AND TransactionDate < @TransactionDate

								)

							OR (

								@op1 = @IsLessThanOrEqualTo

								AND TransactionDate <= @TransactionDate

								)

							OR (

								@op1 = @IsGreaterThan

								AND TransactionDate > @TransactionDate

								)

							OR (

								@op1 = @IsGreaterThanOrEqualTo

								AND TransactionDate >= @TransactionDate

								)

							OR (

								@op1 = @Contains

								AND TransactionDate LIKE '%' + @TransactionDateVarchar + '%'

								)

							OR (

								@op1 = @DoesNotContain

								AND TransactionDate NOT LIKE '%' + @TransactionDateVarchar + '%'

								)

							OR (

								@op1 = @StartsWith

								AND TransactionDate LIKE '' + @TransactionDateVarchar + '%'

								)

							OR (

								@op1 = @EndsWith

								AND TransactionDate LIKE '%' + @TransactionDateVarchar + ''

								)

							)

						OR (

							(

								@Secondop1 = @IsEqualTo

								AND TransactionDate = @SecondTransactionDate

								)

							OR (

								@Secondop1 = @IsNotEqualTo

								AND TransactionDate <> @SecondTransactionDate

								)

							OR (

								@Secondop1 = @IsLessThan

								AND TransactionDate < @SecondTransactionDate

								)

							OR (

								@Secondop1 = @IsLessThanOrEqualTo

								AND TransactionDate <= @SecondTransactionDate

								)

							OR (

								@Secondop1 = @IsGreaterThan

								AND TransactionDate > @SecondTransactionDate

								)

							OR (

								@Secondop1 = @IsGreaterThanOrEqualTo

								AND TransactionDate >= @SecondTransactionDate

								)

							OR (

								@Secondop1 = @Contains

								AND TransactionDate LIKE '%' + @SecondTransactionDateVarchar + '%'

								)

							OR (

								@Secondop1 = @DoesNotContain

								AND TransactionDate NOT LIKE '%' + @SecondTransactionDateVarchar + '%'

								)

							OR (

								@Secondop1 = @StartsWith

								AND TransactionDate LIKE '' + @SecondTransactionDateVarchar + '%'

								)

							OR (

								@Secondop1 = @EndsWith

								AND TransactionDate LIKE '%' + @SecondTransactionDateVarchar + ''

								)

							)

						)

					)

				OR (

					@LogicalOperator1 = 'AND'

					AND (

						(

							(

								@op1 = @IsEqualTo

								AND TransactionDate = @TransactionDate

								)

							OR (

								@op1 = @IsNotEqualTo

								AND TransactionDate <> @TransactionDate

								)

							OR (

								@op1 = @IsLessThan

								AND TransactionDate < @TransactionDate

								)

							OR (

								@op1 = @IsLessThanOrEqualTo

								AND TransactionDate <= @TransactionDate

								)

							OR (

								@op1 = @IsGreaterThan

								AND TransactionDate > @TransactionDate

								)

							OR (

								@op1 = @IsGreaterThanOrEqualTo

								AND TransactionDate >= @TransactionDate

								)

							OR (

								@op1 = @Contains

								AND TransactionDate LIKE '%' + @TransactionDateVarchar + '%'

								)

							OR (

								@op1 = @DoesNotContain

								AND TransactionDate NOT LIKE '%' + @TransactionDateVarchar + '%'

								)

							OR (

								@op1 = @StartsWith

								AND TransactionDate LIKE '' + @TransactionDateVarchar + '%'

								)

							OR (

								@op1 = @EndsWith

								AND TransactionDate LIKE '%' + @TransactionDateVarchar + ''

								)

							)

						AND (

							(

								@Secondop1 = @IsEqualTo

								AND TransactionDate = @SecondTransactionDate

								)

							OR (

								@Secondop1 = @IsNotEqualTo

								AND TransactionDate <> @SecondTransactionDate

								)

							OR (

								@Secondop1 = @IsLessThan

								AND TransactionDate < @SecondTransactionDate

								)

							OR (

								@Secondop1 = @IsLessThanOrEqualTo

								AND TransactionDate <= @SecondTransactionDate

								)

							OR (

								@Secondop1 = @IsGreaterThan

								AND TransactionDate > @SecondTransactionDate

								)

							OR (

								@Secondop1 = @IsGreaterThanOrEqualTo

								AND TransactionDate >= @SecondTransactionDate

								)

							OR (

								@Secondop1 = @Contains

								AND TransactionDate LIKE '%' + @SecondTransactionDateVarchar + '%'

								)

							OR (

								@Secondop1 = @DoesNotContain

								AND TransactionDate NOT LIKE '%' + @SecondTransactionDateVarchar + '%'

								)

							OR (

								@Secondop1 = @StartsWith

								AND TransactionDate LIKE '' + @SecondTransactionDateVarchar + '%'

								)

							OR (

								@Secondop1 = @EndsWith

								AND TransactionDate LIKE '%' + @SecondTransactionDateVarchar + ''

								)

							)

						)

					)

				OR (

					@op1 = @IsEqualTo AND @Secondop1 IS NULL

					AND TransactionDate = @TransactionDate

					)

				OR (

					@op1 = @IsNotEqualTo AND @Secondop1 IS NULL

					AND TransactionDate <> @TransactionDate

					)

				OR (

					@op1 = @IsLessThan AND @Secondop1 IS NULL

					AND TransactionDate < @TransactionDate

					)

				OR (

					@op1 = @IsLessThanOrEqualTo AND @Secondop1 IS NULL

					AND TransactionDate <= @TransactionDate

					)

				OR (

					@op1 = @IsGreaterThan AND @Secondop1 IS NULL

					AND TransactionDate > @TransactionDate

					)

				OR (

					@op1 = @IsGreaterThanOrEqualTo AND @Secondop1 IS NULL

					AND TransactionDate >= @TransactionDate

					)

				OR (

					@op1 = @Contains AND @Secondop1 IS NULL

					AND TransactionDate LIKE '%' + @TransactionDateVarchar + '%'

					)

				OR (

					@op1 = @DoesNotContain AND @Secondop1 IS NULL

					AND TransactionDate NOT LIKE '%' + @TransactionDateVarchar + '%'

					)

				OR (

					@op1 = @StartsWith AND @Secondop1 IS NULL

					AND TransactionDate LIKE '' + @TransactionDateVarchar + '%'

					)

				OR (

					@op1 = @EndsWith AND @Secondop1 IS NULL

					AND TransactionDate LIKE '%' + @TransactionDateVarchar + ''

					)

				)

			AND (

				(@op2 IS NULL)

				OR (

					@op2 = @IsEqualTo

					AND PointType = @PointType

					)

				OR (

					@op2 = @IsNotEqualTo

					AND PointType <> @PointType

					)

				OR (

					@op2 = @IsLessThan

					AND PointType < @PointType

					)

				OR (

					@op2 = @IsLessThanOrEqualTo

					AND PointType <= @PointType

					)

				OR (

					@op2 = @IsGreaterThan

					AND PointType > @PointType

					)

				OR (

					@op2 = @IsGreaterThanOrEqualTo

					AND PointType >= @PointType

					)

				OR (

					@op2 = @Contains

					AND PointType LIKE '%' + @PointType + '%'

					)

				OR (

					@op2 = @DoesNotContain

					AND PointType NOT LIKE '%' + @PointType + '%'

					)

				OR (

					@op2 = @StartsWith

					AND PointType LIKE '' + @PointType + '%'

					)

				OR (

					@op2 = @EndsWith

					AND PointType LIKE '%' + @PointType + ''

					)

				)

			AND (

				(@op3 IS NULL)

				OR (

					@op3 = @IsEqualTo

					AND [Description] = @Description

					)

				OR (

					@op3 = @IsNotEqualTo

					AND [Description] <> @Description

					)

				OR (

					@op3 = @IsLessThan

					AND [Description] < @Description

					)

				OR (

					@op3 = @IsLessThanOrEqualTo

					AND [Description] <= @Description

					)

				OR (

					@op3 = @IsGreaterThan

					AND [Description] > @Description

					)

				OR (

					@op3 = @IsGreaterThanOrEqualTo

					AND [Description] >= @Description

					)

				OR (

					@op3 = @Contains

					AND [Description] LIKE '%' + @Description + '%'

					)

				OR (

					@op3 = @DoesNotContain

					AND [Description] NOT LIKE '%' + @Description + '%'

					)

				OR (

					@op3 = @StartsWith

					AND [Description] LIKE '' + @Description + '%'

					)

				OR (

					@op3 = @EndsWith

					AND [Description] LIKE '%' + @Description + ''

					)

				)

			AND (

				(@op4 IS NULL)

				OR (

					@op4 = @IsEqualTo

					AND Comments = @Comments

					)

				OR (

					@op4 = @IsNotEqualTo

					AND Comments <> @Comments

					)

				OR (

					@op4 = @IsLessThan

					AND Comments < @Comments

					)

				OR (

					@op4 = @IsLessThanOrEqualTo

					AND Comments <= @Comments

					)

				OR (

					@op4 = @IsGreaterThan

					AND Comments > @Comments

					)

				OR (

					@op4 = @IsGreaterThanOrEqualTo

					AND Comments >= @Comments

					)

				OR (

					@op4 = @Contains

					AND Comments LIKE '%' + @Comments + '%'

					)

				OR (

					@op4 = @DoesNotContain

					AND Comments NOT LIKE '%' + @Comments + '%'

					)

				OR (

					@op4 = @StartsWith

					AND Comments LIKE '' + @Comments + '%'

					)

				OR (

					@op4 = @EndsWith

					AND Comments LIKE '%' + @Comments + ''

					)

				)

			AND (

				(@op5 IS NULL)

				OR (

					@op5 = @IsEqualTo

					AND DeliveryType = DeliveryType

					)

				OR (

					@op5 = @IsNotEqualTo

					AND DeliveryType <> @DeliveryType

					)

				OR (

					@op5 = @IsLessThan

					AND DeliveryType < @DeliveryType

					)

				OR (

					@op5 = @IsLessThanOrEqualTo

					AND DeliveryType <= @DeliveryType

					)

				OR (

					@op5 = @IsGreaterThan

					AND DeliveryType > @DeliveryType

					)

				OR (

					@op5 = @IsGreaterThanOrEqualTo

					AND DeliveryType >= @DeliveryType

					)

				OR (

					@op5 = @Contains

					AND DeliveryType LIKE '%' + @DeliveryType + '%'

					)

				OR (

					@op5 = @DoesNotContain

					AND DeliveryType NOT LIKE '%' + @DeliveryType + '%'

					)

				OR (

					@op5 = @StartsWith

					AND DeliveryType LIKE '' + @DeliveryType + '%'

					)

				OR (

					@op5 = @EndsWith

					AND DeliveryType LIKE '%' + @DeliveryType + ''

					)

				)

			AND (

				(@op6 IS NULL)

				OR (

					@op6 = @IsEqualTo

					AND HumanReadableId = @HumanReadableId

					)

				OR (

					@op6 = @IsNotEqualTo

					AND HumanReadableId <> @HumanReadableId

					)

				OR (

					@op6 = @IsLessThan

					AND HumanReadableId < @HumanReadableId

					)

				OR (

					@op6 = @IsLessThanOrEqualTo

					AND HumanReadableId <= @HumanReadableId

					)

				OR (

					@op6 = @IsGreaterThan

					AND HumanReadableId > @HumanReadableId

					)

				OR (

					@op6 = @IsGreaterThanOrEqualTo

					AND HumanReadableId >= @HumanReadableId

					)

				OR (

					@op6 = @Contains

					AND HumanReadableId LIKE '%' + @HumanReadableId + '%'

					)

				OR (

					@op6 = @DoesNotContain

					AND HumanReadableId NOT LIKE '%' + @HumanReadableId + '%'

					)

				OR (

					@op6 = @StartsWith

					AND HumanReadableId LIKE '' + @HumanReadableId + '%'

					)

				OR (

					@op6 = @EndsWith

					AND HumanReadableId LIKE '%' + @HumanReadableId + ''

					)

				)

			AND (

				(@op7 IS NULL)

				OR (

					@op7 = @IsEqualTo

					AND Amount = @Amount

					)

				OR (

					@op7 = @IsNotEqualTo

					AND Amount <> @Amount

					)

				OR (

					@op7 = @IsLessThan

					AND Amount < @Amount

					)

				OR (

					@op7 = @IsLessThanOrEqualTo

					AND Amount <= @Amount

					)

				OR (

					@op7 = @IsGreaterThan

					AND Amount > @Amount

					)

				OR (

					@op7 = @IsGreaterThanOrEqualTo

					AND Amount >= @Amount

					)

				OR (

					@op7 = @Contains

					AND Amount LIKE '%' + @Amount + '%'

					)

				OR (

					@op7 = @DoesNotContain

					AND Amount NOT LIKE '%' + @Amount + '%'

					)

				OR (

					@op7 = @StartsWith

					AND Amount LIKE '' + @Amount + '%'

					)

				OR (

					@op7 = @EndsWith

					AND Amount LIKE '%' + @Amount + ''

					)

				)

			AND (

				(@op8 IS NULL)

				OR (

					@op8 = @IsEqualTo

					AND PackageStatus = @PackageStatus

					)

				OR (

					@op8 = @IsNotEqualTo

					AND PackageStatus <> @PackageStatus

					)

				OR (

					@op8 = @IsLessThan

					AND PackageStatus < @PackageStatus

					)

				OR (

					@op8 = @IsLessThanOrEqualTo

					AND PackageStatus <= @PackageStatus

					)

				OR (

					@op8 = @IsGreaterThan

					AND PackageStatus > @PackageStatus

					)

				OR (

					@op8 = @IsGreaterThanOrEqualTo

					AND PackageStatus >= @PackageStatus

					)

				OR (

					@op8 = @Contains

					AND PackageStatus LIKE '%' + @PackageStatus + '%'

					)

				OR (

					@op8 = @DoesNotContain

					AND PackageStatus NOT LIKE '%' + @PackageStatus + '%'

					)

				OR (

					@op8 = @StartsWith

					AND PackageStatus LIKE '' + @PackageStatus + '%'

					)

				OR (

					@op8 = @EndsWith

					AND PackageStatus LIKE '%' + @PackageStatus + ''

					)

				)

			AND (

				(@op9 IS NULL)

				OR (

					@op9 = @IsEqualTo

					AND TransactionSource = @TransactionSource

					)

				OR (

					@op9 = @IsNotEqualTo

					AND TransactionSource <> @TransactionSource

					)

				OR (

					@op9 = @IsLessThan

					AND TransactionSource < @TransactionSource

					)

				OR (

					@op9 = @IsLessThanOrEqualTo

					AND TransactionSource <= @TransactionSource

					)

				OR (

					@op9 = @IsGreaterThan

					AND TransactionSource > @TransactionSource

					)

				OR (

					@op9 = @IsGreaterThanOrEqualTo

					AND TransactionSource >= @TransactionSource

					)

				OR (

					@op9 = @Contains

					AND TransactionSource LIKE '%' + @TransactionSource + '%'

					)

				OR (

					@op9 = @DoesNotContain

					AND TransactionSource NOT LIKE '%' + @TransactionSource + '%'

					)

				OR (

					@op9 = @StartsWith

					AND TransactionSource LIKE '' + @TransactionSource + '%'

					)

				OR (

					@op9 = @EndsWith

					AND TransactionSource LIKE '%' + @TransactionSource + ''

					)

				)

			AND (

				(@op10 IS NULL)

				OR (

					@op10 = @IsEqualTo

					AND Code = @Code

					)

				OR (

					@op10 = @IsNotEqualTo

					AND Code <> @Code

					)

				OR (

					@op10 = @IsLessThan

					AND Code < @Code

					)

				OR (

					@op10 = @IsLessThanOrEqualTo

					AND Code <= @Code

					)

				OR (

					@op10 = @IsGreaterThan

					AND Code > @Code

					)

				OR (

					@op10 = @IsGreaterThanOrEqualTo

					AND Code >= @Code

					)

				OR (

					@op10 = @Contains

					AND Code LIKE '%' + @Code + '%'

					)

				OR (

					@op10 = @DoesNotContain

					AND Code NOT LIKE '%' + @Code + '%'

					)

				OR (

					@op10 = @StartsWith

					AND Code LIKE '' + @Code + '%'

					)

				OR (

					@op10 = @EndsWith

					AND Code LIKE '%' + @Code + ''

					)

				)

			AND (

				(@op11 IS NULL)

				OR (

					@op11 = @IsEqualTo

					AND Origin = @Origin

					)

				OR (

					@op11 = @IsNotEqualTo

					AND Origin <> @Origin

					)

				OR (

					@op11 = @IsLessThan

					AND Origin < @Origin

					)

				OR (

					@op11 = @IsLessThanOrEqualTo

					AND Origin <= @Origin

					)

				OR (

					@op11 = @IsGreaterThan

					AND Origin > @Origin

					)

				OR (

					@op11 = @IsGreaterThanOrEqualTo

					AND Origin >= @Origin

					)

				OR (

					@op11 = @Contains

					AND Origin LIKE '%' + @Origin + '%'

					)

				OR (

					@op11 = @DoesNotContain

					AND Origin NOT LIKE '%' + @Origin + '%'

					)

				OR (

					@op11 = @StartsWith

					AND Origin LIKE '' + @Origin + '%'

					)

				OR (

					@op11 = @EndsWith

					AND Origin LIKE '%' + @Origin + ''

					)

				)

			AND (

				(@op12 IS NULL)

				OR (

					@op12 IS NULL

					AND @LogicalOperator1 IS NULL

					)

				OR (

					@LogicalOperator12 = 'OR'

					AND (

						(

							(

								@op12 = @IsEqualTo

								AND SynchronisationDate = @SynchronisationDate

								)

							OR (

								@op12 = @IsNotEqualTo

								AND SynchronisationDate <> @SynchronisationDate

								)

							OR (

								@op12 = @IsLessThan

								AND SynchronisationDate < @SynchronisationDate

								)

							OR (

								@op12 = @IsLessThanOrEqualTo

								AND SynchronisationDate <= @SynchronisationDate

								)

							OR (

								@op12 = @IsGreaterThan

								AND SynchronisationDate > @SynchronisationDate

								)

							OR (

								@op12 = @IsGreaterThanOrEqualTo

								AND SynchronisationDate >= @SynchronisationDate

								)

							OR (

								@op12 = @Contains

								AND SynchronisationDate LIKE '%' + @SynchronisationDateVarchar + '%'

								)

							OR (

								@op12 = @DoesNotContain

								AND SynchronisationDate NOT LIKE '%' + @SynchronisationDateVarchar + '%'

								)
							OR (

								@op12 = @StartsWith

								AND SynchronisationDate LIKE '' + @SynchronisationDateVarchar + '%'

								)

							OR (

								@op12 = @EndsWith

								AND SynchronisationDate LIKE '%' + @SynchronisationDateVarchar + ''

								)

							)

						OR (

							(

								@Secondop12 = @IsEqualTo

								AND SynchronisationDate = @SecondSynchronisationDate

								)

							OR (

								@Secondop12 = @IsNotEqualTo

								AND SynchronisationDate <> @SecondSynchronisationDate

								)

							OR (

								@Secondop12 = @IsLessThan

								AND SynchronisationDate < @SecondSynchronisationDate

								)

							OR (

								@Secondop12 = @IsLessThanOrEqualTo

								AND SynchronisationDate <= @SecondSynchronisationDate

								)

							OR (

								@Secondop12 = @IsGreaterThan

								AND SynchronisationDate > @SecondSynchronisationDate

								)

							OR (

								@Secondop12 = @IsGreaterThanOrEqualTo

								AND SynchronisationDate >= @SecondSynchronisationDate

								)

							OR (

								@Secondop12 = @Contains

								AND SynchronisationDate LIKE '%' + @SecondSynchronisationDateVarchar + '%'

								)

							OR (

								@Secondop12 = @DoesNotContain

								AND SynchronisationDate NOT LIKE '%' + @SecondSynchronisationDateVarchar + '%'

								)

							OR (

								@Secondop12 = @StartsWith

								AND SynchronisationDate LIKE '' + @SecondSynchronisationDateVarchar + '%'

								)

							OR (

								@Secondop12 = @EndsWith

								AND SynchronisationDate LIKE '%' + @SecondSynchronisationDateVarchar + ''

								)

							)

						)

					)

				OR (

					@LogicalOperator12 = 'AND'

					AND (

						(

							(

								@op12 = @IsEqualTo

								AND SynchronisationDate = @SynchronisationDate

								)

							OR (

								@op12 = @IsNotEqualTo

								AND SynchronisationDate <> @SynchronisationDate

								)

							OR (

								@op12 = @IsLessThan

								AND SynchronisationDate < @SynchronisationDate

								)

							OR (

								@op12 = @IsLessThanOrEqualTo

								AND SynchronisationDate <= @SynchronisationDate

								)

							OR (

								@op12 = @IsGreaterThan

								AND SynchronisationDate > @SynchronisationDate

								)

							OR (

								@op12 = @IsGreaterThanOrEqualTo

								AND SynchronisationDate >= @SynchronisationDate

								)

							OR (

								@op12 = @Contains

								AND SynchronisationDate LIKE '%' + @SynchronisationDateVarchar + '%'

								)

							OR (

								@op12 = @DoesNotContain

								AND SynchronisationDate NOT LIKE '%' + @SynchronisationDateVarchar + '%'

								)

							OR (

								@op12 = @StartsWith

								AND SynchronisationDate LIKE '' + @SynchronisationDateVarchar + '%'

								)

							OR (

								@op12 = @EndsWith

								AND SynchronisationDate LIKE '%' + @SynchronisationDateVarchar + ''

								)

							)

						AND (

							(

								@Secondop12 = @IsEqualTo

								AND SynchronisationDate = @SecondSynchronisationDate

								)

							OR (

								@Secondop12 = @IsNotEqualTo

								AND SynchronisationDate <> @SecondSynchronisationDate

								)

							OR (

								@Secondop12 = @IsLessThan

								AND SynchronisationDate < @SecondSynchronisationDate

								)

							OR (

								@Secondop12 = @IsLessThanOrEqualTo

								AND SynchronisationDate <= @SecondSynchronisationDate

								)

							OR (

								@Secondop12 = @IsGreaterThan

								AND SynchronisationDate > @SecondSynchronisationDate

								)

							OR (

								@Secondop12 = @IsGreaterThanOrEqualTo

								AND SynchronisationDate >= @SecondSynchronisationDate

								)

							OR (

								@Secondop12 = @Contains

								AND SynchronisationDate LIKE '%' + @SecondSynchronisationDateVarchar + '%'

								)

							OR (

								@Secondop12 = @DoesNotContain

								AND SynchronisationDate NOT LIKE '%' + @SecondSynchronisationDateVarchar + '%'

								)

							OR (

								@Secondop12 = @StartsWith

								AND SynchronisationDate LIKE '' + @SecondSynchronisationDateVarchar + '%'

								)

							OR (

								@Secondop12 = @EndsWith

								AND SynchronisationDate LIKE '%' + @SecondSynchronisationDateVarchar + ''

								)

							)

						)

					)

				OR (

					@op12 = @IsEqualTo AND @Secondop12 IS NULL

					AND SynchronisationDate = @SynchronisationDate

					)

				OR (

					@op12 = @IsNotEqualTo AND @Secondop12 IS NULL

					AND SynchronisationDate <> @SynchronisationDate

					)

				OR (

					@op12 = @IsLessThan AND @Secondop12 IS NULL

					AND SynchronisationDate < @SynchronisationDate

					)

				OR (

					@op12 = @IsLessThanOrEqualTo AND @Secondop12 IS NULL

					AND SynchronisationDate <= @SynchronisationDate

					)

				OR (

					@op12 = @IsGreaterThan AND @Secondop12 IS NULL

					AND SynchronisationDate > @SynchronisationDate

					)

				OR (

					@op12 = @IsGreaterThanOrEqualTo AND @Secondop12 IS NULL

					AND SynchronisationDate >= @SynchronisationDate

					)

				OR (

					@op12 = @Contains AND @Secondop12 IS NULL

					AND SynchronisationDate LIKE '%' + @SynchronisationDateVarchar + '%'

					)

				OR (

					@op12 = @DoesNotContain AND @Secondop12 IS NULL

					AND SynchronisationDate NOT LIKE '%' + @SynchronisationDateVarchar + '%'

					)

				OR (

					@op12 = @StartsWith AND @Secondop12 IS NULL

					AND SynchronisationDate LIKE '' + @SynchronisationDateVarchar + '%'

					)

				OR (

					@op12 = @EndsWith AND @Secondop12 IS NULL

					AND SynchronisationDate LIKE '%' + @SynchronisationDateVarchar + ''

					)

				)

		OPTION (RECOMPILE)

	END



	SELECT *

	FROM (

		SELECT iat.IncentiveAccountTransactionId AS Id

			,iat.Balance

			,iat.TransactionDate AS TransactionDate

			,iat.Comments

			,c.CreationTimeStamp

			,dbo.[GetTranslationValue](ipae.TypeName_Id, @pCultureCode) AS [PointType]

			,(select IndividualId from Individual  where GUIDReference =iat.Depositor_Id) AS [HumanReadableId]

			,dbo.[GetTranslationValue](ip.Description_Id, @pCultureCode) AS [Description]

			,ip.RewardCode AS Code

			,'' AS Origin

			,(isnull(iati.Ammount, 0) * - 1) AS Debit

			,(isnull(iati.Ammount, 0) * - 1) AS Amount

			,0 AS Credit

			,0 AS IsCredit

			,dbo.[GetTranslationValue](sd.Label_Id, @pCultureCode) PackageStatus

			,CAST(iat.SynchronisationDate AS DATE) AS SynchronisationDate

			,dbo.[GetTranslationValue](rdt.Translation_Id, @pCultureCode) AS DeliveryType

			,ts.Code AS TransactionSource
			,iat.GPSUpdateTimestamp

		FROM IncentiveAccount ia

		INNER JOIN Individual i ON i.GUIDReference = ia.IncentiveAccountId

		INNER JOIN Candidate c ON c.GUIDReference = ia.IncentiveAccountId

		INNER JOIN IncentiveAccountTransaction iat ON ia.IncentiveAccountId = iat.Account_Id

			AND iat.Type = 'Debit'

		LEFT JOIN IncentiveAccountTransactionInfo iati ON iati.IncentiveAccountTransactionInfoId = iat.TransactionInfo_Id

		LEFT JOIN TransactionSource ts ON iat.TransactionSource_Id = ts.TransactionSourceId

		LEFT JOIN IncentivePoint ip ON ip.GUIDReference = iati.Point_Id

		LEFT JOIN IncentivePointAccountEntryType ipae ON ipae.GUIDReference = ip.Type_Id

		LEFT JOIN Package p ON p.Debit_Id = iat.IncentiveAccountTransactionId

		LEFT JOIN StateDefinition sd ON sd.Id = p.State_Id

		LEFT JOIN RewardDeliveryType rdt ON rdt.RewardDeliveryTypeId = iati.RewardDeliveryType_Id

		WHERE c.GUIDReference = @pindividualId

		

		UNION

		

		SELECT iat.IncentiveAccountTransactionId AS Id

			,iat.Balance

			,iat.TransactionDate AS TransactionDate

			,iat.Comments

			,c.CreationTimeStamp

			,dbo.[GetTranslationValue](ipae.TypeName_Id, @pCultureCode) AS [PointType]

			,(select IndividualId from Individual  where GUIDReference =iat.Depositor_Id) AS [HumanReadableId]

			,dbo.[GetTranslationValue](ip.Description_Id, @pCultureCode) [Description]

			,ip.Code

			,IIF(ISNULL(ip.HasAllPanels, 0) = 1 AND iat.Panel_Id IS NULL, dbo.[GetTranslationValue](t.TranslationId, @pCultureCode), ISNULL(p.Name, '')) AS Origin

			,0 AS Debit

			,iati.Ammount AS Credit

			,iati.Ammount AS Amount

			,1 AS IsCredit

			,'' AS PackageStatus

			,CAST(iat.SynchronisationDate AS DATE) AS SynchronisationDate

			,'' AS DeliveryType

			,ts.Code AS TransactionSource
			,iat.GPSUpdateTimestamp

		FROM IncentiveAccount ia

		INNER JOIN Candidate c ON c.GUIDReference = ia.IncentiveAccountId

		INNER JOIN IncentiveAccountTransaction iat ON ia.IncentiveAccountId = iat.Account_Id

			AND iat.Type = 'Credit'

		INNER JOIN Individual i ON i.GUIDReference = iat.Account_Id

		LEFT JOIN Translation t ON t.KeyName = 'AllPanels'		

		LEFT JOIN IncentiveAccountTransactionInfo iati ON iati.IncentiveAccountTransactionInfoId = iat.TransactionInfo_Id

		LEFT JOIN TransactionSource ts ON iat.TransactionSource_Id = ts.TransactionSourceId

		LEFT JOIN IncentivePoint ip ON ip.GUIDReference = iati.Point_Id

		LEFT JOIN IncentivePointAccountEntryType ipae ON ipae.GUIDReference = ip.[Type_Id]

		LEFT JOIN Panel p ON p.GUIDReference = iat.Panel_Id

		WHERE c.GUIDReference = @pindividualId

		) AS outputtable

	WHERE (

			(@op1 IS NULL)

			OR (

				@op1 IS NULL

				AND @LogicalOperator1 IS NULL

				)

			OR (

				@LogicalOperator1 = 'OR'

				AND (

					(

						(

							@op1 = @IsEqualTo

							AND TransactionDate = @TransactionDate

							)

						OR (

							@op1 = @IsNotEqualTo

							AND TransactionDate <> @TransactionDate

							)

						OR (

							@op1 = @IsLessThan

							AND TransactionDate < @TransactionDate

							)

						OR (

							@op1 = @IsLessThanOrEqualTo

							AND TransactionDate <= @TransactionDate

							)

						OR (

							@op1 = @IsGreaterThan

							AND TransactionDate > @TransactionDate

							)

						OR (

							@op1 = @IsGreaterThanOrEqualTo

							AND TransactionDate >= @TransactionDate

							)

						OR (

							@op1 = @Contains

							AND TransactionDate LIKE '%' + @TransactionDateVarchar + '%'

							)

						OR (

							@op1 = @DoesNotContain

							AND TransactionDate NOT LIKE '%' + @TransactionDateVarchar + '%'

							)

						OR (

							@op1 = @StartsWith

							AND TransactionDate LIKE '' + @TransactionDateVarchar + '%'

							)

						OR (

							@op1 = @EndsWith

							AND TransactionDate LIKE '%' + @TransactionDateVarchar + ''

							)

						)

					OR (

						(

							@Secondop1 = @IsEqualTo

							AND TransactionDate = @SecondTransactionDate

							)

						OR (

							@Secondop1 = @IsNotEqualTo

							AND TransactionDate <> @SecondTransactionDate

							)

						OR (

							@Secondop1 = @IsLessThan

							AND TransactionDate < @SecondTransactionDate

							)

						OR (

							@Secondop1 = @IsLessThanOrEqualTo

							AND TransactionDate <= @SecondTransactionDate

							)

						OR (

							@Secondop1 = @IsGreaterThan

							AND TransactionDate > @SecondTransactionDate

							)

						OR (

							@Secondop1 = @IsGreaterThanOrEqualTo

							AND TransactionDate >= @SecondTransactionDate

							)

						OR (

							@Secondop1 = @Contains

							AND TransactionDate LIKE '%' + @SecondTransactionDateVarchar + '%'

							)

						OR (

							@Secondop1 = @DoesNotContain

							AND TransactionDate NOT LIKE '%' + @SecondTransactionDateVarchar + '%'

							)

						OR (

							@Secondop1 = @StartsWith

							AND TransactionDate LIKE '' + @SecondTransactionDateVarchar + '%'

							)

						OR (

							@Secondop1 = @EndsWith

							AND TransactionDate LIKE '%' + @SecondTransactionDateVarchar + ''

							)

						)

					)

				)

			OR (

				@LogicalOperator1 = 'AND'

				AND (

					(

						(

							@op1 = @IsEqualTo

							AND TransactionDate = @TransactionDate

							)

						OR (

							@op1 = @IsNotEqualTo

							AND TransactionDate <> @TransactionDate

							)

						OR (

							@op1 = @IsLessThan

							AND TransactionDate < @TransactionDate

							)

						OR (

							@op1 = @IsLessThanOrEqualTo

							AND TransactionDate <= @TransactionDate

							)

						OR (

							@op1 = @IsGreaterThan

							AND TransactionDate > @TransactionDate

							)

						OR (

							@op1 = @IsGreaterThanOrEqualTo

							AND TransactionDate >= @TransactionDate

							)

						OR (

							@op1 = @Contains

							AND TransactionDate LIKE '%' + @TransactionDateVarchar + '%'

							)

						OR (

							@op1 = @DoesNotContain

							AND TransactionDate NOT LIKE '%' + @TransactionDateVarchar + '%'

							)

						OR (

							@op1 = @StartsWith

							AND TransactionDate LIKE '' + @TransactionDateVarchar + '%'

							)

						OR (

							@op1 = @EndsWith

							AND TransactionDate LIKE '%' + @TransactionDateVarchar + ''

							)

						)

					AND (

						(

							@Secondop1 = @IsEqualTo

							AND TransactionDate = @SecondTransactionDate

							)

						OR (

							@Secondop1 = @IsNotEqualTo

							AND TransactionDate <> @SecondTransactionDate

							)

						OR (

							@Secondop1 = @IsLessThan

							AND TransactionDate < @SecondTransactionDate

							)

						OR (

							@Secondop1 = @IsLessThanOrEqualTo

							AND TransactionDate <= @SecondTransactionDate

							)

						OR (

							@Secondop1 = @IsGreaterThan

							AND TransactionDate > @SecondTransactionDate

							)

						OR (

							@Secondop1 = @IsGreaterThanOrEqualTo

							AND TransactionDate >= @SecondTransactionDate

							)

						OR (

							@Secondop1 = @Contains

							AND TransactionDate LIKE '%' + @SecondTransactionDateVarchar + '%'

							)

						OR (

							@Secondop1 = @DoesNotContain

							AND TransactionDate NOT LIKE '%' + @SecondTransactionDateVarchar + '%'

							)

						OR (

							@Secondop1 = @StartsWith

							AND TransactionDate LIKE '' + @SecondTransactionDateVarchar + '%'

							)

						OR (

							@Secondop1 = @EndsWith

							AND TransactionDate LIKE '%' + @SecondTransactionDateVarchar + ''

							)

						)

					)

				)

			OR (

				@op1 = @IsEqualTo AND @Secondop1 IS NULL

				AND TransactionDate = @TransactionDate

				)

			OR (

				@op1 = @IsNotEqualTo AND @Secondop1 IS NULL

				AND TransactionDate <> @TransactionDate

				)

			OR (

				@op1 = @IsLessThan AND @Secondop1 IS NULL

				AND TransactionDate < @TransactionDate

				)

			OR (

				@op1 = @IsLessThanOrEqualTo AND @Secondop1 IS NULL

				AND TransactionDate <= @TransactionDate

				)

			OR (

				@op1 = @IsGreaterThan AND @Secondop1 IS NULL

				AND TransactionDate > @TransactionDate

				)

			OR (

				@op1 = @IsGreaterThanOrEqualTo AND @Secondop1 IS NULL

				AND TransactionDate >= @TransactionDate

				)

			OR (

				@op1 = @Contains AND @Secondop1 IS NULL

				AND TransactionDate LIKE '%' + @TransactionDateVarchar + '%'

				)

			OR (

				@op1 = @DoesNotContain AND @Secondop1 IS NULL

				AND TransactionDate NOT LIKE '%' + @TransactionDateVarchar + '%'

				)

			OR (

				@op1 = @StartsWith AND @Secondop1 IS NULL

				AND TransactionDate LIKE '' + @TransactionDateVarchar + '%'

				)

			OR (

				@op1 = @EndsWith AND @Secondop1 IS NULL

				AND TransactionDate LIKE '%' + @TransactionDateVarchar + ''

				)

			)

		AND (

			(@op2 IS NULL)

			OR (

				@op2 = @IsEqualTo

				AND PointType = @PointType

				)

			OR (

				@op2 = @IsNotEqualTo

				AND PointType <> @PointType

				)

			OR (

				@op2 = @IsLessThan

				AND PointType < @PointType

				)

			OR (

				@op2 = @IsLessThanOrEqualTo

				AND PointType <= @PointType

				)

			OR (

				@op2 = @IsGreaterThan

				AND PointType > @PointType

				)

			OR (

				@op2 = @IsGreaterThanOrEqualTo

				AND PointType >= @PointType

				)

			OR (

				@op2 = @Contains

				AND PointType LIKE '%' + @PointType + '%'

				)

			OR (

				@op2 = @DoesNotContain

				AND PointType NOT LIKE '%' + @PointType + '%'

				)

			OR (

				@op2 = @StartsWith

				AND PointType LIKE '' + @PointType + '%'

				)

			OR (

				@op2 = @EndsWith

				AND PointType LIKE '%' + @PointType + ''

				)

			)

		AND (

			(@op3 IS NULL)

			OR (

				@op3 = @IsEqualTo

				AND [Description] = @Description

				)

			OR (

				@op3 = @IsNotEqualTo

				AND [Description] <> @Description

				)

			OR (

				@op3 = @IsLessThan

				AND [Description] < @Description

				)

			OR (

				@op3 = @IsLessThanOrEqualTo

				AND [Description] <= @Description

				)

			OR (

				@op3 = @IsGreaterThan

				AND [Description] > @Description

				)

			OR (

				@op3 = @IsGreaterThanOrEqualTo

				AND [Description] >= @Description

				)

			OR (

				@op3 = @Contains

				AND [Description] LIKE '%' + @Description + '%'

				)

			OR (

				@op3 = @DoesNotContain

				AND [Description] NOT LIKE '%' + @Description + '%'

				)

			OR (

				@op3 = @StartsWith

				AND [Description] LIKE '' + @Description + '%'

				)

			OR (

				@op3 = @EndsWith

				AND [Description] LIKE '%' + @Description + ''

				)

			)

		AND (

			(@op4 IS NULL)

			OR (

				@op4 = @IsEqualTo

				AND Comments = @Comments

				)

			OR (

				@op4 = @IsNotEqualTo

				AND Comments <> @Comments

				)

			OR (

				@op4 = @IsLessThan

				AND Comments < @Comments

				)

			OR (

				@op4 = @IsLessThanOrEqualTo

				AND Comments <= @Comments

				)

			OR (

				@op4 = @IsGreaterThan

				AND Comments > @Comments

				)

			OR (

				@op4 = @IsGreaterThanOrEqualTo

				AND Comments >= @Comments

				)

			OR (

				@op4 = @Contains

				AND Comments LIKE '%' + @Comments + '%'

				)

			OR (

				@op4 = @DoesNotContain

				AND Comments NOT LIKE '%' + @Comments + '%'

				)

			OR (

				@op4 = @StartsWith

				AND Comments LIKE '' + @Comments + '%'

				)

			OR (

				@op4 = @EndsWith

				AND Comments LIKE '%' + @Comments + ''

				)

			)

		AND (

			(@op5 IS NULL)

			OR (

				@op5 = @IsEqualTo

				AND DeliveryType = DeliveryType

				)

			OR (

				@op5 = @IsNotEqualTo

				AND DeliveryType <> @DeliveryType

				)

			OR (

				@op5 = @IsLessThan

				AND DeliveryType < @DeliveryType

				)

			OR (

				@op5 = @IsLessThanOrEqualTo

				AND DeliveryType <= @DeliveryType

				)

			OR (

				@op5 = @IsGreaterThan

				AND DeliveryType > @DeliveryType

				)

			OR (

				@op5 = @IsGreaterThanOrEqualTo

				AND DeliveryType >= @DeliveryType

				)

			OR (

				@op5 = @Contains

				AND DeliveryType LIKE '%' + @DeliveryType + '%'

				)

			OR (

				@op5 = @DoesNotContain

				AND DeliveryType NOT LIKE '%' + @DeliveryType + '%'

				)

			OR (

				@op5 = @StartsWith

				AND DeliveryType LIKE '' + @DeliveryType + '%'

				)

			OR (

				@op5 = @EndsWith

				AND DeliveryType LIKE '%' + @DeliveryType + ''

				)

			)

		AND (

			(@op6 IS NULL)

			OR (

				@op6 = @IsEqualTo

				AND HumanReadableId = @HumanReadableId

				)

			OR (

				@op6 = @IsNotEqualTo

				AND HumanReadableId <> @HumanReadableId

				)

			OR (

				@op6 = @IsLessThan

				AND HumanReadableId < @HumanReadableId

				)

			OR (

				@op6 = @IsLessThanOrEqualTo

				AND HumanReadableId <= @HumanReadableId

				)

			OR (

				@op6 = @IsGreaterThan

				AND HumanReadableId > @HumanReadableId

				)

			OR (

				@op6 = @IsGreaterThanOrEqualTo

				AND HumanReadableId >= @HumanReadableId

				)

			OR (

				@op6 = @Contains

				AND HumanReadableId LIKE '%' + @HumanReadableId + '%'

				)

			OR (

				@op6 = @DoesNotContain

				AND HumanReadableId NOT LIKE '%' + @HumanReadableId + '%'

				)

			OR (

				@op6 = @StartsWith

				AND HumanReadableId LIKE '' + @HumanReadableId + '%'

				)

			OR (

				@op6 = @EndsWith

				AND HumanReadableId LIKE '%' + @HumanReadableId + ''

				)

			)

		AND (

			(@op7 IS NULL)

			OR (

				@op7 = @IsEqualTo

				AND Amount = @Amount

				)

			OR (

				@op7 = @IsNotEqualTo

				AND Amount <> @Amount

				)

			OR (

				@op7 = @IsLessThan

				AND Amount < @Amount

				)

			OR (

				@op7 = @IsLessThanOrEqualTo

				AND Amount <= @Amount

				)

			OR (

				@op7 = @IsGreaterThan

				AND Amount > @Amount

				)

			OR (

				@op7 = @IsGreaterThanOrEqualTo

				AND Amount >= @Amount

				)

			OR (

				@op7 = @Contains

				AND Amount LIKE '%' + @Amount + '%'

				)

			OR (

				@op7 = @DoesNotContain

				AND Amount NOT LIKE '%' + @Amount + '%'

				)

			OR (

				@op7 = @StartsWith

				AND Amount LIKE '' + @Amount + '%'

				)

			OR (

				@op7 = @EndsWith

				AND Amount LIKE '%' + @Amount + ''
				)

			)

		AND (

			(@op8 IS NULL)

			OR (

				@op8 = @IsEqualTo

				AND PackageStatus = @PackageStatus

				)

			OR (

				@op8 = @IsNotEqualTo

				AND PackageStatus <> @PackageStatus

				)

			OR (

				@op8 = @IsLessThan

				AND PackageStatus < @PackageStatus

				)

			OR (

				@op8 = @IsLessThanOrEqualTo

				AND PackageStatus <= @PackageStatus

				)

			OR (

				@op8 = @IsGreaterThan

				AND PackageStatus > @PackageStatus

				)

			OR (

				@op8 = @IsGreaterThanOrEqualTo

				AND PackageStatus >= @PackageStatus

				)

			OR (

				@op8 = @Contains

				AND PackageStatus LIKE '%' + @PackageStatus + '%'

				)

			OR (

				@op8 = @DoesNotContain

				AND PackageStatus NOT LIKE '%' + @PackageStatus + '%'

				)

			OR (

				@op8 = @StartsWith

				AND PackageStatus LIKE '' + @PackageStatus + '%'

				)

			OR (

				@op8 = @EndsWith

				AND PackageStatus LIKE '%' + @PackageStatus + ''

				)

			)

		AND (

			(@op9 IS NULL)

			OR (

				@op9 = @IsEqualTo

				AND TransactionSource = @TransactionSource

				)

			OR (

				@op9 = @IsNotEqualTo

				AND TransactionSource <> @TransactionSource

				)

			OR (

				@op9 = @IsLessThan

				AND TransactionSource < @TransactionSource

				)

			OR (

				@op9 = @IsLessThanOrEqualTo

				AND TransactionSource <= @TransactionSource

				)

			OR (

				@op9 = @IsGreaterThan

				AND TransactionSource > @TransactionSource

				)

			OR (

				@op9 = @IsGreaterThanOrEqualTo

				AND TransactionSource >= @TransactionSource

				)

			OR (

				@op9 = @Contains

				AND TransactionSource LIKE '%' + @TransactionSource + '%'

				)

			OR (

				@op9 = @DoesNotContain

				AND TransactionSource NOT LIKE '%' + @TransactionSource + '%'

				)

			OR (

				@op9 = @StartsWith

				AND TransactionSource LIKE '' + @TransactionSource + '%'

				)

			OR (

				@op9 = @EndsWith

				AND TransactionSource LIKE '%' + @TransactionSource + ''

				)

			)

		AND (

			(@op10 IS NULL)

			OR (

				@op10 = @IsEqualTo

				AND Code = @Code

				)

			OR (

				@op10 = @IsNotEqualTo

				AND Code <> @Code

				)

			OR (

				@op10 = @IsLessThan

				AND Code < @Code

				)

			OR (

				@op10 = @IsLessThanOrEqualTo

				AND Code <= @Code

				)

			OR (

				@op10 = @IsGreaterThan

				AND Code > @Code

				)

			OR (

				@op10 = @IsGreaterThanOrEqualTo

				AND Code >= @Code

				)

			OR (

				@op10 = @Contains

				AND Code LIKE '%' + @Code + '%'

				)

			OR (

				@op10 = @DoesNotContain

				AND Code NOT LIKE '%' + @Code + '%'

				)

			OR (

				@op10 = @StartsWith

				AND Code LIKE '' + @Code + '%'

				)

			OR (

				@op10 = @EndsWith

				AND Code LIKE '%' + @Code + ''

				)

			)

		AND (

			(@op11 IS NULL)

			OR (

				@op11 = @IsEqualTo

				AND Origin = @Origin

				)

			OR (

				@op11 = @IsNotEqualTo

				AND Origin <> @Origin

				)

			OR (

				@op11 = @IsLessThan

				AND Origin < @Origin

				)

			OR (

				@op11 = @IsLessThanOrEqualTo

				AND Origin <= @Origin

				)

			OR (

				@op11 = @IsGreaterThan

				AND Origin > @Origin

				)

			OR (

				@op11 = @IsGreaterThanOrEqualTo

				AND Origin >= @Origin

				)

			OR (

				@op11 = @Contains

				AND Origin LIKE '%' + @Origin + '%'

				)

			OR (

				@op11 = @DoesNotContain

				AND Origin NOT LIKE '%' + @Origin + '%'

				)

			OR (

				@op11 = @StartsWith

				AND Origin LIKE '' + @Origin + '%'

				)

			OR (

				@op11 = @EndsWith

				AND Origin LIKE '%' + @Origin + ''

				)

			)

		AND (

			(@op12 IS NULL)

			OR (

				@op12 IS NULL

				AND @LogicalOperator1 IS NULL

				)

			OR (

				@LogicalOperator12 = 'OR'

				AND (

					(

						(

							@op12 = @IsEqualTo

							AND SynchronisationDate = @SynchronisationDate

							)

						OR (

							@op12 = @IsNotEqualTo

							AND SynchronisationDate <> @SynchronisationDate

							)

						OR (

							@op12 = @IsLessThan

							AND SynchronisationDate < @SynchronisationDate

							)

						OR (

							@op12 = @IsLessThanOrEqualTo

							AND SynchronisationDate <= @SynchronisationDate

							)

						OR (

							@op12 = @IsGreaterThan

							AND SynchronisationDate > @SynchronisationDate

							)

						OR (

							@op12 = @IsGreaterThanOrEqualTo

							AND SynchronisationDate >= @SynchronisationDate

							)

						OR (

							@op12 = @Contains

							AND SynchronisationDate LIKE '%' + @SynchronisationDateVarchar + '%'

							)

						OR (

							@op12 = @DoesNotContain

							AND SynchronisationDate NOT LIKE '%' + @SynchronisationDateVarchar + '%'

							)

						OR (

							@op12 = @StartsWith

							AND SynchronisationDate LIKE '' + @SynchronisationDateVarchar + '%'

							)

						OR (

							@op12 = @EndsWith

							AND SynchronisationDate LIKE '%' + @SynchronisationDateVarchar + ''

							)

						)

					OR (

						(

							@Secondop12 = @IsEqualTo

							AND SynchronisationDate = @SecondSynchronisationDate

							)

						OR (

							@Secondop12 = @IsNotEqualTo

							AND SynchronisationDate <> @SecondSynchronisationDate

							)

						OR (

							@Secondop12 = @IsLessThan

							AND SynchronisationDate < @SecondSynchronisationDate

							)

						OR (

							@Secondop12 = @IsLessThanOrEqualTo

							AND SynchronisationDate <= @SecondSynchronisationDate

							)

						OR (

							@Secondop12 = @IsGreaterThan

							AND SynchronisationDate > @SecondSynchronisationDate

							)

						OR (

							@Secondop12 = @IsGreaterThanOrEqualTo

							AND SynchronisationDate >= @SecondSynchronisationDate

							)

						OR (

							@Secondop12 = @Contains

							AND SynchronisationDate LIKE '%' + @SecondSynchronisationDateVarchar + '%'

							)

						OR (

							@Secondop12 = @DoesNotContain

							AND SynchronisationDate NOT LIKE '%' + @SecondSynchronisationDateVarchar + '%'

							)

						OR (

							@Secondop12 = @StartsWith

							AND SynchronisationDate LIKE '' + @SecondSynchronisationDateVarchar + '%'

							)

						OR (

							@Secondop12 = @EndsWith

							AND SynchronisationDate LIKE '%' + @SecondSynchronisationDateVarchar + ''

							)

						)

					)

				)

			OR (

				@LogicalOperator12 = 'AND'

				AND (

					(

						(

							@op12 = @IsEqualTo

							AND SynchronisationDate = @SynchronisationDate

							)

						OR (

							@op12 = @IsNotEqualTo

							AND SynchronisationDate <> @SynchronisationDate

							)

						OR (

							@op12 = @IsLessThan

							AND SynchronisationDate < @SynchronisationDate

							)

						OR (

							@op12 = @IsLessThanOrEqualTo

							AND SynchronisationDate <= @SynchronisationDate

							)

						OR (

							@op12 = @IsGreaterThan

							AND SynchronisationDate > @SynchronisationDate

							)

						OR (

							@op12 = @IsGreaterThanOrEqualTo

							AND SynchronisationDate >= @SynchronisationDate

							)

						OR (

							@op12 = @Contains

							AND SynchronisationDate LIKE '%' + @SynchronisationDateVarchar + '%'

							)

						OR (

							@op12 = @DoesNotContain

							AND SynchronisationDate NOT LIKE '%' + @SynchronisationDateVarchar + '%'

							)

						OR (

							@op12 = @StartsWith

							AND SynchronisationDate LIKE '' + @SynchronisationDateVarchar + '%'

							)

						OR (

							@op12 = @EndsWith

							AND SynchronisationDate LIKE '%' + @SynchronisationDateVarchar + ''

							)

						)

					AND (

						(

							@Secondop12 = @IsEqualTo

							AND SynchronisationDate = @SecondSynchronisationDate

							)

						OR (

							@Secondop12 = @IsNotEqualTo

							AND SynchronisationDate <> @SecondSynchronisationDate

							)

						OR (

							@Secondop12 = @IsLessThan

							AND SynchronisationDate < @SecondSynchronisationDate

							)

						OR (

							@Secondop12 = @IsLessThanOrEqualTo

							AND SynchronisationDate <= @SecondSynchronisationDate

							)

						OR (

							@Secondop12 = @IsGreaterThan

							AND SynchronisationDate > @SecondSynchronisationDate

							)

						OR (

							@Secondop12 = @IsGreaterThanOrEqualTo

							AND SynchronisationDate >= @SecondSynchronisationDate

							)

						OR (

							@Secondop12 = @Contains

							AND SynchronisationDate LIKE '%' + @SecondSynchronisationDateVarchar + '%'

							)

						OR (

							@Secondop12 = @DoesNotContain

							AND SynchronisationDate NOT LIKE '%' + @SecondSynchronisationDateVarchar + '%'

							)

						OR (

							@Secondop12 = @StartsWith

							AND SynchronisationDate LIKE '' + @SecondSynchronisationDateVarchar + '%'

							)

						OR (

							@Secondop12 = @EndsWith

							AND SynchronisationDate LIKE '%' + @SecondSynchronisationDateVarchar + ''

							)

						)

					)

				)

			OR (

				@op12 = @IsEqualTo AND @Secondop12 IS NULL

				AND SynchronisationDate = @SynchronisationDate

				)

			OR (

				@op12 = @IsNotEqualTo AND @Secondop12 IS NULL

				AND SynchronisationDate <> @SynchronisationDate

				)

			OR (

				@op12 = @IsLessThan AND @Secondop12 IS NULL

				AND SynchronisationDate < @SynchronisationDate

				)

			OR (

				@op12 = @IsLessThanOrEqualTo AND @Secondop12 IS NULL

				AND SynchronisationDate <= @SynchronisationDate

				)

			OR (

				@op12 = @IsGreaterThan AND @Secondop12 IS NULL

				AND SynchronisationDate > @SynchronisationDate

				)

			OR (

				@op12 = @IsGreaterThanOrEqualTo AND @Secondop12 IS NULL

				AND SynchronisationDate >= @SynchronisationDate

				)

			OR (

				@op12 = @Contains AND @Secondop12 IS NULL

				AND SynchronisationDate LIKE '%' + @SynchronisationDateVarchar + '%'

				)

			OR (

				@op12 = @DoesNotContain AND @Secondop12 IS NULL

				AND SynchronisationDate NOT LIKE '%' + @SynchronisationDateVarchar + '%'

				)

			OR (

				@op12 = @StartsWith AND @Secondop12 IS NULL

				AND SynchronisationDate LIKE '' + @SynchronisationDateVarchar + '%'

				)

			OR (

				@op12 = @EndsWith AND @Secondop12 IS NULL

				AND SynchronisationDate LIKE '%' + @SynchronisationDateVarchar + ''

				)

			)

	ORDER BY CASE 

			WHEN @OrderBy = 'TransactionDate'

				AND @OrderType = 'asc'

				THEN TransactionDate

			END ASC

		,CASE 

			WHEN @OrderBy = 'TransactionDate'

				AND @OrderType = 'desc'

				THEN TransactionDate

			END DESC

		,CASE 

			WHEN @OrderBy = 'PointType'

				AND @OrderType = 'asc'

				THEN PointType

			END ASC

		,CASE 

			WHEN @OrderBy = 'PointType'

				AND @OrderType = 'desc'

				THEN PointType

			END DESC

		,CASE 

			WHEN @OrderBy = 'Description'

				AND @OrderType = 'asc'

				THEN [Description]

			END ASC

		,CASE 

			WHEN @OrderBy = 'Description'

				AND @OrderType = 'desc'

				THEN [Description]

			END DESC

		,CASE 

			WHEN @OrderBy = 'Comments'

				AND @OrderType = 'asc'

				THEN Comments

			END ASC

		,CASE 

			WHEN @OrderBy = 'Comments'

				AND @OrderType = 'desc'

				THEN Comments

			END DESC

		,CASE 

			WHEN @OrderBy = 'DeliveryType'

				AND @OrderType = 'asc'

				THEN DeliveryType

			END ASC

		,CASE 

			WHEN @OrderBy = 'DeliveryType'

				AND @OrderType = 'desc'

				THEN DeliveryType

			END DESC

		,CASE 

			WHEN @OrderBy = 'HumanReadableId'

				AND @OrderType = 'asc'

				THEN HumanReadableId

			END ASC

		,CASE 

			WHEN @OrderBy = 'HumanReadableId'

				AND @OrderType = 'desc'

				THEN HumanReadableId

			END DESC

		,CASE 

			WHEN @OrderBy = 'Amount'

				AND @OrderType = 'asc'

				THEN Amount

			END ASC

		,CASE 

			WHEN @OrderBy = 'Amount'

				AND @OrderType = 'desc'

				THEN Amount

			END DESC

		,CASE 

			WHEN @OrderBy = 'PackageStatus'

				AND @OrderType = 'asc'

				THEN PackageStatus

			END ASC

		,CASE 

			WHEN @OrderBy = 'PackageStatus'

				AND @OrderType = 'desc'

				THEN PackageStatus

			END DESC

		,CASE 

			WHEN @OrderBy = 'TransactionSource'

				AND @OrderType = 'asc'

				THEN TransactionSource

			END ASC

		,CASE 

			WHEN @OrderBy = 'TransactionSource'

				AND @OrderType = 'desc'

				THEN TransactionSource

			END DESC

		,CASE 

			WHEN @OrderBy = 'Code'

				AND @OrderType = 'asc'

				THEN Code

			END ASC

		,CASE 

			WHEN @OrderBy = 'Code'

				AND @OrderType = 'desc'

				THEN Code

			END DESC

		,CASE 

			WHEN @OrderBy = 'Origin'

				AND @OrderType = 'asc'

				THEN Origin

			END ASC

		,CASE 

			WHEN @OrderBy = 'Origin'

				AND @OrderType = 'desc'

				THEN Origin

			END DESC

		,CASE 

			WHEN @OrderBy = 'SynchronisationDate'

				AND @OrderType = 'asc'

				THEN SynchronisationDate

			END ASC

		,CASE 

			WHEN @OrderBy = 'SynchronisationDate'

				AND @OrderType = 'desc'

				THEN SynchronisationDate

			END DESC,GPSUpdateTimestamp DESC

		--end desc

		OFFSET @OFFSETRows rows



	FETCH NEXT @PageSize rows ONLY

	OPTION (RECOMPILE)

END
