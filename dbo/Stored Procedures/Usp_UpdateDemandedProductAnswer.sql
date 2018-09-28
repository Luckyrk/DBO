CREATE PROCEDURE [dbo].[Usp_updatedemandedproductanswer]
  @pColumn                  COLUMNTABLETYPE readonly
, @pDemandedProductAnswer [dbo].[TBL_DEMANDEDPRODUCTANSWER] readonly
, @pNamedAliasTable       dbo.NAMEDALIASIMPORTFEED readonly
, @pCountryId             UNIQUEIDENTIFIER=NULL
, @pUser                  VARCHAR(100)=NULL
, @pFileId                UNIQUEIDENTIFIER=NULL
, @pCultureCode           INT=NULL
, @pSystemDate            DATETIME=NULL
AS
  BEGIN /*
        -- The individual isn''t main shopper is pending NOT COVERED
        */
      DECLARE @CountryCode VARCHAR(10),@isCollabarationRequired BIT=0
      SET @CountryCode= (SELECT countryiso2a
                         FROM   country
                         WHERE  countryid = @pCountryId)
	IF EXISTS(
		SELECT 1 FROM importFile i
		JOIN ImportColumnMapping ifc ON i.ImportFormat_Id=ifc.ImportFormat_Id
		WHERE Property='CollaborationMethodologyCode'
		AND i.GUIDReference=@pFileId
		)
		BEGIN
		SET @isCollabarationRequired=1
		END

      DECLARE @Getdate DATETIME=dbo.Getlocaldatetime(Getdate(), @CountryCode)
      DECLARE @ErrorMessage     NVARCHAR(400),
              @isErrorOccured   BIT=0,
              @BusinessIdLength INT

      IF NOT EXISTS (SELECT 1
                     FROM   importfile I
                            INNER JOIN statedefinition SD
                                    ON SD.id = I.state_id
                                       AND I.guidreference = @pFileId
                     WHERE  SD.code = 'ImportFileProcessing'
                            AND SD.country_id = @pCountryId)
        BEGIN
            INSERT INTO importaudit
            VALUES      ( Newid()
                          , 1
                          , 1
                          , 'File already is processed'
                          , @GetDate
                          , NULL
                          , NULL
                          , @GetDate
                          , @pUser
                          , @GetDate
                          , @pFileId )


            EXEC Insertimportfile
              'ImportFileBusinessValidationError',
              @pUser,
              @pFileId,
              @pCountryId

            RETURN;
        END

      DECLARE @maxColumnCount INT
      SET @maxColumnCount = (SELECT Max(rownumber) FROM   @pColumn)
      
	  DECLARE @REPETSEPARATOER NVARCHAR(max)

      SET @REPETSEPARATOER = Replicate('|', @maxColumnCount)
      
	  IF Object_id('Tempdb..#TempDemandedProductAnswer') IS NOT NULL
        BEGIN
            DROP TABLE #tempdemandedproductanswer
        END

      IF Object_id('Tempdb..#NotAnswered') IS NOT NULL
        BEGIN
            DROP TABLE #notanswered
        END



      IF Object_id('Tempdb..#NotExistsForCurrentProduct') IS NOT NULL
        BEGIN
            DROP TABLE #notexistsforcurrentproduct
        END

	 IF Object_id('Tempdb..#AllPanelistsExistscalendarPeriods') IS NOT NULL
     BEGIN
		DROP TABLE #AllPanelistsExistscalendarPeriods
     END

		IF Object_id('Tempdb..#NoAnswersExists') IS NOT NULL
        BEGIN
            DROP TABLE #NoAnswersExists
        END

      CREATE TABLE #TempDemandedProductAnswer(
	    ROWNO INT ,
		AnswerCode VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
		BusinessID VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
		PanelCode VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
		ProductCategoryCode VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
		YearPeriod VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
		CollaborationMethodologyCode VARCHAR(50) COLLATE DATABASE_DEFAULT NULL,
		Bought VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
		EndDate VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
		Comment VARCHAR(100) COLLATE DATABASE_DEFAULT NULL,
		[FullRow] VARCHAR(MAX) COLLATE DATABASE_DEFAULT,
		isValidAnswerCode BIT NULL,
		isValidBusinessID BIT NULL,
		isValidPanelCode BIT NULL,
		isValidProductCategoryCode BIT NULL,
		isValidYearPeriod BIT NULL,
		isValidCollaborationMethodologyCode BIT NULL,
		isValidBought BIT NULL,
		isValidEndDate BIT NULL,
		isHouseHoldPanel BIT NULL,
		isValidPanelist BIT NULL,
		doNotCallAgain BIT NULL,
		callAgainInterval INT NULL,
		PanelistId UniqueIdentifier NULL,
		ActionTaskId UniqueIdentifier,
		isActionShouldInsert BIT,
		isActionShouldUpdate BIT,
		MainContactId UniqueIdentifier NULL,
		IndividualId UniqueIdentifier,
		CalendarYearId UniqueIdentifier,
		CalendarId UniqueIdentifier,
		CalendarPeriodId UniqueIdentifier,
		DncProduct_Id UniqueIdentifier,
		DncAnswerCategory_Id UniqueIdentifier,
		GroupId UniqueIdentifier,
		PanelId UniqueIdentifier,
		CollabMethodologyID UniqueIdentifier,
		StateCode INT,
		[Year] INT,	
		[Period] INT,
		isNeedtoProcess BIT DEFAULT 1,
		ErrorMessage VARCHAR(MAX) DEFAULT 'DNC Imported  successfully',
		ShouldCreateAction BIT DEFAULT 1
	)

      INSERT INTO #tempdemandedproductanswer
      SELECT  Rownumber
			 , answercode
             , businessid
             , panelcode
             , productcategorycode
             , yearperiod
             , collaborationmethodologycode
             , bought
             , enddate
             , comment
             , [fullrow]
             , CASE
                 WHEN Isnull(answercode, '') = '' THEN 0
                 ELSE Isnumeric(answercode)
               END
             , CASE
                 WHEN Isnull(businessid, '') = '' THEN 0
                 ELSE Isnumeric(Replace(businessid, '-', ''))
               END
             , CASE
                 WHEN Isnull(panelcode, '') = '' THEN 0
                 ELSE Isnumeric(panelcode)
               END
             , CASE
                 WHEN Isnull(productcategorycode, '') = '' THEN 0
                 ELSE Isnumeric(productcategorycode)
               END
             , CASE
                 WHEN Isnull(yearperiod, '') = '' THEN 0
                 WHEN (SELECT Count(0)
                       FROM   dbo.Split(yearperiod, '-')) <> 1 THEN 0
                 ELSE Isnumeric(Replace(yearperiod, '-', ''))
               END
             , CASE
                 WHEN Isnull(collaborationmethodologycode, '') = '' THEN 0
                 ELSE 1
               END
             , CASE
                 WHEN Isnull(bought, '') = '' THEN 1
                 ELSE Isnumeric(bought)
               END
             , CASE
                 WHEN Isnull(enddate, '') = '' THEN 1
                 ELSE Isdate(enddate)
               END
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL
             , NULL--INTO #TempDemandedProductAnswer,
			 ,NULL
			 ,NULL
			 ,1
			 ,'DNC Imported  successfully'
			 ,1	 
      FROM   @pDemandedProductAnswer
	  --SELECT * FROM  #tempdemandedproductanswer
		-- UPDATE #tempdemandedproductanswer SET isNeedtoProcess=0 WHERE (isValidAnswerCode=0 OR	isValidBusinessID=0
		--OR isValidPanelCode=0 or isValidProductCategoryCode=0 OR isValidYearPeriod=0 OR	isValidCollaborationMethodologyCode=0
		--OR isValidBought =0 OR	isValidEndDate =0)
		
      IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer
                 WHERE  isvalidbusinessid = 0
                        AND Isnull(businessid, '') = '')
        BEGIN
            SET @ErrorMessage='The Business Id cannot be empty.'
            SET @isErrorOccured = 1
			
			UPDATE #tempdemandedproductanswer SET isNeedtoProcess=0,ErrorMessage=@ErrorMessage    WHERE  isvalidbusinessid = 0
            AND Isnull(businessid, '') = ''
        END

      IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer
                 WHERE  isvalidbusinessid = 0
                        AND Isnull(businessid, '') <> '')
        BEGIN
            SET @ErrorMessage='Please enter the correct format of the Business Id.'
            SET @isErrorOccured = 1

			UPDATE #tempdemandedproductanswer SET isNeedtoProcess=0,ErrorMessage=@ErrorMessage
			WHERE  isvalidbusinessid = 0 AND Isnull(businessid, '') <> ''
        END

      IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer T1
                        LEFT JOIN individual I ON T1.businessid=I.individualid
                        /*Ltrim(Replace(T1.businessid, '0', ' ')) = Ltrim(
                        --          Replace(I.individualid, '0', ' '))*/
                        AND I.countryid = @pCountryId
                 WHERE  T1.isvalidbusinessid = 1
                        AND I.individualid IS NULL)
        BEGIN
            SET @ErrorMessage='Please enter the valid Business Id.'
            SET @isErrorOccured = 1

            UPDATE t1
            SET    isvalidbusinessid = 0,isNeedtoProcess=0,ErrorMessage=@ErrorMessage
            FROM   #tempdemandedproductanswer T1
            LEFT JOIN individual I ON T1.businessid=I.individualid
				  /* --Ltrim(Replace(T1.businessid, '0', ' ')) = Ltrim(

       --                                Replace(I.individualid, '0', ' '))*/
	                                AND I.countryid = @pCountryId
            WHERE  t1.isvalidbusinessid = 1 AND I.individualid IS NULL
        END

      IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer T1
                 WHERE  T1.enddate IS NOT NULL
                        AND T1.isvalidenddate = 1
                        AND Cast(T1.enddate AS DATE) < Cast(@Getdate AS DATE))
        BEGIN
            SET @ErrorMessage='EndDate cannot be before Today.'
            SET @isErrorOccured = 1

            UPDATE t1
            SET    isvalidenddate = 0,isNeedtoProcess=0,ErrorMessage=@ErrorMessage
            FROM   #tempdemandedproductanswer T1
            WHERE  t1.enddate IS NOT NULL AND t1.isvalidenddate = 1 AND Cast(t1.enddate AS DATE) < Cast(@Getdate AS DATE)

        END

		IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer T1
                 WHERE  T1.isvalidpanelcode = 0
                        AND Isnull(T1.panelcode, '') = '')
        BEGIN
            SET @ErrorMessage='PanelCode cannot be Empty.'
            SET @isErrorOccured = 1
			
			UPDATE t1
			SET    isNeedtoProcess=0,ErrorMessage=@ErrorMessage
			FROM   #tempdemandedproductanswer T1
			WHERE  T1.isvalidpanelcode = 0 AND Isnull(T1.panelcode, '') = ''        

		END

      IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer T1
                 WHERE  T1.isvalidpanelcode = 0
                        AND Isnull(T1.panelcode, '') <> '')
        BEGIN
            SET @ErrorMessage='Invalid PanelCode.'
            SET @isErrorOccured = 1

			UPDATE t1
			SET    isNeedtoProcess=0,ErrorMessage=@ErrorMessage
			FROM   #tempdemandedproductanswer T1
			WHERE  T1.isvalidpanelcode = 0 AND Isnull(T1.panelcode, '') <> ''
        END
		
      IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer T1
                        LEFT JOIN panel P ON P.panelcode = T1.panelcode
                                  AND P.country_id = @pCountryId
                 WHERE  T1.isvalidpanelcode = 1
                        AND P.panelcode IS NULL)
        BEGIN
            SET @ErrorMessage='Invalid PanelCode.'
            SET @isErrorOccured = 1
            
			UPDATE t1
            SET    t1.isvalidpanelcode = 0,isNeedtoProcess=0,ErrorMessage=@ErrorMessage
            FROM   #tempdemandedproductanswer T1
			LEFT JOIN panel P ON P.panelcode = T1.panelcode AND P.country_id = @pCountryId
            WHERE  t1.isvalidpanelcode = 1 AND P.panelcode IS NULL

        END

      IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer T1
                 WHERE  T1.isvalidyearperiod = 0 AND Isnull(T1.yearperiod, '') = '')
        BEGIN
            SET @ErrorMessage='YearPeriod Cannot be empty.'
            SET @isErrorOccured = 1

			UPDATE #tempdemandedproductanswer SET isNeedtoProcess=0,ErrorMessage=@ErrorMessage
                 WHERE  isvalidyearperiod = 0 AND Isnull(yearperiod, '') = ''
        END

      IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer T1
                 WHERE  T1.isvalidyearperiod = 0
                        AND Isnull(T1.yearperiod, '') <> '')
        BEGIN
            SET @ErrorMessage='incorrect YearPeriod.'
            SET @isErrorOccured = 1

			UPDATE #tempdemandedproductanswer SET isNeedtoProcess=0,ErrorMessage=@ErrorMessage
			WHERE   isvalidyearperiod = 0 AND Isnull(yearperiod, '') <> ''
        END


		UPDATE #tempdemandedproductanswer SET [Year]=(SELECT items FROM dbo.Split(yearperiod,'.') WHERE Id=1),
		[Period]=(SELECT items FROM dbo.Split(yearperiod,'.') WHERE Id=2)

      UPDATE t1
      SET    t1.calendaryearid = C.yearperiodid
             , t1.calendarid = C.calendarid
             , t1.calendarperiodid = C.periodperiodid
      FROM   calendardenorm C
	  JOIN Panel P ON P.GUIDReference=C.PanelID
      JOIN #tempdemandedproductanswer T1 ON C.yearperiodvalue=T1.[Year] AND C.periodperiodvalue=T1.Period AND T1.PanelCode=P.PanelCode
				 AND C.ownercountryid = @pCountryId
     WHERE  t1.isvalidyearperiod = 1 AND C.ownercountryid = @pCountryId AND t1.isValidPanelCode = 1
     

		  UPDATE t1
		  SET    t1.calendaryearid = C.yearperiodid
				 , t1.calendarid = C.calendarid
				 , t1.calendarperiodid = C.periodperiodid
		  FROM   calendardenorm C
				 JOIN #tempdemandedproductanswer T1
					ON C.yearperiodvalue=T1.[Year] AND C.periodperiodvalue=T1.Period
					 AND C.ownercountryid = @pCountryId
					  WHERE  t1.isvalidyearperiod = 1 AND T1.calendaryearid IS NULL
				 AND C.ownercountryid = @pCountryId AND t1.isValidPanelCode = 1


     IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer T1
                 WHERE  T1.isvalidyearperiod = 1 AND T1.calendaryearid IS NULL)
        BEGIN
            SET @ErrorMessage='incorrect YearPeriod.'
            SET @isErrorOccured = 1
			
            UPDATE t1
            SET    t1.isvalidyearperiod = 0,isNeedtoProcess=0,ErrorMessage=@ErrorMessage
            FROM   #tempdemandedproductanswer T1
            WHERE  t1.isvalidyearperiod = 1 AND t1.calendaryearid IS NULL
        END

      IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer T1
                 WHERE  T1.isvalidproductcategorycode = 0 AND Isnull(T1.isvalidproductcategorycode, '') = '')
        BEGIN
            SET @ErrorMessage='ProductCategoryCode Cannot be empty.'
            SET @isErrorOccured = 1

			UPDATE t1
            SET    isNeedtoProcess=0,ErrorMessage=@ErrorMessage
            FROM   #tempdemandedproductanswer T1
            WHERE  T1.isvalidproductcategorycode = 0 AND Isnull(T1.isvalidproductcategorycode, '') = ''
        END

      IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer T1
                 WHERE  T1.isvalidproductcategorycode = 0 AND Isnull(T1.isvalidproductcategorycode, '') <> '')
        BEGIN
            SET @ErrorMessage='incorrect ProductCategoryCode.'
            SET @isErrorOccured = 1

			UPDATE t1
            SET    isNeedtoProcess=0,ErrorMessage=@ErrorMessage
            FROM   #tempdemandedproductanswer T1
            WHERE  T1.isvalidproductcategorycode = 0 AND Isnull(T1.isvalidproductcategorycode, '') <> ''
        END

      UPDATE t1
      SET    t1.dncproduct_id = DPC1.id
      FROM   #tempdemandedproductanswer T1
       INNER JOIN demandedproductcategory DPC1 ON DPC1.productcode = T1.productcategorycode
      WHERE  t1.isvalidproductcategorycode = 1 AND country_id = @pCountryId

      IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer T1
                 WHERE  T1.isvalidproductcategorycode = 1 AND T1.dncproduct_id IS NULL)
        BEGIN
            SET @ErrorMessage='incorrect ProductCategoryCode.'
            SET @isErrorOccured = 1
			
            UPDATE t1
            SET    t1.isvalidproductcategorycode = 0,isNeedtoProcess=0,ErrorMessage=@ErrorMessage
            FROM   #tempdemandedproductanswer T1
            WHERE  t1.isvalidproductcategorycode = 1
                   AND t1.dncproduct_id IS NULL
        END

     IF EXISTS (
		SELECT 1
		FROM #tempdemandedproductanswer T1
		WHERE T1.isvalidanswercode = 0
			AND Isnull(T1.isvalidanswercode, '') = ''
		)
	BEGIN
		SET @ErrorMessage = 'AnswerCode Cannot be empty.'
		SET @isErrorOccured = 1

		UPDATE t1
		SET isNeedtoProcess = 0
			,ErrorMessage = @ErrorMessage
		FROM #tempdemandedproductanswer T1
		WHERE T1.isvalidanswercode = 0
			AND Isnull(T1.isvalidanswercode, '') = ''
	END

      IF EXISTS (SELECT 1
                 FROM   #tempdemandedproductanswer T1
                 WHERE  T1.isvalidanswercode = 0
                        AND Isnull(T1.isvalidanswercode, '') <> '')
        BEGIN
            SET @ErrorMessage='incorrect AnswerCode.'
            SET @isErrorOccured = 1

			UPDATE t1
            SET    isNeedtoProcess=0,ErrorMessage=@ErrorMessage
            FROM   #tempdemandedproductanswer T1
            WHERE  T1.isvalidanswercode = 0
                   AND Isnull(T1.isvalidanswercode, '') <> ''
        END

      UPDATE t1
      SET    t1.dncanswercategory_id = DPC1.id
      FROM   #tempdemandedproductanswer T1
             INNER JOIN demandedproductcategoryanswer DPC1
                     ON DPC1.answercatcode = T1.answercode
                        AND DPC1.country_id = @pCountryId
      WHERE  t1.isvalidanswercode = 1
             AND DPC1.country_id = @pCountryId



    IF EXISTS (
		SELECT 1
		FROM #tempdemandedproductanswer T1
		WHERE T1.isvalidanswercode = 1
			AND T1.dncanswercategory_id IS NULL
		)
