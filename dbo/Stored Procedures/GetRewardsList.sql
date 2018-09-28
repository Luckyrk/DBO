/*##########################################################################

-- Name             : GetRewardsList.sql
-- Date             : 2014-12-11
-- Author           : Venkata Ramana
-- Company          : Cognizant Technology Solution
-- Purpose          : This Procedure is used to get the PanelCard Information
-- Usage            :
-- Impact           : 
-- Required grants  : 
-- Called by        : 
-- PARAM Definitions
				,@pCountryId UNIQUEIDENTIFIER  --Guid of Country
				,@pCultureCode INT -- CultureCode

-- Sample Execution :

DECLARE @pParametersTable dbo.GridParametersTable
--insert into @pParametersTable values(N'ValidTo',N'2014-04-06',N'IsGreaterThan',NULL,NULL,NULL)
--insert into @pParametersTable values(N'RewardReason',N'Portable charger',N'Contains',NULL,NULL,NULL)
--insert into @pParametersTable values(N'ValidFrom',N' 2013-04-22 00:00:00.000',N'IsEqualTo',NULL,NULL,NULL)
EXEC GetRewardsList '17d348d8-a08d-ce7a-cb8c-08cf81794a86',2057,'RewardType','DESC',1,10,0,@pParametersTable

##########################################################################
-- ver  user               date        change 
-- 1.0  Ramana     2014-12-11		   initial
##########################################################################*/   
CREATE PROCEDURE GetRewardsList(         
@ppCountryID UNIQUEIDENTIFIER,    
@ppCultureCode INT,    
@ppOrderBy VARCHAR(50),    
@ppOrderType VARCHAR(5),    
@ppPageNumber INT=1,    
@ppPageSize INT=20,    
@ppIsExport BIT=0,    
@ppParametersTable dbo.GridParametersTable READONLY    
)    
AS    
BEGIN    
    
DECLARE @pCountryID UNIQUEIDENTIFIER = @ppCountryID    
DECLARE @pCultureCode INT = @ppCultureCode    
DECLARE @pOrderBy VARCHAR(50) = @ppOrderBy    
DECLARE @pOrderType VARCHAR(5) = @ppOrderType    
DECLARE @pPageNumber INT = @ppPageNumber    
DECLARE @pPageSize INT = @ppPageSize    
DECLARE @pIsExport BIT = @ppIsExport    
DECLARE @pParametersTable dbo.GridParametersTable    
    
INSERT INTO @pParametersTable    
SELECT * FROM @ppParametersTable  --1  
    
    
    
SET NOCOUNT ON;    
DECLARE @op1 VARCHAR(50),@op2 VARCHAR(50),@op3 VARCHAR(50),@op4 VARCHAR(50),@op5 VARCHAR(50),@op6 VARCHAR(50),@op7 VARCHAR(50),@op8 VARCHAR(50),@op9 VARCHAR(50),@op10 VARCHAR(50)--,@op11 VARCHAR(50),@op12 VARCHAR(50),@op13 VARCHAR(50),@op14 VARCHAR(50)   
 
DECLARE @LogicalOperator5 VARCHAR(5),@LogicalOperator6 VARCHAR(5),@LogicalOperator10 VARCHAR(5)     
DECLARE @Secondop5 VARCHAR(50),@Secondop6 VARCHAR(50)    
DECLARE @SecondValidFromDate DATE,@SecondValidToDate DATE    
DECLARE @RewardCode INT,@RewardType NVARCHAR(1000),@RewardReason NVARCHAR(1000),@Value INT,@ValidFrom DATE,@ValidTo DATE,@HasStockControl BIT,@StockLevel INT    
,@GiftPrice FLOAT    
    
