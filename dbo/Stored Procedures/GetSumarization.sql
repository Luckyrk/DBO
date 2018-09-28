/*************************************/
/*##########################################################################

-- Name				: GetSumarization

-- Date             : 11/25/2014

-- Author           : Teena Areti

-- Purpose          : This SP fetches the Individual summarizationdetails.

					  param definitions

-- Usage            : 

-- Impact           : 

-- Required grants  : 

-- Called by        : Called from UI

-- PARAM Definitions

			-- @pBusinessGUID UNIQUEIDENTIFIER -- GUID of individual

			-- @pCountryId UNIQUEIDENTIFIER  -- GUID of Country

			--@pCultureCode int culture code

-- Usage

	EXEC [GetSumarization] '911567BB-67A7-4428-8969-00002C099054','3558A18E-CCEB-CADC-CB8C-08CF81794A86',2057



 ##########################################################################

-- ver  user        date			change 

-- 1.0  Teena Areti     11/25/2014		initial

-- 1.1  Teena Areti     12/01/2014		Tuned the SP

##########################################################################*/
CREATE PROCEDURE [dbo].[GetSumarization] @pBusinessGUID UNIQUEIDENTIFIER
	,@pCountryId UNIQUEIDENTIFIER
	,@pCultureCode INT
AS
BEGIN
BEGIN TRY
	SELECT TOP 1 I.GUIDReference AS Id
		,I.IndividualId AS BusinessId
		,PIdentity.PersonalIdentificationId AS [PersonalIdentificationId]
		,PIdentity.DateOfBirth AS [DateOfBirth]
		,PIdentity.LastOrderedName AS [LastName]
		,PIdentity.MiddleOrderedName AS MiddleName
		,PIdentity.FirstOrderedName AS [FirstName]
		,dbo.[GetTranslationValue](sd.Label_Id, @pCultureCode) AS StateName
		,sdh.CreationDate AS ChangeOfStateFrom
		,IT.Code AS Code
		,(
			CASE 
				WHEN NOT EXISTS (
						SELECT 1
						FROM Translation
						WHERE TranslationId = IT.Translation_Id
							AND KeyName = 'NullTitle'
						)
					THEN dbo.[GetTranslationValue](IT.Translation_Id, @pCultureCode)
				ELSE NULL
				END
			) AS NAME
		,INS.Code AS SexCode
		,dbo.[GetTranslationValue](INS.Translation_Id, @pCultureCode) AS SexName
	FROM Individual I
	INNER JOIN PersonalIdentification PIdentity ON PIdentity.PersonalIdentificationId = i.PersonalIdentificationId
		AND i.GUIDReference = @pBusinessGUID
	LEFT JOIN IndividualTitle IT ON IT.GUIDReference = PIdentity.TitleId
	LEFT JOIN IndividualSex INS ON INS.GUIDReference = IT.Sex_Id
	INNER JOIN Candidate cand ON cand.GUIDReference = i.GUIDReference
	LEFT JOIN StateDefinitionHistory SDH ON sdh.Candidate_Id = cand.GUIDReference
	INNER JOIN StateDefinition SD ON sd.Id = cand.CandidateStatus
	WHERE i.GUIDReference = @pBusinessGUID
		AND cand.Country_Id = @pCountryId
	ORDER BY sdh.CreationDate DESC

	SELECT DISTINCT IT.Code AS Code
		,dbo.[GetTranslationValue](IT.Translation_Id, @pCultureCode) AS NAME
		,INS.Code AS SexCode
		,dbo.[GetTranslationValue](INS.Translation_Id, @pCultureCode) AS SexName
	FROM IndividualTitle IT
	LEFT JOIN IndividualSex INS ON INS.GUIDReference = IT.Sex_Id
	WHERE It.Country_Id = @pCountryId
		AND IT.Code <> 0
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