BEGIN
	SET @ErrorMessage = 'incorrect AnswerCode.'
	SET @isErrorOccured = 1

	UPDATE t1
	SET t1.isvalidanswercode = 0
		,isNeedtoProcess = 0
		,ErrorMessage = @ErrorMessage
	FROM #tempdemandedproductanswer T1
	WHERE t1.isvalidanswercode = 1
		AND t1.dncanswercategory_id IS NULL
END

UPDATE t1
SET ishouseholdpanel = (
		CASE 
			WHEN P.[type] = 'Individual'
				THEN 0
			ELSE 1
			END
		)
FROM #tempdemandedproductanswer T1
INNER JOIN panel P ON P.panelcode = T1.panelcode
WHERE t1.isvalidpanelcode = 1

IF EXISTS (
		SELECT 1
		FROM #tempdemandedproductanswer T1
		LEFT JOIN (
			SELECT PL.guidreference
				,P.panelcode
				,I.individualid
				,P.country_id
			FROM panelist PL
			INNER JOIN panel P ON P.guidreference = PL.panel_id
			INNER JOIN individual I ON I.guidreference = PL.panelmember_id
			WHERE P.country_id = @pCountryID
			
			UNION
			
			SELECT PL.guidreference
				,P.panelcode
				,I.individualid
				,P.country_id
			FROM panelist PL
			INNER JOIN panel P ON P.guidreference = PL.panel_id
			--JOIN Collective C ON C.GUIDReference=PL.PanelMember_Id
			INNER JOIN collectivemembership CM ON CM.group_id = PL.panelmember_id
			INNER JOIN individual I ON I.guidreference = CM.individual_id
			WHERE P.country_id = @pCountryID
			) Panli ON Panli.panelcode = T1.panelcode
			AND Panli.individualid = T1.businessid
		WHERE T1.isvalidbusinessid = 1
			AND Panli.panelcode IS NULL
		)
