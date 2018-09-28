/*##########################################################################    

-- Name             : ReserveCollectiveSequenceBatch.sql  

-- Date             : 2015-05-20    

-- Author           : Fernandez Matias    

-- Company          : Cognizant Technology Solution      

exec [ReserveCollectiveSequenceBatch] 1,'3558A18E-CCEB-CADC-CB8C-08CF81794A86'   

##########################################################################    

-- ver  user                      date        change   

-- 1.0  Fernandez Matias    2015-05-20   initial    

-- 1.1 Fernandez Matias     2015-08-24    logic change to fill gaps

-- 1.2 Fernandez Matias     2015-09-04    logic change to fit reserved ids

-- 1.3 GopiChand			2016-01-29    logic change to determine minimum value in KeyAppSettings

-- 1.4 Fernandez Matias     2016-04-19    logic change to determine minimum value in KeyAppSettings -> make it work if the config doesn't exist
##########################################################################*/

CREATE PROCEDURE [dbo].[ReserveCollectiveSequenceBatch] (
       @pQuantityIn INT
       ,@pCountryIdIn UNIQUEIDENTIFIER )
AS
BEGIN
       SET XACT_ABORT ON
       BEGIN TRANSACTION

       DECLARE @pQuantity INT=@pQuantityIn;
    DECLARE @pCountryId UNIQUEIDENTIFIER =@pCountryIdIn;

       BEGIN TRY
              INSERT INTO CollectiveSequenceMaxValues
              SELECT NEWID(), 0, c.CountryId, 0
              FROM Country c
              LEFT JOIN CollectiveSequenceMaxValues sq ON c.CountryId=sq.Country_id
              WHERE sq.GUIDReference IS NULL AND c.CountryId=@pCountryId

              DECLARE @vCollectiveTableMax BIGINT;
              
			  SELECT @vCollectiveTableMax = ISNULL((SELECT ISNULL(KV.Value, KS.DefaultValue) AS Value
												FROM KeyAppSetting KS
												LEFT JOIN KeyValueAppSetting KV ON KV.KeyAppSetting_Id=KS.GUIDReference AND KV.Country_Id = @pCountryId
												WHERE KS.KeyName='MinIndividualID'),1)

              DECLARE @vCollectiveNext BIGINT;
              SELECT @vCollectiveNext = ISNULL(MAX(ISNULL(ReservedSequence, Sequence)),0) FROM Collective WHERE CountryId = @pCountryId
			  



              DECLARE @vDefinitiveMax BIGINT = (0.5 * ((@vCollectiveTableMax + @vCollectiveNext) + ABS(@vCollectiveTableMax - @vCollectiveNext))) + @pQuantity + 1
			  
			  IF OBJECT_ID('tempdb..#AllSequences') IS NOT NULL DROP TABLE #AllSequences
              SELECT TOP (@vDefinitiveMax) n = ROW_NUMBER() OVER (ORDER BY s1.[object_id]) INTO #AllSequences
              FROM sys.all_objects AS s1 CROSS JOIN sys.all_objects AS s2 OPTION (MAXDOP 1);

              IF OBJECT_ID('tempdb..#ReturnedSequences') IS NOT NULL DROP TABLE #ReturnedSequences
              
              SELECT TOP (@pQuantity) c1.n AS Sequence INTO #ReturnedSequences
              FROM #AllSequences c1
              LEFT JOIN 
                     (SELECT Sequence FROM Collective WHERE Countryid=@pCountryId
                     UNION SELECT ReservedSequence as Sequence FROM Collective WHERE Countryid=@pCountryId AND ReservedSequence IS NOT NULL)
                           c2 ON c2.Sequence = (c1.n)
              WHERE c2.Sequence IS NULL AND c1.n  > @vCollectiveTableMax 
              ORDER BY C1.n
              
              UPDATE sq SET MaxMissingSequenceIdValue=Seq.MxSeq
              FROM CollectiveSequenceMaxValues sq 
              JOIN (SELECT MAX(Sequence) as MxSeq FROM #ReturnedSequences) AS Seq ON 1=1
              WHERE Country_id=@pCountryId  and Seq.MxSeq > @vCollectiveTableMax 

              SELECT * FROM #ReturnedSequences
       END TRY

       BEGIN CATCH
              RAISERROR ('Error while updating the CollectiveSequenceMaxValues table', 16, 1);
       END CATCH

       COMMIT TRANSACTION
       SET XACT_ABORT OFF
END