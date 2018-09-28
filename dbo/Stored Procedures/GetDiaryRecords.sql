/*##########################################################################
-- Name				: GetDiaryRecords
-- DATE             : 2014-11-04
-- Author           : 
-- Purpose          : 
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
      	 @pPanelId	         -- Guid of Panel
		 @pOrderBy           -- The column name on which user is going to perform the sorting 
		 @pOrderType         -- Specifies the Sorting type ASC OR DESC
		 @pPageNumber        -- Page number of the page
		 @pPageSize          -- Page size (The number of Records user wants to see in the grid)
		 @pIsExport          -- Specifies user want to export the data
		 @pParametersTable dbo.GridParametersTable readonly -- This is going to have all the searching criteria performed through the Gridview.
-- Sample Execution :
	
DECLARE @p8 dbo.GridParametersTable
--insert into @p8 values(N'ReceivedDate',N'2004-09-03',N'IsGreaterThanOrEqualTo',NULL,NULL,NULL)
--insert into @p8 values(N'CreationTimeStamp',N'2014-09-18',N'IsEqualTo',N'OR',N'IsLessThanOrEqualTo',N'2014-09-11')
--insert into @p8 values(N'Points',N'100',N'IsGreaterThanOrEqualTo',NULL,NULL,NULL)
--insert into @p8 values(N'DiaryDateFull',N'2006.7.4',N'IsEqualTo',NULL,NULL,NULL)
--insert into @p8 values(N'BusinessId',N'10257901-01',N'IsEqualTo',NULL,NULL,NULL)
exec GetDiaryRecords '142B5C5E-4254-C057-0C86-08D11B00442A',NULL,NULL,1,100,0,@p8
	   
##########################################################################
-- version  user                  DATE        change 
-- 1.0  Ramana					  2014-11-04   Initial
-- 1.2  Ramana				      2014-11-18   Refactor
##########################################################################*/

CREATE PROCEDURE GetDiaryRecords
 @pPanelId VARCHAR(50)
 ,@pYear INT,@pPeriod INT,@pWeek INT
  ,@pTargetDate DATETIME
,@pOrderBy VARCHAR(100),@pOrderType VARCHAR(10) -- ASC OR DESC
,@pPageNumber INT=1,@pPageSize INT=100,@pIsExport BIT=0
,@pParametersTable dbo.GridParametersTable READONLY
AS
BEGIN
SET NOCOUNT ON;

		DECLARE @GetDate DATETIME
		DECLARE @CountryId UNIQUEIDENTIFIER
		DECLARE @GivenPanelname NVARCHAR(100),@IsFilterExists BIT=0
SELECT @GivenPanelname = ISNULL(Name,''),@CountryId=Country_Id
FROM Panel
WHERE GUIDReference = @pPanelId
		
		SET @GetDate = (select dbo.GetLocalDateTimeByCountryId(getdate(),@CountryId))

DECLARE @op1 VARCHAR(50),@op2 VARCHAR(50),@op3 VARCHAR(50),@op4 VARCHAR(50),@op5 VARCHAR(50),@op6 VARCHAR(50),@op7 VARCHAR(50),@op8 VARCHAR(50),@op9 VARCHAR(50),@op10 VARCHAR(50),@op11 VARCHAR(50),@op12 VARCHAR(50),@op13 VARCHAR(50),@op14 VARCHAR(50)
DECLARE @LogicalOperator3 VARCHAR(5),@LogicalOperator10 VARCHAR(5) 
DECLARE @Secondop3 VARCHAR(50),@Secondop10 VARCHAR(50)
DECLARE @SecondReceivedDate DATE,@SecondCreationTimeStamp DATE
DECLARE @Id uniqueidentifier,@BusinessId NVARCHAR(100),@ReceivedDate DATE,@IncentiveCode INT,@Points INT,@NumberOfDaysEarly NVARCHAR(5),@NumberOfDaysLate NVARCHAR(5),@DiarySourceFull NVARCHAR(60)
,@Panelname NVARCHAR(100),@CreationTimeStamp DATE,@ClaimFlag INT,@Together NVARCHAR(5),@DiaryDateFull NVARCHAR(20),@DiaryState NVARCHAR(300)

SELECT @op1=Opertor,@Id=ParameterValue FROM @pParametersTable WHERE ParameterName='Id'
SELECT @op2=Opertor,@BusinessId=ParameterValue FROM @pParametersTable WHERE ParameterName='BusinessId'
SELECT @op3=Opertor,@ReceivedDate=CAST(ParameterValue AS DATE),@Secondop3=SecondParameterOperator,@SecondReceivedDate=CAST(SecondParameterValue AS DATE),@LogicalOperator3=LogicalOperator FROM @pParametersTable WHERE ParameterName='ReceivedDate'
SELECT @op4=Opertor,@IncentiveCode=ParameterValue FROM @pParametersTable WHERE ParameterName='IncentiveCode'
SELECT @op5=Opertor,@Points=ParameterValue FROM @pParametersTable WHERE ParameterName='Points'
SELECT @op6=Opertor,@NumberOfDaysEarly=ParameterValue FROM @pParametersTable WHERE ParameterName='NumberOfDaysEarly'
SELECT @op7=Opertor,@NumberOfDaysLate=ParameterValue FROM @pParametersTable WHERE ParameterName='NumberOfDaysLate'
SELECT @op8=Opertor,@DiarySourceFull=ParameterValue FROM @pParametersTable WHERE ParameterName='DiarySourceFull'
SELECT @op9=Opertor,@Panelname=ParameterValue FROM @pParametersTable WHERE ParameterName='Panelname'
SELECT @op10=Opertor,@CreationTimeStamp=CAST(ParameterValue AS DATE),@Secondop10=SecondParameterOperator,@SecondCreationTimeStamp=CAST(SecondParameterValue AS DATE),@LogicalOperator10=LogicalOperator FROM @pParametersTable WHERE ParameterName='CreationTimeStamp'
SELECT @op11=Opertor,@ClaimFlag=ParameterValue FROM @pParametersTable WHERE ParameterName='ClaimFlag'
SELECT @op12=Opertor,@Together=ParameterValue FROM @pParametersTable WHERE ParameterName='Together'
SELECT @op13=Opertor,@DiaryDateFull=ParameterValue FROM @pParametersTable WHERE ParameterName='DiaryDateFull'
SELECT @op14=Opertor,@DiaryState=ParameterValue FROM @pParametersTable WHERE ParameterName='DiaryState'

DECLARE
@IdVarchar NVARCHAR(100)=CAST(@id AS NVARCHAR),
@IncentiveCodeVarchar NVARCHAR(10)=CAST(@IncentiveCode AS NVARCHAR),
@PointsVarchar NVARCHAR(10)=CAST(@Points AS NVARCHAR),
@ClaimFlagVarchar NVARCHAR(10)=CAST(@ClaimFlag AS NVARCHAR),
@TogetherVarchar NVARCHAR(10)=CAST(@Together AS NVARCHAR),
@CreationTimeStampVarchar NVARCHAR(100)=CAST(@CreationTimeStamp AS NVARCHAR),
@SecondCreationTimeStampVarchar NVARCHAR(100)=CAST(@SecondCreationTimeStamp AS NVARCHAR),
@ReceivedDateVarchar NVARCHAR(100)=CAST(@ReceivedDate AS NVARCHAR),
@SecondReceivedDateVarchar NVARCHAR(100)=CAST(@SecondReceivedDate AS NVARCHAR)

IF(@pOrderBy IS NULL)
SET @pOrderBy='DESC'

IF(@pOrderType IS NULL)
SET @pOrderType='CreationTimeStamp'


DECLARE @OFFSETRows INT=0