BEGIN
	SET @ErrorMessage = 'incorrect Panelist.'
	SET @isErrorOccured = 1

	UPDATE t1
	SET isvalidpanelist = 0
		,isNeedtoProcess = 0
		,ErrorMessage = @ErrorMessage
	FROM #tempdemandedproductanswer T1
	LEFT JOIN (
		SELECT PL.guidreference
			,P.panelcode
			,I.individualid
			,P.country_id
		FROM panelist PL
		INNER JOIN panel P ON P.guidreference = PL.panel_id
		INNER JOIN individual I ON I.guidreference = PL.panelmember_id
		WHERE P.country_id = @pCountryID
		
		UNION
		
		SELECT PL.guidreference
			,P.panelcode
			,I.individualid
			,P.country_id
		FROM panelist PL
		INNER JOIN panel P ON P.guidreference = PL.panel_id
		--JOIN Collective C ON C.GUIDReference=PL.PanelMember_Id
		INNER JOIN collectivemembership CM ON CM.group_id = PL.panelmember_id
		INNER JOIN individual I ON I.guidreference = CM.individual_id
		WHERE P.country_id = @pCountryID
		) Panli ON Panli.panelcode = T1.panelcode
		AND Panli.individualid = T1.businessid
	WHERE t1.isvalidbusinessid = 1
		AND Panli.panelcode IS NULL
