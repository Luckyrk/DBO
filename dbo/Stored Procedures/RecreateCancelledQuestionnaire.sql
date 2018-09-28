/*##########################################################################    

-- Name				: RecreateCancelledQuestionnaire.sql    

-- Date             : 2017-19-12

-- Author           : GPSDeveloper    

-- Company          : HCL Technologies   

-- Purpose          : Recreate the cancelled transaction

##########################################################################    



##########################################################################*/
CREATE PROCEDURE [dbo].[RecreateCancelledQuestionnaire] (
	@pQuestionnaireTransactionId INT
	,@pStateCode VARCHAR(100)
	,@pInvitationDate DATETIME
	)
AS
BEGIN
	BEGIN TRANSACTION T

	BEGIN TRY
		DECLARE @PENDINGTRANSACTIONID UNIQUEIDENTIFIER

		SELECT @PENDINGTRANSACTIONID = SD.Id
		FROM STATEDEFINITION SD
		JOIN STATEMODEL SM ON SD.STATEMODEL_ID = SM.GUIDReference
		WHERE SD.CODE = @pStateCode
			AND SM.TYPE = 'Domain.PanelManagement.Questionnaire.Questionnaire'

		INSERT INTO QUESTIONNAIRETRANSACTION (
			PanelistID
			,CountryID
			,QuestionnaireID
			,InvitationDate
			,StateID
			,GPSUser
			,GPSUPdateTimestamp
			,CompletionDate
			,NumberofDays
			,GroupContactId
			,[UID]
			,InterviewerId
			,PanelistName
			,panelist_code
			,QuestionnaireDate
			)
		SELECT PanelistID
			,CountryID
			,QuestionnaireID
			,@pInvitationDate
			,@PENDINGTRANSACTIONID
			,GPSUser
			,GETDATE()
			,NULL
			,NULL
			,GroupContactId
			,[UID]
			,InterviewerId
			,PanelistName
			,panelist_code
			,GETDATE()
		FROM QUESTIONNAIRETRANSACTION
		WHERE QuestionnaireTransactionID = @pQuestionnaireTransactionId

		COMMIT TRANSACTION T
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION T

		DECLARE @ERR_MSG AS NVARCHAR(4000)
			,@ERR_STA AS SMALLINT

		SET @ERR_MSG = ERROR_MESSAGE();
		SET @ERR_STA = ERROR_STATE();

		THROW 50001
			,@ERR_MSG
			,@ERR_STA;
	END CATCH
END

GO


