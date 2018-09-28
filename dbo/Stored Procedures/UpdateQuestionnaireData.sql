/*##########################################################################    
-- Name				: UpdateQuestionnaireData.sql    
-- Date             : 2017-19-12
-- Author           : GPSDeveloper    
-- Company          : HCL Technologies   
-- Purpose          : To Update the Questionnaire Data

##########################################################################    
##########################################################################*/
CREATE PROCEDURE [dbo].[UpdateQuestionnaireData] (
	@pQuestionnaireTransactionId INT
	,@pStateCode VARCHAR(100)
	,@pInvitationDate DATETIME
	,@pNewInvitationDate DATETIME
	)
AS
BEGIN
	BEGIN TRANSACTION T

	BEGIN TRY
		DECLARE @STATEID UNIQUEIDENTIFIER
		DECLARE @PENDINGTRANSACTIONID UNIQUEIDENTIFIER

		SELECT @STATEID = SD.Id
		FROM STATEDEFINITION SD
		JOIN STATEMODEL SM ON SD.STATEMODEL_ID = SM.GUIDReference
		WHERE SD.CODE = @pStateCode
			AND SM.TYPE = 'Domain.PanelManagement.Questionnaire.Questionnaire'

		UPDATE QUESTIONNAIRETRANSACTION
		SET StateID = @STATEID
			,InvitationDate = @pInvitationDate
		WHERE QuestionnaireTransactionID = @pQuestionnaireTransactionId

		IF (ISNULL(@pNewInvitationDate, '') <> '1900-01-01 00:00:00.000')
		BEGIN
			SELECT @PENDINGTRANSACTIONID = SD.Id
			FROM STATEDEFINITION SD
			JOIN STATEMODEL SM ON SD.STATEMODEL_ID = SM.GUIDReference
			WHERE SD.CODE = 'Pending'
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
				,@pNewInvitationDate
				,@PENDINGTRANSACTIONID
				,GPSUser
				,GETDATE()
				,NULL
				,NULL
				,GroupContactId
				,NULL
				,InterviewerId
				,PanelistName
				,panelist_code
				,GETDATE()
			FROM QUESTIONNAIRETRANSACTION
			WHERE QuestionnaireTransactionID = @pQuestionnaireTransactionId
		END

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