END



      DECLARE @MainShopperId UNIQUEIDENTIFIER

SELECT @MainShopperId = dynamicroleid
FROM DynamicRole
INNER JOIN Translation trn ON trn.translationid = dynamicrole.translation_id
	AND trn.keyname = 'MainShopperRoleName'
WHERE country_id = @pCountryid

-- The individual isn''t main shopper is pending
IF EXISTS (
		SELECT 1
		FROM #tempdemandedproductanswer T1
		WHERE T1.isvalidcollaborationmethodologycode = 0
			AND @isCollabarationRequired = 1
		)
BEGIN
	SET @ErrorMessage = 'Collaboration Methodology Cannot be empty.'
	SET @isErrorOccured = 1

	UPDATE t1
	SET isNeedtoProcess = 0
		,ErrorMessage = @ErrorMessage
	FROM #tempdemandedproductanswer T1
	WHERE T1.isvalidcollaborationmethodologycode = 0
		AND @isCollabarationRequired = 1
END

IF EXISTS (
		SELECT 1
		FROM #tempdemandedproductanswer T1
		LEFT JOIN collaborationmethodology C ON T1.collaborationmethodologycode = C.code
			AND C.country_id = @pCountryId
		WHERE C.code IS NULL
			AND T1.isvalidcollaborationmethodologycode = 1
			AND @isCollabarationRequired = 1
		)
