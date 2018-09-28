
CREATE PROCEDURE [dbo].[InsertDemographics]
	@pBelongTypeId UNIQUEIDENTIFIER
	
AS
BEGIN

SET NOCOUNT ON;
BEGIN TRY
DECLARE @BelongingID UniqueIdentiFier,@BelongTypeID UniqueIdentiFier=@pBelongTypeId,@CandidateCount INT,@SortAttributeID UniqueIdentiFier
DECLARE @BelongCount INT=0,
              @SortAttributeCount INT=0
Declare @OrderedBelongingCOunt INT=0,@TotalBelongCount INT,@TotalSortAttributeIdCount INT=0
DECLARE @CurrentBelongId UniqueIdentifier,@CurrentCandidateID UniqueIdentifier,@CurrentSortAttId UniqueIdentifier
CREATE TABLE #BelongIds
(
SNO INT IDENTITY(1,1),
Belong_Id UniqueIdentifier
,Candidate_Id UniqueIdentifier
)
CREATE TABLE #SortAttributeIds
(
SNO INT IDENTITY(1,1),
SortAttributeID UniqueIdentifier
)
--INSERT INTO #BelongIds
--SELECT B.GUIDReference FROM Belonging B
--JOIN SortAttribute SA ON SA.BelongingType_Id=B.TypeId 
--WHERE B.TypeId=@BelongTypeID

--Getting all the Belongings based on BelongType
INSERT INTO #BelongIds
SELECT DISTINCT B.GUIDReference,B.CandidateId FROM Belonging B
WHERE B.TypeId=@BelongTypeID
SELECT * FROM #BelongIds

--Getting all the Sort Attributes based on BelongType
INSERT INTO #SortAttributeIds
SELECT DISTINCT S.Id FROM SortAttribute S
WHERE S.BelongingType_Id=@BelongTypeID
SELECT * FROM #SortAttributeIds

SET @TotalBelongCount=0
SET @TotalSortAttributeIdCount=0
SET @BelongCount=1
SET @SortAttributeCount=1

SELECT @TotalBelongCount=COUNT(0) FROM #BelongIds
SELECT @TotalSortAttributeIdCount=COUNT(0) FROM #SortAttributeIds
--SELECT @TotalSortAttributeIdCount AS SORT,@TotalBelongCount AS Belong
WHILE(@BelongCount<=(@TotalBelongCount))
BEGIN
              SET @SortAttributeCount=1
              SET @CurrentBelongId=NULL
              SELECT @CurrentBelongId=Belong_Id,@CurrentCandidateID=Candidate_Id FROM #BelongIds WHERE SNO=@BelongCount
              
              WHILE(@SortAttributeCount<=(@TotalSortAttributeIdCount))
              BEGIN
                           SET @CurrentSortAttId=NULL
                           SELECT @CurrentSortAttId=SortAttributeID FROM #SortAttributeIds WHERE SNO=@SortAttributeCount
                           SET @OrderedBelongingCOunt=0

                           IF(@CurrentSortAttId IS NOT NULL)
                           BEGIN
                                  IF NOT EXISTS(SELECT 1 FROM OrderedBelonging WHERE Belonging_Id=@CurrentBelongId AND BelongingSection_Id=@CurrentSortAttId)
                                  BEGIN
                                         --SELECT 'inserted' AS INSERTED
                                         
                                         SELECT @OrderedBelongingCOunt=COUNT(0) FROM OrderedBelonging O
                                         JOIN Belonging B ON B.GUIDReference=O.Belonging_Id
                                         WHERE O.BelongingSection_Id=@CurrentSortAttId
                                         AND B.CandidateId=@CurrentCandidateID

										 --SELECT @CurrentCandidateID as Candi,@CurrentSortAttId as sort										 

                                         SET @OrderedBelongingCOunt=ISNULL(@OrderedBelongingCOunt,0)+1        
                                         SELECT @OrderedBelongingCOunt as OrderedBelongingCOunt,@CurrentSortAttId as CurrentSortAttId ,@CurrentBelongId as  CurrentBelongId
										 ,@CurrentCandidateID as CandidateId

										 INSERT INTO OrderedBelonging (Id,BelongingSection_Id,Belonging_Id,[Order],GPSUser,GPSUpdateTimestamp,CreationTimeStamp)
										 VALUES(NEWID(),@CurrentSortAttId,@CurrentBelongId,@OrderedBelongingCOunt,'',GETDATE(),GETDATE())
                                         END
                                         ELSE 
                                         BEGIN
                                                PRINT 'EXISTS'
                                         END
                                         SET @SortAttributeCount=@SortAttributeCount+1
                           END
              END

              SET @BelongCount=@BelongCount+1
              SET @SortAttributeCount=1
END

DROP TABLE #SortAttributeIds
DROP TABLE #BelongIds

--SELECT * FROM OrderedBelonging
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
end