SELECT @op1=Opertor,@RewardCode=ParameterValue FROM @pParametersTable WHERE ParameterName='RewardCode'    
SELECT @op2=Opertor,@RewardReason=ParameterValue FROM @pParametersTable WHERE ParameterName='RewardReason'    
SELECT @op3=Opertor,@Value=ParameterValue FROM @pParametersTable WHERE ParameterName='Value'    
SELECT @op4=Opertor,@RewardType=ParameterValue FROM @pParametersTable WHERE ParameterName='RewardType'    
SELECT @op5=Opertor,@ValidFrom=CAST(ParameterValue AS DATE),@Secondop5=SecondParameterOperator,@SecondValidFromDate=CAST(SecondParameterValue AS DATE),@LogicalOperator5=LogicalOperator FROM @pParametersTable WHERE ParameterName='ValidFrom'    
SELECT @op6=Opertor,@ValidTo=CAST(ParameterValue AS DATE),@Secondop6=SecondParameterOperator,@SecondValidToDate=CAST(SecondParameterValue AS DATE),@LogicalOperator6=LogicalOperator FROM @pParametersTable WHERE ParameterName='ValidTo'    
SELECT @op7=Opertor,@HasStockControl=ParameterValue FROM @pParametersTable WHERE ParameterName='HasStockControl'    
SELECT @op8=Opertor,@StockLevel=ParameterValue FROM @pParametersTable WHERE ParameterName='StockLevel'    
SELECT @op9=Opertor,@GiftPrice=ParameterValue FROM @pParametersTable WHERE ParameterName='GiftPrice'    
    
DECLARE    
@RewardCodeVarchar VARCHAR(100)=CAST(@RewardCode AS VARCHAR),    
@ValueVarchar VARCHAR(10)=CAST(@Value AS VARCHAR),    
@ValidFromVarchar VARCHAR(100)=CAST(@ValidFrom AS VARCHAR),    
@SecondValidFromDateVarchar VARCHAR(100)=CAST(@SecondValidFromDate AS VARCHAR),    
@ValidToVarchar VARCHAR(100)=CAST(@ValidTo AS VARCHAR),    
@SecondValidToDateVarchar VARCHAR(100)=CAST(@SecondValidToDate AS VARCHAR),    
@HasStockControlVarchar VARCHAR(10)=CAST(@HasStockControl AS VARCHAR),    
@StockLevelVarchar VARCHAR(10)=CAST(@StockLevel AS VARCHAR),    
@GiftPriceVarchar VARCHAR(10)=CAST(@GiftPrice AS VARCHAR)    

IF(@pOrderBy IS NULL)    
SET @pOrderBy='CreationTimeStamp'    

IF(@pOrderType IS NULL)    
SET @pOrderType='DESC'    
    
    
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

IF(@pIsExport=0)         
 SET @OFFSETRows=(@pPageSize* (@pPageNumber-1))           
ELSE     
 SET @pPageSize=15000    
    
IF OBJECT_ID('tempdb..#tmpRewards') IS NOT NULL    
 DROP TABLE #tmpRewards    
   
 ;WITH TEMP AS (  
 SELECT ISNULL(TT.Value,[KeyName]) AS Value,TranslationId FROM    
 Translation T  
 LEFT JOIN TranslationTerm TT ON TT.Translation_Id=T.TranslationId AND CultureCode=@pCultureCode  
 )  
