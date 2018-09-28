CREATE PROCEDURE [dbo].[GetInsertVisualCronJobs_AdminScreens] (
       @pProcessGUID UNIQUEIDENTIFIER
       ,@pProcessStatus NVARCHAR(max)
       ,@pStatusDescrip NVARCHAR(max)
       ,@pCountryISO2A NVARCHAR(max)
       ,@pProcessType NVARCHAR(max)
       ,@pProcessName NVARCHAR(max)
       ,@pDatabaseName NVARCHAR(max)
       ,@pSYSTEM_USER NVARCHAR(max)
       ,@pHOST_NAME NVARCHAR(max)
       ,@pStartDateTime DATETIME
       ,@pStopDateTime DATETIME
       ,@pExecTime_Mins_Complete FLOAT(53)
       ,@pParentId UNIQUEIDENTIFIER
       )
AS
BEGIN
BEGIN TRY 
       DECLARE @pInstance_Ids INT
       DECLARE @pEmptyGuid UNIQUEIDENTIFIER
       DECLARE @pprocessdate DATETIME;
	  

       SET @pEmptyGuid = '00000000-0000-0000-0000-000000000000'

	

       IF (
                     @pProcessGUID ! = @pEmptyGuid
                     AND @pParentId = @pEmptyGuid
                     )
       BEGIN
              IF NOT EXISTS (
                           SELECT *
                           FROM Process
                           WHERE ProcessGUID = @pProcessGUID
                                  AND ParentId = @pEmptyGuid
                           )
              BEGIN
                     IF NOT EXISTS (
                                  SELECT instance_id
                                  FROM Process
                                  )
                     BEGIN
                           SET @pInstance_Ids = 1
                     END
                     ELSE
                     BEGIN
                           SET @pInstance_Ids = (
                                         SELECT max(instance_Id)
                                         FROM Process
                                         ) + 1
                     END

                     INSERT INTO [dbo].[Process] (
                           [Instance_Id]
                           ,[ProcessGUID]
                           ,[ProcessStatus]
                           ,[StatusDescrip]
                           ,[CountryISO2A]
                           ,[ProcessType]
                           ,[ProcessName]
                           ,[DatabaseName]
                           ,[SYSTEM_USER]
                           ,[HOST_NAME]
                           ,[StartDateTime]
                           ,[StopDateTime]
                           ,[ExecTime_Mins_Complete]
                           ,[ParentId]
                           )
                     VALUES (
                           @pInstance_Ids
                           ,@pProcessGUID
                           ,@pProcessStatus
                           ,@pStatusDescrip
                           ,@pCountryISO2A
                           ,@pProcessType
                           ,@pProcessName
                           ,@pDatabaseName
                           ,@pSYSTEM_USER
                           ,@pHOST_NAME
                           ,@pStartDateTime
                           ,@pStopDateTime
                           ,@pExecTime_Mins_Complete
                           ,@pParentId
                           )
              END
              ELSE
              BEGIN
                     UPDATE [Process]
                     SET [ProcessStatus] = @pProcessStatus
                           ,[ExecTime_Mins_Complete] = @pExecTime_Mins_Complete
                          ,[StartDateTime] = @pStartDateTime
                           ,[StopDateTime] = @pStopDateTime
                     WHERE ProcessGUID = @pProcessGUID
                           AND ParentId = @pEmptyGuid
              END
       END
       ELSE
       BEGIN
              IF (@pParentId != @pEmptyGuid)
              BEGIN
                     --IF EXISTS (select *  from  Process where ProcessGUID = @pProcessGUID and ParentId != @pEmptyGuid )
                     IF NOT EXISTS (
                                  SELECT *
                                  FROM Process
                                  WHERE ParentId = @pParentId
                                  )
                     BEGIN
                           SET @pInstance_Ids = (
                                         SELECT max(instance_Id)
                                         FROM Process
                                         ) + 1

                           INSERT INTO [dbo].[Process] (
                                  [Instance_Id]
                                  ,[ProcessGUID]
                                  ,[ProcessStatus]
                                  ,[StatusDescrip]
                                  ,[CountryISO2A]
                                  ,[ProcessType]
                                  ,[ProcessName]
                                  ,[DatabaseName]
                                  ,[SYSTEM_USER]
                                  ,[HOST_NAME]
                                  ,[StartDateTime]
                                  ,[StopDateTime]
                                  ,[ExecTime_Mins_Complete]
                                  ,[ParentId]
                                  )
                           VALUES (
                                  @pInstance_Ids
                                  ,@pProcessGUID
                                  ,@pProcessStatus
                                  ,@pStatusDescrip
                                  ,@pCountryISO2A
                                  ,@pProcessType
                                  ,@pProcessName
                                  ,@pDatabaseName
                                  ,@pSYSTEM_USER
                                  ,@pHOST_NAME
                                  ,@pStartDateTime
                                  ,@pStopDateTime
                                  ,@pExecTime_Mins_Complete
                                  ,@pParentId
                                  )
                     END
              END
       END
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
END