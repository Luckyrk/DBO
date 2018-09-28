USE GPS_PM_LATAM

IF EXISTS (SELECT *  FROM INFORMATION_SCHEMA.ROUTINES WHERE SPECIFIC_SCHEMA = N'dbo' AND SPECIFIC_NAME = N'uspLATAMPetBelongingsImport')
   DROP PROCEDURE dbo.uspLATAMPetBelongingsImport
GO

CREATE PROCEDURE dbo.uspLATAMPetBelongingsImport
	@Testing TINYINT = 1 --just used to set some values in the temp tables to test the process. Once it is all working we can set this variable to 0
AS
BEGIN

	DECLARE @GPSUser NVARCHAR(20)
	DECLARE @GPSTimeStamp DATETIME
	DECLARE @ImportedRows INT

	SET @GPSUser = 'AutomatedPetImport'
	SET @GPSTimeStamp = GetDate()

	/********************************NOTE*********************************************************
	With Testing = 1, I have change some of the data for Group 1062, but you need to 
	add this Belonging to via the UI and ensure the belongingCode is 1 before you run the process
	*********************************************************************************************/

	BEGIN TRY
		BEGIN TRAN
			--DROP TABLE LATAMBelongingsImportErrors
			IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'LATAMBelongingsImportErrors')
				BEGIN
				  CREATE TABLE LATAMBelongingsImportErrors
					(
						ID INT IDENTITY(1,1)
						, ImportFileID INT
						, CountryISO2A NVARCHAR(3)
						, GroupBusinessID INT
						, BelongingCode TINYINT
						, ForUpdate TINYINT
						, ImportDate DATETIME
						, SyncDate DATETIME
						, ErrorText NVARCHAR(500)
						, DemogKey NVARCHAR(50)
						, DemogValue NVARCHAR(200)
					)
					IF EXISTS(SELECT * FROM sys.indexes WHERE object_id = object_id('dbo.LATAMBelongingsImportErrors') AND NAME ='IX_GroupBusinessID_CountryID')
						DROP INDEX IX_GroupBusinessID_CountryID ON dbo.LATAMBelongingsImportErrors
					ELSE
						CREATE INDEX IX_GroupBusinessID_CountryID on dbo.LATAMBelongingsImportErrors(CountryISO2A ASC, GroupBusinessID ASC)

				END


			IF EXISTS (	SELECT * FROM tempdb.dbo.sysobjects o WHERE o.xtype in ('U') AND o.id = object_id(N'tempdb..#t1')) 
				BEGIN  
					DROP TABLE #t1
				END

			CREATE TABLE #t1
			(
				ID INT
				, GroupBusinessID INT NOT NULL
				, CountryISO2A NVARCHAR(3) NOT NULL
				, ForUpdate TINYINT NOT NULL
				, BelongingTypeName NVARCHAR(200) NOT NULL
				, BelongingCode INT NULL
				, H700 TINYINT NULL --AnimalType Enum
				, H705 NVARCHAR(200) NULL --PetName String
				, H706 TINYINT NULL --Sex Enum
				, H701 TINYINT NULL --Size Enum
				, H702 TINYINT NULL --Age Enum
				, H703 TINYINT NULL --Feeding Enum
				, H707 NVARCHAR(100) --InicialDate Date
				, H704 NVARCHAR(100) NULL --DateOfDeath Date
				, BelongingStateCode NVARCHAR(100) NULL
				, SyncDate DATETIME NOT NULL
				, ImportDate DATETIME NULL
				, CountryID UNIQUEIDENTIFIER
				, CandidateID UNIQUEIDENTIFIER
				, BelongingID UNIQUEIDENTIFIER
				, BelongingTypeID UNIQUEIDENTIFIER
				, LocalTime DATETIME
				, StateID UNIQUEIDENTIFIER
				, MaxBelongingCode TINYINT
				, BelongingType NVARCHAR(100)
			)

			INSERT INTO #t1 (ID, GroupBusinessID, CountryISO2A, ForUpdate, BelongingTypeName, BelongingCode, H700, H705, H706, H701, H702, H703, H707
					, H704, BelongingStateCode, SyncDate, ImportDate)
			SELECT 	ID, GroupBusinessID, CountryISO2A, ForUpdate, BelongingTypeName, BelongingCode, AnimalType, Name, Sex, Size, Age, Feeding, InicialDate
					, DateOfDeath, BelongingStateCode, SyncDate, @GPSTimeStamp
			FROM [172.28.232.32]. [IT_WORKFLOW].[dbo].[WF_STGA_IMPORT_QPET]
			WHERE ImportDate IS NULL

			IF @@RowCount = 0 --No data to import exit the procedure
			BEGIN
				ROLLBACK TRAN
				RETURN
			END

			--BEGIN

				IF @Testing = 1
					BEGIN
						SELECT 'Testing NULL CandidateID'
						--Testing. 
						--UPDATE #t1 SET GroupBusinessID = 91062 WHERE ID  = 1 --Original Value is 1
					END

				UPDATE #t1 SET CountryID = c.CountryID, CandidateID = cl.GUIDReference, BelongingtypeID = bt.ID, LocalTime = dbo.GetLocalDateTime(GetDate(), t.CountryISO2A)
					, StateID = sd.ID, BelongingType = LEFT(bt.[Type], LEN(bt.[Type]) - 4)
					FROM #t1 t
						INNER JOIN Country c ON t.CountryISO2A = c.CountryISO2a
						INNER JOIN Collective cl ON c.CountryID = cl.CountryID AND t.GroupBusinessID = cl.Sequence
						INNER JOIN 
						(SELECT ID, bt.Country_Id, tt.Value, [Type] FROM BelongingType bt
							INNER JOIN TranslationTerm tt ON bt.Translation_ID = tt.Translation_Id
							WHERE tt.CultureCode = 2057
						) bt ON bt.Value = t.BelongingTypeName AND c.CountryId = bt.Country_Id
						INNER JOIN StateDefinition sd ON sd.Code = 'BelongingActive' AND c.CountryID = sd.Country_ID

				--For those Belongings that are new ForUpdate = 0
				--Create a new belonging GUID
				UPDATE #t1 SET BelongingID = NewID() WHERE ForUpdate = 0

				--For those Belongings that have an updated value ForUpdate = 1
				--Get the relevant Belonging to update
		
				IF @Testing = 1
					BEGIN
						SELECT 'Changing to an update Belonging'
						UPDATE #t1 SET ForUpdate = 1, BelongingCode = 1, H702 = 3, BelongingID = NULL WHERE ID  = 1
					END 


				UPDATE #t1 SET BelongingID = b.GUIDReference
				--SELECT b.GUIDReference, *
					FROM Belonging b
					INNER JOIN #t1 t ON b.CandidateID = t.CandidateID
							AND t.BelongingTypeID = b.TypeID
							AND t.BelongingCode = b.BelongingCode
				WHERE ForUpdate = 1
				AND t.BelongingCode IS NOT NULL
				AND t.CandidateID IS NOT NULL

				--Get the maxium belonging code for each Group so that we can create new rows with MaxCode + 1

				UPDATE #t1 SET MaxBelongingCode = ISNULL(MaxCode, 0)
				FROM #t1 t
					INNER JOIN
					(
						SELECT r.COuntryID, b.CandidateID, Max(b.BelongingCode) AS MaxCode
						FROM Belonging b
						INNER JOIN Respondent r ON b.GUIDReference = r.GUIDReference
						INNER JOIN #t1 t ON b.GUIDReference =  t.BelongingID
						GROUP BY r.CountryID, b.CandidateID
					) mx ON t.CountryID = mx.CountryID AND t.CandidateID = mx.CandidateID
				WHERE t.CandidateID IS NOT NULL

				UPDATE #t1 SET BelongingCode = r.BelongingCode
				FROM #t1 t
					INNER JOIN
					(
						SELECT
							ID
							, CountryISO2A
							, GroupBusinessID
							, ISNULL(MaxBelongingCode, 0) + ISNULL(ROW_NUMBER() OVER(PARTITION BY CountryISO2A, GroupBusinessID ORDER BY ID ASC), 0) AS BelongingCode
						FROM #t1
						WHERE BelongingCode is NULL
					) r ON t.ID = r.ID AND t.CountryISO2A = r.CountryISO2A AND t.GroupBusinessID = r.GroupBusinessID
				WHERE t.BelongingCode is NULL
				AND t.CandidateID IS NOT NULL

				--SELECT * FROM #t1
		
				IF @Testing = 1
					BEGIN
						SELECT 'Change values to invalid ones for testing'
						--Testing. 
						--UPDATE #t1 SET H700 = 5 WHERE ID  = 1 --Original Value is 1
						--UPDATE #t1 SET H701 = 100 WHERE ID  = 1 --Original Value is 1
						--UPDATE #t1 SET H702 = 25 WHERE ID  = 1 --Original Value is 1
						UPDATE #t1 SET H703 = 10 WHERE ID  = 1 --Original Value is 7
						UPDATE #t1 SET H706 = 4 WHERE ID  = 1 --Original Value is 1
						UPDATE #t1 SET H707 = '2015-165-32' WHERE ID = 1
					END

				--Now create a unpivot for use one we populate the AttributeValue tables with the demog values.

				if exists (	select * from tempdb.dbo.sysobjects o	where o.xtype in ('U') 	and o.id = object_id(N'tempdb..#t4')) 
					BEGIN  
						DROP TABLE #t4
					END

				CREATE TABLE #t4
				(
					ID INT
					, GroupBusinessID INT NOT NULL
					, CountryISO2A NVARCHAR(3) NOT NULL
					, ForUpdate TINYINT NOT NULL
					, BelongingTypeName NVARCHAR(200) NOT NULL
					, BelongingCode INT NULL
					, BelongingStateCode NVARCHAR(100) NULL
					, SyncDate DATETIME NOT NULL
					, ImportDate DATETIME NOT NULL
					, CountryID UNIQUEIDENTIFIER
					, CandidateID UNIQUEIDENTIFIER
					, BelongingID UNIQUEIDENTIFIER
					, BelongingTypeID UNIQUEIDENTIFIER
					, LocalTime DATETIME
					, StateID UNIQUEIDENTIFIER
					, MaxBelongingCode TINYINT
					, BelongingType NVARCHAR(100)
					, AttribType NVARCHAR(20)
					, ValidDemog BIT
					, AttribKey NVARCHAR(20)
					, DemogValue NVARCHAR(100)
				)

				INSERT INTO #t4
					SELECT	ID, GroupBusinessID, CountryISO2A, ForUpdate, BelongingTypeName, BelongingCode, BelongingStateCode, SyncDate, ImportDate,
						CountryID, CandidateID, BelongingID, BelongingtypeID, LocalTime, StateID, MaxBelongingCode, BelongingType, NULL AS AttribType, NULL AS ValidDemog, AttribKey, DemogValue
					FROM 
					(
						SELECT ID, GroupBusinessID, CountryISO2A, ForUpdate, BelongingTypeName, BelongingCode, BelongingStateCode, SyncDate, ImportDate,
						CountryID, CandidateID, BelongingID, BelongingtypeID, LocalTime, StateID, MaxBelongingCode, BelongingType, NULL AS ValidDemog, 
							CONVERT(NVARCHAR(100), H700) AS H700, CONVERT(NVARCHAR(100), H701) AS H701
							, CONVERT(NVARCHAR(100), H702) AS H702, CONVERT(NVARCHAR(100), H703) AS H703
							, CONVERT(NVARCHAR(100), H704) AS H704, CONVERT(NVARCHAR(100), H705) AS H705
							, CONVERT(NVARCHAR(100), H706) AS H706, CONVERT(NVARCHAR(100), H707) AS H707 FROM #t1
						) t
					UNPIVOT
					(DemogValue FOR AttribKey IN
					(H700, H701, H702, H703, H704, H705, H706, H707)) AS unpvt
					ORDER BY ID, AttribKey

				UPDATE #t4 SET AttribType = a.[Type]
				 --SELECT *
					FROM #t4 t
					INNER JOIN Attribute a ON t.CountryID = a.Country_Id AND a.[Key] = t.AttribKey AND a.Country_Id = t.CountryID


				--SELECT * FROM #t4

				/******************************************************************************************
				--Check for valid enum values and update the ...validEnum column to 1 for all valid values.
				*******************************************************************************************/


				UPDATE #t4 SET ValidDemog = 1
				 --SELECT t.ID, H700, ed.ID
					FROM #t4 t
					INNER JOIN Attribute a ON t.CountryID = a.Country_Id AND a.[Key] = t.AttribKey
					INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_Id AND t.DemogValue = ed.Value
				WHERE t.AttribType = 'Enum'



				UPDATE #t4 SET ValidDemog = 1
				 --SELECT t.ID, H700, ed.ID
					FROM #t4 t
					INNER JOIN Attribute a ON t.CountryID = a.Country_Id AND a.[Key] = t.AttribKey
				WHERE t.AttribType = 'Date'
				AND ISDATE(t.DemogValue) = 1
				AND t.DemogValue is NOT NULL

				UPDATE #t4 SET ValidDemog = 1
				 --SELECT t.ID, H700, ed.ID
					FROM #t4 t
					INNER JOIN Attribute a ON t.CountryID = a.Country_Id AND a.[Key] = t.AttribKey
				WHERE t.AttribType = 'String'
				AND t.DemogValue is NOT NULL

				/**************************
				INSERT New Belongings
				***************************/

				INSERT INTO Respondent
				SELECT BelongingID
					, 'Belonging'
					, t.CountryID
					, @GPSUser
					, @GPSTimeStamp
					, @GPSTimeStamp
					FROM #t1 t
					LEFT JOIN Respondent r ON t.BelongingID = r.GUIDReference
				WHERE r.GUIDReference IS NULL
				AND t.CandidateID IS NOT NULL
				AND t.ForUpdate = 0



				INSERT INTO Belonging
				SELECT
					BelongingID
					, CandidateID
					, BelongingTypeID
					, BelongingCode
					, @GPSUser
					, @GPSTimeStamp
					, LocalTime
					, StateID
					, BelongingType
				FROM #t1 t
				WHERE ForUpdate = 0
				AND t.CandidateID IS NOT NULL


				IF EXISTS (SELECT * FROM tempdb.dbo.sysobjects o WHERE o.xtype in ('U') AND o.id = object_id(N'tempdb..#t3')) 
					BEGIN  
						DROP TABLE #t3
					END
				

				SELECT DISTINCT t.ID, t.GroupBusinessID, CONVERT(UNIQUEIDENTIFIER, NULL) AS GUIDReference, sa.ID AS BelongingSectionID, BelongingID
					INTO #t3
					FROM SortAttribute sa
						INNER JOIN #t1 t ON sa.BelongingType_ID = t.BelongingTypeID
						WHERE Demographic_ID IS NULL
						AND ForUpdate = 0
						AND t.CandidateID IS NOT NULL


				UPDATE #t3 SET GUIDReference = NewID()


				INSERT INTO OrderedBelonging(Id, BelongingSection_Id, Belonging_Id, [Order], GPSUser, GPSUpdateTimestamp, CreationTimeStamp)
					SELECT
						GUIDReference
						, t3.BelongingSectionID
						, t3.BelongingID
						, 0
						, @GPSUser
						, SyncDate
						, SyncDate
					FROM #t3 t3
						INNER JOIN #t1 t1 ON t3.ID = t1.ID AND t3.GroupBusinessID = t1.GroupBusinessID AND t1.CandidateID IS NOT NULL
	

				--Enums
				INSERT INTO AttributeValue 
					SELECT
						NewID()
						, a.GUIDReference
						, NULL
						, t.BelongingID
						, @GPSUser
						, SyncDate
						, SyncDate
						, NULL
						, NULL
						, NULL
						, t.CountryID
						, NULL
						, 'EnumAttributeValue'
						, ed.id
					FROM #t4 t
						INNER JOIN Attribute a ON a.[Key] = t.AttribKey AND a.Country_Id = t.CountryID
						INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_Id AND ed.Value = t.DemogValue
					WHERE t.ForUpdate = 0
					AND t.CandidateID IS NOT NULL
					AND ValidDemog = 1


				--Others String/Date etc
				INSERT INTO AttributeValue 
					SELECT
						NewID()
						, a.GUIDReference
						, NULL
						, t.BelongingID
						, @GPSUser
						, SyncDate
						, SyncDate
						, NULL
						, DemogValue
						, DemogValue
						, t.CountryID
						, NULL
						, AttribType + 'AttributeValue'
						, NULL
					FROM #t4 t
						INNER JOIN Attribute a ON a.[Key] = AttribKey AND a.Country_Id = t.CountryID
					WHERE t.ForUpdate = 0
					AND t.CandidateID IS NOT NULL
					AND t.AttribType <> 'Enum'
					AND t.ValidDemog = 1


				/*****************************************
				UPDATE existing Belongings - ForUpdate = 1
				******************************************/
				--SELECT * FROM #t1

				--Enums
				UPDATE AttributeValue SET Value = DemogValue, EnumDefinition_ID = ed.ID, GPSUpdatetimestamp = SyncDate
					FROM #t4 t
						INNER JOIN Attribute a ON a.[Key] = t.AttribKey AND a.Country_Id = t.CountryID
						INNER JOIN AttributeValue av ON a.GUIDReference= av.DemographicID AND av.RespondentID = t.BelongingID
						INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_Id AND t.DemogValue = ed.Value
					WHERE ForUpdate = 1
					AND t.CandidateID IS NOT NULL
					AND t.ValidDemog = 1
					AND t.BelongingID is NOT NULL


				--String/Date
				UPDATE AttributeValue SET Value = t.DemogValue, GPSUpdatetimestamp = SyncDate
					FROM #t4 t
						INNER JOIN Attribute a ON a.[Key] = t.AttribKey AND a.Country_Id = t.CountryID
						INNER JOIN AttributeValue av ON a.GUIDReference= av.DemographicID AND av.RespondentID = t.BelongingID
					WHERE ForUpdate = 1
					AND t.CandidateID IS NOT NULL
					AND t.AttribType <> 'Enum'
					AND t.BelongingID is NOT NULL
					AND t.ValidDemog = 1

				--SELECT * FROM #t2

				/***************************************************************
				Add any new values to existing Belongings
					As an example, a belonging may have been previously set up
					with only a couple of the demogs populated. But the new
					import may have other values to add to the Belonging.
				***************************************************************/

				--Enums
				INSERT INTO AttributeValue
				SELECT
					NewID()
					, a.GUIDReference
					, NULL
					, t.BelongingID
					, @GPSUser
					, SyncDate
					, SyncDate
					, NULL
					, t.DemogValue
					, t.DemogValue
					, t.CountryID
					, NULL
					, 'EnumAttributeValue'
					, ed.Id
				FROM #t4 t
					INNER JOIN Attribute a ON a.[Key] = t.[AttribKey] AND a.Country_Id = t.CountryID
					INNER JOIN EnumDefinition ed ON a.GUIDReference = ed.Demographic_Id AND ed.Value = t.DemogValue
					LEFT JOIN AttributeValue av ON a.GUIDReference= av.DemographicID AND av.RespondentID = t.BelongingID
					WHERE ForUpdate = 1
						AND av.GUIDReference IS NULL
						AND t.CandidateID IS NOT NULL
						AND t.ValidDemog = 1
						AND t.AttribType = 'Enum'
						AND t.BelongingID is NOT NULL

				--Others
				INSERT INTO AttributeValue
				SELECT
					NewID()
					, a.GUIDReference
					, NULL
					, t.BelongingID
					, @GPSUser
					, SyncDate
					, SyncDate
					, NULL
					, t.DemogValue
					, t.DemogValue
					, t.CountryID
					, NULL
					, AttribType + 'AttributeValue'
					, NULL
				FROM #t4 t
					INNER JOIN Attribute a ON a.[Key] = t.[AttribKey] AND a.Country_Id = t.CountryID
					LEFT JOIN AttributeValue av ON a.GUIDReference= av.DemographicID AND av.RespondentID = t.BelongingID
					WHERE ForUpdate = 1
						AND av.GUIDReference IS NULL
						AND t.CandidateID IS NOT NULL
						AND t.AttribType <> 'Enum'
						AND t.BelongingID is NOT NULL
						AND t.ValidDemog = 1

			--END
		COMMIT TRAN
	END TRY

	BEGIN CATCH
		ROLLBACK TRAN
	END CATCH
	
	--Note: I couldnt put this inside the transaction as it cause the job to continuously fail
	UPDATE [172.28.232.32]. [IT_WORKFLOW].[dbo].[WF_STGA_IMPORT_QPET] SET ImportDate = @GPSTimeStamp WHERE ImportDate IS NULL

		--UPDATE [172.28.232.32]. [IT_WORKFLOW].[dbo].[WF_STGA_IMPORT_QPET] SET ImportDate = NULL
		/****************************************
		Informational Error Checks and logging:

		CandidateID is NULL - Group ID cannot be found
		BelongingCode is NOT NULL and ForUpdate = 0 - Cannot insert BelongingCode for new belongings. Its a system generated value
		BelongingCode is NULL and ForUpdate = 1 - For Updates to existing Belongings the BelongingCode is required
		Enum Value does not exist - Needs work for either the Inserts or Updates.

		*****************************************/

		DECLARE @ErrorCount SMALLINT
		SET @ErrorCount = 0
	

	--	SELECT * FROM LATAMBelongingsImportErrors

		--Check for NULL CandidateID's
		INSERT INTO LATAMBelongingsImportErrors(ImportFileID, CountryISO2A, GroupBusinessID, BelongingCode, ForUpdate, SyncDate, ImportDate, ErrorText)
			SELECT ID, CountryISO2A, GroupBusinessID, BelongingCode, ForUpdate, SyncDate, ImportDate, 'CandidateID could not be found for this GroupBusinessID' FROM #t1 WHERE CandidateID IS NULL

		SET @ErrorCount = @@RowCount

		--Check for NULL BelongingID's
		INSERT INTO LATAMBelongingsImportErrors(ImportFileID, CountryISO2A, GroupBusinessID, BelongingCode, ForUpdate, SyncDate, ImportDate, ErrorText)
			SELECT ID, CountryISO2A, GroupBusinessID, BelongingCode, ForUpdate, SyncDate, ImportDate, 'BelongingID could not be found for this GroupBusinessID and BelongingCode' FROM #t1 WHERE BelongingID IS NULL

		SET @ErrorCount = @ErrorCount + @@RowCount

		--Check for invalid enums
		INSERT INTO LATAMBelongingsImportErrors(ImportFileID, CountryISO2A, GroupBusinessID, BelongingCode, ForUpdate, SyncDate, ImportDate, ErrorText, DemogKey, DemogValue)
			SELECT ID, CountryISO2A, GroupBusinessID, BelongingCode, ForUpdate, SyncDate, ImportDate, 'Invalid enum value for ' + AttribKey + '. Value does not exist in GPM', AttribKey, DemogValue
				 FROM #t4 WHERE ValidDemog IS NULL AND AttribType = 'Enum' 

		SET @ErrorCount = @ErrorCount + @@RowCount

		--Check for invalid dates
		INSERT INTO LATAMBelongingsImportErrors(ImportFileID, CountryISO2A, GroupBusinessID, BelongingCode, ForUpdate, SyncDate, ImportDate, ErrorText, DemogKey, DemogValue)
			SELECT ID, CountryISO2A, GroupBusinessID, BelongingCode, ForUpdate, SyncDate, ImportDate, 'Invalid date value for ' + AttribKey, AttribKey, DemogValue
				 FROM #t4 WHERE ValidDemog IS NULL AND AttribType = 'Date'
				  
		SET @ErrorCount = @ErrorCount + @@RowCount

		IF @ErrorCount <> 0
			BEGIN
				INSERT INTO LATAMBelongingsImportErrors(ImportDate, ErrorText)
				SELECT @GPSTimeStamp, 'There were ' + CONVERT(NVARCHAR(10), @ErrorCount) + ' row(s) not imported due to data errors. The file import date was ' + CONVERT(NVARCHAR(20), @GPSTimeStamp)

				DECLARE @ErrorMessage NVARCHAR(4000);  
				DECLARE @ErrorSeverity INT;  
				DECLARE @ErrorState INT;  

				SELECT   
					@ErrorMessage = 'There were ' + CONVERT(NVARCHAR(10), @ErrorCount) + ' row(s) not imported due to data errors. The file import date was ' + CONVERT(NVARCHAR(20), @GPSTimeStamp), 
					@ErrorSeverity =  15,
					@ErrorState = 1  

				RAISERROR (@ErrorMessage, -- Message text.  
						   @ErrorSeverity, -- Severity.  
						   @ErrorState -- State.  
						   );  	
			END

END