BEGIN
	SET @ErrorMessage = 'incorrect Collaboration Methodology.'
	SET @isErrorOccured = 1

	UPDATE t1
	SET isvalidcollaborationmethodologycode = 0
		,isNeedtoProcess = 0
		,ErrorMessage = @ErrorMessage
	FROM #tempdemandedproductanswer T1
	LEFT JOIN collaborationmethodology C ON T1.collaborationmethodologycode = C.code
		AND C.country_id = @pCountryId
	WHERE C.code IS NULL
		AND t1.isvalidcollaborationmethodologycode = 1
END

UPDATE t1
SET panelistid = T2.guidreference
	,individualid = indguid
	,t1.panelid = T2.panelid
	,t1.maincontactid = CASE 
		WHEN t1.ishouseholdpanel = 0
			THEN indguid
		ELSE NULL
		END
	,t1.groupid = T2.groupid
FROM #tempdemandedproductanswer T1
INNER JOIN (
	SELECT PL.guidreference
		,P.panelcode
		,I.individualid
		,P.country_id
		,I.guidreference AS IndGUID
		,CM.group_id AS GroupID
		,P.guidreference AS PanelId
	FROM panelist PL
	INNER JOIN panel P ON P.guidreference = PL.panel_id
	INNER JOIN individual I ON I.guidreference = PL.panelmember_id
	INNER JOIN collectivemembership CM ON CM.individual_id = PL.panelmember_id
	WHERE P.country_id = @pCountryId
	
	UNION
	
	SELECT PL.guidreference
		,P.panelcode
		,I.individualid
		,P.country_id
		,I.guidreference AS IndGUID
		,CM.group_id AS GroupID
		,P.guidreference AS PanelId
	FROM panelist PL
	INNER JOIN panel P ON P.guidreference = PL.panel_id
	--JOIN Collective C ON C.GUIDReference=PL.PanelMember_Id
	INNER JOIN collectivemembership CM ON CM.group_id = PL.panelmember_id
	INNER JOIN individual I ON I.guidreference = CM.individual_id
	WHERE P.country_id = @pCountryId
	) T2 ON T1.panelcode = T2.panelcode
	AND T1.businessid = T2.individualid

UPDATE Tupd
SET doNotCallAgain = dnca
	,callAgainInterval = callagain