SELECT * INTO #tmpRewards FROM (    
      SELECT IP.RewardCode    
      ,T1.Value  AS RewardReason  
     --,dbo.GetTranslationValue(IP.Description_Id, @pCultureCode) AS RewardReason    
     ,IP.GUIDReference AS ID,IP.Value    
     ,IPAT.TypeName_Id    
     ,T2.Value AS RewardType  
     --,dbo.GetTranslationValue(IPAT.TypeName_Id, @pCultureCode) AS RewardType    
     ,CAST(IP.ValidFrom AS DATE) AS ValidFrom    
     ,CAST(IP.ValidTo AS DATE) AS ValidTo    
     ,IP.HasStockControl    
     ,ISNULL(IP.StockLevel,0) AS StockLevel    
     ,IP.GiftPrice    
     ,IP.CreationTimeStamp     
   FROM IncentivePoint IP     
      JOIN IncentivePointAccountEntryType IPAT ON IPAT.GUIDReference=IP.Type_Id   
      LEFT JOIN  TEMP T1 ON T1.TranslationId=IP.Description_Id  
      LEFT JOIN  TEMP T2 ON T2.TranslationId=IPAT.TypeName_Id  
      WHERE IP.Type='Reward'    
      AND IPAT.Country_Id=@pCountryID    
) AS TEMPTABLE    
WHERE (      
(@op1 IS NULL)    
OR (@op1=@IsEqualTo AND RewardCode = @RewardCode )    
OR (@op1=@IsNotEqualTo AND RewardCode <> @RewardCode)    
OR (@op1=@IsLessThan AND RewardCode < @RewardCode)    
OR (@op1=@IsLessThanOrEqualTo AND RewardCode <= @RewardCode )    
OR (@op1=@IsGreaterThan AND RewardCode > @RewardCode)    
OR (@op1=@IsGreaterThanOrEqualTo AND RewardCode >= @RewardCode)    
OR (@op1=@Contains AND RewardCode LIKE '%'+@RewardCodeVarchar+'%')    
OR (@op1=@DoesNotContain AND RewardCode NOT LIKE '%'+@RewardCodeVarchar+'%')    
OR (@op1=@StartsWith AND RewardCode LIKE ''+@RewardCodeVarchar+'%')    
OR (@op1=@EndsWith AND RewardCode LIKE '%'+@RewardCodeVarchar+'' )                                                                                         
)    
AND    
(      
(@op2 IS NULL)    
OR (@op2=@IsEqualTo AND RewardReason = @RewardReason )    
OR (@op2=@IsNotEqualTo AND RewardReason <> @RewardReason)    
OR (@op2=@IsLessThan AND RewardReason < @RewardReason)    
OR (@op2=@IsLessThanOrEqualTo AND RewardReason <= @RewardReason )    
OR (@op2=@IsGreaterThan AND RewardReason > @RewardReason)    
OR (@op2=@IsGreaterThanOrEqualTo AND RewardReason >= @RewardReason)    
OR (@op2=@Contains AND RewardReason LIKE '%'+@RewardReason+'%')    
OR (@op2=@DoesNotContain AND RewardReason NOT LIKE '%'+@RewardReason+'%')    
OR (@op2=@StartsWith AND RewardReason LIKE ''+@RewardReason+'%')    
OR (@op2=@EndsWith AND RewardReason LIKE '%'+@RewardReason+'' )                                                                                            
)    
AND    
(      
(@op3 IS NULL)    
OR (@op3=@IsEqualTo AND Value = @Value )    
OR (@op3=@IsNotEqualTo AND Value <> @Value)    
OR (@op3=@IsLessThan AND Value < @Value)    
OR (@op3=@IsLessThanOrEqualTo AND Value <= @Value )    
OR (@op3=@IsGreaterThan AND Value > @Value)    
OR (@op3=@IsGreaterThanOrEqualTo AND Value >= @Value)    
OR (@op3=@Contains AND Value LIKE '%'+@ValueVarchar+'%')    
OR (@op3=@DoesNotContain AND Value NOT LIKE '%'+@ValueVarchar+'%')    
OR (@op3=@StartsWith AND Value LIKE ''+@ValueVarchar+'%')    
OR (@op3=@EndsWith AND Value LIKE '%'+@ValueVarchar+'' )                                                                                            
)    
AND    
(      
(@op4 IS NULL)    
OR (@op4=@IsEqualTo AND RewardType = @RewardType )    
OR (@op4=@IsNotEqualTo AND RewardType <> @RewardType)    
OR (@op4=@IsLessThan AND RewardType< @RewardType)    
OR (@op4=@IsLessThanOrEqualTo AND RewardType <= @RewardType )    
OR (@op4=@IsGreaterThan AND RewardType > @RewardType)    
OR (@op4=@IsGreaterThanOrEqualTo AND RewardType>= @RewardType)    
OR (@op4=@Contains AND RewardType LIKE '%'+@RewardType+'%')    
OR (@op4=@DoesNotContain AND RewardType NOT LIKE '%'+@RewardType+'%')    
OR (@op4=@StartsWith AND RewardType LIKE ''+@RewardType+'%')    
OR (@op4=@EndsWith AND RewardType LIKE '%'+@RewardType+'' )                                                                                         
)    
and    
(                        
(@op5 IS NULL)    
OR (@op5 IS NULL AND @LogicalOperator5 IS NULL)            
OR (@LogicalOperator5='OR' AND     
            (    
                    (    
                                (@op5=@IsEqualTo AND ValidFrom = @ValidFrom )    
                        OR (@op5=@IsNotEqualTo AND ValidFrom <> @ValidFrom)    
                        OR (@op5=@IsLessThan AND ValidFrom < @ValidFrom)    
                        OR (@op5=@IsLessThanOrEqualTo AND ValidFrom <= @ValidFrom )    
                        OR (@op5=@IsGreaterThan AND ValidFrom > @ValidFrom)    
                        OR (@op5=@IsGreaterThanOrEqualTo AND ValidFrom >= @ValidFrom)    
                        OR (@op5=@Contains AND ValidFrom LIKE '%'+@ValidFromVarchar +'%')    
                        OR (@op5=@DoesNotContain AND ValidFrom NOT LIKE '%'+@ValidFromVarchar+'%')    
                        OR (@op5=@StartsWith AND ValidFrom LIKE ''+@ValidFromVarchar+'%')    
                        OR (@op5=@EndsWith AND ValidFrom LIKE '%'+@ValidFromVarchar+'' )    
                    )    
                    OR     
                    (    
                                (@Secondop5=@IsEqualTo AND ValidFrom = @SecondValidFromDate)     
                            OR    (@Secondop5=@IsNotEqualTo AND ValidFrom <> @SecondValidFromDate)     
                            OR (@Secondop5=@IsLessThan AND ValidFrom < @SecondValidFromDate)     
                            OR (@Secondop5=@IsLessThanOrEqualTo AND ValidFrom <= @SecondValidFromDate)     
                            OR (@Secondop5=@IsGreaterThan AND ValidFrom > @SecondValidFromDate)     
                            OR (@Secondop5=@IsGreaterThanOrEqualTo AND ValidFrom >= @SecondValidFromDate)     
                            OR (@Secondop5=@Contains AND ValidFrom LIKE '%'+@SecondValidFromDateVarchar+'%')    
                        OR (@Secondop5=@DoesNotContain AND ValidFrom NOT LIKE '%'+@SecondValidFromDateVarchar+'%')    
                        OR (@Secondop5=@StartsWith AND ValidFrom LIKE ''+@SecondValidFromDateVarchar+'%' )    
                        OR (@Secondop5=@EndsWith AND ValidFrom LIKE '%'+@SecondValidFromDateVarchar+'' )     
                    )    
                                      
            )     
    )    
    OR (@LogicalOperator5='AND' AND     
            (    
                    (    
                                (@op5=@IsEqualTo AND ValidFrom = @ValidFrom )    
                        OR (@op5=@IsNotEqualTo AND ValidFrom <> @ValidFrom)    
                        OR (@op5=@IsLessThan AND ValidFrom < @ValidFrom)    
                        OR (@op5=@IsLessThanOrEqualTo AND ValidFrom <= @ValidFrom )    
                        OR (@op5=@IsGreaterThan AND ValidFrom > @ValidFrom)    
                        OR (@op5=@IsGreaterThanOrEqualTo AND ValidFrom >= @ValidFrom)    
                        OR (@op5=@Contains AND ValidFrom LIKE '%'+@ValidFromVarchar+'%')    
                        OR (@op5=@DoesNotContain AND ValidFrom NOT LIKE '%'+@ValidFromVarchar+'%')    
                        OR (@op5=@StartsWith AND ValidFrom LIKE ''+@ValidFromVarchar+'%')    
                        OR (@op5=@EndsWith AND ValidFrom LIKE '%'+@ValidFromVarchar+'' )    
                    )    
                    AND     
                    (    
                                (@Secondop5=@IsEqualTo AND ValidFrom = @SecondValidFromDate)     
                            OR    (@Secondop5=@IsNotEqualTo AND ValidFrom <> @SecondValidFromDate)     
                            OR (@Secondop5=@IsLessThan AND ValidFrom < @SecondValidFromDate)     
                            OR (@Secondop5=@IsLessThanOrEqualTo AND ValidFrom <= @SecondValidFromDate)     
                            OR (@Secondop5=@IsGreaterThan AND ValidFrom > @SecondValidFromDate)     
                            OR (@Secondop5=@IsGreaterThanOrEqualTo AND ValidFrom >= @SecondValidFromDate)     
                            OR (@Secondop5=@Contains AND ValidFrom LIKE '%'+@SecondValidFromDateVarchar+'%')    
                        OR (@Secondop5=@DoesNotContain AND ValidFrom NOT LIKE '%'+@SecondValidFromDateVarchar+'%')    
                        OR (@Secondop5=@StartsWith AND ValidFrom LIKE ''+@SecondValidFromDateVarchar+'%' )    
                        OR (@Secondop5=@EndsWith AND ValidFrom LIKE '%'+@SecondValidFromDateVarchar+'' )     
                    )    
                                      
            )     
    )    
OR (@Secondop5 IS NULL    
AND     
(    
 (@op5=@IsEqualTo AND ValidFrom = @ValidFrom )    
OR (@op5=@IsNotEqualTo AND ValidFrom <> @ValidFrom)    
OR (@op5=@IsLessThan AND ValidFrom < @ValidFrom)    
OR (@op5=@IsLessThanOrEqualTo AND ValidFrom <= @ValidFrom )    
OR (@op5=@IsGreaterThan AND ValidFrom > @ValidFrom)    
OR (@op5=@IsGreaterThanOrEqualTo AND ValidFrom >= @ValidFrom)    
OR (@op5=@Contains AND ValidFrom LIKE '%'+@ValidFromVarchar+'%')    
OR (@op5=@DoesNotContain AND ValidFrom NOT LIKE '%'+@ValidFromVarchar+'%')    
OR (@op5=@StartsWith AND ValidFrom LIKE ''+@ValidFromVarchar+'%')    
OR (@op5=@EndsWith AND ValidFrom LIKE '%'+@ValidFromVarchar+'' )                      
 )    
)              
)    
and    
(                        
(@op6 IS NULL)    
OR (@op6 IS NULL AND @LogicalOperator6 IS NULL)            
OR (@LogicalOperator6='OR' AND     
            (    
                    (    
                                (@op6=@IsEqualTo AND ValidTo = @ValidTo )    
                        OR (@op6=@IsNotEqualTo AND ValidTo <> @ValidTo)    
                        OR (@op6=@IsLessThan AND ValidTo < @ValidTo)    
                        OR (@op6=@IsLessThanOrEqualTo AND ValidTo <= @ValidTo )    
                        OR (@op6=@IsGreaterThan AND ValidTo > @ValidTo)    
                        OR (@op6=@IsGreaterThanOrEqualTo AND ValidTo >= @ValidTo)    
                        OR (@op6=@Contains AND ValidTo LIKE '%'+@ValidToVarchar +'%')    
                        OR (@op6=@DoesNotContain AND ValidTo NOT LIKE '%'+@ValidToVarchar+'%')    
                        OR (@op6=@StartsWith AND ValidTo LIKE ''+@ValidToVarchar+'%')    
                        OR (@op6=@EndsWith AND ValidTo LIKE '%'+@ValidToVarchar+'' )    
                    )    
                    OR     
                    (    
                                (@Secondop6=@IsEqualTo AND ValidTo = @SecondValidToDate)     
                            OR    (@Secondop6=@IsNotEqualTo AND ValidTo <> @SecondValidToDate)     
                            OR (@Secondop6=@IsLessThan AND ValidTo < @SecondValidToDate)     
                            OR (@Secondop6=@IsLessThanOrEqualTo AND ValidTo <= @SecondValidToDate)     
                            OR (@Secondop6=@IsGreaterThan AND ValidTo > @SecondValidToDate)     
                            OR (@Secondop6=@IsGreaterThanOrEqualTo AND ValidTo >= @SecondValidToDate)     
                            OR (@Secondop6=@Contains AND ValidTo LIKE '%'+@SecondValidToDateVarchar+'%')    
                        OR (@Secondop6=@DoesNotContain AND ValidTo NOT LIKE '%'+@SecondValidToDateVarchar+'%')    
                        OR (@Secondop6=@StartsWith AND ValidTo LIKE ''+@SecondValidToDateVarchar+'%' )    
                        OR (@Secondop6=@EndsWith AND ValidTo LIKE '%'+@SecondValidToDateVarchar+'' )      
                    )    
                                      
            )     
    )    
    OR (@LogicalOperator6='AND' AND     
            (    
                    (    
                                (@op6=@IsEqualTo AND ValidTo = @ValidTo )    
                        OR (@op6=@IsNotEqualTo AND ValidTo <> @ValidTo)    
                        OR (@op6=@IsLessThan AND ValidTo < @ValidTo)    
                        OR (@op6=@IsLessThanOrEqualTo AND ValidTo <= @ValidTo )    
                        OR (@op6=@IsGreaterThan AND ValidTo > @ValidTo)    
                        OR (@op6=@IsGreaterThanOrEqualTo AND ValidTo >= @ValidTo)    
                        OR (@op6=@Contains AND ValidTo LIKE '%'+@ValidToVarchar+'%')    
                        OR (@op6=@DoesNotContain AND ValidTo NOT LIKE '%'+@ValidToVarchar+'%')    
                        OR (@op6=@StartsWith AND ValidTo LIKE ''+@ValidToVarchar+'%')    
                        OR (@op6=@EndsWith AND ValidTo LIKE '%'+@ValidToVarchar+'' )    
                    )    
                    AND     
                    (    
                                (@Secondop6=@IsEqualTo AND ValidTo = @SecondValidToDate)     
                            OR    (@Secondop6=@IsNotEqualTo AND ValidTo <> @SecondValidToDate)     
                            OR (@Secondop6=@IsLessThan AND ValidTo < @SecondValidToDate)     
                            OR (@Secondop6=@IsLessThanOrEqualTo AND ValidTo <= @SecondValidToDate)     
                            OR (@Secondop6=@IsGreaterThan AND ValidTo > @SecondValidToDate)     
                            OR (@Secondop6=@IsGreaterThanOrEqualTo AND ValidTo >= @SecondValidToDate)     
                            OR (@Secondop6=@Contains AND ValidTo LIKE '%'+@SecondValidToDateVarchar+'%')    
                        OR (@Secondop6=@DoesNotContain AND ValidTo NOT LIKE '%'+@SecondValidToDateVarchar+'%')    
                        OR (@Secondop6=@StartsWith AND ValidTo LIKE ''+@SecondValidToDateVarchar+'%' )    
                        OR (@Secondop6=@EndsWith AND ValidTo LIKE '%'+@SecondValidToDateVarchar+'' )      
                    )                                     
            )     
    )    
OR    
(@Secondop6 IS NULL     
AND    
(    
  (@op6=@IsEqualTo AND ValidTo = @ValidTo )    
OR (@op6=@IsNotEqualTo AND ValidTo <> @ValidTo)    
OR (@op6=@IsLessThan AND ValidTo < @ValidTo)    
OR (@op6=@IsLessThanOrEqualTo AND ValidTo <= @ValidTo )    
OR (@op6=@IsGreaterThan AND ValidTo > @ValidTo)    
OR (@op6=@IsGreaterThanOrEqualTo AND ValidTo >= @ValidTo)    
OR (@op6=@Contains AND ValidTo LIKE '%'+@ValidToVarchar+'%')    
OR (@op6=@DoesNotContain AND ValidTo NOT LIKE '%'+@ValidToVarchar+'%')    
OR (@op6=@StartsWith AND ValidTo LIKE ''+@ValidToVarchar+'%')    
OR (@op6=@EndsWith AND ValidTo LIKE '%'+@ValidToVarchar+'' )                   
)    
)                                                      
)    
AND    
(      
(@op7 IS NULL)    
OR (@op7=@IsEqualTo AND HasStockControl = @HasStockControl )    
OR (@op7=@IsNotEqualTo AND HasStockControl <> @HasStockControl)    
OR (@op7=@IsLessThan AND HasStockControl< @HasStockControl)    
OR (@op7=@IsLessThanOrEqualTo AND HasStockControl <= @HasStockControl )    
OR (@op7=@IsGreaterThan AND HasStockControl > @HasStockControl)    
OR (@op7=@IsGreaterThanOrEqualTo AND HasStockControl>= @HasStockControl)    
OR (@op7=@Contains AND HasStockControl LIKE '%'+@HasStockControlVarchar+'%')    
OR (@op7=@DoesNotContain AND HasStockControl NOT LIKE '%'+@HasStockControlVarchar+'%')    
OR (@op7=@StartsWith AND HasStockControl LIKE ''+@HasStockControlVarchar+'%')    
OR (@op7=@EndsWith AND HasStockControl LIKE '%'+@HasStockControlVarchar+'' )                                                                                            
)    
AND    
(      
(@op8 IS NULL)    
OR (@op8=@IsEqualTo AND StockLevel = @StockLevel )    
OR (@op8=@IsNotEqualTo AND StockLevel <> @StockLevel)    
OR (@op8=@IsLessThan AND StockLevel< @StockLevel)    
OR (@op8=@IsLessThanOrEqualTo AND StockLevel <= @StockLevel )    
OR (@op8=@IsGreaterThan AND StockLevel > @StockLevel)    
OR (@op8=@IsGreaterThanOrEqualTo AND StockLevel>= @StockLevel)    
OR (@op8=@Contains AND StockLevel LIKE '%'+@StockLevelVarchar+'%')    
OR (@op8=@DoesNotContain AND StockLevel NOT LIKE '%'+@StockLevelVarchar+'%')    
OR (@op8=@StartsWith AND StockLevel LIKE ''+@StockLevelVarchar+'%')    
OR (@op8=@EndsWith AND StockLevel LIKE '%'+@StockLevelVarchar+'' )                                                                                         
)    
AND    
(      
(@op9 IS NULL)    
OR (@op9=@IsEqualTo AND GiftPrice = @GiftPrice )    
OR (@op9=@IsNotEqualTo AND GiftPrice <> @GiftPrice)    
OR (@op9=@IsLessThan AND GiftPrice< @GiftPrice)    
OR (@op9=@IsLessThanOrEqualTo AND GiftPrice <= @GiftPrice )    
OR (@op9=@IsGreaterThan AND GiftPrice > @GiftPrice)    
OR (@op9=@IsGreaterThanOrEqualTo AND GiftPrice>= @GiftPrice)    
OR (@op9=@Contains AND GiftPrice LIKE '%'+@GiftPriceVarchar+'%')    
OR (@op9=@DoesNotContain AND GiftPrice NOT LIKE '%'+@GiftPriceVarchar+'%')    
OR (@op9=@StartsWith AND GiftPrice LIKE ''+@GiftPriceVarchar+'%')    
OR (@op9=@EndsWith AND GiftPrice LIKE '%'+@GiftPriceVarchar+'' )                                                                                           
)    
OPTION (RECOMPILE)    
    