DECLARE @IsLessThan VARCHAR(50)='IsLessThan',
        @IsLessThanOrEqualTo VARCHAR(50)='IsLessThanOrEqualTo',
        @IsEqualTo VARCHAR(50)='IsEqualTo',
        @IsNotEqualTo VARCHAR(50)='IsNotEqualTo',
        @IsGreaterThanOrEqualTo VARCHAR(50)='IsGreaterThanOrEqualTo',
        @IsGreaterThan VARCHAR(50)='IsGreaterThan',
        @StartsWith VARCHAR(50)='StartsWith',
        @EndsWith VARCHAR(50)='EndsWith',
        @Contains VARCHAR(50)='Contains',
        @IsContainedIn VARCHAR(50)='IsContainedIn',
        @DoesNotContain VARCHAR(50)='DoesNotContain'
	DECLARE @StartDate DATE,@Enddate DATE
	SET @Enddate =CAST(ISNULL(@pTargetDate,@GetDate) AS DATE)

	IF((SELECT Count(0) FROM @pParametersTable)>0)
	 BEGIN
		SET @IsFilterExists=1
	 END
	
	IF(@IsFilterExists=1)
	 BEGIN
		SET @StartDate ='1900-01-01' 	
	 END 
	ELSE
	 BEGIN
		SET @StartDate =DATEADD(month, - 6, CONVERT(DATE, @Enddate))
	 END

	--SET @StartDate = DATEADD(month, - 6, CONVERT(DATE, @Enddate))


	

	IF(@pIsExport=0)	
		  SET @OFFSETRows=(@pPageSize* (@pPageNumber-1))	
	 ELSE 
		SET @pPageSize=30000

	IF(@pIsExport=0)
	BEGIN
	  SELECT COUNT(0) AS TotlaRows FROM (
	SELECT Id,BusinessId,CAST(ReceivedDate AS DATE) AS ReceivedDate,IncentiveCode,Points,(CASE WHEN NumberOfDaysEarly=1 THEN 'Yes'
															 ELSE '' END
															) AS NumberOfDaysEarly,
														   (CASE WHEN NumberOfDaysLate=1 THEN 'Yes'
															 ELSE '' END
															) AS NumberOfDaysLate,
		  DiarySourceFull, @GivenPanelname  AS Panelname,CAST(CreationTimeStamp AS DATE) AS CreationTimeStamp,ClaimFlag,
		 (CASE WHEN Together=1 THEN 'Yes'
		   ELSE '' END
		 ) AS Together,
		  CONVERT(VARCHAR,DiaryDateYear)+'.'+CONVERT(VARCHAR,DiaryDatePeriod)+'.'+CONVERT(VARCHAR,DiaryDateWeek) AS DiaryDateFull,
		  DiaryState
		  FROM DiaryEntry 
		  WHERE PanelId= @pPanelId
		  AND CAST(ReceivedDate AS DATE) BETWEEN @StartDate AND @Enddate
		  AND (DiaryDateYear<@pYear

		  OR (DiaryDateYear=@pYear AND DiaryDatePeriod<@pPeriod)

		  OR (DiaryDateYear=@pYear AND DiaryDatePeriod=@pPeriod AND DiaryDateWeek<=@pWeek)

		  )
		 UNION ALL

	SELECT Id,BusinessId,NULL AS ReceivedDate,0 AS IncentiveCode,0 AS Points,(CASE WHEN NumberOfDaysEarly=1 THEN 'Yes'
																	   ELSE '' END
																	  ) AS NumberOfDaysEarly,
																	 (CASE WHEN NumberOfDaysLate=1 THEN 'Yes'
																		ELSE '' END
																	 ) AS NumberOfDaysLate,
									
                                    
		  DiarySourceFull, @GivenPanelname  AS Panelname,CAST(CreationTimeStamp AS DATE),ClaimFlag,'' AS Together,
		 CONVERT(VARCHAR,DiaryDateYear)+'.'+CONVERT(VARCHAR,DiaryDatePeriod)+'.'+CONVERT(VARCHAR,DiaryDateWeek) AS DiaryDateFull,
		 '' AS DiaryState
		FROM MissingDiaries 
		WHERE PanelId= @pPanelId 
		AND CAST(CreationTimeStamp AS DATE) BETWEEN @StartDate AND @Enddate
		AND (DiaryDateYear<@pYear

		  OR (DiaryDateYear=@pYear AND DiaryDatePeriod<@pPeriod)

		  OR (DiaryDateYear=@pYear AND DiaryDatePeriod=@pPeriod AND DiaryDateWeek<=@pWeek)

		  )
		) AS TEMPTABLE
			WHERE (  
			   (@op1 IS NULL)
			OR (@op1=@IsEqualTo AND Id = @Id )
			OR (@op1=@IsNotEqualTo AND Id <> @Id)
			OR (@op1=@IsLessThan AND Id < @Id)
			OR (@op1=@IsLessThanOrEqualTo AND Id <= @Id )
			OR (@op1=@IsGreaterThan AND Id > @Id)
			OR (@op1=@IsGreaterThanOrEqualTo AND Id >= @Id)
			OR (@op1=@Contains AND Id LIKE '%'+@Idvarchar+'%')
			OR (@op1=@DoesNotContain AND Id NOT LIKE '%'+@Idvarchar+'%')
			OR (@op1=@StartsWith AND Id LIKE ''+@Idvarchar+'%')
			OR (@op1=@EndsWith AND Id LIKE '%'+@Idvarchar+'' )	
												
			)
			AND
			(  
			   (@op2 IS NULL)
			OR (@op2=@IsEqualTo AND BusinessId = @BusinessId )
			OR (@op2=@IsNotEqualTo AND BusinessId <> @BusinessId)
			OR (@op2=@IsLessThan AND BusinessId < @BusinessId)
			OR (@op2=@IsLessThanOrEqualTo AND BusinessId <= @BusinessId )
			OR (@op2=@IsGreaterThan AND BusinessId > @BusinessId)
			OR (@op2=@IsGreaterThanOrEqualTo AND BusinessId >= @BusinessId)
			OR (@op2=@Contains AND BusinessId LIKE '%'+@BusinessId+'%')
			OR (@op2=@DoesNotContain AND BusinessId NOT LIKE '%'+@BusinessId+'%')
			OR (@op2=@StartsWith AND BusinessId LIKE ''+@BusinessId+'%')
			OR (@op2=@EndsWith AND BusinessId LIKE '%'+@BusinessId+'' )										
			)
			
			AND
			(			
			   (@op3 IS NULL)
			OR (@op3 IS NULL AND @LogicalOperator3 IS NULL)		
			OR (@LogicalOperator3='OR' AND 
					(
						(
								(@op3=@IsEqualTo AND ReceivedDate = @ReceivedDate )
							OR (@op3=@IsNotEqualTo AND ReceivedDate <> @ReceivedDate)
							OR (@op3=@IsLessThan AND ReceivedDate < @ReceivedDate)
							OR (@op3=@IsLessThanOrEqualTo AND ReceivedDate <= @ReceivedDate )
							OR (@op3=@IsGreaterThan AND ReceivedDate > @ReceivedDate)
							OR (@op3=@IsGreaterThanOrEqualTo AND ReceivedDate >= @ReceivedDate)
							OR (@op3=@Contains AND ReceivedDate LIKE '%'+@ReceivedDateVarchar +'%')
							OR (@op3=@DoesNotContain AND ReceivedDate NOT LIKE '%'+@ReceivedDateVarchar+'%')
							OR (@op3=@StartsWith AND ReceivedDate LIKE ''+@ReceivedDateVarchar+'%')
							OR (@op3=@EndsWith AND ReceivedDate LIKE '%'+@ReceivedDateVarchar+'' )
						)
						OR 
						(
								(@Secondop3=@IsEqualTo AND ReceivedDate = @SecondReceivedDate) 
							 OR	(@Secondop3=@IsNotEqualTo AND ReceivedDate <> @SecondReceivedDate) 
							 OR (@Secondop3=@IsLessThan AND ReceivedDate < @SecondReceivedDate) 
							 OR (@Secondop3=@IsLessThanOrEqualTo AND ReceivedDate <= @SecondReceivedDate) 
							 OR (@Secondop3=@IsGreaterThan AND ReceivedDate > @SecondReceivedDate) 
							 OR (@Secondop3=@IsGreaterThanOrEqualTo AND ReceivedDate >= @SecondReceivedDate) 
							 OR (@Secondop3=@Contains AND ReceivedDate LIKE '%'+@SecondReceivedDateVarchar+'%')
							 OR (@Secondop3=@DoesNotContain AND ReceivedDate NOT LIKE '%'+@SecondReceivedDateVarchar+'%')
							 OR (@Secondop3=@StartsWith AND ReceivedDate LIKE ''+@SecondReceivedDateVarchar+'%' )
							 OR (@Secondop3=@EndsWith AND ReceivedDate LIKE '%'+@SecondReceivedDateVarchar+'' )	
						 )
					
					) 
				)
				OR (@LogicalOperator3='AND' AND 
					(
						(
								(@op3=@IsEqualTo AND ReceivedDate = @ReceivedDate )
							OR (@op3=@IsNotEqualTo AND ReceivedDate <> @ReceivedDate)
							OR (@op3=@IsLessThan AND ReceivedDate < @ReceivedDate)
							OR (@op3=@IsLessThanOrEqualTo AND ReceivedDate <= @ReceivedDate )
							OR (@op3=@IsGreaterThan AND ReceivedDate > @ReceivedDate)
							OR (@op3=@IsGreaterThanOrEqualTo AND ReceivedDate >= @ReceivedDate)
							OR (@op3=@Contains AND ReceivedDate LIKE '%'+@ReceivedDateVarchar+'%')
							OR (@op3=@DoesNotContain AND ReceivedDate NOT LIKE '%'+@ReceivedDateVarchar+'%')
							OR (@op3=@StartsWith AND ReceivedDate LIKE ''+@ReceivedDateVarchar+'%')
							OR (@op3=@EndsWith AND ReceivedDate LIKE '%'+@ReceivedDateVarchar+'' )
						)
						AND 
						(
								(@Secondop3=@IsEqualTo AND ReceivedDate = @SecondReceivedDate) 
							 OR	(@Secondop3=@IsNotEqualTo AND ReceivedDate <> @SecondReceivedDate) 
							 OR (@Secondop3=@IsLessThan AND ReceivedDate < @SecondReceivedDate) 
							 OR (@Secondop3=@IsLessThanOrEqualTo AND ReceivedDate <= @SecondReceivedDate) 
							 OR (@Secondop3=@IsGreaterThan AND ReceivedDate > @SecondReceivedDate) 
							 OR (@Secondop3=@IsGreaterThanOrEqualTo AND ReceivedDate >= @SecondReceivedDate) 
							 OR (@Secondop3=@Contains AND ReceivedDate LIKE '%'+@SecondReceivedDateVarchar+'%')
							 OR (@Secondop3=@DoesNotContain AND ReceivedDate NOT LIKE '%'+@SecondReceivedDateVarchar+'%')
							 OR (@Secondop3=@StartsWith AND ReceivedDate LIKE ''+@SecondReceivedDateVarchar+'%' )
							 OR (@Secondop3=@EndsWith AND ReceivedDate LIKE '%'+@SecondReceivedDateVarchar+'' )	
						 )
					
					) 
				)
			OR (@Secondop3 IS NULL 
				AND
				(
					 (@op3=@IsEqualTo AND ReceivedDate = @ReceivedDate )
					OR (@op3=@IsNotEqualTo AND ReceivedDate <> @ReceivedDate)
					OR (@op3=@IsLessThan AND ReceivedDate < @ReceivedDate)
					OR (@op3=@IsLessThanOrEqualTo AND ReceivedDate <= @ReceivedDate )
					OR (@op3=@IsGreaterThan AND ReceivedDate > @ReceivedDate)
					OR (@op3=@IsGreaterThanOrEqualTo AND ReceivedDate >= @ReceivedDate)
					OR (@op3=@Contains AND ReceivedDate LIKE '%'+@ReceivedDateVarchar+'%')
					OR (@op3=@DoesNotContain AND ReceivedDate NOT LIKE '%'+@ReceivedDateVarchar+'%')
					OR (@op3=@StartsWith AND ReceivedDate LIKE ''+@ReceivedDateVarchar+'%')
					OR (@op3=@EndsWith AND ReceivedDate LIKE '%'+@ReceivedDateVarchar+'' )			
				)
			 )							
			)
			
			AND
			(  
			   (@op4 IS NULL)
			OR (@op4=@IsEqualTo AND IncentiveCode = @IncentiveCode )
			OR (@op4=@IsNotEqualTo AND IncentiveCode <> @IncentiveCode)
			OR (@op4=@IsLessThan AND IncentiveCode < @IncentiveCode)
			OR (@op4=@IsLessThanOrEqualTo AND IncentiveCode <= @IncentiveCode )
			OR (@op4=@IsGreaterThan AND IncentiveCode > @IncentiveCode)
			OR (@op4=@IsGreaterThanOrEqualTo AND IncentiveCode >= @IncentiveCode)
			OR (@op4=@Contains AND IncentiveCode LIKE '%'+@IncentiveCodeVarchar+'%')
			OR (@op4=@DoesNotContain AND ReceivedDate NOT LIKE '%'+@IncentiveCodeVarchar+'%')
			OR (@op4=@StartsWith AND IncentiveCode LIKE ''+@IncentiveCodeVarchar+'%')
			OR (@op4=@EndsWith AND IncentiveCode LIKE '%'+@IncentiveCodeVarchar+'' )										
			)
			AND
			(  
			   (@op5 IS NULL)
			OR (@op5=@IsEqualTo AND Points = @Points )
			OR (@op5=@IsNotEqualTo AND Points <> @Points)
			OR (@op5=@IsLessThan AND Points < @Points)
			OR (@op5=@IsLessThanOrEqualTo AND Points <= @Points )
			OR (@op5=@IsGreaterThan AND Points > @Points)
			OR (@op5=@IsGreaterThanOrEqualTo AND Points >= @Points)
			OR (@op5=@Contains AND Points LIKE '%'+@PointsVarchar+'%')
			OR (@op5=@DoesNotContain AND Points NOT LIKE '%'+@PointsVarchar+'%')
			OR (@op5=@StartsWith AND Points LIKE ''+@PointsVarchar+'%')
			OR (@op5=@EndsWith AND Points LIKE '%'+@PointsVarchar+'' )										
			)
			AND
			(  
			   (@op6 IS NULL)
			OR (@op6=@IsEqualTo AND NumberOfDaysEarly = @NumberOfDaysEarly )
			OR (@op6=@IsNotEqualTo AND NumberOfDaysEarly <> @NumberOfDaysEarly)
			OR (@op6=@IsLessThan AND NumberOfDaysEarly < @NumberOfDaysEarly)
			OR (@op6=@IsLessThanOrEqualTo AND NumberOfDaysEarly <= @NumberOfDaysEarly )
			OR (@op6=@IsGreaterThan AND NumberOfDaysEarly > @NumberOfDaysEarly)
			OR (@op6=@IsGreaterThanOrEqualTo AND NumberOfDaysEarly >= @NumberOfDaysEarly)
			OR (@op6=@Contains AND NumberOfDaysEarly LIKE '%'+@NumberOfDaysEarly+'%')
			OR (@op6=@DoesNotContain AND NumberOfDaysEarly NOT LIKE '%'+@NumberOfDaysEarly+'%')
			OR (@op6=@StartsWith AND NumberOfDaysEarly LIKE ''+@NumberOfDaysEarly+'%')
			OR (@op6=@EndsWith AND NumberOfDaysEarly LIKE '%'+@NumberOfDaysEarly+'' )										
			)
			AND
			(  
			   (@op7 IS NULL)
			OR (@op7=@IsEqualTo AND NumberOfDaysLate = @NumberOfDaysLate )
			OR (@op7=@IsNotEqualTo AND NumberOfDaysLate <> @NumberOfDaysLate)
			OR (@op7=@IsLessThan AND NumberOfDaysLate < @NumberOfDaysLate)
			OR (@op7=@IsLessThanOrEqualTo AND NumberOfDaysLate <= @NumberOfDaysLate )
			OR (@op7=@IsGreaterThan AND NumberOfDaysLate > @NumberOfDaysLate)
			OR (@op7=@IsGreaterThanOrEqualTo AND NumberOfDaysLate >= @NumberOfDaysLate)
			OR (@op7=@Contains AND NumberOfDaysLate LIKE '%'+@NumberOfDaysLate+'%')
			OR (@op7=@DoesNotContain AND NumberOfDaysLate NOT LIKE '%'+@NumberOfDaysLate+'%')
			OR (@op7=@StartsWith AND NumberOfDaysLate LIKE ''+@NumberOfDaysLate+'%')
			OR (@op7=@EndsWith AND NumberOfDaysLate LIKE '%'+@NumberOfDaysLate+'' )										
			)
			AND
			(  
			   (@op8 IS NULL)
			OR (@op8=@IsEqualTo AND DiarySourceFull = @DiarySourceFull )
			OR (@op8=@IsNotEqualTo AND DiarySourceFull <> @DiarySourceFull)
			OR (@op8=@IsLessThan AND DiarySourceFull < @DiarySourceFull)
			OR (@op8=@IsLessThanOrEqualTo AND DiarySourceFull <= @DiarySourceFull )
			OR (@op8=@IsGreaterThan AND DiarySourceFull > @DiarySourceFull)
			OR (@op8=@IsGreaterThanOrEqualTo AND DiarySourceFull >= @DiarySourceFull)
			OR (@op8=@Contains AND DiarySourceFull LIKE '%'+@DiarySourceFull+'%')
			OR (@op8=@DoesNotContain AND DiarySourceFull NOT LIKE '%'+@DiarySourceFull+'%')
			OR (@op8=@StartsWith AND DiarySourceFull LIKE ''+@DiarySourceFull+'%')
			OR (@op8=@EndsWith AND DiarySourceFull LIKE '%'+@DiarySourceFull+'' )										
			)
			AND
			(  
			   (@op9 IS NULL)
			OR (@op9=@IsEqualTo AND Panelname = @Panelname )
			OR (@op9=@IsNotEqualTo AND Panelname <> @Panelname)
			OR (@op9=@IsLessThan AND Panelname < @Panelname)
			OR (@op9=@IsLessThanOrEqualTo AND Panelname <= @Panelname )
			OR (@op9=@IsGreaterThan AND Panelname > @Panelname)
			OR (@op9=@IsGreaterThanOrEqualTo AND Panelname >= @Panelname)
			OR (@op9=@Contains AND Panelname LIKE '%'+@Panelname+'%')
			OR (@op9=@DoesNotContain AND Panelname NOT LIKE '%'+@Panelname+'%')
			OR (@op9=@StartsWith AND Panelname LIKE ''+@Panelname+'%')
			OR (@op9=@EndsWith AND Panelname LIKE '%'+@Panelname+'' )										
			)
			
			AND
			(			
			   (@op10 IS NULL)
			OR (@op10 IS NULL AND @LogicalOperator10 IS NULL)		
			OR (@LogicalOperator10='OR' AND 
					(
						(
							   (@op10=@IsEqualTo AND CreationTimeStamp = @CreationTimeStamp )
							OR (@op10=@IsNotEqualTo AND CreationTimeStamp <> @CreationTimeStamp)
							OR (@op10=@IsLessThan AND CreationTimeStamp < @CreationTimeStamp)
							OR (@op10=@IsLessThanOrEqualTo AND CreationTimeStamp <= @CreationTimeStamp )
							OR (@op10=@IsGreaterThan AND CreationTimeStamp > @CreationTimeStamp)
							OR (@op10=@IsGreaterThanOrEqualTo AND CreationTimeStamp >= @CreationTimeStamp)
							OR (@op10=@Contains AND CreationTimeStamp LIKE '%'+@CreationTimeStampVarchar+'%')
							OR (@op10=@DoesNotContain AND CreationTimeStamp NOT LIKE '%'+@CreationTimeStampVarchar+'%')
							OR (@op10=@StartsWith AND CreationTimeStamp LIKE ''+@CreationTimeStampVarchar+'%')
							OR (@op10=@EndsWith AND CreationTimeStamp LIKE '%'+@CreationTimeStampVarchar+'' )	
						)
						OR 
						(
								(@Secondop10=@IsEqualTo AND CreationTimeStamp = @SecondCreationTimeStamp) 
							 OR	(@Secondop10=@IsNotEqualTo AND CreationTimeStamp <> @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsLessThan AND CreationTimeStamp < @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsLessThanOrEqualTo AND CreationTimeStamp <= @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsGreaterThan AND CreationTimeStamp > @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsGreaterThanOrEqualTo AND CreationTimeStamp >= @SecondCreationTimeStamp) 
							 OR (@Secondop10=@Contains AND CreationTimeStamp LIKE '%'+@SecondCreationTimeStampVarchar+'%')
							 OR (@Secondop10=@DoesNotContain AND CreationTimeStamp NOT LIKE '%'+@SecondCreationTimeStampVarchar+'%')
							 OR (@Secondop10=@StartsWith AND CreationTimeStamp LIKE ''+@SecondCreationTimeStampVarchar+'%' )
							 OR (@Secondop10=@EndsWith AND CreationTimeStamp LIKE '%'+@SecondCreationTimeStampVarchar+'' )	
						 )
					
					) 
				)
				OR (@LogicalOperator10='AND' AND 
					(
						(
								  (@op10=@IsEqualTo AND CreationTimeStamp = @CreationTimeStamp )
							OR (@op10=@IsNotEqualTo AND CreationTimeStamp <> @CreationTimeStamp)
							OR (@op10=@IsLessThan AND CreationTimeStamp < @CreationTimeStamp)
							OR (@op10=@IsLessThanOrEqualTo AND CreationTimeStamp <= @CreationTimeStamp )
							OR (@op10=@IsGreaterThan AND CreationTimeStamp > @CreationTimeStamp)
							OR (@op10=@IsGreaterThanOrEqualTo AND CreationTimeStamp >= @CreationTimeStamp)
							OR (@op10=@Contains AND CreationTimeStamp LIKE '%'+@CreationTimeStampVarchar+'%')
							OR (@op10=@DoesNotContain AND CreationTimeStamp NOT LIKE '%'+@CreationTimeStampVarchar+'%')
							OR (@op10=@StartsWith AND CreationTimeStamp LIKE ''+@CreationTimeStampVarchar+'%')
							OR (@op10=@EndsWith AND CreationTimeStamp LIKE '%'+@CreationTimeStampVarchar+'' )	
						)
						AND 
						(
									(@Secondop10=@IsEqualTo AND CreationTimeStamp = @SecondCreationTimeStamp) 
							 OR	(@Secondop10=@IsNotEqualTo AND CreationTimeStamp <> @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsLessThan AND CreationTimeStamp < @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsLessThanOrEqualTo AND CreationTimeStamp <= @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsGreaterThan AND CreationTimeStamp > @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsGreaterThanOrEqualTo AND CreationTimeStamp >= @SecondCreationTimeStamp) 
							 OR (@Secondop10=@Contains AND CreationTimeStamp LIKE '%'+@SecondCreationTimeStampVarchar+'%')
							 OR (@Secondop10=@DoesNotContain AND CreationTimeStamp NOT LIKE '%'+@SecondCreationTimeStampVarchar+'%')
							 OR (@Secondop10=@StartsWith AND CreationTimeStamp LIKE ''+@SecondCreationTimeStampVarchar+'%' )
							 OR (@Secondop10=@EndsWith AND CreationTimeStamp LIKE '%'+@SecondCreationTimeStampVarchar+'' )	
						 )
					
					) 
				)
			OR (@Secondop10 IS NULL
				AND 
				(
				   (@op10=@IsEqualTo AND CreationTimeStamp = @CreationTimeStamp )
				OR (@op10=@IsNotEqualTo AND CreationTimeStamp <> @CreationTimeStamp)
				OR (@op10=@IsLessThan AND CreationTimeStamp < @CreationTimeStamp)
				OR (@op10=@IsLessThanOrEqualTo AND CreationTimeStamp <= @CreationTimeStamp )
				OR (@op10=@IsGreaterThan AND CreationTimeStamp > @CreationTimeStamp)
				OR (@op10=@IsGreaterThanOrEqualTo AND CreationTimeStamp >= @CreationTimeStamp)
				OR (@op10=@Contains AND CreationTimeStamp LIKE '%'+@CreationTimeStampVarchar+'%')
				OR (@op10=@DoesNotContain AND CreationTimeStamp NOT LIKE '%'+@CreationTimeStampVarchar+'%')
				OR (@op10=@StartsWith AND CreationTimeStamp LIKE ''+@CreationTimeStampVarchar+'%')
				OR (@op10=@EndsWith AND CreationTimeStamp LIKE '%'+@CreationTimeStampVarchar+'' )			
				)
			 )							
			)
			AND
			(  
			   (@op11 IS NULL)
			OR (@op11=@IsEqualTo AND ClaimFlag = @ClaimFlag )
			OR (@op11=@IsNotEqualTo AND ClaimFlag <> @ClaimFlag)
			OR (@op11=@IsLessThan AND ClaimFlag < @ClaimFlag)
			OR (@op11=@IsLessThanOrEqualTo AND ClaimFlag <= @ClaimFlag )
			OR (@op11=@IsGreaterThan AND ClaimFlag > @ClaimFlag)
			OR (@op11=@IsGreaterThanOrEqualTo AND ClaimFlag >= @ClaimFlag)
			OR (@op11=@Contains AND ClaimFlag LIKE '%'+@ClaimFlagVarchar+'%')
			OR (@op11=@DoesNotContain AND ClaimFlag NOT LIKE '%'+@ClaimFlagVarchar+'%')
			OR (@op11=@StartsWith AND ClaimFlag LIKE ''+@ClaimFlagVarchar+'%')
			OR (@op11=@EndsWith AND ClaimFlag LIKE '%'+@ClaimFlagVarchar+'' )										
			)
			AND
			(  
			   (@op12 IS NULL)
			OR (@op12=@IsEqualTo AND Together = @Together )
			OR (@op12=@IsNotEqualTo AND Together <> @Together)
			OR (@op12=@IsLessThan AND Together < @Together)
			OR (@op12=@IsLessThanOrEqualTo AND Together <= @Together )
			OR (@op12=@IsGreaterThan AND Together > @Together)
			OR (@op12=@IsGreaterThanOrEqualTo AND Together >= @Together)
			OR (@op12=@Contains AND Together LIKE '%'+@TogetherVarchar+'%')
			OR (@op12=@DoesNotContain AND Together NOT LIKE '%'+@TogetherVarchar+'%')
			OR (@op12=@StartsWith AND Together LIKE ''+@TogetherVarchar+'%')
			OR (@op12=@EndsWith AND Together LIKE '%'+@TogetherVarchar+'' )										
			)
			AND
			(  
			   (@op13 IS NULL)
			OR (@op13=@IsEqualTo AND DiaryDateFull = @DiaryDateFull )
			OR (@op13=@IsNotEqualTo AND DiaryDateFull <> @DiaryDateFull)
			OR (@op13=@IsLessThan AND DiaryDateFull < @DiaryDateFull)
			OR (@op13=@IsLessThanOrEqualTo AND DiaryDateFull <= @DiaryDateFull )
			OR (@op13=@IsGreaterThan AND DiaryDateFull > @DiaryDateFull)
			OR (@op13=@IsGreaterThanOrEqualTo AND DiaryDateFull >= @DiaryDateFull)
			OR (@op13=@Contains AND DiaryDateFull LIKE '%'+@DiaryDateFull+'%')
			OR (@op13=@DoesNotContain AND DiaryDateFull NOT LIKE '%'+@DiaryDateFull+'%')
			OR (@op13=@StartsWith AND DiaryDateFull LIKE ''+@DiaryDateFull+'%')
			OR (@op13=@EndsWith AND DiaryDateFull LIKE '%'+@DiaryDateFull+'' )										
			)
			AND
			(  
			   (@op14 IS NULL)
			OR (@op14=@IsEqualTo AND DiaryState = @DiaryState )
			OR (@op14=@IsNotEqualTo AND DiaryState <> @DiaryState)
			OR (@op14=@IsLessThan AND DiaryState < @DiaryState)
			OR (@op14=@IsLessThanOrEqualTo AND DiaryState <= @DiaryState )
			OR (@op14=@IsGreaterThan AND DiaryState > @DiaryState)
			OR (@op14=@IsGreaterThanOrEqualTo AND DiaryState >= @DiaryState)
			OR (@op14=@Contains AND DiaryState LIKE '%'+@DiaryState+'%')
			OR (@op14=@DoesNotContain AND DiaryState NOT LIKE '%'+@DiaryState+'%')
			OR (@op14=@StartsWith AND DiaryState LIKE ''+@DiaryState+'%')
			OR (@op14=@EndsWith AND DiaryState LIKE '%'+@DiaryState+'' )										
			)			
						
		   OPTION (RECOMPILE)
	END	
			
	SELECT * FROM (
	SELECT  Id,BusinessId,CAST(ReceivedDate AS DATE) AS ReceivedDate,IncentiveCode,Points,(CASE WHEN NumberOfDaysEarly=1 THEN 'Yes'
															 ELSE '' END
															) AS NumberOfDaysEarly,
														   (CASE WHEN NumberOfDaysLate=1 THEN 'Yes'
															 ELSE '' END
															) AS NumberOfDaysLate,
		  DiarySourceFull, @GivenPanelname  AS Panelname,CAST(CreationTimeStamp AS DATE)AS CreationTimeStamp,ClaimFlag,
		 (CASE WHEN Together=1 THEN 'Yes'
		   ELSE '' END
		 ) AS Together,
		  CONVERT(VARCHAR,DiaryDateYear)+'.'+CONVERT(VARCHAR,DiaryDatePeriod)+'.'+CONVERT(VARCHAR,DiaryDateWeek) AS DiaryDateFull,
		  DiaryState
		  FROM DiaryEntry 
		  WHERE PanelId= @pPanelId
		  AND CAST(ReceivedDate AS DATE) BETWEEN @StartDate AND @Enddate
		  AND (DiaryDateYear<@pYear

		  OR (DiaryDateYear=@pYear AND DiaryDatePeriod<@pPeriod)

		  OR (DiaryDateYear=@pYear AND DiaryDatePeriod=@pPeriod AND DiaryDateWeek<=@pWeek)

		  )
		 UNION ALL

	SELECT  Id,BusinessId,NULL AS ReceivedDate,0 AS IncentiveCode,0 AS Points,(CASE WHEN NumberOfDaysEarly=1 THEN 'Yes'
																	   ELSE '' END
																	  ) AS NumberOfDaysEarly,
																	 (CASE WHEN NumberOfDaysLate=1 THEN 'Yes'
																		ELSE '' END
																	 ) AS NumberOfDaysLate,
									
                                    
		  DiarySourceFull, @GivenPanelname  AS Panelname,CAST(CreationTimeStamp AS DATE)AS CreationTimeStamp,ClaimFlag,'' AS Together,
		 CONVERT(VARCHAR,DiaryDateYear)+'.'+CONVERT(VARCHAR,DiaryDatePeriod)+'.'+CONVERT(VARCHAR,DiaryDateWeek) AS DiaryDateFull,
		 '' AS DiaryState
		FROM MissingDiaries 
		WHERE PanelId= @pPanelId 
		AND CAST(CreationTimeStamp AS DATE) BETWEEN @StartDate AND @Enddate
		AND (DiaryDateYear<@pYear

		  OR (DiaryDateYear=@pYear AND DiaryDatePeriod<@pPeriod)

		  OR (DiaryDateYear=@pYear AND DiaryDatePeriod=@pPeriod AND DiaryDateWeek<=@pWeek)

		  )
		) AS TEMPTABLE
			WHERE (  
			   (@op1 IS NULL)
			OR (@op1=@IsEqualTo AND Id = @Id )
			OR (@op1=@IsNotEqualTo AND Id <> @Id)
			OR (@op1=@IsLessThan AND Id < @Id)
			OR (@op1=@IsLessThanOrEqualTo AND Id <= @Id )
			OR (@op1=@IsGreaterThan AND Id > @Id)
			OR (@op1=@IsGreaterThanOrEqualTo AND Id >= @Id)
			OR (@op1=@Contains AND Id LIKE '%'+@Idvarchar+'%')
			OR (@op1=@DoesNotContain AND Id NOT LIKE '%'+@Idvarchar+'%')
			OR (@op1=@StartsWith AND Id LIKE ''+@Idvarchar+'%')
			OR (@op1=@EndsWith AND Id LIKE '%'+@Idvarchar+'' )	
												
			)
			AND
			(  
			   (@op2 IS NULL)
			OR (@op2=@IsEqualTo AND BusinessId = @BusinessId )
			OR (@op2=@IsNotEqualTo AND BusinessId <> @BusinessId)
			OR (@op2=@IsLessThan AND BusinessId < @BusinessId)
			OR (@op2=@IsLessThanOrEqualTo AND BusinessId <= @BusinessId )
			OR (@op2=@IsGreaterThan AND BusinessId > @BusinessId)
			OR (@op2=@IsGreaterThanOrEqualTo AND BusinessId >= @BusinessId)
			OR (@op2=@Contains AND BusinessId LIKE '%'+@BusinessId+'%')
			OR (@op2=@DoesNotContain AND BusinessId NOT LIKE '%'+@BusinessId+'%')
			OR (@op2=@StartsWith AND BusinessId LIKE ''+@BusinessId+'%')
			OR (@op2=@EndsWith AND BusinessId LIKE '%'+@BusinessId+'' )										
			)
			AND
			(			
			   (@op3 IS NULL)
			OR (@op3 IS NULL AND @LogicalOperator3 IS NULL)		
			OR (@LogicalOperator3='OR' AND 
					(
						(
								(@op3=@IsEqualTo AND ReceivedDate = @ReceivedDate )
							OR (@op3=@IsNotEqualTo AND ReceivedDate <> @ReceivedDate)
							OR (@op3=@IsLessThan AND ReceivedDate < @ReceivedDate)
							OR (@op3=@IsLessThanOrEqualTo AND ReceivedDate <= @ReceivedDate )
							OR (@op3=@IsGreaterThan AND ReceivedDate > @ReceivedDate)
							OR (@op3=@IsGreaterThanOrEqualTo AND ReceivedDate >= @ReceivedDate)
							OR (@op3=@Contains AND ReceivedDate LIKE '%'+@ReceivedDateVarchar+'%')
							OR (@op3=@DoesNotContain AND ReceivedDate NOT LIKE '%'+@ReceivedDateVarchar+'%')
							OR (@op3=@StartsWith AND ReceivedDate LIKE ''+@ReceivedDateVarchar+'%')
							OR (@op3=@EndsWith AND ReceivedDate LIKE '%'+@ReceivedDateVarchar+'' )
						)
						OR 
						(
								(@Secondop3=@IsEqualTo AND ReceivedDate = @SecondReceivedDate) 
							 OR	(@Secondop3=@IsNotEqualTo AND ReceivedDate <> @SecondReceivedDate) 
							 OR (@Secondop3=@IsLessThan AND ReceivedDate < @SecondReceivedDate) 
							 OR (@Secondop3=@IsLessThanOrEqualTo AND ReceivedDate <= @SecondReceivedDate) 
							 OR (@Secondop3=@IsGreaterThan AND ReceivedDate > @SecondReceivedDate) 
							 OR (@Secondop3=@IsGreaterThanOrEqualTo AND ReceivedDate >= @SecondReceivedDate) 
							 OR (@Secondop3=@Contains AND ReceivedDate LIKE '%'+@SecondReceivedDateVarchar+'%')
							 OR (@Secondop3=@DoesNotContain AND ReceivedDate NOT LIKE '%'+@SecondReceivedDateVarchar+'%')
							 OR (@Secondop3=@StartsWith AND ReceivedDate LIKE ''+@SecondReceivedDateVarchar+'%' )
							 OR (@Secondop3=@EndsWith AND ReceivedDate LIKE '%'+@SecondReceivedDateVarchar+'' )	
						 )
					
					) 
				)
				OR (@LogicalOperator3='AND' AND 
					(
						(
								(@op3=@IsEqualTo AND ReceivedDate = @ReceivedDate )
							OR (@op3=@IsNotEqualTo AND ReceivedDate <> @ReceivedDate)
							OR (@op3=@IsLessThan AND ReceivedDate < @ReceivedDate)
							OR (@op3=@IsLessThanOrEqualTo AND ReceivedDate <= @ReceivedDate )
							OR (@op3=@IsGreaterThan AND ReceivedDate > @ReceivedDate)
							OR (@op3=@IsGreaterThanOrEqualTo AND ReceivedDate >= @ReceivedDate)
							OR (@op3=@Contains AND ReceivedDate LIKE '%'+@ReceivedDateVarchar+'%')
							OR (@op3=@DoesNotContain AND ReceivedDate NOT LIKE '%'+@ReceivedDateVarchar+'%')
							OR (@op3=@StartsWith AND ReceivedDate LIKE ''+@ReceivedDateVarchar+'%')
							OR (@op3=@EndsWith AND ReceivedDate LIKE '%'+@ReceivedDateVarchar+'' )
						)
						AND 
						(
								(@Secondop3=@IsEqualTo AND ReceivedDate = @SecondReceivedDate) 
							 OR	(@Secondop3=@IsNotEqualTo AND ReceivedDate <> @SecondReceivedDate) 
							 OR (@Secondop3=@IsLessThan AND ReceivedDate < @SecondReceivedDate) 
							 OR (@Secondop3=@IsLessThanOrEqualTo AND ReceivedDate <= @SecondReceivedDate) 
							 OR (@Secondop3=@IsGreaterThan AND ReceivedDate > @SecondReceivedDate) 
							 OR (@Secondop3=@IsGreaterThanOrEqualTo AND ReceivedDate >= @SecondReceivedDate) 
							 OR (@Secondop3=@Contains AND ReceivedDate LIKE '%'+@SecondReceivedDateVarchar+'%')
							 OR (@Secondop3=@DoesNotContain AND ReceivedDate NOT LIKE '%'+@SecondReceivedDateVarchar+'%')
							 OR (@Secondop3=@StartsWith AND ReceivedDate LIKE ''+@SecondReceivedDateVarchar+'%' )
							 OR (@Secondop3=@EndsWith AND ReceivedDate LIKE '%'+@SecondReceivedDateVarchar+'' )	
						 )
					
					) 
				)
			OR (@Secondop3 IS NULL 
				AND
				(
					   (@op3=@IsEqualTo AND ReceivedDate = @ReceivedDate )
					OR (@op3=@IsNotEqualTo AND ReceivedDate <> @ReceivedDate)
					OR (@op3=@IsLessThan AND ReceivedDate < @ReceivedDate)
					OR (@op3=@IsLessThanOrEqualTo AND ReceivedDate <= @ReceivedDate )
					OR (@op3=@IsGreaterThan AND ReceivedDate > @ReceivedDate)
					OR (@op3=@IsGreaterThanOrEqualTo AND ReceivedDate >= @ReceivedDate)
					OR (@op3=@Contains AND ReceivedDate LIKE '%'+@ReceivedDateVarchar+'%')
					OR (@op3=@DoesNotContain AND ReceivedDate NOT LIKE '%'+@ReceivedDateVarchar+'%')
					OR (@op3=@StartsWith AND ReceivedDate LIKE ''+@ReceivedDateVarchar+'%')
					OR (@op3=@EndsWith AND ReceivedDate LIKE '%'+@ReceivedDateVarchar+'' )		
				)
			  )											
			)	

			AND
			(  
			   (@op4 IS NULL)
			OR (@op4=@IsEqualTo AND IncentiveCode = @IncentiveCode )
			OR (@op4=@IsNotEqualTo AND IncentiveCode <> @IncentiveCode)
			OR (@op4=@IsLessThan AND IncentiveCode < @IncentiveCode)
			OR (@op4=@IsLessThanOrEqualTo AND IncentiveCode <= @IncentiveCode )
			OR (@op4=@IsGreaterThan AND IncentiveCode > @IncentiveCode)
			OR (@op4=@IsGreaterThanOrEqualTo AND IncentiveCode >= @IncentiveCode)
			OR (@op4=@Contains AND IncentiveCode LIKE '%'+@IncentiveCodeVarchar+'%')
			OR (@op4=@DoesNotContain AND ReceivedDate NOT LIKE '%'+@IncentiveCodeVarchar+'%')
			OR (@op4=@StartsWith AND IncentiveCode LIKE ''+@IncentiveCodeVarchar+'%')
			OR (@op4=@EndsWith AND IncentiveCode LIKE '%'+@IncentiveCodeVarchar+'' )										
			)
			AND
			(  
			   (@op5 IS NULL)
			OR (@op5=@IsEqualTo AND Points = @Points )
			OR (@op5=@IsNotEqualTo AND Points <> @Points)
			OR (@op5=@IsLessThan AND Points < @Points)
			OR (@op5=@IsLessThanOrEqualTo AND Points <= @Points )
			OR (@op5=@IsGreaterThan AND Points > @Points)
			OR (@op5=@IsGreaterThanOrEqualTo AND Points >= @Points)
			OR (@op5=@Contains AND Points LIKE '%'+@PointsVarchar+'%')
			OR (@op5=@DoesNotContain AND Points NOT LIKE '%'+@PointsVarchar+'%')
			OR (@op5=@StartsWith AND Points LIKE ''+@PointsVarchar+'%')
			OR (@op5=@EndsWith AND Points LIKE '%'+@PointsVarchar+'' )										
			)
			AND
			(  
			   (@op6 IS NULL)
			OR (@op6=@IsEqualTo AND NumberOfDaysEarly = @NumberOfDaysEarly )
			OR (@op6=@IsNotEqualTo AND NumberOfDaysEarly <> @NumberOfDaysEarly)
			OR (@op6=@IsLessThan AND NumberOfDaysEarly < @NumberOfDaysEarly)
			OR (@op6=@IsLessThanOrEqualTo AND NumberOfDaysEarly <= @NumberOfDaysEarly )
			OR (@op6=@IsGreaterThan AND NumberOfDaysEarly > @NumberOfDaysEarly)
			OR (@op6=@IsGreaterThanOrEqualTo AND NumberOfDaysEarly >= @NumberOfDaysEarly)
			OR (@op6=@Contains AND NumberOfDaysEarly LIKE '%'+@NumberOfDaysEarly+'%')
			OR (@op6=@DoesNotContain AND NumberOfDaysEarly NOT LIKE '%'+@NumberOfDaysEarly+'%')
			OR (@op6=@StartsWith AND NumberOfDaysEarly LIKE ''+@NumberOfDaysEarly+'%')
			OR (@op6=@EndsWith AND NumberOfDaysEarly LIKE '%'+@NumberOfDaysEarly+'' )										
			)
			AND
			(  
			   (@op7 IS NULL)
			OR (@op7=@IsEqualTo AND NumberOfDaysLate = @NumberOfDaysLate )
			OR (@op7=@IsNotEqualTo AND NumberOfDaysLate <> @NumberOfDaysLate)
			OR (@op7=@IsLessThan AND NumberOfDaysLate < @NumberOfDaysLate)
			OR (@op7=@IsLessThanOrEqualTo AND NumberOfDaysLate <= @NumberOfDaysLate )
			OR (@op7=@IsGreaterThan AND NumberOfDaysLate > @NumberOfDaysLate)
			OR (@op7=@IsGreaterThanOrEqualTo AND NumberOfDaysLate >= @NumberOfDaysLate)
			OR (@op7=@Contains AND NumberOfDaysLate LIKE '%'+@NumberOfDaysLate+'%')
			OR (@op7=@DoesNotContain AND NumberOfDaysLate NOT LIKE '%'+@NumberOfDaysLate+'%')
			OR (@op7=@StartsWith AND NumberOfDaysLate LIKE ''+@NumberOfDaysLate+'%')
			OR (@op7=@EndsWith AND NumberOfDaysLate LIKE '%'+@NumberOfDaysLate+'' )										
			)
			AND
			(  
			   (@op8 IS NULL)
			OR (@op8=@IsEqualTo AND DiarySourceFull = @DiarySourceFull )
			OR (@op8=@IsNotEqualTo AND DiarySourceFull <> @DiarySourceFull)
			OR (@op8=@IsLessThan AND DiarySourceFull < @DiarySourceFull)
			OR (@op8=@IsLessThanOrEqualTo AND DiarySourceFull <= @DiarySourceFull )
			OR (@op8=@IsGreaterThan AND DiarySourceFull > @DiarySourceFull)
			OR (@op8=@IsGreaterThanOrEqualTo AND DiarySourceFull >= @DiarySourceFull)
			OR (@op8=@Contains AND DiarySourceFull LIKE '%'+@DiarySourceFull+'%')
			OR (@op8=@DoesNotContain AND DiarySourceFull NOT LIKE '%'+@DiarySourceFull+'%')
			OR (@op8=@StartsWith AND DiarySourceFull LIKE ''+@DiarySourceFull+'%')
			OR (@op8=@EndsWith AND DiarySourceFull LIKE '%'+@DiarySourceFull+'' )										
			)
			AND
			(  
			   (@op9 IS NULL)
			OR (@op9=@IsEqualTo AND Panelname = @Panelname )
			OR (@op9=@IsNotEqualTo AND Panelname <> @Panelname)
			OR (@op9=@IsLessThan AND Panelname < @Panelname)
			OR (@op9=@IsLessThanOrEqualTo AND Panelname <= @Panelname )
			OR (@op9=@IsGreaterThan AND Panelname > @Panelname)
			OR (@op9=@IsGreaterThanOrEqualTo AND Panelname >= @Panelname)
			OR (@op9=@Contains AND Panelname LIKE '%'+@Panelname+'%')
			OR (@op9=@DoesNotContain AND Panelname NOT LIKE '%'+@Panelname+'%')
			OR (@op9=@StartsWith AND Panelname LIKE ''+@Panelname+'%')
			OR (@op9=@EndsWith AND Panelname LIKE '%'+@Panelname+'' )										
			)			
			AND
			(			
			   (@op10 IS NULL)
			OR (@op10 IS NULL AND @LogicalOperator10 IS NULL)		
			OR (@LogicalOperator10='OR' AND 
					(
						(
							   (@op10=@IsEqualTo AND CreationTimeStamp = @CreationTimeStamp )
							OR (@op10=@IsNotEqualTo AND CreationTimeStamp <> @CreationTimeStamp)
							OR (@op10=@IsLessThan AND CreationTimeStamp < @CreationTimeStamp)
							OR (@op10=@IsLessThanOrEqualTo AND CreationTimeStamp <= @CreationTimeStamp )
							OR (@op10=@IsGreaterThan AND CreationTimeStamp > @CreationTimeStamp)
							OR (@op10=@IsGreaterThanOrEqualTo AND CreationTimeStamp >= @CreationTimeStamp)
							OR (@op10=@Contains AND CreationTimeStamp LIKE '%'+@CreationTimeStampVarchar+'%')
							OR (@op10=@DoesNotContain AND CreationTimeStamp NOT LIKE '%'+@CreationTimeStampVarchar+'%')
							OR (@op10=@StartsWith AND CreationTimeStamp LIKE ''+@CreationTimeStampVarchar+'%')
							OR (@op10=@EndsWith AND CreationTimeStamp LIKE '%'+@CreationTimeStampVarchar+'' )	
						)
						OR 
						(
								(@Secondop10=@IsEqualTo AND CreationTimeStamp = @SecondCreationTimeStamp) 
							 OR	(@Secondop10=@IsNotEqualTo AND CreationTimeStamp <> @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsLessThan AND CreationTimeStamp < @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsLessThanOrEqualTo AND CreationTimeStamp <= @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsGreaterThan AND CreationTimeStamp > @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsGreaterThanOrEqualTo AND CreationTimeStamp >= @SecondCreationTimeStamp) 
							 OR (@Secondop10=@Contains AND CreationTimeStamp LIKE '%'+@SecondCreationTimeStampVarchar+'%')
							 OR (@Secondop10=@DoesNotContain AND CreationTimeStamp NOT LIKE '%'+@SecondCreationTimeStampVarchar+'%')
							 OR (@Secondop10=@StartsWith AND CreationTimeStamp LIKE ''+@SecondCreationTimeStampVarchar+'%' )
							 OR (@Secondop10=@EndsWith AND CreationTimeStamp LIKE '%'+@SecondCreationTimeStampVarchar+'' )	
						 )
					
					) 
				)
				OR (@LogicalOperator10='AND' AND 
					(
						(
								  (@op10=@IsEqualTo AND CreationTimeStamp = @CreationTimeStamp )
							OR (@op10=@IsNotEqualTo AND CreationTimeStamp <> @CreationTimeStamp)
							OR (@op10=@IsLessThan AND CreationTimeStamp < @CreationTimeStamp)
							OR (@op10=@IsLessThanOrEqualTo AND CreationTimeStamp <= @CreationTimeStamp )
							OR (@op10=@IsGreaterThan AND CreationTimeStamp > @CreationTimeStamp)
							OR (@op10=@IsGreaterThanOrEqualTo AND CreationTimeStamp >= @CreationTimeStamp)
							OR (@op10=@Contains AND CreationTimeStamp LIKE '%'+@CreationTimeStampVarchar+'%')
							OR (@op10=@DoesNotContain AND CreationTimeStamp NOT LIKE '%'+@CreationTimeStampVarchar+'%')
							OR (@op10=@StartsWith AND CreationTimeStamp LIKE ''+@CreationTimeStampVarchar+'%')
							OR (@op10=@EndsWith AND CreationTimeStamp LIKE '%'+@CreationTimeStampVarchar+'' )	
						)
						AND 
						(
									(@Secondop10=@IsEqualTo AND CreationTimeStamp = @SecondCreationTimeStamp) 
							 OR	(@Secondop10=@IsNotEqualTo AND CreationTimeStamp <> @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsLessThan AND CreationTimeStamp < @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsLessThanOrEqualTo AND CreationTimeStamp <= @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsGreaterThan AND CreationTimeStamp > @SecondCreationTimeStamp) 
							 OR (@Secondop10=@IsGreaterThanOrEqualTo AND CreationTimeStamp >= @SecondCreationTimeStamp) 
							 OR (@Secondop10=@Contains AND CreationTimeStamp LIKE '%'+@SecondCreationTimeStampVarchar+'%')
							 OR (@Secondop10=@DoesNotContain AND CreationTimeStamp NOT LIKE '%'+@SecondCreationTimeStampVarchar+'%')
							 OR (@Secondop10=@StartsWith AND CreationTimeStamp LIKE ''+@SecondCreationTimeStampVarchar+'%' )
							 OR (@Secondop10=@EndsWith AND CreationTimeStamp LIKE '%'+@SecondCreationTimeStampVarchar+'' )	
						 )
					
					) 
				)
			OR (@Secondop10 IS NULL
				AND
				(
					 (@op10=@IsEqualTo AND CreationTimeStamp = @CreationTimeStamp )
					OR (@op10=@IsNotEqualTo AND CreationTimeStamp <> @CreationTimeStamp)
					OR (@op10=@IsLessThan AND CreationTimeStamp < @CreationTimeStamp)
					OR (@op10=@IsLessThanOrEqualTo AND CreationTimeStamp <= @CreationTimeStamp )
					OR (@op10=@IsGreaterThan AND CreationTimeStamp > @CreationTimeStamp)
					OR (@op10=@IsGreaterThanOrEqualTo AND CreationTimeStamp >= @CreationTimeStamp)
					OR (@op10=@Contains AND CreationTimeStamp LIKE '%'+@CreationTimeStampVarchar+'%')
					OR (@op10=@DoesNotContain AND CreationTimeStamp NOT LIKE '%'+@CreationTimeStampVarchar+'%')
					OR (@op10=@StartsWith AND CreationTimeStamp LIKE ''+@CreationTimeStampVarchar+'%')
					OR (@op10=@EndsWith AND CreationTimeStamp LIKE '%'+@CreationTimeStampVarchar+'' )	
				)
			)											
			)
			AND
			(  
			   (@op11 IS NULL)
			OR (@op11=@IsEqualTo AND ClaimFlag = @ClaimFlag )
			OR (@op11=@IsNotEqualTo AND ClaimFlag <> @ClaimFlag)
			OR (@op11=@IsLessThan AND ClaimFlag < @ClaimFlag)
			OR (@op11=@IsLessThanOrEqualTo AND ClaimFlag <= @ClaimFlag )
			OR (@op11=@IsGreaterThan AND ClaimFlag > @ClaimFlag)
			OR (@op11=@IsGreaterThanOrEqualTo AND ClaimFlag >= @ClaimFlag)
			OR (@op11=@Contains AND ClaimFlag LIKE '%'+@ClaimFlagVarchar+'%')
			OR (@op11=@DoesNotContain AND ClaimFlag NOT LIKE '%'+@ClaimFlagVarchar+'%')
			OR (@op11=@StartsWith AND ClaimFlag LIKE ''+@ClaimFlagVarchar+'%')
			OR (@op11=@EndsWith AND ClaimFlag LIKE '%'+@ClaimFlagVarchar+'' )										
			)
			AND
			(  
			   (@op12 IS NULL)
			OR (@op12=@IsEqualTo AND Together = @Together )
			OR (@op12=@IsNotEqualTo AND Together <> @Together)
			OR (@op12=@IsLessThan AND Together < @Together)
			OR (@op12=@IsLessThanOrEqualTo AND Together <= @Together )
			OR (@op12=@IsGreaterThan AND Together > @Together)
			OR (@op12=@IsGreaterThanOrEqualTo AND Together >= @Together)
			OR (@op12=@Contains AND Together LIKE '%'+@TogetherVarchar+'%')
			OR (@op12=@DoesNotContain AND Together NOT LIKE '%'+@TogetherVarchar+'%')
			OR (@op12=@StartsWith AND Together LIKE ''+@TogetherVarchar+'%')
			OR (@op12=@EndsWith AND Together LIKE '%'+@TogetherVarchar+'' )										
			)
			AND
			(  
			   (@op13 IS NULL)
			OR (@op13=@IsEqualTo AND DiaryDateFull = @DiaryDateFull )
			OR (@op13=@IsNotEqualTo AND DiaryDateFull <> @DiaryDateFull)
			OR (@op13=@IsLessThan AND DiaryDateFull < @DiaryDateFull)
			OR (@op13=@IsLessThanOrEqualTo AND DiaryDateFull <= @DiaryDateFull )
			OR (@op13=@IsGreaterThan AND DiaryDateFull > @DiaryDateFull)
			OR (@op13=@IsGreaterThanOrEqualTo AND DiaryDateFull >= @DiaryDateFull)
			OR (@op13=@Contains AND DiaryDateFull LIKE '%'+@DiaryDateFull+'%')
			OR (@op13=@DoesNotContain AND DiaryDateFull NOT LIKE '%'+@DiaryDateFull+'%')
			OR (@op13=@StartsWith AND DiaryDateFull LIKE ''+@DiaryDateFull+'%')
			OR (@op13=@EndsWith AND DiaryDateFull LIKE '%'+@DiaryDateFull+'' )										
			)
			AND
			(  
			   (@op14 IS NULL)
			OR (@op14=@IsEqualTo AND DiaryState = @DiaryState )
			OR (@op14=@IsNotEqualTo AND DiaryState <> @DiaryState)
			OR (@op14=@IsLessThan AND DiaryState < @DiaryState)
			OR (@op14=@IsLessThanOrEqualTo AND DiaryState <= @DiaryState )
			OR (@op14=@IsGreaterThan AND DiaryState > @DiaryState)
			OR (@op14=@IsGreaterThanOrEqualTo AND DiaryState >= @DiaryState)
			OR (@op14=@Contains AND DiaryState LIKE '%'+@DiaryState+'%')
			OR (@op14=@DoesNotContain AND DiaryState NOT LIKE '%'+@DiaryState+'%')
			OR (@op14=@StartsWith AND DiaryState LIKE ''+@DiaryState+'%')
			OR (@op14=@EndsWith AND DiaryState LIKE '%'+@DiaryState+'' )										
			)
			--AND
			--(  
			--   (@op14 IS NULL)
			--OR (@op14=@IsEqualTo AND DiarySourceFull = @DiarySourceFull )
			--OR (@op14=@IsNotEqualTo AND DiarySourceFull <> @DiarySourceFull)
			--OR (@op14=@IsLessThan AND DiarySourceFull < @DiarySourceFull)
			--OR (@op14=@IsLessThanOrEqualTo AND DiarySourceFull <= @DiarySourceFull )
			--OR (@op14=@IsGreaterThan AND DiarySourceFull > @DiarySourceFull)
			--OR (@op14=@IsGreaterThanOrEqualTo AND DiarySourceFull >= @DiarySourceFull)
			--OR (@op14=@Contains AND DiarySourceFull LIKE '%'+@DiarySourceFull+'%')
			--OR (@op14=@DoesNotContain AND DiarySourceFull NOT LIKE '%'+@DiarySourceFull+'%')
			--OR (@op14=@StartsWith AND DiarySourceFull LIKE ''+@DiarySourceFull+'%')
			--OR (@op14=@EndsWith AND DiarySourceFull LIKE '%'+@DiarySourceFull+'' )										
			--)			
			order by 
			CASE WHEN @pOrderBy='BusinessId' AND @pOrderType='ASC' THEN BusinessId END ASC,
			CASE WHEN @pOrderBy='BusinessId' AND @pOrderType='DESC' THEN	BusinessId END DESC,
			CASE WHEN @pOrderBy='IncentiveCode' AND @pOrderType='ASC' THEN IncentiveCode END ASC,
			CASE WHEN @pOrderBy='IncentiveCode' AND @pOrderType='DESC' THEN	IncentiveCode END DESC,
			CASE WHEN @pOrderBy='Points' AND @pOrderType='ASC' THEN Points END ASC,
			CASE WHEN @pOrderBy='Points' AND @pOrderType='DESC' THEN	Points END DESC,
			CASE WHEN @pOrderBy='NumberOfDaysEarly' AND @pOrderType='ASC' THEN NumberOfDaysEarly END ASC,
			CASE WHEN @pOrderBy='NumberOfDaysEarly' AND @pOrderType='DESC' THEN	NumberOfDaysEarly END DESC,
			CASE WHEN @pOrderBy='NumberOfDaysLate' AND @pOrderType='ASC' THEN NumberOfDaysLate END ASC,
			CASE WHEN @pOrderBy='NumberOfDaysLate' AND @pOrderType='DESC' THEN	NumberOfDaysLate END DESC,			
			CASE WHEN @pOrderBy='DiarySourceFull' AND @pOrderType='ASC' THEN DiarySourceFull END ASC,
			CASE WHEN @pOrderBy='DiarySourceFull' AND @pOrderType='DESC' THEN	DiarySourceFull END DESC,
			CASE WHEN @pOrderBy='Panelname' AND @pOrderType='ASC' THEN Panelname END ASC,
			CASE WHEN @pOrderBy='Panelname' AND @pOrderType='DESC' THEN	Panelname END DESC,
			CASE WHEN @pOrderBy='CreationTimeStamp' AND @pOrderType='ASC' THEN CreationTimeStamp END ASC,
			CASE WHEN @pOrderBy='CreationTimeStamp' AND @pOrderType='DESC' THEN	CreationTimeStamp END DESC,
			CASE WHEN @pOrderBy='ClaimFlag' AND @pOrderType='ASC' THEN ClaimFlag END ASC,
			CASE WHEN @pOrderBy='ClaimFlag' AND @pOrderType='DESC' THEN	ClaimFlag END DESC,
			CASE WHEN @pOrderBy='Together' AND @pOrderType='ASC' THEN Together END ASC,
			CASE WHEN @pOrderBy='Together' AND @pOrderType='DESC' THEN	Together END DESC,
			CASE WHEN @pOrderBy='DiaryDateFull' AND @pOrderType='ASC' THEN DiaryDateFull END ASC,
			CASE WHEN @pOrderBy='DiaryDateFull' AND @pOrderType='DESC' THEN	DiaryDateFull END DESC,		
			CASE WHEN @pOrderBy='DiaryState' AND @pOrderType='ASC' THEN DiaryState END ASC,
			CASE WHEN @pOrderBy='DiaryState' AND @pOrderType='DESC' THEN	DiaryState END DESC,
			CASE WHEN @pOrderBy='ReceivedDate' AND @pOrderType='ASC' THEN ReceivedDate END ASC,
			CASE WHEN @pOrderBy='ReceivedDate' AND @pOrderType='DESC' THEN	ReceivedDate END DESC					
		   OFFSET  @OFFSETRows ROWS  FETCH NEXT @pPageSize ROWS ONLY
		   OPTION (RECOMPILE)
  END