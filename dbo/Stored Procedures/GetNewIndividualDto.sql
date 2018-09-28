/*##########################################################################
-- Name				: GetNewIndividualDto
-- Date             : 2014-11-26
-- Author           : Ramana
-- Purpose          : 
					  param definitions
-- Usage            : 
-- Impact           : 
-- Required grants  : 
-- Called by        : Called from UI
-- PARAM Definitions
			-- @pIndividualId UNIQUEIDENTIFIER -- GUID of individual
			-- @pBusinessId BusinessId  of individual
			-- @pCountryId UNIQUEIDENTIFIER  -- GUID of Country
-- Usage
-- EXEC GetNewIndividualDto  '911567BB-67A7-4428-8969-00002C099054','4470082-02','3558A18E-CCEB-CADC-CB8C-08CF81794A86'

 ##########################################################################
-- ver  user        date			change 
-- 1.0  Ramana     2014-11-26		initial
##########################################################################*/


CREATE PROCEDURE GetNewIndividualDto @pIndividualId UNIQUEIDENTIFIER
	,@pBusinessId VARCHAR(60)
	,@pCountryId UNIQUEIDENTIFIER
AS
BEGIN
	SELECT I.GUIDReference AS IndividualId
		,IndividualId AS BusinessId
	FROM Individual I
	INNER JOIN Candidate C ON C.GUIDReference = I.GUIDReference
	WHERE (
			I.GUIDReference = @pIndividualId
			OR IndividualId = @pBusinessId
			)
		AND C.Country_Id = @pCountryId
END