IF(@pIsExport=0)    
 SELECT COUNT(0) AS TotalRows FROM #tmpRewards    
     
    
SELECT * FROM #tmpRewards    
ORDER BY     
 CASE WHEN @pOrderBy='RewardCode' AND @pOrderType='ASC' THEN RewardCode END ASC,    
 CASE WHEN @pOrderBy='RewardCode' AND @pOrderType='DESC' THEN  RewardCode END DESC,    
 CASE WHEN @pOrderBy='RewardReason' AND @pOrderType='ASC' THEN RewardReason END ASC,    
 CASE WHEN @pOrderBy='RewardReason' AND @pOrderType='DESC' THEN       RewardReason END DESC,    
 CASE WHEN @pOrderBy='Value' AND @pOrderType='ASC' THEN Value END ASC,    
 CASE WHEN @pOrderBy='Value' AND @pOrderType='DESC' THEN       Value END DESC,    
 CASE WHEN @pOrderBy='RewardType' AND @pOrderType='ASC' THEN RewardType END ASC,    
 CASE WHEN @pOrderBy='RewardType' AND @pOrderType='DESC' THEN  RewardType END DESC,            
 CASE WHEN @pOrderBy='ValidFrom' AND @pOrderType='ASC' THEN ValidFrom END ASC,    
 CASE WHEN @pOrderBy='ValidFrom' AND @pOrderType='DESC' THEN   ValidFrom END DESC,    
 CASE WHEN @pOrderBy='ValidTo' AND @pOrderType='ASC' THEN ValidTo END ASC,    
 CASE WHEN @pOrderBy='ValidTo' AND @pOrderType='DESC' THEN     ValidTo END DESC,    
 CASE WHEN @pOrderBy='HasStockControl' AND @pOrderType='ASC' THEN HasStockControl END ASC,    
 CASE WHEN @pOrderBy='HasStockControl' AND @pOrderType='DESC' THEN    HasStockControl END DESC,    
 CASE WHEN @pOrderBy='StockLevel' AND @pOrderType='ASC' THEN StockLevel END ASC,    
 CASE WHEN @pOrderBy='StockLevel' AND @pOrderType='DESC' THEN  StockLevel END DESC,    
 CASE WHEN @pOrderBy='StockLevel' AND @pOrderType='ASC' THEN GiftPrice END ASC,    
 CASE WHEN @pOrderBy='StockLevel' AND @pOrderType='DESC' THEN  GiftPrice END DESC    
OFFSET  @OFFSETRows ROWS  FETCH NEXT @pPageSize ROWS ONLY    
OPTION (RECOMPILE)    
    
    
END 