FROM #tempdemandedproductanswer Tupd
INNER JOIN (
	SELECT T1.productcategorycode
		,T1.panelistid
		,CAST(MAX(CAST(dpcam.DoNotCallAgain AS INT)) AS BIT) AS dnca
		,MAX(dpcam.AskAgainInterval) AS callagain
	FROM #tempdemandedproductanswer T1
	INNER JOIN demandedproductcategory DPC ON DPC.productcode = T1.productcategorycode
	INNER JOIN demandedproductanswer DA ON DA.panelist_id = T1.panelistid
		AND DA.dncproduct_id = DPC.id
	INNER JOIN demandedproductcategoryanswer DCA ON DA.dncanswercategory_id = DCA.id
	LEFT JOIN DemandedProductCategoryAnswerMapping dpcam ON dpcam.DemandedProductCategory_Id = dpc.Id
		AND dpcam.DemandedProductCategoryAnswer_Id = dca.Id
	GROUP BY T1.productcategorycode
		,T1.panelistid
	) T2 ON T2.PanelistId = Tupd.PanelistId
	AND t2.ProductCategoryCode = Tupd.ProductCategoryCode


      -- IF EXISTS (SELECT 1 FROM   #tempdemandedproductanswer T1 WHERE  doNotCallAgain = 1)

	IF EXISTS (
		SELECT 1
		FROM #tempdemandedproductanswer T1
		INNER JOIN (
			SELECT *
			FROM (
				SELECT Row_Number() OVER (
						PARTITION BY Panelist_Id
						,DncProduct_Id ORDER BY CreationTimeStamp DESC
						) AS SNO
					,*
				FROM DemandedProductAnswer
				) TT
			WHERE SNO = 1
			) dpa ON dpa.Panelist_Id = t1.PanelistId
			AND dpa.DncProduct_Id = T1.DncProduct_Id
		INNER JOIN ActionTask AT ON AT.GUIDReference = dpa.ActionTask_Id
		WHERE doNotCallAgain = 1
		)
BEGIN
	--SET @ErrorMessage='The individual requested not to be called again.'
	--SET @isErrorOccured = 1
	--UPDATE T1 SET isNeedtoProcess=0,ErrorMessage=@ErrorMessage
	UPDATE T1
	SET ShouldCreateAction = 0
		,ErrorMessage = 'Response inserted, but no action will be created.'
	FROM #tempdemandedproductanswer T1
	INNER JOIN DemandedProductAnswer dpa ON dpa.Panelist_Id = t1.PanelistId
		AND dpa.DncProduct_Id = T1.DncProduct_Id
	INNER JOIN ActionTask AT ON AT.GUIDReference = dpa.ActionTask_Id
	WHERE doNotCallAgain = 1
END

IF EXISTS (
		SELECT 1
		FROM #tempdemandedproductanswer T1
		INNER JOIN CalendarPeriod cp ON cp.PeriodId = T1.CalendarPeriodId
		INNER JOIN DemandedProductAnswer dpa ON dpa.Panelist_Id = t1.PanelistId
			AND dpa.DncProduct_Id = T1.DncProduct_Id
		INNER JOIN CalendarPeriod dpacp ON dpacp.PeriodId = dpa.CalendarPeriod_PeriodId
		INNER JOIN ActionTask AT ON AT.GUIDReference = dpa.ActionTask_Id
		WHERE ISNULL(callAgainInterval, 0) > 0
			AND dpa.Id IS NOT NULL
			AND DATEADD(MONTH, callAgainInterval, dpacp.StartDate) > cp.StartDate
		)
BEGIN
	SELECT 'Response inserted, but no action will be created.'

	--SET @isErrorOccured = 1
	--UPDATE T1 SET isNeedtoProcess=0,ErrorMessage=CONCAT('The individual requested not to be called for this product in ',callAgainInterval,' months.')
	UPDATE T1
	SET ShouldCreateAction = 0
		,ErrorMessage = 'Response inserted, but no action will be created.'
	FROM #tempdemandedproductanswer T1
	INNER JOIN CalendarPeriod cp ON cp.PeriodId = T1.CalendarPeriodId
	INNER JOIN DemandedProductAnswer dpa ON dpa.Panelist_Id = t1.PanelistId
		AND dpa.DncProduct_Id = T1.DncProduct_Id
	INNER JOIN CalendarPeriod dpacp ON dpacp.PeriodId = dpa.CalendarPeriod_PeriodId
	INNER JOIN ActionTask AT ON AT.GUIDReference = dpa.ActionTask_Id
	WHERE ISNULL(callAgainInterval, 0) > 0
		AND dpa.Id IS NOT NULL
		AND DATEADD(MONTH, callAgainInterval, dpacp.StartDate) > cp.StartDate
END

--SELECT @isErrorOccured AS isErrorOccured
--IF( Isnull(@isErrorOccured, 0) = 0 )
--  BEGIN
UPDATE #tempdemandedproductanswer
SET statecode = (
		CASE 
			WHEN answercode = '99'
				THEN 1
			ELSE 4
			END
		)
WHERE isNeedtoProcess = 1
IF (@isCollabarationRequired = 1)
BEGIN
	UPDATE t1
	SET collabmethodologyid = C.guidreference
	FROM collaborationmethodology C
	INNER JOIN #tempdemandedproductanswer T1 ON T1.collaborationmethodologycode = C.code
		AND C.country_id = @pCountryId
	WHERE t1.isvalidcollaborationmethodologycode = 1
		AND isNeedtoProcess = 1
END

--SELECT @isErrorOccured
--       , 'No Error' 
/* if everything is fine then continue... */
DECLARE @ActionTaskTypeId UNIQUEIDENTIFIER

SELECT @ActionTaskTypeId = guidreference
FROM actiontasktype
WHERE isfordpa = 1
	AND country_id = @pCountryId

UPDATE t1
SET t1.maincontactid = DRA.candidate_id
FROM #tempdemandedproductanswer T1
INNER JOIN dynamicroleassignment DRA ON DRA.dynamicrole_id = @MainShopperId
	AND DRA.candidate_id = T1.individualid
	AND (
		DRA.panelist_id = T1.panelistid
		OR DRA.group_id = T1.groupid
		)
WHERE t1.ishouseholdpanel = 1
	AND DRA.country_id = @pCountryId
	AND isNeedtoProcess = 1

--Case1:- For the panelist there is no answer exists in the system till now. So new Action should create.
SELECT TEMP.panelistid
	,Newid() AS ActionTaskId
	,CalendarId
	,CalendarPeriodId
INTO #NoAnswersExists
FROM (
	SELECT T1.panelistid
		,CalendarId
		,CalendarPeriodId
	FROM #tempdemandedproductanswer T1
	LEFT JOIN demandedproductanswer DA ON DA.panelist_id = T1.panelistid
	WHERE DA.id IS NULL
		AND isNeedtoProcess = 1 --doubt
	GROUP BY T1.panelistid
		,T1.CalendarId
		,T1.CalendarPeriodId
	) AS TEMP

UPDATE t1
SET actiontaskid = T2.actiontaskid
	,isactionshouldinsert = 1
FROM #tempdemandedproductanswer T1
INNER JOIN #NoAnswersExists T2 ON T2.panelistid = T1.panelistid
	AND T1.CalendarId = T2.CalendarId
	AND T1.CalendarPeriodId = T2.CalendarPeriodId
	AND isNeedtoProcess = 1

--Case2:- For the panelist there is  answer exists for the other products . So new Action should create with the Existing ActionId previously.
--Case2a:-For the same panelist , for the same period we have create only one action, so actionId willl be same for all the products with in the same period for same panelist
SELECT DISTINCT DA.panelist_id
	,DA.calendarperiod_calendarid
	,DA.calendarperiod_periodid
	,DA.actiontask_id
INTO #AllPanelistsExistscalendarPeriods
FROM #tempdemandedproductanswer T1
INNER JOIN demandedproductanswer DA ON DA.panelist_id = T1.panelistid
WHERE Isnull(t1.isactionshouldinsert, 0) = 0
	AND isNeedtoProcess = 1

UPDATE t1
SET actiontaskid = DA.actiontask_id
	,isactionshouldupdate = 1 --SELECT *
FROM #tempdemandedproductanswer T1
INNER JOIN #AllPanelistsExistscalendarPeriods DA ON DA.panelist_id = T1.panelistid
	AND DA.calendarperiod_calendarid = T1.calendarid
	AND DA.calendarperiod_periodid = T1.calendarperiodid
WHERE Isnull(t1.isactionshouldinsert, 0) = 0
	AND isNeedtoProcess = 1

--Case2b:-For the same panelist , for the same period we ahve create only one action, so actionId willl be same for all the products with in the same period for same panelist,
--but for the new products we have to create a new action with the existing actioncode
SELECT *
	,Newid() AS ActionTaskId
INTO #notexistsforcurrentproduct
FROM (
	SELECT DISTINCT T1.panelistid
		,T1.calendarid
		,T1.calendarperiodid
	FROM #tempdemandedproductanswer T1
	--INNER JOIN  DemandedProductAnswer DA ON  DA.Panelist_Id=T1.PanelistId AND T1.CalendarId=DA.CalendarPeriod_CalendarId
	-- AND DA.CalendarPeriod_PeriodId=T1.CalendarPeriodId
	WHERE Isnull(isactionshouldinsert, 0) = 0
		AND isNeedtoProcess = 1
		AND T1.actiontaskid IS NULL
		AND NOT EXISTS (
			SELECT *
			FROM demandedproductanswer DA1
			WHERE DA1.panelist_id = T1.panelistid
				--AND DA.CalendarPeriod_CalendarId=DA1.CalendarPeriod_CalendarId
				AND T1.calendarperiodid = DA1.calendarperiod_periodid
				AND T1.dncproduct_id = DA1.dncproduct_id
				AND T1.calendarid = DA1.calendarperiod_calendarid
			)
	) TT

UPDATE t1
SET isactionshouldinsert = 1
	,t1.actiontaskid = TEMP.actiontaskid
FROM #tempdemandedproductanswer T1
INNER JOIN #notexistsforcurrentproduct TEMP ON T1.panelistid = TEMP.panelistid
	AND T1.calendarid = TEMP.calendarid
	AND T1.calendarperiodid = TEMP.calendarperiodid
--AND T1.DncProduct_Id=Temp.DncProduct_Id
WHERE Isnull(t1.isactionshouldinsert, 0) = 0
	AND t1.actiontaskid IS NULL
	AND isNeedtoProcess = 1
	--IMPPPPPPPPP=> (Till now isActionShouldInsert=1 then insert new Action and isActionShouldUpdate=1 then update the answer only)
    
	BEGIN TRANSACTION
            BEGIN TRY
			DECLARE @ImportStatus VARCHAR(100)='ImportFileSuccess',@NoNeedtoProcessCount INT=0,@NeedtoProcessCount INT=0
			SET @NoNeedtoProcessCount=(SELECT COUNT(0) FROM #tempdemandedproductanswer WHERE isNeedtoProcess=0)
			SET @NeedtoProcessCount=(SELECT COUNT(0) FROM #tempdemandedproductanswer WHERE isNeedtoProcess=1)

				IF (@NeedtoProcessCount = 0)
				BEGIN
				 SET @ImportStatus='ImportFileError'
				END
				ELSE IF(@NoNeedtoProcessCount>0 AND @NeedtoProcessCount>0)
				BEGIN
					SET @ImportStatus='ImportFilePartiallySucceded'
				END			
			
				-- STARTTT
                INSERT INTO ActionTask (
	guidreference
	,startdate
	,enddate
	,completiondate
	,actioncomment
	,internalorexternal
	,gpsuser
	,gpsupdatetimestamp
	,creationtimestamp
	,STATE
	,communicationcompletion_id
	,actiontasktype_id
	,country_id
	,candidate_id
	,formid
	,assignee_id
	,panel_id
	)
SELECT DISTINCT actiontaskid
	,@Getdate
	,enddate
	,NULL
	,comment
	,0
	,@pUser
	,@Getdate
	,@Getdate
	,1
	,NULL
	,@ActionTaskTypeId
	,@pCountryId
	,individualid
	,NULL
	,NULL
	,panelid
FROM #tempdemandedproductanswer
WHERE isactionshouldinsert = 1
	AND isNeedtoProcess = 1
	AND ShouldCreateAction = 1 --AND ISNULL(isActionShouldUpdate,0)=0

INSERT INTO demandedproductanswer (
	id
	,gpsuser
	,gpsupdatetimestamp
	,creationtimestamp
	,panelist_id
	,dncproduct_id
	,dncanswercategory_id
	,calendarperiod_calendarid
	,calendarperiod_periodid
	,actiontask_id
	,country_id
	,collaborationmethodology_id
	)
SELECT Newid()
	,@pUser
	,@Getdate
	,@GetDate
	,panelistid
	,dncproduct_id
	,dncanswercategory_id
	,calendarid
	,calendarperiodid
	,IIF(ShouldCreateAction = 1, actiontaskid, NULL)
	,@pCountryId
	,collabmethodologyid
FROM #tempdemandedproductanswer T1
--WHERE  isactionshouldinsert = 1 AND isNeedtoProcess=1
WHERE NOT EXISTS (
		SELECT *
		FROM demandedproductanswer D1
		WHERE D1.panelist_id = T1.panelistid
			AND D1.dncproduct_id = T1.dncproduct_id
			AND D1.calendarperiod_calendarid = T1.calendarid
			AND D1.calendarperiod_periodid = T1.calendarperiodid
		)

UPDATE DA
SET DA.dncanswercategory_id = TD.dncanswercategory_id
FROM demandedproductanswer DA
INNER JOIN #tempdemandedproductanswer TD ON TD.panelistid = DA.panelist_id
	AND DA.dncproduct_id = TD.dncproduct_id
WHERE isActionShouldUpdate = 1
	AND isNeedtoProcess = 1

SELECT DA.panelist_id
	,DA.calendarperiod_calendarid
	,DA.calendarperiod_periodid
	,DA.actiontask_id
	,ShouldCreateAction
INTO #notanswered
FROM demandedproductanswer DA
INNER JOIN demandedproductcategoryanswer DPC1 ON DA.dncanswercategory_id = DPC1.id
	AND DPC1.country_id = @pCountryId
INNER JOIN #tempdemandedproductanswer TD ON TD.panelistid = DA.panelist_id
	AND DA.calendarperiod_calendarid = TD.calendarid
	AND DA.calendarperiod_periodid = TD.calendarperiodid
WHERE DPC1.answercatcode = '99'
	AND isNeedtoProcess = 1

UPDATE AT
SET [State] = 4
FROM #tempdemandedproductanswer T1
INNER JOIN actiontask AT ON AT.guidreference = T1.actiontaskid
LEFT JOIN #notanswered T2 ON T2.actiontask_id = T1.actiontaskid
WHERE T2.actiontask_id IS NULL
	AND T1.ShouldCreateAction = 1



				UPDATE AT
SET [State] = 4
FROM #tempdemandedproductanswer T1
INNER JOIN CalendarPeriod cp ON cp.PeriodId = T1.CalendarPeriodId
INNER JOIN DemandedProductAnswer dpa ON dpa.Panelist_Id = t1.PanelistId
	AND dpa.DncProduct_Id = T1.DncProduct_Id
INNER JOIN CalendarPeriod dpacp ON dpacp.PeriodId = dpa.CalendarPeriod_PeriodId
INNER JOIN ActionTask AT ON AT.GUIDReference = dpa.ActionTask_Id
WHERE T1.AnswerCode <> '99'
	AND (
		doNotCallAgain = 1
		OR (
			ISNULL(callAgainInterval, 0) > 0
			AND dpa.Id IS NOT NULL
			AND DATEADD(MONTH, callAgainInterval, dpacp.StartDate) > cp.StartDate
			)
		)

UPDATE AT
SET [State] = 1
FROM #notanswered T1
INNER JOIN actiontask AT ON AT.guidreference = T1.actiontask_id
	AND ShouldCreateAction = 1

--ENDD
EXEC Insertimportfile @ImportStatus
	,@pUser
	,@pFileId
	,@pCountryId

INSERT INTO importaudit (
	guidreference
	,error
	,isinvalid
	,[message]
	,[date]
	,serializedrowdata
	,serializedrowerrors
	,creationtimestamp
	,gpsuser
	,gpsupdatetimestamp
	,[file_id]
	)
SELECT Newid()
	,0
	,0
	,ErrorMessage --CAST(Rowno AS VARCHAR(10))+'.'+ErrorMessage
	,@GetDate
	,Feed.[fullrow]
	,@REPETSEPARATOER
	,@GetDate
	,@pUser
	,@GetDate
	,@pFileId
FROM #tempdemandedproductanswer Feed
ORDER BY ROWNO ASC

				--WHERE isNeedtoProcess=1

                COMMIT TRANSACTION
            END TRY

            BEGIN CATCH
                --SELECT Error_message()
                --       , Error_line()

                ROLLBACK TRANSACTION
INSERT INTO importaudit
VALUES (
	Newid()
	,1
	,1
	,Error_message()
	,@GetDate
	,NULL
	,NULL
	,@GetDate
	,@pUser
	,@GetDate
	,@pFileId
	)

EXEC Insertimportfile 'ImportFileBusinessValidationError'
	,@pUser
	,@pFileId
	,@pCountryId
            END catch		

	

  END 