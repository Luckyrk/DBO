/*##########################################################################    

-- Name				: GetQuestionnaireTransactionData.sql    

-- Date             : 2017-19-12

-- Author           : GPSDeveloper    

-- Company          : HCL Technologies   

-- Purpose          : To get the Questionnaire Transaction Data

##########################################################################    



##########################################################################*/
CREATE PROCEDURE [dbo].[GetQuestionnaireTransactionData] (@pQuestionnaireTransactionId INT)
AS
BEGIN
	BEGIN TRANSACTION T

	BEGIN TRY
		SELECT I.IndividualId AS [BusinessId]
			,QuestionnaireTransactionId
			,QT.InvitationDate
			,CONVERT(DATE, GETDATE(), 106) AS CurrentDate
			,SD.CODE AS [StateCode]
		FROM QUESTIONNAIRETRANSACTION QT
		JOIN INDIVIDUAL I ON I.GUIDReference = QT.GroupContactId
		JOIN STATEDEFINITION SD ON QT.STATEID = SD.ID
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
